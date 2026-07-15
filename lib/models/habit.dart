class Habit {
  Habit({
    required this.id,
    required this.title,
    required this.emoji,
    required this.reminderHour,
    required this.reminderMinute,
    required this.enabled,
    required this.completedDates,
  });

  final String id;
  final String title;
  final String emoji;
  final int reminderHour;
  final int reminderMinute;
  final bool enabled;
  final List<String> completedDates; // yyyy-MM-dd

  bool isDoneToday() {
    final today = DateTime.now();
    final key =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completedDates.contains(key);
  }

  Habit copyWith({
    String? title,
    String? emoji,
    int? reminderHour,
    int? reminderMinute,
    bool? enabled,
    List<String>? completedDates,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      enabled: enabled ?? this.enabled,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'enabled': enabled,
        'completedDates': completedDates,
      };

  factory Habit.fromMap(Map<dynamic, dynamic> map) => Habit(
        id: map['id'] as String,
        title: map['title'] as String,
        emoji: map['emoji'] as String? ?? '🌱',
        reminderHour: map['reminderHour'] as int? ?? 9,
        reminderMinute: map['reminderMinute'] as int? ?? 0,
        enabled: map['enabled'] as bool? ?? true,
        completedDates: (map['completedDates'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}
