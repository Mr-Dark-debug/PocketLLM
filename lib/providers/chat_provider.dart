import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/provider_settings.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  late ApiService _apiService;
  bool _isLoading = false;
  ProviderSettings? _settings;

  ChatProvider({
    required String apiKey,
    ProviderSettings? providerSettings,
  }) {
    _settings = providerSettings;
    _apiService = ApiService(
      apiKey: apiKey,
      providerSettings: providerSettings,
    );
  }

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  void updateSettings({
    required String apiKey,
    required ProviderSettings providerSettings,
  }) {
    _settings = providerSettings;
    _apiService = ApiService(
      apiKey: apiKey,
      providerSettings: providerSettings,
    );
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _messages.add(Message(
      content: message,
      isUser: true,
    ));
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      // Get AI response
      final response = await _apiService.getChatCompletion(message);
      
      _messages.add(Message(
        content: response,
        isUser: false,
      ));
    } catch (e) {
      _messages.add(Message(
        content: 'Error: Failed to get response. Please try again.',
        isUser: false,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
} 