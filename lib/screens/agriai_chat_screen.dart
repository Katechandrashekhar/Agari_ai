import 'package:flutter/material.dart';
import '../services/offline_ai_service.dart';

class AgriAIChatScreen extends StatefulWidget {
  const AgriAIChatScreen({super.key});

  @override
  State<AgriAIChatScreen> createState() => _AgriAIChatScreenState();
}

class _AgriAIChatScreenState extends State<AgriAIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late OfflineAIService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = OfflineAIService();
    _aiService.initialize();
    _aiService.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _aiService.removeListener(_scrollToBottom);
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _aiService.sendMessage(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 8),
            Text('AgriAI Assistant'),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _aiService.clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick suggestions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'आप इन विषयों पर सवाल पूछ सकते हैं:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildSuggestionChip('🌾 गेहूं कैसे उगाएं?'),
                    _buildSuggestionChip('🍅 टमाटर के रोग'),
                    _buildSuggestionChip('🧪 खाद की जानकारी'),
                    _buildSuggestionChip('💰 बाजार के भाव'),
                    _buildSuggestionChip('🌱 मिट्टी की देखभाल'),
                  ],
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: AnimatedBuilder(
              animation: _aiService,
              builder: (context, _) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _aiService.messages.length,
                  itemBuilder: (context, index) {
                    final message = _aiService.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'अपना सवाल यहाँ लिखें...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _textController.text = text.replaceAll(RegExp(r'[🌾🍅🧪💰🌱]\s*'), '');
        _sendMessage();
      },
      child: Chip(
        label: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF4CAF50)),
        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    if (message.isTyping) {
      return _buildTypingIndicator();
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4CAF50),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF4CAF50) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF4CAF50),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++)
                  Container(
                    margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 8),
                const Text('जवाब लिख रहे हैं...', style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}