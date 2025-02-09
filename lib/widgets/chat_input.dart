import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSend,
    required this.isLoading,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _textController = TextEditingController();
  bool _hasText = false;

  void _handleSubmit() {
    final message = _textController.text.trim();
    if (message.isNotEmpty && !widget.isLoading) {
      widget.onSend(message);
      _textController.clear();
      setState(() {
        _hasText = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 5),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              color: Colors.grey[600],
              onPressed: () {
                // TODO: Implement attachment functionality
              },
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                onChanged: (value) {
                  setState(() {
                    _hasText = value.trim().isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 15),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _hasText ? Colors.deepPurple : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                color: Colors.white,
                onPressed: _hasText && !widget.isLoading ? _handleSubmit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
} 