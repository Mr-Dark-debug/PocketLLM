import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final Function(PlatformFile)? onFileSelected;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSend,
    this.onFileSelected,
    required this.isLoading,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool get _canSend => _controller.text.trim().isNotEmpty && !widget.isLoading;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_canSend) {
      final message = _controller.text.trim();
      _controller.clear();
      widget.onSend(message);
    }
  }

  Future<void> _handleAttachment() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.isNotEmpty && widget.onFileSelected != null) {
        widget.onFileSelected!(result.files.first);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: _handleAttachment,
              icon: Icon(
                Icons.attach_file_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Attach file',
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _handleSubmit(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _canSend 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: _canSend ? _handleSubmit : null,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 