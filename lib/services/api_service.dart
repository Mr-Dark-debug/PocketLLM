import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/provider_settings.dart';

class ApiService {
  static const String defaultBaseUrl = 'https://api.sree.shop/v1/chat/completions';
  final String apiKey;
  final ProviderSettings? providerSettings;

  ApiService({
    required this.apiKey,
    this.providerSettings,
  });

  Future<String> getChatCompletion(String message) async {
    final Uri uri;
    final Map<String, dynamic> body;
    final Map<String, String> headers;

    if (providerSettings == null) {
      // Default provider (current implementation)
      uri = Uri.parse(defaultBaseUrl);
      headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
      body = {
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'user',
            'content': message,
          }
        ],
        'temperature': 0.7,
      };
    } else {
      switch (providerSettings!.provider) {
        case LLMProvider.local:
          uri = Uri.parse(defaultBaseUrl);
          headers = {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          };
          body = {
            'model': providerSettings!.modelName,
            'messages': [
              {
                'role': 'user',
                'content': message,
              }
            ],
            'temperature': 0.7,
          };
          break;

        case LLMProvider.ollama:
          final baseUrl = providerSettings!.baseUrl ?? 'http://localhost:11434/api';
          uri = Uri.parse('$baseUrl/chat');
          headers = {'Content-Type': 'application/json'};
          body = {
            'model': providerSettings!.modelName,
            'messages': [
              {
                'role': 'user',
                'content': message,
              }
            ],
            'stream': false,
          };
          break;

        case LLMProvider.llmStudio:
          final baseUrl = providerSettings!.baseUrl ?? 'http://localhost:1234/v1';
          uri = Uri.parse('$baseUrl/chat/completions');
          headers = {'Content-Type': 'application/json'};
          body = {
            'model': providerSettings!.modelName,
            'messages': [
              {
                'role': 'user',
                'content': message,
              }
            ],
            'temperature': 0.7,
          };
          break;
      }
    }

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (providerSettings?.provider == LLMProvider.ollama) {
          return data['message']['content'];
        } else {
          return data['choices'][0]['message']['content'];
        }
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 