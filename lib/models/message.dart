class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Message copyWith({
    String? content,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return Message(
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
} 