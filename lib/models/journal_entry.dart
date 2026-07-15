class JournalEntry {
  JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.mood,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String mood;
  final List<String> tags;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'mood': mood,
        'tags': tags,
      };

  factory JournalEntry.fromMap(Map<dynamic, dynamic> map) => JournalEntry(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        mood: map['mood'] as String? ?? 'heavy',
        tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}
