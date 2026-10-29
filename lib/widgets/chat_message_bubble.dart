import 'package:flutter/material.dart';
import '../models/chat_message.dart';

/// Chat Message Bubble Widget
/// Displays individual chat messages with proper styling
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String)? onImageTap;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // AI Assistant Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message Content
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                // Message Bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Colors.green[600]
                        : message.messageType == ChatMessageType.error
                            ? Colors.red[50]
                            : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message Type Icon (for special messages)
                      if (message.messageType != ChatMessageType.text)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.messageType.icon,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                message.messageType.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: message.isUser 
                                      ? Colors.white70 
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Message Text
                      SelectableText(
                        message.text,
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white
                              : message.messageType == ChatMessageType.error
                                  ? Colors.red[800]
                                  : Colors.black87,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      
                      // Image (if present)
                      if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: GestureDetector(
                            onTap: () => onImageTap?.call(message.imageUrl!),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                message.imageUrl!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, 
                                             color: Colors.grey),
                                        Text('Image not available'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Timestamp
                Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                    left: message.isUser ? 0 : 16,
                    right: message.isUser ? 16 : 0,
                  ),
                  child: Text(
                    message.formattedTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 8),
            // User Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.green[600],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}