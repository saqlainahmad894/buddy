enum MessageSender { user, buddy, system }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.createdAt,
    this.imagePath,
    this.audioPath,
    this.moodTag,
  });

  final String id;
  final String text;
  final MessageSender sender;
  final DateTime createdAt;
  final String? imagePath;
  final String? audioPath;
  final String? moodTag;

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'sender': sender.name,
        'createdAt': createdAt.toIso8601String(),
        'imagePath': imagePath,
        'audioPath': audioPath,
        'moodTag': moodTag,
      };

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        text: map['text'] as String,
        sender: MessageSender.values.firstWhere(
          (e) => e.name == map['sender'],
          orElse: () => MessageSender.buddy,
        ),
        createdAt: DateTime.parse(map['createdAt'] as String),
        imagePath: map['imagePath'] as String?,
        audioPath: map['audioPath'] as String?,
        moodTag: map['moodTag'] as String?,
      );
}
