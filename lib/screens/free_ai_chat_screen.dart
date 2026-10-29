import 'package:flutter/material.dart';
import '../services/free_ai_chatbot_service.dart';
import '../widgets/chat_message_bubble.dart';

/// Free AI Chat Screen for AgriAI app  
/// Provides FREE intelligent farming assistance through chat interface
class FreeAIChatScreen extends StatefulWidget {
  const FreeAIChatScreen({super.key});

  @override
  State<FreeAIChatScreen> createState() => _FreeAIChatScreenState();
}

class _FreeAIChatScreenState extends State<FreeAIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late FreeAIChatbotService _chatbotService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeChatbot();
  }

  /// Initialize free chatbot service
  Future<void> _initializeChatbot() async {
    _chatbotService = FreeAIChatbotService();
    await _chatbotService.initialize();
    
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
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FREE AgriAI Assistant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '100% Free • Smart Responses',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
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
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _chatbotService.clearChat(),
                child: const Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('100% Free AI'),
                  ],
                ),
              ),
            ],
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
                  Text('Free AI Assistant loading...'),
                ],
              ),
            )
          : Column(
              children: [
                // Free AI Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.blue[400]!],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        '100% FREE AI • No API Key Required',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
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
                    child: AnimatedBuilder(
                      animation: _chatbotService,
                      builder: (context, child) {
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _chatbotService.chatHistory.length,
                          itemBuilder: (context, index) {
                            final message = _chatbotService.chatHistory[index];
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
                        // Suggestion button
                        GestureDetector(
                          onTap: () => _showQuickSuggestions(),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.blue[400],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
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
                              suffixIcon: Icon(
                                Icons.free_breakfast,
                                color: Colors.green[400],
                                size: 20,
                              ),
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
                              gradient: LinearGradient(
                                colors: [Colors.green[600]!, Colors.green[500]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
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

  /// Show quick suggestions
  void _showQuickSuggestions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Quick Questions (त्वरित प्रश्न)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Hindi suggestions
            _buildSuggestionTile('गेहूं कैसे उगाएं?', '🌾'),
            _buildSuggestionTile('धान की खेती कब करें?', '🌾'),
            _buildSuggestionTile('मक्का में कौन सी खाद डालें?', '🌽'),
            _buildSuggestionTile('कीड़े कैसे भगाएं?', '🐛'),
            _buildSuggestionTile('बारिश के बाद क्या करें?', '🌧️'),
            _buildSuggestionTile('आज की मंडी भाव क्या है?', '💰'),
            
            const Divider(height: 24),
            
            // English suggestions  
            _buildSuggestionTile('How to grow wheat?', '🌾'),
            _buildSuggestionTile('Best fertilizer for crops?', '🌿'),
            _buildSuggestionTile('Pest control methods?', '🐛'),
            _buildSuggestionTile('Weather farming tips?', '🌦️'),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Build suggestion tile
  Widget _buildSuggestionTile(String text, String emoji) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        _messageController.text = text;
        _sendMessage();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}