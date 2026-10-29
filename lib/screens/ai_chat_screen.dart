import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_chatbot_service.dart';
import '../services/free_ai_chatbot_service.dart';
import '../services/auth_service.dart';

import '../widgets/chat_message_bubble.dart';

/// AI Chat Screen for AgriAI app  
/// Provides intelligent farming assistance through chat interface
class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AIChatbotService _chatbotService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeChatbot();
  }

  /// Initialize chatbot service
  Future<void> _initializeChatbot() async {
    _chatbotService = Provider.of<AIChatbotService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (!_chatbotService.isInitialized) {
      await _chatbotService.initialize(user: authService.currentUser);
    }
    
    setState(() {
      _isInitialized = true;
    });
  }

  /// Send text message
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _chatbotService.sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  /// Scroll to bottom of chat
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

  /// Handle voice input
  void _handleVoiceInput() async {
    if (_chatbotService.isListening) {
      await _chatbotService.stopListening();
    } else {
      await _chatbotService.startListening();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AgriAI Assistant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Consumer<AIChatbotService>(
                    builder: (context, chatbot, child) {
                      String status = 'Smart Farming Expert';
                      if (chatbot.isListening) {
                        status = 'सुन रहा हूं... 🎙️';
                      } else if (chatbot.isSpeaking) {
                        status = 'बोल रहा हूं... 🔊';
                      }
                      
                      return Text(
                        status,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<AIChatbotService>(
            builder: (context, chatbot, child) {
              return PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () => chatbot.clearChat(),
                    child: const Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear Chat'),
                      ],
                    ),
                  ),
                  if (chatbot.isSpeaking)
                    PopupMenuItem(
                      onTap: () => chatbot.stopSpeaking(),
                      child: const Row(
                        children: [
                          Icon(Icons.stop),
                          SizedBox(width: 8),
                          Text('Stop Speaking'),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text('AI Assistant loading...'),
                ],
              ),
            )
          : Column(
              children: [
                // Chat messages
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.green[50]!,
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Consumer<AIChatbotService>(
                      builder: (context, chatbot, child) {
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: chatbot.chatHistory.length,
                          itemBuilder: (context, index) {
                            final message = chatbot.chatHistory[index];
                            return ChatMessageBubble(
                              message: message,
                              onImageTap: (imageUrl) {
                                // Handle image tap if needed
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                
                // Message input area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Voice input button
                        Consumer<AIChatbotService>(
                          builder: (context, chatbot, child) {
                            return GestureDetector(
                              onTap: _handleVoiceInput,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: chatbot.isListening 
                                      ? Colors.red[400] 
                                      : Colors.green[400],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    if (chatbot.isListening)
                                      BoxShadow(
                                        color: Colors.red.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                  ],
                                ),
                                child: Icon(
                                  chatbot.isListening ? Icons.mic : Icons.mic_none,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        
                        // Text input field
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Ask about farming... (खेती के बारे में पूछें)',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.green[400]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Send button
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}