import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../models/discipline_goal.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/user_profile.dart';
import '../services/buddy_engine.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';

class BuddyState extends ChangeNotifier {
  BuddyState({
    required StorageService storage,
    required BuddyEngine engine,
    required NotificationService notifications,
    PrayerService? prayers,
  })  : _storage = storage,
        _engine = engine,
        _notifications = notifications,
        _prayers = prayers ?? PrayerService();

  final StorageService _storage;
  final BuddyEngine _engine;
  final NotificationService _notifications;
  final PrayerService _prayers;
  final _uuid = const Uuid();

  UserProfile profile = UserProfile(name: '', onboarded: false);
  List<ChatMessage> messages = [];
  List<Habit> habits = [];
  List<JournalEntry> journal = [];
  List<DisciplineGoal> goals = [];
  DayPrayers? todayPrayers;
  bool busy = false;
  bool ready = false;

  /// Bottom-nav index currently visible (0 = chat).
  int activeTab = 0;

  /// Unread Buddy messages while user is on another tab.
  int unreadChat = 0;

  /// When set, HomeShell jumps to this tab then clears it.
  int? tabJump;

  Future<void> load() async {
    profile = _storage.loadProfile();
    messages = _storage.loadMessages();
    habits = _storage.loadHabits();
    journal = _storage.loadJournal();
    goals = _storage.loadGoals();

    if (profile.onboarded) {
      if (habits.isEmpty) {
        await _seedDefaultHabits();
      } else {
        await _ensureCareHabits();
      }
      if (goals.isEmpty) {
        await _seedDefaultGoals();
      } else {
        await _ensureCareGoals();
      }
    }

    if (profile.onboarded && messages.isEmpty) {
      await _pushBuddy(_engine.welcome(profile), countUnread: false);
    }

    await _refreshCareSchedules();
    ready = true;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    String buddyName = 'Buddy',
    String aboutMe = '',
    String whatHelps = '',
    String struggles = '',
  }) async {
    profile = profile.copyWith(
      name: name.trim().isEmpty ? 'Brother' : name.trim(),
      buddyName: buddyName.trim().isEmpty ? 'Buddy' : buddyName.trim(),
      aboutMe: aboutMe.trim(),
      whatHelps: whatHelps.trim(),
      struggles: struggles.trim(),
      onboarded: true,
    );
    await _storage.saveProfile(profile);
    await _seedDefaultHabits();
    await _seedDefaultGoals();
    messages = [];
    await _pushBuddy(_engine.welcome(profile), countUnread: false);
    await _refreshCareSchedules();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile next) async {
    profile = next;
    await _storage.saveProfile(profile);
    await _refreshCareSchedules();
    notifyListeners();
  }

  Future<void> _refreshCareSchedules() async {
    todayPrayers = _prayers.forProfile(profile);
    await _notifications.scheduleDailyCare(profile);
    for (final h in habits) {
      await _notifications.scheduleHabit(h);
    }
    for (final g in goals) {
      await _notifications.scheduleDiscipline(g);
    }
    await _notifications.schedulePrayers(
      profile: profile,
      prayerService: _prayers,
      enabled: profile.prayerRemindersEnabled,
      minutesBefore: profile.minutesBeforePrayer,
    );
  }

  void refreshPrayers() {
    todayPrayers = _prayers.forProfile(profile);
    notifyListeners();
  }

  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || busy) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: trimmed,
      sender: MessageSender.user,
      createdAt: DateTime.now(),
    );
    messages = [...messages, userMsg];
    await _storage.saveMessages(messages);
    busy = true;
    notifyListeners();

    final context = messages
        .where((m) => m.sender != MessageSender.system)
        .map((m) => '${m.sender.name}: ${m.text}')
        .toList();

    final reply = await _engine.reply(
      userText: trimmed,
      profile: profile,
      recentContext: context,
    );

    busy = false;
    await _pushBuddy(reply);
  }

  Future<void> sendPhoto(File file) async {
    if (busy) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(p.join(dir.path, 'photos', '${_uuid.v4()}.jpg'));
    await dest.parent.create(recursive: true);
    await file.copy(dest.path);

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: 'Shared a photo with you.',
      sender: MessageSender.user,
      createdAt: DateTime.now(),
      imagePath: dest.path,
    );
    messages = [...messages, userMsg];
    await _storage.saveMessages(messages);
    busy = true;
    notifyListeners();

    final reply = await _engine.reply(
      userText:
          'I shared a picture of myself. Compliment me like a good friend.',
      profile: profile,
      recentContext:
          messages.map((m) => '${m.sender.name}: ${m.text}').toList(),
      imageHint: 'selfie',
    );

    busy = false;
    await _pushBuddy(reply);
  }

  Future<void> sendVoiceNote(File file) async {
    if (busy) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(p.join(dir.path, 'voice', '${_uuid.v4()}.m4a'));
    await dest.parent.create(recursive: true);
    await file.copy(dest.path);

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: 'Sent a voice note.',
      sender: MessageSender.user,
      createdAt: DateTime.now(),
      audioPath: dest.path,
    );
    messages = [...messages, userMsg];
    await _storage.saveMessages(messages);
    busy = true;
    notifyListeners();

    final reply = await _engine.reply(
      userText:
          'I sent a voice note because typing felt hard. Hold space for me — I may be carrying a lot.',
      profile: profile,
      recentContext:
          messages.map((m) => '${m.sender.name}: ${m.text}').toList(),
    );

    busy = false;
    await _pushBuddy(reply);
  }

  void setActiveTab(int index) {
    activeTab = index;
    if (index == 0) unreadChat = 0;
    notifyListeners();
  }

  void openChat() {
    activeTab = 0;
    unreadChat = 0;
    tabJump = 0;
    notifyListeners();
  }

  void consumeTabJump() {
    tabJump = null;
  }

  Future<void> askCheckIn() async =>
      _pushBuddy(_engine.checkIn(profile), openChat: true);

  Future<void> askDawah() async => _pushBuddy(
        '${_engine.dawahPing()}\n\n${_engine.islamicBite()}',
        openChat: true,
      );

  Future<void> askAppreciation() async => _pushBuddy(
        _engine.offlineReply(
          'Please share a kind word of encouragement',
          profile,
        ),
        openChat: true,
      );

  Future<void> askDisciplineNudge() async {
    final open = goals.where((g) => !g.isDoneToday()).toList();
    if (open.isEmpty) {
      await _pushBuddy(
        'Your focus board looks clear for today. Nice work — rest well, then lock in again tomorrow.',
        openChat: true,
      );
      return;
    }
    final g = open.first;
    await _pushBuddy(
      'Gentle goal reminder:\n\n'
      '“${g.title}”\n'
      '${g.why.isEmpty ? 'One honest step is enough.' : g.why}\n\n'
      'You’ve got this.',
      openChat: true,
    );
  }

  Future<void> _pushBuddy(
    String text, {
    String? imagePath,
    bool openChat = false,
    bool countUnread = true,
  }) async {
    final msg = ChatMessage(
      id: _uuid.v4(),
      text: text,
      sender: MessageSender.buddy,
      createdAt: DateTime.now(),
      imagePath: imagePath,
    );
    messages = [...messages, msg];
    await _storage.saveMessages(messages);

    if (openChat) {
      activeTab = 0;
      unreadChat = 0;
      tabJump = 0;
    } else if (countUnread && activeTab != 0) {
      unreadChat += 1;
    }
    notifyListeners();
  }

  Future<void> _seedDefaultHabits() async {
    habits = [
      Habit(
        id: _uuid.v4(),
        title: 'Fajr / morning remembrance',
        emoji: '🌅',
        reminderHour: 5,
        reminderMinute: 30,
        enabled: true,
        completedDates: [],
      ),
      Habit(
        id: _uuid.v4(),
        title: 'Drink water',
        emoji: '💧',
        reminderHour: 10,
        reminderMinute: 0,
        enabled: true,
        completedDates: [],
      ),
      Habit(
        id: _uuid.v4(),
        title: 'Break — look at scenery',
        emoji: '🌿',
        reminderHour: 16,
        reminderMinute: 0,
        enabled: true,
        completedDates: [],
      ),
      Habit(
        id: _uuid.v4(),
        title: 'Journal a few lines',
        emoji: '📝',
        reminderHour: 21,
        reminderMinute: 30,
        enabled: true,
        completedDates: [],
      ),
    ];
    await _storage.saveHabits(habits);
  }

  Future<void> _seedDefaultGoals() async {
    goals = [
      DisciplineGoal(
        id: _uuid.v4(),
        title: 'No useless scrolling',
        why: 'Protect your mind — choose intention over endless feeds.',
        category: 'digital',
        reminderHour: 20,
        reminderMinute: 15,
        enabled: true,
        completedDates: [],
        streak: 0,
        bestStreak: 0,
      ),
      DisciplineGoal(
        id: _uuid.v4(),
        title: 'Pray on time when I can',
        why: 'Keep salah as the anchor of the day.',
        category: 'deen',
        reminderHour: 12,
        reminderMinute: 0,
        enabled: true,
        completedDates: [],
        streak: 0,
        bestStreak: 0,
      ),
      DisciplineGoal(
        id: _uuid.v4(),
        title: 'Move my body 15 minutes',
        why: 'A short walk or stretch resets energy.',
        category: 'body',
        reminderHour: 17,
        reminderMinute: 0,
        enabled: true,
        completedDates: [],
        streak: 0,
        bestStreak: 0,
      ),
    ];
    await _storage.saveGoals(goals);
  }

  Future<void> _ensureCareHabits() async {
    final titles = habits.map((h) => h.title.toLowerCase()).toSet();
    var changed = false;

    Future<void> addIfMissing({
      required String title,
      required String emoji,
      required int hour,
      required int minute,
      required List<String> matchKeys,
    }) async {
      final exists = matchKeys.any((k) => titles.any((t) => t.contains(k)));
      if (exists) return;
      habits = [
        ...habits,
        Habit(
          id: _uuid.v4(),
          title: title,
          emoji: emoji,
          reminderHour: hour,
          reminderMinute: minute,
          enabled: true,
          completedDates: [],
        ),
      ];
      changed = true;
    }

    await addIfMissing(
      title: 'Break — look at scenery',
      emoji: '🌿',
      hour: 16,
      minute: 0,
      matchKeys: ['scenery', 'break'],
    );
    await addIfMissing(
      title: 'Journal a few lines',
      emoji: '📝',
      hour: 21,
      minute: 30,
      matchKeys: ['journal'],
    );

    if (changed) await _storage.saveHabits(habits);
  }

  Future<void> _ensureCareGoals() async {
    final titles = goals.map((g) => g.title.toLowerCase()).toSet();
    final hasScroll = titles.any((t) => t.contains('scroll'));
    if (hasScroll) return;

    goals = [
      ...goals,
      DisciplineGoal(
        id: _uuid.v4(),
        title: 'No useless scrolling',
        why: 'Protect your mind — choose intention over endless feeds.',
        category: 'digital',
        reminderHour: 20,
        reminderMinute: 15,
        enabled: true,
        completedDates: [],
        streak: 0,
        bestStreak: 0,
      ),
    ];
    await _storage.saveGoals(goals);
  }

  String _todayKey() {
    final today = DateTime.now();
    return '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
  }

  Future<void> toggleHabitDone(Habit habit) async {
    final key = _todayKey();
    final dates = [...habit.completedDates];
    if (dates.contains(key)) {
      dates.remove(key);
    } else {
      dates.add(key);
    }
    await updateHabit(habit.copyWith(completedDates: dates));
  }

  Future<void> updateHabit(Habit habit) async {
    habits = habits.map((h) => h.id == habit.id ? habit : h).toList();
    await _storage.saveHabits(habits);
    await _notifications.scheduleHabit(habit);
    notifyListeners();
  }

  Future<void> addHabit(String title, {String emoji = '🌱'}) async {
    final habit = Habit(
      id: _uuid.v4(),
      title: title,
      emoji: emoji,
      reminderHour: 12,
      reminderMinute: 0,
      enabled: true,
      completedDates: [],
    );
    habits = [...habits, habit];
    await _storage.saveHabits(habits);
    await _notifications.scheduleHabit(habit);
    notifyListeners();
  }

  Future<void> removeHabit(Habit habit) async {
    await _notifications.cancelHabit(habit);
    habits = habits.where((h) => h.id != habit.id).toList();
    await _storage.saveHabits(habits);
    notifyListeners();
  }

  Future<void> toggleGoalDone(DisciplineGoal goal) async {
    final key = _todayKey();
    final dates = [...goal.completedDates];
    var streak = goal.streak;
    var best = goal.bestStreak;
    if (dates.contains(key)) {
      dates.remove(key);
      streak = streak > 0 ? streak - 1 : 0;
    } else {
      dates.add(key);
      streak += 1;
      if (streak > best) best = streak;
    }
    await updateGoal(
      goal.copyWith(completedDates: dates, streak: streak, bestStreak: best),
    );
  }

  Future<void> updateGoal(DisciplineGoal goal) async {
    goals = goals.map((g) => g.id == goal.id ? goal : g).toList();
    await _storage.saveGoals(goals);
    await _notifications.scheduleDiscipline(goal);
    notifyListeners();
  }

  Future<void> addGoal({
    required String title,
    String why = '',
    String category = 'mind',
  }) async {
    final goal = DisciplineGoal(
      id: _uuid.v4(),
      title: title,
      why: why,
      category: category,
      reminderHour: 20,
      reminderMinute: 0,
      enabled: true,
      completedDates: [],
      streak: 0,
      bestStreak: 0,
    );
    goals = [...goals, goal];
    await _storage.saveGoals(goals);
    await _notifications.scheduleDiscipline(goal);
    notifyListeners();
  }

  Future<void> removeGoal(DisciplineGoal goal) async {
    await _notifications.cancelDiscipline(goal);
    goals = goals.where((g) => g.id != goal.id).toList();
    await _storage.saveGoals(goals);
    notifyListeners();
  }

  Future<void> addJournal({
    required String title,
    required String body,
    required String mood,
    List<String> tags = const [],
  }) async {
    final entry = JournalEntry(
      id: _uuid.v4(),
      title: title.trim().isEmpty ? 'Untitled weight' : title.trim(),
      body: body.trim(),
      createdAt: DateTime.now(),
      mood: mood,
      tags: tags,
    );
    journal = [entry, ...journal];
    await _storage.saveJournal(journal);
    notifyListeners();

    await _pushBuddy(
      'Thanks for journaling. Mood tagged: $mood.\n\n'
      'If you want to talk about it, open Buddy chat — I’m here.',
    );
  }

  Future<void> deleteJournal(String id) async {
    journal = journal.where((e) => e.id != id).toList();
    await _storage.saveJournal(journal);
    notifyListeners();
  }
}
