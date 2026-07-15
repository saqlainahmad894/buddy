import 'package:hive_flutter/hive_flutter.dart';

import '../models/chat_message.dart';
import '../models/discipline_goal.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/user_profile.dart';

class StorageService {
  static const _profileBox = 'profile';
  static const _chatBox = 'chat';
  static const _habitsBox = 'habits';
  static const _journalBox = 'journal';
  static const _goalsBox = 'discipline';

  late Box _profile;
  late Box _chat;
  late Box _habits;
  late Box _journal;
  late Box _goals;

  Future<void> init() async {
    await Hive.initFlutter();
    _profile = await Hive.openBox(_profileBox);
    _chat = await Hive.openBox(_chatBox);
    _habits = await Hive.openBox(_habitsBox);
    _journal = await Hive.openBox(_journalBox);
    _goals = await Hive.openBox(_goalsBox);
  }

  UserProfile loadProfile() {
    final raw = _profile.get('user');
    if (raw is Map) return UserProfile.fromMap(raw);
    return UserProfile(name: '', onboarded: false);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _profile.put('user', profile.toMap());
  }

  List<ChatMessage> loadMessages() {
    final list = _chat.get('messages', defaultValue: <dynamic>[]) as List;
    return list
        .whereType<Map>()
        .map((e) => ChatMessage.fromMap(e))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    await _chat.put('messages', messages.map((m) => m.toMap()).toList());
  }

  List<Habit> loadHabits() {
    final list = _habits.get('items', defaultValue: <dynamic>[]) as List;
    return list.whereType<Map>().map((e) => Habit.fromMap(e)).toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    await _habits.put('items', habits.map((h) => h.toMap()).toList());
  }

  List<JournalEntry> loadJournal() {
    final list = _journal.get('entries', defaultValue: <dynamic>[]) as List;
    return list
        .whereType<Map>()
        .map((e) => JournalEntry.fromMap(e))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveJournal(List<JournalEntry> entries) async {
    await _journal.put('entries', entries.map((e) => e.toMap()).toList());
  }

  List<DisciplineGoal> loadGoals() {
    final list = _goals.get('items', defaultValue: <dynamic>[]) as List;
    return list.whereType<Map>().map((e) => DisciplineGoal.fromMap(e)).toList();
  }

  Future<void> saveGoals(List<DisciplineGoal> goals) async {
    await _goals.put('items', goals.map((g) => g.toMap()).toList());
  }
}
