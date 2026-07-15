import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/discipline_goal.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import 'prayer_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _checkInId = 1001;
  static const _dawahId = 1002;
  static const _eveningId = 1003;
  static const _journalId = 1004;
  static const _sceneryId = 1005;
  static const _scrollId = 1006;
  static const _prayerBase = 2000;

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'buddy_care',
          'Buddy reminders',
          channelDescription: 'Salah, habits, goals, journal, breaks',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> scheduleDailyCare(UserProfile profile) async {
    await _plugin.cancel(_checkInId);
    await _plugin.cancel(_dawahId);
    await _plugin.cancel(_eveningId);
    await _plugin.cancel(_journalId);
    await _plugin.cancel(_sceneryId);
    await _plugin.cancel(_scrollId);

    if (profile.checkInsEnabled) {
      await _scheduleDaily(
        id: _checkInId,
        hour: profile.dayCheckInHour,
        minute: profile.dayCheckInMinute,
        title: 'Buddy',
        body: 'Quick check-in — how is your day going?',
      );
      await _scheduleDaily(
        id: _eveningId,
        hour: profile.eveningCheckInHour,
        minute: profile.eveningCheckInMinute,
        title: 'Buddy',
        body: 'Evening check-in. How are you winding down?',
      );
      await _scheduleDaily(
        id: _sceneryId,
        hour: profile.sceneryHour,
        minute: profile.sceneryMinute,
        title: 'Take a short break',
        body:
            'Step away from the screen. Look outside, sky, trees — rest your eyes for 2 minutes.',
      );
      await _scheduleDaily(
        id: _scrollId,
        hour: profile.scrollHour,
        minute: profile.scrollMinute,
        title: 'Scroll pause',
        body:
            'Gentle reminder: put the endless feed down for a bit. Choose something intentional.',
      );
      await _scheduleDaily(
        id: _journalId,
        hour: profile.journalHour,
        minute: profile.journalMinute,
        title: 'Journal once today',
        body: 'Write a few lines about your day — anything counts.',
      );
    }

    if (profile.dawahEnabled) {
      await _scheduleDaily(
        id: _dawahId,
        hour: profile.dawahHour,
        minute: profile.dawahMinute,
        title: 'A quiet reminder',
        body: 'Take one breath and remember Allah.',
      );
    }
  }

  Future<void> scheduleHabit(Habit habit) async {
    final id = habit.id.hashCode & 0x7fffffff;
    await _plugin.cancel(id);
    if (!habit.enabled) return;

    await _scheduleDaily(
      id: id,
      hour: habit.reminderHour,
      minute: habit.reminderMinute,
      title: '${habit.emoji} ${habit.title}',
      body: _habitBody(habit.title),
    );
  }

  String _habitBody(String title) {
    final t = title.toLowerCase();
    if (t.contains('journal')) {
      return 'One short journal entry keeps your mind clearer.';
    }
    if (t.contains('scenery') || t.contains('break') || t.contains('outside')) {
      return 'Pause. Look at the sky or a window view for a moment.';
    }
    if (t.contains('scroll')) {
      return 'Protect your focus — skip useless scrolling for now.';
    }
    if (t.contains('water')) {
      return 'Have a glass of water when you can.';
    }
    if (t.contains('fajr') || t.contains('pray') || t.contains('remembrance')) {
      return 'A soft salah / dhikr reminder.';
    }
    return 'Soft nudge from Buddy — when you’re ready.';
  }

  Future<void> cancelHabit(Habit habit) async {
    await _plugin.cancel(habit.id.hashCode & 0x7fffffff);
  }

  Future<void> scheduleDiscipline(DisciplineGoal goal) async {
    final id = (goal.id.hashCode ^ 0xABCD) & 0x7fffffff;
    await _plugin.cancel(id);
    if (!goal.enabled) return;

    await _scheduleDaily(
      id: id,
      hour: goal.reminderHour,
      minute: goal.reminderMinute,
      title: 'Goal: ${goal.title}',
      body: goal.why.isEmpty
          ? 'Friendly reminder for your discipline goal today.'
          : goal.why,
    );
  }

  Future<void> cancelDiscipline(DisciplineGoal goal) async {
    await _plugin.cancel((goal.id.hashCode ^ 0xABCD) & 0x7fffffff);
  }

  /// Schedules salah reminders for remaining prayers today + all prayers tomorrow.
  Future<void> schedulePrayers({
    required UserProfile profile,
    required PrayerService prayerService,
    required bool enabled,
    required int minutesBefore,
  }) async {
    for (var i = 0; i < 24; i++) {
      await _plugin.cancel(_prayerBase + i);
    }
    if (!enabled) return;

    final now = DateTime.now();
    final today = prayerService.forProfile(profile, now: now);
    final tomorrow = prayerService.forProfile(
      profile,
      now: DateTime(now.year, now.month, now.day + 1, 12),
    );

    var i = 0;
    for (final day in [today, tomorrow]) {
      for (final slot in day.slots) {
        if (slot.name == 'Sunrise') continue;
        if (i >= 23) break;

        final remindAt = slot.time.subtract(Duration(minutes: minutesBefore));
        if (remindAt.isAfter(now)) {
          await _plugin.zonedSchedule(
            _prayerBase + i,
            '${slot.name} soon',
            '$minutesBefore min to ${slot.name}. Time to prepare for salah.',
            tz.TZDateTime.from(remindAt, tz.local),
            _details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
          i++;
        }

        if (slot.time.isAfter(now) && i < 24) {
          await _plugin.zonedSchedule(
            _prayerBase + i,
            'Time for ${slot.name}',
            'Salah time — pray when you can.',
            tz.TZDateTime.from(slot.time, tz.local),
            _details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
          i++;
        }
      }
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (when.isBefore(now)) {
      when = when.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
