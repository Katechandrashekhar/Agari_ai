import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/chat_message.dart';
import '../models/user.dart' as app_user;

/// AI Chatbot Service for AgriAI app
/// Provides intelligent farming assistance using Google Gemini AI
class AIChatbotService extends ChangeNotifier {
  static const String _geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY');
  
  late GenerativeModel _model;
  late SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  final List<ChatMessage> _chatHistory = [];
  app_user.User? _currentUser;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  List<ChatMessage> get chatHistory => _chatHistory;

  /// Initialize AI Chatbot Service
  Future<void> initialize({app_user.User? user}) async {
    try {
      _currentUser = user;
      
      // Initialize Gemini AI Model  
      _model = GenerativeModel(
        model: 'models/gemini-1.5-flash',
        apiKey: _geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );

      // Initialize Speech to Text
      _speechToText = SpeechToText();
      await _speechToText.initialize(
        onStatus: (status) {
          _isListening = status == 'listening';
          notifyListeners();
        },
        onError: (error) {
          print('Speech recognition error: $error');
          _isListening = false;
          notifyListeners();
        },
      );

      // Initialize Text to Speech
      _flutterTts = FlutterTts();
      await _setupTts();

      _isInitialized = true;
      
      // Add welcome message
      _addWelcomeMessage();
      
      notifyListeners();
      print('AI Chatbot Service initialized successfully');
    } catch (e) {
      print('Error initializing AI Chatbot Service: $e');
      _isInitialized = false;
    }
  }

