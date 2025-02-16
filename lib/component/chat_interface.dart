import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:clipboard/clipboard.dart';
import 'models.dart';
import 'tavily_service.dart';
import 'chat_history_manager.dart'; // Import the new chat history manager

class ChatInterface extends StatefulWidget {
  @override
  _ChatInterfaceState createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  late String _selectedModel;
  final String apiKey = 'ddc-m4qlvrgpt1W1E4ZXc4bvm5T5Z6CRFLeXRCx9AbRuQOcGpFFrX2';
  final String apiUrl = 'https://api.sree.shop/v1/chat/completions';
  final TavilyService _tavilyService = TavilyService();
  bool _isOnline = false;
  final ChatHistoryManager _chatHistoryManager = ChatHistoryManager();

  // Suggested messages (dynamic)
  List<String> _suggestedMessages = [];

  @override
  void initState() {
    super.initState();
    _selectedModel = ModelsRepository.models.first.id;
    _loadChatHistory();
    _generateSuggestedQuestions(); // Generate dynamic questions on startup
  }

  Future<void> _generateSuggestedQuestions() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _selectedModel,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Generate 3 interesting and engaging questions with emojis for a chatbot conversation.',
            }
          ],
          'temperature': 0.8,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        setState(() {
          _suggestedMessages = aiResponse.split('\n').map((q) => q.trim()).toList();
        });
      } else {
        throw Exception('Failed to generate suggested questions');
      }
    } catch (e) {
      setState(() {
        _suggestedMessages = [
          "🤔 What's the meaning of life?",
          "🌍 How can we protect the environment?",
          "🤖 What are the latest AI trends?"
        ];
      });
    }
  }

  Future<void> _loadChatHistory() async {
    final savedMessages = await _chatHistoryManager.loadChatHistory();
    setState(() {
      _messages.addAll(savedMessages);
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final userMessage = _messageController.text;
    final newMessage = Message(
      content: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(newMessage);
      _isLoading = true;
    });
    _messageController.clear();
    _saveChatHistory();
    try {
      final aiResponse = await _getAIResponse(userMessage);
      String cleanedResponse = _cleanUpResponse(aiResponse);
      if (_isOnline) {
        final tavilyResults = await _performWebSearch(userMessage);
        setState(() {
          _messages.add(Message(
            content: '$cleanedResponse\n\n**Web Search Results:**\n$tavilyResults',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        setState(() {
          _messages.add(Message(
            content: cleanedResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(Message(
          content: 'Error: Something went wrong',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _saveChatHistory();
      _scrollToBottom();
    }
  }

  String _cleanUpResponse(String response) {
    return response.replaceAll(RegExp(r"In\s*\$\~{3}\$.*?\$\~{3}\$"), '').trim();
  }

  Future<void> _saveChatHistory() async {
    await _chatHistoryManager.saveChatHistory(_messages);
  }

  Future<String> _getAIResponse(String userMessage) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _selectedModel,
        'messages': [
          {'role': 'user', 'content': userMessage},
        ],
        'temperature': 0.7,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get AI response');
    }
  }

  Future<String> _performWebSearch(String query) async {
    try {
      final result = await _tavilyService.search(query);
      final answer = result['answer'] ?? 'No answer found.';
      final results = (result['results'] as List)
          .map((item) => '- ${item['title']} (${item['url']})')
          .join('\n');
      return '$answer\n\n$results';
    } catch (e) {
      return 'Error fetching web search results: $e';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildModelSelector() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Theme(
          data: ThemeData(canvasColor: Colors.white),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedModel,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8B5CF6)),
              isExpanded: true,
              items: ModelsRepository.models.map((model) {
                return DropdownMenuItem<String>(
                  value: model.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      model.id,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedModel = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebIcon() {
    return InkWell(
      onTap: () {
        setState(() {
          _isOnline = !_isOnline;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Icon(
              Icons.public,
              color: _isOnline ? Colors.green : Colors.grey,
              size: 30,
            ),
            Text(
              _isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: _isOnline ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedMessages() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Start a conversation with one of these:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedMessages.map((message) {
              return ElevatedButton(
                onPressed: () {
                  _messageController.text = message;
                  _sendMessage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildSuggestedMessages()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildWebIcon(),
                    const SizedBox(width: 8),
                    _buildModelSelector(),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Color(0xFF8B5CF6)),
                      onPressed: () {
                        // Handle attachment functionality
                      },
                    ),
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic, color: Color(0xFF8B5CF6), size: 32),
                      onPressed: () {
                        // Handle voice input functionality
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _isLoading ? const Color(0xFF8B5CF6) : const Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        onPressed: _isLoading ? null : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Color(0xFF8B5CF6),
                radius: 16,
                child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!message.isUser)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'PocketLLM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser ? const Color(0xFF8B5CF6) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                      code: TextStyle(
                        backgroundColor: Colors.grey[200],
                        color: Colors.black87,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    if (!message.isUser) ...[
                      const SizedBox(width: 8),
                      _buildCopyButton(message.content),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (message.isUser)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Color(0xFF4CAF50),
                radius: 16,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(String content) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          FlutterClipboard.copy(content).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Copied to clipboard!'),
                  ],
                ),
                backgroundColor: const Color(0xFF8B5CF6),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF8B5CF6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.copy,
                size: 16,
                color: Color(0xFF8B5CF6),
              ),
              SizedBox(width: 4),
              Text(
                'Copy',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}