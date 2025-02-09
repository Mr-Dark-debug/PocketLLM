import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              radius: 20,
              child: Icon(
                Icons.smart_toy_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 5),
                  bottomRight: Radius.circular(isUser ? 5 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) ...[
                    Text(
                      'PocketLLM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  MarkdownBody(
                    data: message.content,
                    selectable: true,
                    builders: {
                      'code': CodeElementBuilder(
                        textStyle: TextStyle(
                          backgroundColor: isUser 
                              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                              : theme.colorScheme.primaryContainer,
                          color: isUser ? Colors.white : theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                    },
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                        fontSize: 15,
                      ),
                      code: TextStyle(
                        backgroundColor: isUser 
                            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                            : theme.colorScheme.primaryContainer,
                        color: isUser ? Colors.white : theme.colorScheme.onSurface,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: isUser 
                            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                            : theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      blockquote: TextStyle(
                        color: isUser ? Colors.white70 : Colors.grey[600],
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                      h1: TextStyle(
                        color: isUser ? Colors.white : theme.textTheme.headlineMedium?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: TextStyle(
                        color: isUser ? Colors.white : theme.textTheme.headlineSmall?.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      h3: TextStyle(
                        color: isUser ? Colors.white : theme.textTheme.titleLarge?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              radius: 20,
              child: Icon(
                Icons.person_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  final TextStyle? textStyle;

  CodeElementBuilder({this.textStyle});

  @override
  Widget? visitElementAfter(Element element, TextStyle? preferredStyle) {
    String text = element.textContent;
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: textStyle?.backgroundColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    text,
                    style: textStyle,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text));
              },
              tooltip: 'Copy code',
            ),
          ),
        ],
      ),
    );
  }
} 