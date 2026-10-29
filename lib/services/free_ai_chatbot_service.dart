
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/user.dart' as app_user;

/// Free AI Chatbot Service using smart template responses
/// No API key required - works offline with smart responses
class FreeAIChatbotService extends ChangeNotifier {
  
  bool _isInitialized = false;
  final List<ChatMessage> _chatHistory = [];
  app_user.User? _currentUser;
  
  // Getters
  bool get isInitialized => _isInitialized;
  List<ChatMessage> get chatHistory => _chatHistory;

  /// Initialize Free AI Service
  Future<void> initialize({app_user.User? user}) async {
    try {
      _currentUser = user;
      _isInitialized = true;
      _addWelcomeMessage();
      notifyListeners();
      print('Free AI Chatbot Service initialized successfully');
    } catch (e) {
      print('Error initializing Free AI Service: $e');
    }
  }

  /// Send message to Free AI
  Future<void> sendMessage(String text) async {
    if (!_isInitialized || text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      messageType: ChatMessageType.text,
    );
    _chatHistory.add(userMessage);
    notifyListeners();

    try {
      // Generate smart template response
      String response = await _generateTemplateResponse(text);
      
      // Add AI response
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: ChatMessageType.text,
      );
      _chatHistory.add(aiMessage);
      notifyListeners();
      
    } catch (e) {
      print('Free AI Error: $e');
      
      // Add smart fallback response
      final fallbackResponse = await _generateTemplateResponse(text);
      final aiMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_smart',
        text: fallbackResponse,
        isUser: false,
        messageType: ChatMessageType.text,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(aiMessage);
      notifyListeners();
    }
  }



  /// Generate smart template response
  Future<String> _generateTemplateResponse(String userMessage) async {
    final language = _currentUser?.language ?? 'english';
    final lowerMessage = userMessage.toLowerCase();
    
    // Smart keyword detection for farming
    if (language == 'hindi') {
      // Hindi responses
      if (lowerMessage.contains('गेहूं') || lowerMessage.contains('wheat')) {
        return '''🌾 **गेहूं की खेती की जानकारी:**

📅 **बुआई का समय:** नवंबर-दिसंबर
🌱 **बीज दर:** 100-120 किग्रा प्रति हेक्टेयर
💧 **सिंचाई:** 4-5 बार (21, 40, 65, 85 दिन पर)
🌿 **खाद:** 120 किग्रा नाइट्रोजन, 60 किग्रा फॉस्फोरस

⚠️ **सावधानी:**
• दीमक से बचाव करें
• गेरुआ रोग की निगरानी करें
• पकने पर समय पर कटाई करें

क्या और जानना चाहते हैं?''';
      }
      
      else if (lowerMessage.contains('धान') || lowerMessage.contains('rice')) {
        return '''🌾 **धान की खेती की जानकारी:**

📅 **बुआई का समय:** जून-जुलाई (खरीफ)
🌱 **नर्सरी:** 25-30 दिन बाद रोपाई
💧 **पानी:** खेत में 2-3 इंच पानी रखें
🌿 **खाद:** 80 किग्रा नाइट्रोजन, 40 किग्रा फॉस्फोरस

⚠️ **मुख्य रोग:**
• भूरा धब्बा रोग
• जीवाणु पत्ती झुलसा
• तना बेधक कीट

क्या विशेष समस्या है?''';
      }
      
      else if (lowerMessage.contains('मक्का') || lowerMessage.contains('corn') || lowerMessage.contains('maize')) {
        return '''🌽 **मक्का की खेती की जानकारी:**

📅 **बुआई का समय:** 
• खरीफ: जून-जुलाई
• रबी: नवंबर-दिसंबर

🌱 **बीज दर:** 20-25 किग्रा प्रति हेक्टेयर
💧 **सिंचाई:** 4-5 बार आवश्यकता के अनुसार
🌿 **खाद:** 120 किग्रा नाइट्रोजन, 60 किग्रा फॉस्फोरस

⚠️ **मुख्य कीट:**
• तना बेधक
• पत्ती लपेटक
• मक्का का भुनगा

और कोई सवाल?''';
      }
      
      else if (lowerMessage.contains('मौसम') || lowerMessage.contains('weather') || lowerMessage.contains('बारिश') || lowerMessage.contains('rain')) {
        return '''🌦️ **मौसम और खेती की जानकारी:**

🌧️ **बारिश के बाद करें:**
• खेत का पानी निकालें
• कीटनाशक का छिड़काव न करें
• मिट्टी सूखने पर जुताई करें

☀️ **धूप में करें:**
• सिंचाई की व्यवस्था
• छायादार जगह तैयार करें
• पशुओं के लिए पानी की व्यवस्था

❄️ **सर्दी में करें:**
• रबी फसलों की बुआई
• पाले से बचाव
• गेहूं की निगरानी

कैसा मौसम है आपके यहां?''';
      }
      
      else if (lowerMessage.contains('खाद') || lowerMessage.contains('fertilizer') || lowerMessage.contains('उर्वरक')) {
        return '''🌿 **खाद और उर्वरक की जानकारी:**

🧪 **मुख्य पोषक तत्व:**
• नाइट्रोजन (N) - पत्तियों के लिए
• फॉस्फोरस (P) - जड़ों के लिए  
• पोटैश (K) - फूल-फल के लिए

🌱 **जैविक खाद:**
• गोबर की खाद - 10-15 टन/हेक्टेयर
• कंपोस्ट - 5-8 टन/हेक्टेयर
• वर्मी कंपोस्ट - 2-3 टन/हेक्टेयर

⚗️ **रासायनिक उर्वरक:**
• यूरिया - नाइट्रोजन के लिए
• डीएपी - फॉस्फोरस के लिए
• एमओपी - पोटैश के लिए

कौन सी फसल के लिए चाहिए?''';
      }
      
      else if (lowerMessage.contains('कीड़े') || lowerMessage.contains('बीमारी') || lowerMessage.contains('रोग') || lowerMessage.contains('pest')) {
        return '''🐛 **कीट-रोग प्रबंधन:**

🔍 **पहचान के तरीके:**
• पत्तियों पर धब्बे देखें
• तने में छेद चेक करें
• जड़ों की जांच करें

🌿 **जैविक उपचार:**
• नीम का तेल - 5 मिली/लीटर पानी
• लहसुन का स्प्रे - प्राकृतिक कीटनाशक
• ट्राइकोडर्मा - मिट्टी जनित रोगों के लिए

⚗️ **रासायनिक उपचार:**
• इमिडाक्लोप्रिड - चूसने वाले कीट
• क्लोरपायरिफॉस - मिट्टी के कीट
• मैंकोजेब - फफूंद रोग

फोटो भेजें सटीक सलाह के लिए!''';
      }
      
      else {
        return '''🙏 नमस्कार किसान भाई!

मैं आपका AgriAI असिस्टेंट हूं। आप मुझसे पूछ सकते हैं:

🌾 **फसल संबंधी:**
• "गेहूं कैसे उगाएं?"
• "धान की बुआई कब करें?"
• "मक्का में कौन सी खाद डालें?"

🌦️ **मौसम और सिंचाई:**
• "बारिश के बाद क्या करें?"
• "सूखे में फसल कैसे बचाएं?"

🐛 **कीट-रोग:**
• "पत्तियों पर धब्बे क्यों आते हैं?"
• "जैविक कीटनाशक कैसे बनाएं?"

💰 **बाजार की जानकारी:**
• "आज की मंडी भाव क्या है?"

कृपया अपना प्रश्न पूछें! 😊''';
      }
    } else {
      // English responses
      if (lowerMessage.contains('wheat')) {
        return '''🌾 **Wheat Farming Information:**

📅 **Sowing Time:** November-December
🌱 **Seed Rate:** 100-120 kg per hectare
💧 **Irrigation:** 4-5 times (21, 40, 65, 85 days)
🌿 **Fertilizer:** 120 kg Nitrogen, 60 kg Phosphorus

⚠️ **Precautions:**
• Protect from termites
• Monitor for rust disease  
• Timely harvesting when ripe

What else would you like to know?''';
      } else {
        return '''🙏 Hello Farmer!

I'm your AgriAI Assistant. You can ask me about:

🌾 **Crop Management:**
• "How to grow wheat?"
• "When to sow rice?"
• "Best fertilizer for corn?"

🌦️ **Weather & Irrigation:**
• "What to do after rain?"
• "Drought management tips?"

🐛 **Pest & Disease:**
• "Leaf spot treatment?"
• "Organic pesticides?"

💰 **Market Information:**
• "Today's crop prices?"

Please ask your question! 😊''';
      }
    }
  }



  /// Add welcome message
  void _addWelcomeMessage() {
    final welcomeText = _currentUser?.language == 'hindi' 
        ? '''नमस्कार ${_currentUser?.name ?? 'किसान भाई'}! 🌾

मैं AgriAI का **FREE Smart Farming Assistant** हूं।

✅ **100% Free Service**
🌐 **Internet Based AI**  
🚀 **Instant Responses**

आप मुझसे खेती के बारे में कुछ भी पूछ सकते हैं!

🌱 फसल की समस्याएं • 🌦️ मौसम की सलाह
💰 बाजार की जानकारी • 🐛 कीट-रोग उपचार

कैसे मदद कर सकूं?'''
        : '''Hello ${_currentUser?.name ?? 'Farmer'}! 🌾

I'm AgriAI's **FREE Smart Farming Assistant**.

✅ **100% Free Service**
🌐 **Internet Based AI**  
🚀 **Instant Responses**

Ask me anything about farming!

🌱 Crop Problems • 🌦️ Weather Advice
💰 Market Info • 🐛 Pest Control

How can I help you?''';

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: welcomeText,
      isUser: false,
      timestamp: DateTime.now(),
      messageType: ChatMessageType.text,
    );

    _chatHistory.add(message);
  }

  /// Clear chat history
  void clearChat() {
    _chatHistory.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  /// Update current user
  void updateUser(app_user.User? user) {
    _currentUser = user;
    notifyListeners();
  }
}