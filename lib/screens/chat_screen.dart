import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/settings_dialog.dart';
import '../models/provider_settings.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String initialApiKey;

  const ChatScreen({
    super.key,
    this.initialApiKey = "ddc-m4qlvrgpt1W1E4ZXc4bvm5T5Z6CRFLeXRCx9AbRuQOcGpFFrX2",
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatProvider _chatProvider;
  ProviderSettings? _providerSettings;

  @override
  void initState() {
    super.initState();
    _chatProvider = ChatProvider(
      apiKey: widget.initialApiKey,
      providerSettings: _providerSettings,
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        onSettingsChanged: (settings) {
          setState(() {
            _providerSettings = settings;
            _chatProvider.updateSettings(
              apiKey: widget.initialApiKey,
              providerSettings: settings,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider.value(
      value: _chatProvider,
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  color: Colors.deepPurple,
                  width: double.infinity,
                  child: const Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person_outline,
                            size: 40, color: Colors.white),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'PocketLLM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.grey),
                  title: const Text(
                    'Clear Chat',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    _chatProvider.clearChat();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.grey),
                  title: const Text(
                    'About',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    // TODO: Implement about functionality
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 2,
          title: const Text(
            'PocketLLM',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[50],
          child: Column(
            children: [
              Expanded(
                child: provider.Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    if (chatProvider.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start a conversation',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatProvider.messages[
                          chatProvider.messages.length - 1 - index
                        ];
                        return ChatBubble(message: message);
                      },
                    );
                  },
                ),
              ),
              provider.Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  return ChatInput(
                    onSend: chatProvider.sendMessage,
                    isLoading: chatProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatProvider.dispose();
    super.dispose();
  }
} 