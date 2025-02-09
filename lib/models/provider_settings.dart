import 'dart:convert';

enum LLMProvider {
  local,
  ollama,
  llmStudio
}

class Model {
  final String id;
  final String ownedBy;
  final double ownerCostPerMillionTokens;

  Model({
    required this.id,
    required this.ownedBy,
    required this.ownerCostPerMillionTokens,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'],
      ownedBy: json['owned_by'],
      ownerCostPerMillionTokens: json['owner_cost_per_million_tokens'].toDouble(),
    );
  }
}

class ProviderSettings {
  final LLMProvider provider;
  final String modelName;
  final String? baseUrl;

  const ProviderSettings({
    required this.provider,
    required this.modelName,
    this.baseUrl,
  });

  static List<Model> getLocalModels() {
    const jsonStr = '''
    {
      "data": [
        {
          "id": "claude-3-5-sonnet-20240620",
          "owned_by": "DevsDoCode",
          "owner_cost_per_million_tokens": 15
        },
        {
          "id": "claude-3-5-sonnet",
          "owned_by": "DevsDoCode",
          "owner_cost_per_million_tokens": 15
        },
        {
          "id": "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B",
          "owned_by": "DevsDoCode",
          "owner_cost_per_million_tokens": 2
        },
        {
          "id": "deepseek-r1",
          "owned_by": "DevsDoCode",
          "owner_cost_per_million_tokens": 2.19
        },
        {
          "id": "deepseek-v3",
          "owned_by": "DevsDoCode",
          "owner_cost_per_million_tokens": 1.28
        },
        {
          "id": "gpt-4o",
          "owned_by": "DevsDoCode",
          "owner_cost_per_million_tokens": 5
        },
        {
          "id": "gpt-4o-2024-05-13",
          "owned_by": "DevsDoCode",
          "owner_cost_per_million_tokens": 5
        },
        {
          "id": "Meta-Llama-3.3-70B-Instruct-Turbo",
          "owned_by": "DevsDoCode",
          "owner_cost_per_million_tokens": 0.3
        }
      ]
    }
    ''';

    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return (jsonMap['data'] as List)
        .map((model) => Model.fromJson(model))
        .toList();
  }
} 