class AIModel {
  final String id;
  final double costPerMillionTokens;

  AIModel({required this.id, required this.costPerMillionTokens});
}

class ModelsRepository {
  static final List<AIModel> models = [
    AIModel(id: 'claude-3-5-sonnet-20240620', costPerMillionTokens: 15),
    AIModel(id: 'claude-3-5-sonnet', costPerMillionTokens: 15),
    AIModel(id: 'deepseek-ai/DeepSeek-R1-Distill-Qwen-32B', costPerMillionTokens: 2),
    AIModel(id: 'deepseek-r1', costPerMillionTokens: 2.19),
    AIModel(id: 'deepseek-v3', costPerMillionTokens: 1.28),
    AIModel(id: 'gpt-4o', costPerMillionTokens: 5),
    AIModel(id: 'gpt-4o-2024-05-13', costPerMillionTokens: 5),
    AIModel(id: 'Meta-Llama-3.3-70B-Instruct-Turbo', costPerMillionTokens: 0.3),
  ];
}

class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  // Add fromJson and toJson methods for serialization
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}