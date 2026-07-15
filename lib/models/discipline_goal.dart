class DisciplineGoal {
  DisciplineGoal({
    required this.id,
    required this.title,
    required this.why,
    required this.category,
    required this.reminderHour,
    required this.reminderMinute,
    required this.enabled,
    required this.completedDates,
    required this.streak,
    required this.bestStreak,
  });

  final String id;
  final String title;
  final String why;
  final String category; // deen, body, mind, digital
  final int reminderHour;
  final int reminderMinute;
  final bool enabled;
  final List<String> completedDates;
  final int streak;
  final int bestStreak;

  bool isDoneToday() {
    final today = DateTime.now();
    final key =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completedDates.contains(key);
  }

  DisciplineGoal copyWith({
    String? title,
    String? why,
    String? category,
    int? reminderHour,
    int? reminderMinute,
    bool? enabled,
    List<String>? completedDates,
    int? streak,
    int? bestStreak,
  }) {
    return DisciplineGoal(
      id: id,
      title: title ?? this.title,
      why: why ?? this.why,
      category: category ?? this.category,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      enabled: enabled ?? this.enabled,
      completedDates: completedDates ?? this.completedDates,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'why': why,
        'category': category,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'enabled': enabled,
        'completedDates': completedDates,
        'streak': streak,
        'bestStreak': bestStreak,
      };

  factory DisciplineGoal.fromMap(Map<dynamic, dynamic> map) => DisciplineGoal(
        id: map['id'] as String,
        title: map['title'] as String,
        why: map['why'] as String? ?? '',
        category: map['category'] as String? ?? 'mind',
        reminderHour: map['reminderHour'] as int? ?? 20,
        reminderMinute: map['reminderMinute'] as int? ?? 0,
        enabled: map['enabled'] as bool? ?? true,
        completedDates: (map['completedDates'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        streak: map['streak'] as int? ?? 0,
        bestStreak: map['bestStreak'] as int? ?? 0,
      );
}
