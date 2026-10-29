/// Chat Message model for AI Chatbot
/// Represents individual messages in the chat conversation
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType messageType;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.messageType = ChatMessageType.text,
    this.imageUrl,
    this.metadata,
  });

  /// Create ChatMessage from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      messageType: _parseMessageType(json['messageType']),
      imageUrl: json['imageUrl'],
      metadata: json['metadata'],
    );
  }

  /// Convert ChatMessage to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType.toString(),
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  /// Parse message type from string
  static ChatMessageType _parseMessageType(String? type) {
    switch (type) {
      case 'ChatMessageType.text':
        return ChatMessageType.text;
      case 'ChatMessageType.image':
        return ChatMessageType.image;
      case 'ChatMessageType.voice':
        return ChatMessageType.voice;
      case 'ChatMessageType.error':
        return ChatMessageType.error;
      case 'ChatMessageType.system':
        return ChatMessageType.system;
      default:
        return ChatMessageType.text;
    }
  }

  /// Create a copy with updated fields
  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    ChatMessageType? messageType,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted time for display
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Check if message was sent today
  bool get isSentToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
           timestamp.month == now.month &&
           timestamp.day == now.day;
  }

  /// Get display date for message
  String get displayDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Enum for different types of chat messages
enum ChatMessageType {
  text,      // Regular text message
  image,     // Image message (with crop photos)
  voice,     // Voice message
  error,     // Error message
  system,    // System/bot message
}

/// Extension for ChatMessageType enum
extension ChatMessageTypeExtension on ChatMessageType {
  /// Get display name for message type
  String get displayName {
    switch (this) {
      case ChatMessageType.text:
        return 'Text';
      case ChatMessageType.image:
        return 'Image';
      case ChatMessageType.voice:
        return 'Voice';
      case ChatMessageType.error:
        return 'Error';
      case ChatMessageType.system:
        return 'System';
    }
  }

  /// Get icon for message type
  String get icon {
    switch (this) {
      case ChatMessageType.text:
        return '💬';
      case ChatMessageType.image:
        return '📷';
      case ChatMessageType.voice:
        return '🎙️';
      case ChatMessageType.error:
        return '❌';
      case ChatMessageType.system:
        return '🤖';
    }
  }
}