  /// Setup Text to Speech
  Future<void> _setupTts() async {
    await _flutterTts.setLanguage('hi-IN'); // Hindi
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });
    
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  /// Add welcome message
  void _addWelcomeMessage() {
    final welcomeText = _currentUser?.language == 'hindi' 
        ? '''नमस्कार ${_currentUser?.name ?? 'किसान भाई'}! 🌾

मैं AgriAI का स्मार्ट फार्मिंग असिस्टेंट हूं। आप मुझसे खेती के बारे में कुछ भी पूछ सकते हैं:

🌱 फसल की समस्याएं और समाधान
🌦️ मौसम के अनुसार सलाह  
💰 बाजार की कीमतें और बेचने का समय
🚜 खाद और उर्वरक की जानकारी
🔬 बीमारी की पहचान और इलाज

आप टाइप कर सकते हैं या voice button दबाकर बोल सकते हैं। कैसे मदद कर सकूं आपकी?'''
        : _currentUser?.language == 'marathi'
        ? '''नमस्कार ${_currentUser?.name ?? 'शेतकरी बंधू'}! 🌾

मी AgriAI चा स्मार्ट फार्मिंग असिस्टंट आहे। तुम्ही माझ्याकडून शेतीबाबत कुठलाही प्रश्न विचारू शकता:

🌱 पिकांच्या समस्या आणि उपाय
🌦️ हवामानानुसार सल्ला
💰 बाजार भाव आणि विक्रीची वेळ  
🚜 खत आणि कीटकनाशकांची माहिती
🔬 रोगांची ओळख आणि उपचार

तुम्ही टाइप करू शकता किंवा voice button दाबून बोलू शकता. कशी मदत करू?'''
        : '''Hello ${_currentUser?.name ?? 'Farmer'}! 🌾

I'm AgriAI's Smart Farming Assistant. You can ask me anything about farming:

🌱 Crop problems and solutions
🌦️ Weather-based advice
💰 Market prices and selling time
🚜 Fertilizer and pesticide information  
🔬 Disease identification and treatment

You can type or press the voice button to speak. How can I help you today?''';

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: welcomeText,
      isUser: false,
      timestamp: DateTime.now(),
      messageType: ChatMessageType.text,
    );

    _chatHistory.add(message);
  }

  /// Send text message to AI
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
      // Generate AI response
      final response = await _generateAIResponse(text);
      
      // Add AI response
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: ChatMessageType.text,
      );
      _chatHistory.add(aiMessage);
      
      // Speak response if Hindi/Marathi
      if (_currentUser?.language == 'hindi' || _currentUser?.language == 'marathi') {
        _speakText(response);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
      
      // Add fallback response even if API fails
      final fallbackResponse = _getFallbackResponse(text);
      final aiMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_fallback',
        text: fallbackResponse,
        isUser: false,
        messageType: ChatMessageType.system,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(aiMessage);
      notifyListeners();
    }
  }

  /// Generate AI response using Gemini
  Future<String> _generateAIResponse(String userMessage) async {
    try {
      print('🔄 Attempting to generate AI response for: $userMessage');
      
      final prompt = _buildContextualPrompt(userMessage);
      print('📝 Generated prompt: $prompt');
      
      final content = [Content.text(prompt)];
      print('⏳ Sending request to Gemini API...');
      
      final response = await _model.generateContent(content);
      print('✅ Received response from Gemini API');
      
      if (response.text != null && response.text!.isNotEmpty) {
        print('✨ AI Response: ${response.text!.substring(0, response.text!.length > 100 ? 100 : response.text!.length)}...');
        return response.text!;
      } else {
        print('⚠️ Empty response from Gemini API, using fallback');
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      print('❌ Gemini API Error Details: $e');
      print('🔄 Falling back to static response');
      return _getFallbackResponse(userMessage);
    }
  }

  /// Get fallback response when API fails
  String _getFallbackResponse(String userMessage) {
    final language = _currentUser?.language ?? 'english';
    
    // Simple keyword-based responses
    final lowerMessage = userMessage.toLowerCase();
    
    if (language == 'hindi') {
      if (lowerMessage.contains('मौसम') || lowerMessage.contains('weather') || lowerMessage.contains('location') || lowerMessage.contains('स्थान')) {
        return '''🌦️ मौसम की जानकारी:

📍 **आपका स्थान:** आपका GPS स्थान स्वचालित रूप से पता लगाया जा रहा है

🌾 **सामान्य सुझाव:**
• Weather स्क्रीन पर जाएं - आपका वर्तमान स्थान स्वचालित रूप से मिल जाएगा
• GPS location enable करें permission के लिए
• सुबह और शाम खेत का निरीक्षण करें
• मिट्टी की नमी जाँचें

💡 **कुछ इस तरह पूछें:**
• "मेरे यहाँ का मौसम कैसा है?"
• "इस मौसम में कौन सी फसल उगाएं?"
• "बारिश होगी या नहीं?"

🔧 **सुविधा:** Weather टैब में जाकर आपको automatic GPS location मिलेगा!''';
      } else if (lowerMessage.contains('कीड़े') || lowerMessage.contains('बीमारी') || lowerMessage.contains('रोग')) {
        return '''🐛 कीट-रोग की जानकारी:

आपकी फसल में कीड़े या बीमारी की समस्या हो सकती है।

🌿 **तुरंत करें:**
• पत्तियों और तने की जाँच करें
• प्रभावित हिस्सों को अलग करें
• नीम का तेल या जैविक कीटनाशक का उपयोग करें

📞 **सलाह:** 
स्थानीय कृषि विशेषज्ञ से संपर्क करें या फोटो भेजें।''';
      } else {
        return '''🙏 नमस्कार किसान भाई!

मैं आपका स्मार्ट कृषि सहायक हूँ। आप मुझसे पूछ सकते हैं:

🌾 **फसल संबंधी:**
• "गेहूं की बुआई कैसे करें?"
• "धान में पानी कितना दें?"
• "मक्का की उर्वरक मात्रा क्या है?"

🌦️ **मौसम और सिंचाई:**
• "बारिश के बाद क्या करें?"
• "सूखे में फसल कैसे बचाएं?"

💰 **बाज़ार की जानकारी:**
• "आज की मंडी भाव क्या है?"
• "फसल कब बेचें?"

कृपया अपना प्रश्न पूछें!''';
      }
    } else {
      if (lowerMessage.contains('weather') || lowerMessage.contains('climate')) {
        return '''🌦️ Weather Information:

Today's weather is suitable for farming activities.

🌾 **General Suggestions:**
• Check field conditions morning and evening
• Monitor soil moisture levels
• Watch for pest and disease signs

💡 **Ask me about:**
• "When to water crops?"
• "How much fertilizer to use?"
• "How to control pests?"''';
      } else if (lowerMessage.contains('pest') || lowerMessage.contains('disease') || lowerMessage.contains('insect')) {
        return '''🐛 Pest & Disease Management:

Your crops may have pest or disease issues.

🌿 **Immediate Actions:**
• Inspect leaves and stems carefully
• Isolate affected areas
• Use neem oil or organic pesticides

📞 **Advice:** 
Contact local agricultural expert or send photos for diagnosis.''';
      } else {
        return '''🙏 Hello Farmer!

I'm your Smart Agriculture Assistant. You can ask me about:

🌾 **Crop Management:**
• "How to grow wheat?"
• "Rice irrigation schedule?"
• "Corn fertilizer requirements?"

🌦️ **Weather & Irrigation:**
• "What to do after rain?"
• "Drought management tips?"

💰 **Market Information:**
• "Today's market prices?"
• "Best time to sell crops?"

Please ask your question!''';
      }
    }
  }

  /// Build contextual prompt for better responses
  String _buildContextualPrompt(String userMessage) {
    final language = _currentUser?.language ?? 'english';
    final userName = _currentUser?.name ?? 'Farmer';

    final userSoilType = _currentUser?.soilType ?? 'Not specified';
    final userCrops = 'General crops'; // You can enhance this based on user data

    String basePrompt = '';
    
    if (language == 'hindi') {
      basePrompt = '''आप एक अनुभवी भारतीय कृषि विशेषज्ञ और स्मार्ट फार्मिंग सलाहकार हैं।

किसान की जानकारी:
- नाम: $userName  
- स्थान: भारत (GPS location automatic detect हो रहा है)
- मिट्टी का प्रकार: $userSoilType
- फसलें: $userCrops

📍 **Important**: यह app automatic GPS location detect करता है Weather screen में। अगर यूजर मौसम या location के बारे में पूछे तो उन्हें Weather tab पर भेज दें।

निम्नलिखित सिद्धांतों का पालन करें:
1. हमेशा हिंदी में उत्तर दें
2. व्यावहारिक और वैज्ञानिक सलाह दें
3. अगर weather/location सवाल आए तो कहें "Weather tab में automatic GPS location मिलेगा"
4. सरल भाषा का उपयोग करें
5. जरूरत पड़ने पर चरणबद्ध समाधान दें
6. 🌾, 🌱, 💰, 🌦️, 📍 जैसे emojis का उपयोग करें

किसान का प्रश्न: "$userMessage"

कृपया विस्तृत और उपयोगी उत्तर दें:''';
    } else if (language == 'marathi') {
      basePrompt = '''तुम्ही एक अनुभवी भारतीय कृषी तज्ञ आणि स्मार्ट फार्मिंग सल्लागार आहात।

शेतकऱ्याची माहिती:
- नाव: $userName
- ठिकाण: भारत  
- मातीचा प्रकार: $userSoilType
- पिके: $userCrops

या तत्त्वांचे पालन करा:
1. नेहमी मराठीत उत्तर द्या
2. व्यावहारिक आणि वैज्ञानिक सल्ला द्या
3. स्थानिक परिस्थिती लक्षात घ्या
4. सोप्या भाषेचा वापर करा
5. गरज पडल्यास टप्प्यात उपाय सांगा
6. 🌾, 🌱, 💰, 🌦️ असे emojis वापरा

शेतकऱ्याचा प्रश्न: "$userMessage"

कृपया तपशीलवार आणि उपयुक्त उत्तर द्या:''';
    } else {
      basePrompt = '''You are an experienced Indian agricultural expert and smart farming consultant.

Farmer Information:
- Name: $userName
- Location: India
- Soil Type: $userSoilType  
- Crops: $userCrops

Follow these principles:
1. Always respond in English
2. Provide practical and scientific advice
3. Consider local Indian farming conditions
4. Use simple, easy-to-understand language
5. Give step-by-step solutions when needed
6. Use emojis like 🌾, 🌱, 💰, 🌦️ to make responses engaging

Farmer's Question: "$userMessage"

Please provide a detailed and helpful response:''';
    }

    return basePrompt;
  }

  /// Start voice recognition
  Future<void> startListening() async {
    if (!_isInitialized) return;

    // Check microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('Microphone permission not granted');
      return;
    }

    final available = await _speechToText.initialize();
    if (!available) {
      print('Speech recognition not available');
      return;
    }

    // Determine language based on user preference
    String localeId = 'en-US';
    if (_currentUser?.language == 'hindi') {
      localeId = 'hi-IN';
    } else if (_currentUser?.language == 'marathi') {
      localeId = 'mr-IN';
    }

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          sendMessage(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenMode: ListenMode.confirmation,
    );
  }

  /// Stop voice recognition
  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  /// Speak text using TTS
  Future<void> _speakText(String text) async {
    if (!_isInitialized) return;
    
    // Remove emojis for better TTS
    final cleanText = text.replaceAll(RegExp(r'[🌾🌱💰🌦️🚜🔬📱📈⚠️✅❌🎯]'), '');
    
    await _flutterTts.speak(cleanText);
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  /// Add error message
  void _addErrorMessage() {
    final errorText = _currentUser?.language == 'hindi'
        ? 'माफ़ करें, कुछ गड़बड़ हुई है। कृपया फिर से कोशिश करें।'
        : _currentUser?.language == 'marathi'
        ? 'माफ करा, काहीतरी चूक झाली आहे. कृपया पुन्हा प्रयत्न करा.'
        : 'Sorry, something went wrong. Please try again.';

    final errorMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: errorText,
      isUser: false,
      timestamp: DateTime.now(),
      messageType: ChatMessageType.error,
    );

    _chatHistory.add(errorMessage);
    notifyListeners();
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

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}