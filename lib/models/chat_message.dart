class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? content,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
} 