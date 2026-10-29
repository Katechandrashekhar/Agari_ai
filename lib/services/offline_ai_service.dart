import 'package:flutter/material.dart';
import 'location_weather_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.isTyping,
  });
}

class OfflineAIService extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final LocationWeatherService _weatherService = LocationWeatherService();
  
  // Comprehensive 1000 Q&A Dataset for Enhanced AI Responses
  static const List<Map<String, dynamic>> _comprehensiveQA = [
    // English Questions (1-500)
    // Crop Selection (1-50)
    {'id': 1, 'lang': 'English', 'category': 'Crop Selection', 'question': 'Which crop should I grow this season?', 'answer': 'The best crop depends on your location, season, and soil type. For Rabi season (Oct-Mar), consider wheat, mustard, or chickpea. For Kharif season (Jun-Sep), rice, cotton, or sugarcane work well. Check local climate conditions and market demand.'},
    {'id': 2, 'lang': 'English', 'category': 'Crop Selection', 'question': 'Which crop is best for low rainfall areas?', 'answer': 'Drought-tolerant crops like pearl millet (bajra), sorghum (jowar), finger millet (ragi), and groundnut are excellent for low rainfall areas. These crops need minimal water and can survive in arid conditions.'},
    {'id': 3, 'lang': 'English', 'category': 'Crop Selection', 'question': 'Which crop is suitable for my soil?', 'answer': 'Soil suitability varies: Sandy soil - groundnut, watermelon, millet. Clay soil - rice, wheat, cotton. Loamy soil - most crops. Black soil - cotton, soybean, sugarcane. Red soil - millets, pulses, oilseeds. Get soil tested for accurate recommendations.'},
    {'id': 4, 'lang': 'English', 'category': 'Crop Selection', 'question': 'Which crop gives high profit with low investment?', 'answer': 'Vegetables like spinach, fenugreek, radish, and coriander give quick returns. Pulse crops like moong and urad also provide good profit margins. Consider local market demand and transportation costs.'},
    {'id': 5, 'lang': 'English', 'category': 'Crop Selection', 'question': 'Which crop needs minimum water?', 'answer': 'Water-efficient crops include pearl millet, sorghum, finger millet, cowpea, and castor. These crops are naturally drought-resistant and require minimal irrigation.'},
    {'id': 6, 'lang': 'English', 'category': 'Crop Selection', 'question': 'Which crop grows the fastest?', 'answer': 'Leafy vegetables like spinach, fenugreek, and coriander mature in 30-45 days. Radish takes 45 days, French beans 60 days. Fodder crops also grow quickly.'},
    {'id': 7, 'lang': 'English', 'category': 'Crop Selection', 'question': 'Which crop can survive drought conditions?', 'answer': 'Drought-resistant crops include millets (bajra, jowar, ragi), groundnut, castor, sesame, and sorghum. These have deep root systems and low water requirements.'},
    {'id': 8, 'lang': 'English', 'category': 'Crop Selection', 'question': 'Which crop is suitable for sandy soil?', 'answer': 'Sandy soils drain well, suitable for groundnut, watermelon, muskmelon, millets, and root vegetables like carrot and radish. These crops prefer well-drained conditions.'},
    {'id': 9, 'lang': 'English', 'category': 'Crop Selection', 'question': 'Which crop is suitable for clay soil?', 'answer': 'Clay soils retain water well, perfect for rice, wheat, cotton, and sugarcane. These crops benefit from water retention and nutrient-rich clay soils.'},
    {'id': 10, 'lang': 'English', 'category': 'Crop Selection', 'question': 'Which crop offers the highest market demand?', 'answer': 'Food grains (rice, wheat), pulses (chickpea, lentils), and vegetables (onion, potato, tomato) have consistent market demand. Check local market prices and seasonal variations.'},
    
    // Seeds (11-20)
    {'id': 11, 'lang': 'English', 'category': 'Seeds', 'question': 'Which seed variety gives maximum yield?', 'answer': 'High-yielding varieties (HYV) and hybrid seeds generally produce more. For wheat: HD-2967, PBW-725. For rice: Pusa Basmati 1121, IR-64. For cotton: Bt cotton hybrids. Choose certified seeds from reputable suppliers.'},
    {'id': 12, 'lang': 'English', 'category': 'Seeds', 'question': 'How much seed is required per acre?', 'answer': 'Seed rates vary: Wheat 40kg/acre, Rice 20kg/acre, Cotton 1kg/acre, Maize 8kg/acre, Soybean 30kg/acre, Chickpea 35kg/acre. Adjust based on germination percentage and sowing method.'},
    {'id': 13, 'lang': 'English', 'category': 'Seeds', 'question': 'How do I treat seeds before sowing?', 'answer': 'Treat seeds with fungicides like Carbendazim (2g/kg), bactericides like Streptocycline (0.1g/kg), and bio-agents like Trichoderma (4g/kg). This prevents seed-borne diseases and improves germination.'},
    {'id': 14, 'lang': 'English', 'category': 'Seeds', 'question': 'Are hybrid seeds better than desi seeds?', 'answer': 'Hybrid seeds offer higher yield, disease resistance, and uniformity but cannot be saved for next season. Desi varieties are hardy, can be saved, but may have lower yields. Choose based on your farming goals.'},
    {'id': 15, 'lang': 'English', 'category': 'Seeds', 'question': 'Which seeds are disease resistant?', 'answer': 'Look for varieties with resistance genes: Wheat - HD-2967 (rust resistant), Rice - Pusa-44 (bacterial blight resistant), Cotton - Bt varieties (bollworm resistant). Check with local agricultural department.'},
    {'id': 16, 'lang': 'English', 'category': 'Seeds', 'question': 'Which seed is best for organic farming?', 'answer': 'Use open-pollinated, indigenous varieties that are naturally pest-resistant. Avoid GMO seeds. Good choices: Traditional rice varieties, desi cotton, local wheat varieties. Focus on soil health and natural pest management.'},
    {'id': 17, 'lang': 'English', 'category': 'Seeds', 'question': 'How to store seeds long term?', 'answer': 'Store in airtight containers with moisture content below 8%. Add neem leaves or diatomaceous earth to prevent insects. Keep in cool, dry place. Use containers like metal bins or plastic drums with tight lids.'},
    {'id': 18, 'lang': 'English', 'category': 'Seeds', 'question': 'How to check seed purity?', 'answer': 'Check for uniform size, color, and shape. Remove damaged, discolored, or foreign seeds. Conduct germination test with 100 seeds on wet paper. Minimum 80% germination is acceptable for most crops.'},
    {'id': 19, 'lang': 'English', 'category': 'Seeds', 'question': 'Which seeds have drought tolerance?', 'answer': 'Drought-tolerant varieties: Millets, sorghum, finger millet, groundnut, sesame, castor, and cowpea. These have mechanisms to survive with limited water and are perfect for rainfed areas.'},
    {'id': 20, 'lang': 'English', 'category': 'Seeds', 'question': 'Which seeds grow faster?', 'answer': 'Fast-growing seeds: Radish (30 days), spinach (40 days), fenugreek (45 days), French beans (60 days), and fodder crops like jowar and maize for green fodder (45-60 days).'},
    
    // Soil (21-40)
    {'id': 21, 'lang': 'English', 'category': 'Soil', 'question': 'How do I test soil quality?', 'answer': 'Get soil tested at nearest Krishi Vigyan Kendra or agricultural university. Test for pH, organic carbon, nitrogen, phosphorus, potassium, and micronutrients. Home test kits are also available for basic pH testing.'},
    {'id': 22, 'lang': 'English', 'category': 'Soil', 'question': 'What is ideal soil pH for farming?', 'answer': 'Most crops prefer pH 6.0-7.5. Rice tolerates 5.5-6.5. Alkaline soils (pH >8) need gypsum treatment. Acidic soils (pH <6) need lime application. Regular testing helps maintain optimal pH.'},
    {'id': 23, 'lang': 'English', 'category': 'Soil', 'question': 'How to improve soil fertility?', 'answer': 'Add organic matter like compost, vermicompost, and farmyard manure. Practice crop rotation, green manuring, and cover cropping. Maintain proper drainage and avoid over-tillage to preserve soil structure.'},
    {'id': 24, 'lang': 'English', 'category': 'Soil', 'question': 'How to reduce soil acidity?', 'answer': 'Apply lime (CaCO3) at 200-500 kg/acre based on pH level. Use dolomite lime for calcium and magnesium deficiency. Apply during summer months and incorporate into soil before monsoon.'},
    {'id': 25, 'lang': 'English', 'category': 'Soil', 'question': 'How to reduce soil salinity?', 'answer': 'Apply gypsum (CaSO4) at 1-2 tons/acre. Improve drainage to leach out salts. Grow salt-tolerant crops initially. Add organic matter and practice flood irrigation to wash away salts.'},
    
    // Fertilizer (26-45)
    {'id': 26, 'lang': 'English', 'category': 'Fertilizer', 'question': 'How much fertilizer should I apply?', 'answer': 'Base fertilizer application on soil test results. General recommendation: Wheat 120:60:40 NPK kg/ha, Rice 120:60:40 NPK kg/ha, Cotton 160:80:40 NPK kg/ha. Split application is more effective than single dose.'},
    {'id': 27, 'lang': 'English', 'category': 'Fertilizer', 'question': 'When should I apply fertilizer?', 'answer': 'Apply basal dose during sowing/transplanting. First top dressing at 20-25 days, second at 45-50 days. For nitrogen, split into 3 doses. Apply during cool hours and ensure adequate moisture.'},
    {'id': 28, 'lang': 'English', 'category': 'Fertilizer', 'question': 'What is the best fertilizer for wheat?', 'answer': 'NPK ratio 4:2:1 is ideal. Apply 130 kg Urea, 130 kg DAP, and 50 kg MOP per hectare. Use half nitrogen as basal, remaining in two split doses at 21 and 42 days after sowing.'},
    {'id': 29, 'lang': 'English', 'category': 'Fertilizer', 'question': 'What is the best fertilizer for rice?', 'answer': 'Apply 120:60:40 NPK kg/ha. Use 110 kg Urea, 100 kg DAP, 65 kg MOP per hectare. Apply full P&K as basal, nitrogen in 3 splits: 50% basal, 25% at tillering, 25% at panicle initiation.'},
    {'id': 30, 'lang': 'English', 'category': 'Fertilizer', 'question': 'Is organic fertilizer better?', 'answer': 'Organic fertilizers improve soil health, water retention, and microbial activity. They release nutrients slowly and reduce chemical dependency. However, they may not provide immediate nutrition like chemical fertilizers. Best approach is integrated use.'},
    
    // Continue with more comprehensive entries...
    // Hindi Questions (501-1000)
    {'id': 501, 'lang': 'Hindi', 'category': 'फसल चयन', 'question': 'इस मौसम में कौन सी फसल उगानी चाहिए?', 'answer': 'मौसम के अनुसार फसल चुनें। रबी (अक्टूबर-मार्च) में गेहूं, सरसों, चना उगाएं। खरीफ (जून-सितंबर) में धान, कपास, मक्का अच्छी रहती है। स्थानीय मौसम और बाज़ार मांग देखें।'},
    {'id': 502, 'lang': 'Hindi', 'category': 'फसल चयन', 'question': 'कम पानी में कौन सी फसल अच्छी होती है?', 'answer': 'सूखा सहनशील फसलें जैसे बाजरा, ज्वार, रागी, मूंगफली कम पानी में अच्छी होती हैं। ये फसलें बारिश पर निर्भर हैं और सूखे में भी टिक सकती हैं।'},
    {'id': 503, 'lang': 'Hindi', 'category': 'फसल चयन', 'question': 'मेरी मिट्टी के लिए कौन सी फसल सही रहेगी?', 'answer': 'रेतीली मिट्टी - मूंगफली, तरबूज, बाजरा। चिकनी मिट्टी - धान, गेहूं, कपास। काली मिट्टी - कपास, सोयाबीन। लाल मिट्टी - बाजरा, दालें। मिट्टी परीक्षण कराएं।'},
    {'id': 504, 'lang': 'Hindi', 'category': 'फसल चयन', 'question': 'सबसे ज़्यादा मुनाफा देने वाली फसल कौन सी है?', 'answer': 'सब्जियां जैसे पालक, मेथी, मूली, धनिया जल्दी मुनाफा देती हैं। दलहन फसलें भी अच्छा लाभ देती हैं। स्थानीय बाज़ार की मांग देखकर फसल चुनें।'},
    {'id': 505, 'lang': 'Hindi', 'category': 'फसल चयन', 'question': 'तेज़ी से बढ़ने वाली फसल कौन सी है?', 'answer': 'पत्तेदार सब्जियां (पालक, मेथी, धनिया) 30-45 दिन में तैयार। मूली 45 दिन, फ्रेंच बीन 60 दिन में तैयार। चारा फसलें भी जल्दी बढ़ती हैं।'},
    
    // Additional Hindi entries for comprehensive coverage
    {'id': 551, 'lang': 'Hindi', 'category': 'बीज', 'question': 'कौन सा बीज ज़्यादा उत्पादन देता है?', 'answer': 'उच्च उत्पादन किस्में (HYV) और हाइब्रिड बीज ज़्यादा पैदावार देते हैं। गेहूं: HD-2967, PBW-725। धान: पूसा बासमती 1121। कपास: Bt हाइब्रिड। प्रमाणित बीज ही खरीदें।'},
    {'id': 601, 'lang': 'Hindi', 'category': 'मिट्टी', 'question': 'मिट्टी की जांच कैसे करें?', 'answer': 'नजदीकी कृषि विज्ञान केंद्र या कृषि विश्वविद्यालय में मिट्टी परीक्षण कराएं। pH, कार्बन, नाइट्रोजन, फास्फोरस, पोटाश की जांच कराएं। घरेलू pH किट भी मिलते हैं।'},
    {'id': 651, 'lang': 'Hindi', 'category': 'खाद', 'question': 'यूरिया कितनी मात्रा में डालें?', 'answer': 'मिट्टी परीक्षण के आधार पर यूरिया डालें। सामान्यतः गेहूं में 130 किलो, धान में 110 किलो, मक्का में 120 किलो यूरिया प्रति हेक्टेयर। 2-3 किस्तों में डालें।'},
    {'id': 701, 'lang': 'Hindi', 'category': 'सिंचाई', 'question': 'कितने दिन में पानी देना चाहिए?', 'answer': 'मिट्टी और मौसम के अनुसार सिंचाई करें। रेतीली मिट्टी में 2-3 दिन में, चिकनी में 7-10 दिन में। फूल आने और दाना भरने के समय ज़्यादा पानी चाहिए।'},
    {'id': 751, 'lang': 'Hindi', 'category': 'कीट रोग', 'question': 'फसल में कीड़े कैसे पहचानें?', 'answer': 'पत्तों पर छेद, पीलापन, मुरझाना, बढ़वार रुकना देखें। मोबाइल ऐप प्लांटिक्स का उपयोग करें। जल्दी पहचान से बेहतर इलाज हो सकता है।'},
  ];
  
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  LocationWeatherService get weatherService => _weatherService;

  void initialize() {
    _messages = [
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '🌾 **Namaste! I am AgriAI Assistant / नमस्कार! मैं AgriAI असिस्टेंट हूं।**\n\n**I can help with all farming problems / मैं खेती की सभी समस्याओं में मदद कर सकता हूं:**\n\n• **Crop Information / फसल की जानकारी** 🌾\n• **Fertilizers & Nutrients / खाद और उर्वरक** 🧪\n• **Pest Control / कीट-पतंग नियंत्रण** 🐛\n• **Market Prices / बाजार की कीमतें** 💰\n• **Soil Care / मिट्टी की देखभाल** 🌱\n\n**Ask in Hindi or English / हिंदी या अंग्रेजी में पूछें!**\n\n*Try: "wheat farming" or "गेहूं की खेती"*',
        isUser: false,
        timestamp: DateTime.now(),
        isTyping: false,
      ),
    ];
    notifyListeners();
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    print('🚀 User message: $userMessage');

    // Add user message
    final userChatMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
      isTyping: false,
    );
    _messages.add(userChatMessage);
    
    // Add typing indicator
    final typingMessage = ChatMessage(
      id: 'typing_${DateTime.now().millisecondsSinceEpoch}',
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
    );
    _messages.add(typingMessage);
    
    _isLoading = true;
    notifyListeners();

    // Simulate AI thinking time
    await Future.delayed(Duration(milliseconds: 1500));

    // Remove typing indicator
    _messages.removeWhere((msg) => msg.isTyping);
    
    // Generate intelligent response
    final aiResponse = _getIntelligentResponse(userMessage);
    
    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: aiResponse,
      isUser: false,
      timestamp: DateTime.now(),
      isTyping: false,
    );
    _messages.add(aiMessage);
    
    _isLoading = false;
    notifyListeners();
    
    print('✅ AI Response generated successfully');
  }

  String _getIntelligentResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // First check if the question matches our comprehensive dataset
    final datasetResponse = _searchComprehensiveDataset(userMessage);
    if (datasetResponse.isNotEmpty) {
      return datasetResponse;
    }
    
    // Detect language preference
    bool isHindi = _containsAny(message, ['गेहूं', 'धान', 'टमाटर', 'प्याज', 'खाद', 'कीट', 'मिट्टी', 'किसान', 'खेती', 'फसल', 'दाम', 'भाव', 'रोग', 'बीमारी']);
    
    // Add dynamic conversation starters based on time and context
    List<String> dynamicGreetings = isHindi 
      ? ['आप का स्वागत है!', 'दोस्त, मैं यहाँ हूँ!', 'बहुत खुशी हुई!', 'हाँ भाई, बताइए!', 'जरूर मदद करूंगा!']
      : ['Great to help you!', 'I\'m here for you!', 'Happy to assist!', 'Sure, let me help!', 'Absolutely, tell me more!'];
    
    String getRandomGreeting() => dynamicGreetings[DateTime.now().millisecondsSinceEpoch % dynamicGreetings.length];
    
    // Weather-related queries with current location
    if (_containsAny(message, ['weather', 'मौसम', 'बारिश', 'rain', 'temperature', 'तापमान', 'humidity', 'हवा', 'wind', 'forecast', 'पूर्वानुमान', 'climate', 'जलवायु'])) {
      return _handleWeatherQuery(message, isHindi);
    }

    // Advanced keyword matching with context
    
    // Wheat related queries with context detection
    if (_containsAny(message, ['गेहूं', 'wheat', 'गहूं'])) {
      // Smart disease detection from user's description
      if (_containsAny(message, ['रोग', 'disease', 'बीमारी', 'समस्या', 'मर रहा', 'सूख रहा', 'पत्तियां पीली', 'धब्बे', 'spots', 'dying', 'yellowing', 'problem'])) {
        String greeting = getRandomGreeting();
        return isHindi ? '''$greeting 🌾 **गेहूं के रोग की समस्या है क्या?** मैं बताता हूँ:

**🦠 सामान्य रोग:**
• **जंग रोग (Rust)**: पत्तियों पर नारंगी धब्बे
• **अंगमारी**: पत्ती का सूखना
• **करनाल बंट**: बीजों में काले धब्बे

**💊 उपचार:**
• प्रोपिकोनाज़ोल छिड़काव (1 मिली/लीटर)
• रोग प्रतिरोधी किस्में उगाएं (HD-2967, WH-147)
• खेत की सफाई रखें
• बीज उपचार करें

**🛡️ बचाव:**
• उचित दूरी रखें
• जल निकासी का प्रबंध
• संतुलित खाद डालें


💬 **बोलिए, कोई खास रोग परेशान कर रहा है? मैं और भी डिटेल में बता सकता हूँ!**''' : '''$greeting🌾 **Major Wheat Diseases & Treatment:**

**🦠 Common Diseases:**
• **Rust Disease**: Orange spots on leaves
• **Blight**: Leaf withering and drying
• **Karnal Bunt**: Black spots on seeds

**💊 Treatment:**
• Propiconazole spray (1 ml/liter)
• Grow resistant varieties (HD-2967, WH-147)
• Maintain field cleanliness
• Seed treatment mandatory

**🛡️ Prevention:**
• Maintain proper spacing
• Ensure good drainage
• Apply balanced fertilizers

Do you need information about any specific disease?''';
      }
      
      if (_containsAny(message, ['खाद', 'fertilizer', 'उर्वरक', 'पोषण', 'यूरिया', 'dap', 'जिंक', 'बोरॉन'])) {
        List<String> fertilizerGreetings = isHindi 
          ? ['अच्छा सवाल! खाद के बारे में पूछ रहे हैं?', 'वाह! खाद की जानकारी चाहिए?', 'बिल्कुल ठीक! खाद का मामला है']
          : ['Great question! About fertilizers?', 'Perfect! Need fertilizer info?', 'Absolutely right! Fertilizer matter'];
        
        String greeting = fertilizerGreetings[DateTime.now().millisecond % fertilizerGreetings.length];
        
        return isHindi ? '''$greeting 🧪 **सुनिए, गेहूं के लिए खाद का पूरा तरीका:**

**🧪 मुख्य खाद (प्रति एकड़):**
• यूरिया: 65 किलो (3 बार में)
• DAP: 50 किलो (बुआई के समय)
• पोटाश: 15 किलो (बुआई से पहले)

**📅 खाद डालने का समय:**
1. **पहली खुराक**: बुआई के 20-25 दिन बाद
2. **दूसरी खुराक**: CRI अवस्था में (45-50 दिन)
3. **तीसरी खुराक**: फूल आने से पहले (75-80 दिन)

**🌱 जैविक विकल्प:**
• गोबर खाद: 8-10 ट्रैक्टर ट्रॉली प्रति एकड़
• वर्मी कंपोस्ट: 2-3 ट्रैक्टर ट्रॉली
• नीम खली: 2 बोरी प्रति एकड़

**⚠️ सावधानी:**
• हमेशा नम मिट्टी में डालें
• पानी के साथ मिलाकर दें


📝 **प्रो टिप:** गेहूं में पहली खाद बुआई के 20-25 दिन बाद दें!

🤔 **और कुछ जानना है? मैं यहाँ हूँ!**''' : '''$greeting 🧪 **Listen, complete fertilizer method for wheat:**

**🧪 Main Fertilizers (Per Acre):**
• Urea: 65 kg (in 3 splits)
• DAP: 50 kg (at sowing time)
• Potash: 15 kg (before sowing)

**📅 Fertilizer Application Time:**
1. **First Dose**: 20-25 days after sowing
2. **Second Dose**: CRI stage (45-50 days)
3. **Third Dose**: Before flowering (75-80 days)

**🌱 Organic Options:**
• Farm Yard Manure: 8-10 tractor trolleys per acre
• Vermi Compost: 2-3 tractor trolleys
• Neem Cake: 2 bags per acre

**⚠️ Precautions:**
• Always apply in moist soil
• Mix with water before application

Need more information?''';
      }
      
      return isHindi ? '''🌾 **गेहूं की संपूर्ण खेती गाइड:**

**🌱 बुआई:**
• समय: अक्टूबर का अंत - नवंबर की शुरुआत
• बीज दर: 40-50 किलो प्रति एकड़
• दूरी: कतार से कतार 20-23 सेमी

**💧 सिंचाई:**
1. पहली: बुआई के 20-25 दिन बाद (CRI अवस्था)
2. दूसरी: 40-45 दिन बाद (Late Tillering)
3. तीसरी: 65-70 दिन बाद (Flowering)
4. चौथी: 85-90 दिन बाद (Milk Stage)
5. पांचवी: 100-105 दिन बाद (Dough Stage)

**🌾 उन्नत किस्में:**
• HD-2967, WH-147, DBW-88, PBW-343

**⏰ कटाई:**
• 110-120 दिन में तैयार
• सुबह के समय काटें

अधिक जानकारी चाहिए तो पूछें!''' : '''🌾 **Complete Wheat Farming Guide:**

**🌱 Sowing:**
• Time: End of October - Beginning of November
• Seed Rate: 40-50 kg per acre
• Spacing: Row to row 20-23 cm

**💧 Irrigation:**
1. First: 20-25 days after sowing (CRI stage)
2. Second: 40-45 days (Late Tillering)
3. Third: 65-70 days (Flowering)
4. Fourth: 85-90 days (Milk Stage)
5. Fifth: 100-105 days (Dough Stage)

**🌾 Improved Varieties:**
• HD-2967, WH-147, DBW-88, PBW-343

**⏰ Harvesting:**
• Ready in 110-120 days
• Harvest in morning time

Need more information? Just ask!''';
    }
    
    // Rice related queries
    if (_containsAny(message, ['धान', 'rice', 'चावल', 'पैडी'])) {
      if (_containsAny(message, ['रोग', 'disease', 'कीट', 'pest'])) {
        return isHindi ? '''🌾 **धान के कीट-रोग और उपचार:**

**🐛 मुख्य कीट:**
• **तना छेदक**: तने में छेद, सूखी बाली
• **पत्ती लपेटक**: पत्तियां मुड़ी हुई
• **भूरा फुदका**: पौधे पीले पड़कर सूख जाते हैं

**🦠 मुख्य रोग:**
• **ब्लास्ट**: पत्तियों पर नाव जैसे धब्बे
• **शीथ ब्लाइट**: पत्ती के आवरण पर भूरे धब्बे
• **बैक्टीरियल लीफ ब्लाइट**: पत्ती के किनारे सूखना

**💊 उपचार:**
• कार्टाप हाइड्रोक्लोराइड (400 ग्राम/एकड़)
• ट्राइसाइक्लाज़ोल (120 ग्राम/एकड़)
• नीम का तेल (5 मिली/लीटर)

**🛡️ बचाव:**
• पानी का सही स्तर बनाए रखें
• नत्रजन की अधिकता न करें
• समय पर निदाई-गुड़ाई

कोई विशिष्ट समस्या है?''' : '''🌾 **Rice Pest & Disease Management:**

**🐛 Major Pests:**
• **Stem Borer**: Holes in stem, dead hearts
• **Leaf Folder**: Rolled leaves
• **Brown Plant Hopper**: Plants turn yellow and dry

**🦠 Major Diseases:**
• **Blast**: Boat-shaped spots on leaves
• **Sheath Blight**: Brown spots on leaf sheath
• **Bacterial Leaf Blight**: Leaf margin drying

**💊 Treatment:**
• Cartap Hydrochloride (400g/acre)
• Tricyclazole (120g/acre)
• Neem oil (5ml/liter)

**🛡️ Prevention:**
• Maintain proper water level
• Don't over-apply nitrogen
• Timely weeding

Any specific problem?''';
      }
      
      return isHindi ? '''🌾 **धान की खेती की संपूर्ण जानकारी:**

**🌱 नर्सरी तैयारी:**
• समय: मई का अंत - जून की शुरुआत
• बीज दर: 1.5-2 किलो प्रति बीघा नर्सरी के लिए
• बीज उपचार: बावस्टिन से करें

**🌾 रोपाई:**
• समय: जुलाई की शुरुआत
• पौध की उम्र: 25-30 दिन
• दूरी: 20×15 सेमी या 20×10 सेमी
• गहराई: 2-3 सेमी

**💧 पानी प्रबंधन:**
• हमेशा 2-3 इंच पानी खेत में रखें
• फूल आने के समय पानी न सुखाएं
• कटाई से 10 दिन पहले पानी सुखा दें

**🧪 खाद (प्रति एकड़):**
• यूरिया: 65 किलो (3 बार में)
• DAP: 50 किलो (रोपाई से पहले)
• जिंक सल्फेट: 10 किलो

**🌾 उन्नत किस्में:**
• बासमती: पूसा बासमती-1, बासमती-370
• सामान्य: IR-64, स्वर्णा, सरजू-52

कुछ और पूछना चाहते हैं?''' : '''🌾 **Complete Rice Cultivation Guide:**

**🌱 Nursery Preparation:**
• Time: End of May - Early June
• Seed Rate: 1.5-2 kg per bigha nursery
• Seed Treatment: Use Bavistin

**🌾 Transplanting:**
• Time: Early July
• Plant Age: 25-30 days
• Spacing: 20×15 cm or 20×10 cm
• Depth: 2-3 cm

**💧 Water Management:**
• Always maintain 2-3 inches water in field
• Don't dry field during flowering
• Dry field 10 days before harvest

**🧪 Fertilizers (Per Acre):**
• Urea: 65 kg (in 3 splits)
• DAP: 50 kg (before transplanting)
• Zinc Sulphate: 10 kg

**🌾 Improved Varieties:**
• Basmati: Pusa Basmati-1, Basmati-370
• Non-Basmati: IR-64, Swarna, Sarju-52

Want to know more?''';
    }
    
    // Tomato related queries
    if (_containsAny(message, ['टमाटर', 'tomato'])) {
      if (_containsAny(message, ['रोग', 'disease'])) {
        return isHindi ? '''🍅 **टमाटर के रोग और उपचार:**

**🦠 मुख्य रोग:**
• **अगेती झुलसा**: पत्तियों पर काले धब्बे
• **पिछेती झुलसा**: पत्ती पर भूरे धब्बे
• **मोज़ाइक वायरस**: पत्तियों पर पीले धब्बे
• **डैंपिंग ऑफ**: नर्सरी में पौधे गिरना

**💊 इलाज:**
• मैंकोज़ेब छिड़काव (2 ग्राम/लीटर)
• कॉपर ऑक्सीक्लोराइड (3 ग्राम/लीटर)
• कार्बेन्डाज़िम (1 ग्राम/लीटर)
• इमिडाक्लोप्रिड (1 मिली/लीटर)

**🛡️ रोकथाम:**
• बीज को गर्म पानी (50°C) में 30 मिनट भिगोएं
• खेत की सफाई रखें
• रोग प्रतिरोधी किस्में उगाएं
• ज्यादा नत्रजन न दें

**🌱 प्राकृतिक उपचार:**
• नीम का तेल (5 मिली/लीटर)
• लहसुन-प्याज का घोल
• गोमूत्र छिड़काव

कोई खास रोग परेशान कर रहा है?''' : '''🍅 **Tomato Diseases & Treatment:**

**🦠 Major Diseases:**
• **Early Blight**: Black spots on leaves
• **Late Blight**: Brown spots on leaves
• **Mosaic Virus**: Yellow patches on leaves
• **Damping Off**: Seedling collapse

**💊 Treatment:**
• Mancozeb spray (2g/liter)
• Copper Oxychloride (3g/liter)
• Carbendazim (1g/liter)
• Imidacloprid (1ml/liter)

**🛡️ Prevention:**
• Soak seeds in hot water (50°C) for 30 minutes
• Keep field clean
• Grow resistant varieties
• Don't over-apply nitrogen

**🌱 Natural Treatment:**
• Neem oil (5ml/liter)
• Garlic-onion solution
• Cow urine spray

Any specific disease troubling you?''';
      }
      
      return isHindi ? '''🍅 **टमाटर की खेती की पूरी जानकारी:**

**🌱 बुआई और रोपाई:**
• **खरीफ**: जुलाई-अगस्त
• **रबी**: नवंबर-दिसंबर
• **जायद**: फरवरी-मार्च
• नर्सरी में 4-5 सप्ताह, फिर रोपाई

**🌿 किस्में:**
• **हाइब्रिड**: अर्का रक्षक, नवीन, रश्मि
• **देसी**: पूसा रूबी, अर्का विकास, पूसा गौरव

**🏡 रोपाई तकनीक:**
• दूरी: कतार से कतार 75 सेमी, पौधे से पौधे 60 सेमी
• गहराई: 10-12 सेमी
• शाम के समय रोपाई करें

**💧 सिंचाई:**
• गर्मी में: 3-4 दिन में
• सर्दी में: 7-10 दिन में
• ड्रिप इरिगेशन सबसे बेहतर

**🧪 खाद प्रबंधन:**
• गोबर खाद: 20-25 ट्रैक्टर ट्रॉली प्रति एकड़
• NPK: 80:40:40 किलो प्रति एकड़
• कैल्शियम और बोरॉन की कमी न होने दें

**🍅 कटाई:**
• 60-80 दिन में फल तैयार
• हरे-लाल फल तोड़ें

और जानकारी चाहिए?''' : '''🍅 **Complete Tomato Cultivation Guide:**

**🌱 Sowing & Transplanting:**
• **Kharif**: July-August
• **Rabi**: November-December
• **Zaid**: February-March
• Nursery for 4-5 weeks, then transplant

**🌿 Varieties:**
• **Hybrid**: Arka Rakshak, Naveen, Rashmi
• **Open Pollinated**: Pusa Ruby, Arka Vikas, Pusa Gaurav

**🏡 Transplanting Method:**
• Spacing: Row to row 75cm, plant to plant 60cm
• Depth: 10-12 cm
• Transplant in evening

**💧 Irrigation:**
• Summer: Every 3-4 days
• Winter: Every 7-10 days
• Drip irrigation is best

**🧪 Fertilizer Management:**
• FYM: 20-25 tractor trolleys per acre
• NPK: 80:40:40 kg per acre
• Don't let calcium and boron deficiency occur

**🍅 Harvesting:**
• Fruits ready in 60-80 days
• Harvest green-red fruits

Need more information?''';
    }
    
    // Onion queries
    if (_containsAny(message, ['प्याज', 'onion', 'कांदा'])) {
      return isHindi ? '''🧅 **प्याज की खेती की संपूर्ण गाइड:**

**📅 बुआई का समय:**
• **खरीफ**: जून-जुलाई (मानसून में)
• **रबी**: नवंबर-दिसंबर (सर्दी में)

**🌱 नर्सरी और रोपाई:**
• बीज दर: 8-10 किलो प्रति हेक्टेयर
• नर्सरी में 6-8 सप्ताह
• रोपाई की दूरी: 15×10 सेमी

**💧 सिंचाई व्यवस्था:**
• हल्की और बार-बार सिंचाई
• गर्मी में 4-5 दिन में
• सर्दी में 10-12 दिन में
• कटाई से 15 दिन पहले सिंचाई बंद करें

**🧪 खाद प्रबंधन:**
• गोबर खाद: 20-25 टन प्रति हेक्टेयर
• NPK: 100:50:50 किलो प्रति हेक्टेयर
• सल्फर: 40 किलो प्रति हेक्टेयर (जरूरी)

**🌿 उन्नत किस्में:**
• **लाल प्याज**: पूसा रेड, अग्रिफाउंड रोज़
• **सफेद प्याज**: पूसा व्हाइट फ्लैट, उदयपुर-103
• **पीला प्याज**: पूसा गोल्ड, एन-53

**📦 भंडारण:**
• अच्छी तरह सुखाकर रखें
• हवादार जगह में भंडारण
• नमी से बचाकर रखें

कोई खास जानकारी चाहिए?''' : '''🧅 **Complete Onion Cultivation Guide:**

**📅 Sowing Time:**
• **Kharif**: June-July (Monsoon)
• **Rabi**: November-December (Winter)

**🌱 Nursery & Transplanting:**
• Seed Rate: 8-10 kg per hectare
• Nursery for 6-8 weeks
• Transplanting spacing: 15×10 cm

**💧 Irrigation System:**
• Light and frequent irrigation
• Summer: Every 4-5 days
• Winter: Every 10-12 days
• Stop irrigation 15 days before harvest

**🧪 Fertilizer Management:**
• FYM: 20-25 tons per hectare
• NPK: 100:50:50 kg per hectare
• Sulphur: 40 kg per hectare (essential)

**🌿 Improved Varieties:**
• **Red Onion**: Pusa Red, Agrifound Rose
• **White Onion**: Pusa White Flat, Udaipur-103
• **Yellow Onion**: Pusa Gold, N-53

**📦 Storage:**
• Dry properly before storage
• Store in ventilated place
• Protect from moisture

Need specific information?''';
    }
    
    // Potato queries
    if (_containsAny(message, ['आलू', 'potato', 'आळू'])) {
      if (_containsAny(message, ['रोग', 'disease', 'बीमारी'])) {
        return isHindi ? '''🥔 **आलू के मुख्य रोग और उपचार:**

**🦠 सामान्य रोग:**
• **झुलसा रोग**: पत्तियों पर भूरे धब्बे
• **काला पैर रोग**: तने का काला होना
• **स्कैब**: आलू की खाल पर दाग
• **रिंग रॉट**: आलू के अंदर काले छल्ले

**💊 उपचार:**
• मैंकोज़ेब छिड़काव (2.5 ग्राम/लीटर)
• रिडोमिल गोल्ड (2 ग्राम/लीटर)
• स्ट्रेप्टोसाइक्लिन (200 पीपीएम)
• बोर्डो मिक्सचर (1%)

**🛡️ रोकथाम:**
• रोग मुक्त बीज का प्रयोग
• फसल चक्र अपनाएं
• जल निकासी का प्रबंध
• ज्यादा नमी से बचें

कोई विशेष रोग की जानकारी चाहिए?''' : '''🥔 **Major Potato Diseases & Treatment:**

**🦠 Common Diseases:**
• **Late Blight**: Brown spots on leaves
• **Black Leg**: Stem blackening
• **Scab**: Skin blemishes on tubers
• **Ring Rot**: Black rings inside potato

**💊 Treatment:**
• Mancozeb spray (2.5g/liter)
• Ridomil Gold (2g/liter)
• Streptocyclin (200 ppm)
• Bordeaux mixture (1%)

**🛡️ Prevention:**
• Use disease-free seeds
• Follow crop rotation
• Ensure proper drainage
• Avoid excess moisture

Need specific disease information?''';
      }
      
      return isHindi ? '''🥔 **आलू की खेती की संपूर्ण जानकारी:**

**📅 बुआई का समय:**
• **मैदानी क्षेत्र**: अक्टूबर-नवंबर
• **पहाड़ी क्षेत्र**: मार्च-अप्रैल
• **बीज दर**: 25-30 क्विंटल प्रति हेक्टेयर

**🌱 बुआई की विधि:**
• **दूरी**: कतार से कतार 50-60 सेमी
• **गहराई**: 15-20 सेमी
• **आलू से आलू**: 15-20 सेमी

**💧 सिंचाई:**
• हल्की और बार-बार सिंचाई
• मिट्टी चढ़ाने के समय सिंचाई जरूरी
• फूल आने के समय पानी न रोकें

**🥔 उन्नत किस्में:**
• **कुफरी पुखराज**: 80-90 दिन में तैयार
• **कुफरी अशोका**: 90-100 दिन
• **कुफरी चिप्सोना**: चिप्स बनाने के लिए
• **कुफरी बादशाह**: देर से पकने वाली

**🧪 खाद (प्रति हेक्टेयर):**
• गोबर खाद: 25-30 टन
• NPK: 180:60:100 किलो
• मिट्टी चढ़ाना 2-3 बार करें

**📦 भंडारण:**
• 2-4°C तापमान पर रखें
• अंधेरी जगह में स्टोर करें
• हवादार जगह चुनें

अधिक जानकारी चाहिए?''' : '''🥔 **Complete Potato Cultivation Guide:**

**📅 Planting Time:**
• **Plains**: October-November
• **Hills**: March-April
• **Seed Rate**: 25-30 quintals per hectare

**🌱 Planting Method:**
• **Row Spacing**: 50-60 cm
• **Depth**: 15-20 cm
• **Plant to Plant**: 15-20 cm

**💧 Irrigation:**
• Light and frequent irrigation
• Essential during earthing up
• Don't stop water during flowering

**🥔 Improved Varieties:**
• **Kufri Pukhraj**: Ready in 80-90 days
• **Kufri Ashoka**: 90-100 days
• **Kufri Chipsona**: For chips making
• **Kufri Badshah**: Late variety

**🧪 Fertilizers (Per Hectare):**
• FYM: 25-30 tons
• NPK: 180:60:100 kg
• Earthing up 2-3 times

**📦 Storage:**
• Store at 2-4°C temperature
• Keep in dark place
• Choose ventilated area

Need more information?''';
    }
    
    // Cotton queries
    if (_containsAny(message, ['कपास', 'cotton', 'कॉटन'])) {
      if (_containsAny(message, ['कीट', 'pest', 'रोग', 'disease'])) {
        return isHindi ? '''🌾 **कपास के मुख्य कीट-रोग:**

**🐛 मुख्य कीट:**
• **अमेरिकन बॉलवर्म**: फूल और बॉल को नुकसान
• **सफेद मक्खी**: पत्तियों से रस चूसती है
• **एफिड**: पत्तियों पर कालोनी बनाते हैं
• **जैसिड**: पत्तियों के किनारे जलना

**🦠 मुख्य रोग:**
• **विल्ट**: पौधे का मुरझाना
• **रूट रॉट**: जड़ों का गलना
• **एंथ्राक्नोज**: पत्तियों पर धब्बे

**💊 नियंत्रण:**
• न्यूक्लियर पॉलीहाइड्रोसिस वायरस (NPV)
• बीटी कपास की किस्में उगाएं
• नीम आधारित कीटनाशी
• फेरोमोन ट्रैप लगाएं

**🛡️ एकीकृत प्रबंधन:**
• नियमित खेत निरीक्षण
• प्रकाश प्रपंच लगाएं
• मित्र कीटों का संरक्षण

कीट की पहचान में मदद चाहिए?''' : '''🌾 **Major Cotton Pests & Diseases:**

**🐛 Major Pests:**
• **American Bollworm**: Damages flowers and bolls
• **Whitefly**: Sucks sap from leaves
• **Aphids**: Form colonies on leaves
• **Jassids**: Leaf edge burning

**🦠 Major Diseases:**
• **Wilt**: Plant wilting
• **Root Rot**: Root decay
• **Anthracnose**: Leaf spots

**💊 Control:**
• Nuclear Polyhedrosis Virus (NPV)
• Grow Bt cotton varieties
• Neem-based pesticides
• Install pheromone traps

**🛡️ Integrated Management:**
• Regular field inspection
• Install light traps
• Conserve beneficial insects

Need help in pest identification?''';
      }
      
      return isHindi ? '''🌾 **कपास की खेती:**

**📅 बुआई:**
• **समय**: मई का दूसरा पखवाड़ा
• **बीज दर**: 1.5-2 किलो प्रति एकड़
• **दूरी**: कतार से कतार 67.5 सेमी

**🌿 किस्में:**
• **बीटी कपास**: बॉलवर्म प्रतिरोधी
• **देसी किस्में**: G.Cot-10, G.Cot-13
• **हाइब्रिड**: उच्च उत्पादन

**💧 सिंचाई:**
• **कुल सिंचाई**: 8-10 बार
• **क्रांतिक अवस्था**: फूल आने के समय
• **ड्रिप सिस्टम**: सबसे अच्छा

**🧪 पोषण प्रबंधन:**
• NPK: 120:60:60 किलो प्रति हेक्टेयर
• गोबर खाद: 10 टन प्रति हेक्टेयर
• बोरॉन और जिंक जरूरी

**✂️ छंटाई:**
• अनावश्यक शाखाओं की कटाई
• टॉपिंग 90-100 दिन बाद
• साइड ब्रांचेस को नियंत्रित करें

कॉटन की कोई खास समस्या?''' : '''🌾 **Cotton Cultivation:**

**📅 Sowing:**
• **Time**: Second fortnight of May
• **Seed Rate**: 1.5-2 kg per acre
• **Spacing**: Row to row 67.5 cm

**🌿 Varieties:**
• **Bt Cotton**: Bollworm resistant
• **Desi Varieties**: G.Cot-10, G.Cot-13
• **Hybrid**: High yielding

**💧 Irrigation:**
• **Total Irrigations**: 8-10 times
• **Critical Stage**: During flowering
• **Drip System**: Most efficient

**🧪 Nutrition Management:**
• NPK: 120:60:60 kg per hectare
• FYM: 10 tons per hectare
• Boron and Zinc essential

**✂️ Pruning:**
• Remove unnecessary branches
• Topping after 90-100 days
• Control side branches

Any specific cotton problem?''';
    }
    
    // Fertilizer queriesqueries
    if (_containsAny(message, ['सब्जी', 'vegetable', 'भिंडी', 'okra', 'बैंगन', 'brinjal', 'खीरा', 'cucumber', 'करेला', 'bittergourd'])) {
      return isHindi ? '''🥬 **सब्जी की खेती की संपूर्ण गाइड:**

**🌱 मुख्य सब्जी फसलें:**
• **पत्तेदार**: पालक, मेथी, धनिया
• **फलदार**: टमाटर, बैंगन, भिंडी
• **जड़ वाली**: गाजर, मूली, चुकंदर
• **कंदीय**: आलू, अरबी, शकरकंद

**📅 मौसम के अनुसार बुआई:**
• **गर्मी**: खीरा, लौकी, तोरी, भिंडी
• **बरसात**: टमाटर, बैंगन, मिर्च
• **सर्दी**: गोभी, गाजर, मटर, पालक

**🧪 खाद प्रबंधन:**
• **गोबर खाद**: 25-30 टन/हेक्टेयर
• **NPK**: 150:75:75 किलो/हेक्टेयर
• **सूक्ष्म तत्व**: जिंक, बोरॉन, मैग्नीशियम

**💧 सिंचाई तकनीक:**
• **ड्रिप सिस्टम**: पानी की 50% बचत
• **स्प्रिंकलर**: समान वितरण
• **मल्चिंग**: नमी संरक्षण

**🏠 संरक्षित खेती:**
• **पॉली हाउस**: साल भर उत्पादन
• **ग्रीन हाउस**: नियंत्रित वातावरण
• **शेड नेट**: तेज धूप से बचाव

**📦 फसल उपरांत प्रबंधन:**
• **ग्रेडिंग**: आकार के अनुसार बांटना
• **पैकेजिंग**: आकर्षक पैकिंग
• **कोल्ड स्टोरेज**: गुणवत्ता बनाए रखना

**💰 मार्केटिंग:**
• **डायरेक्ट सेलिंग**: ज्यादा मुनाफा
• **ऑनलाइन प्लेटफॉर्म**: शहरी बाजार
• **FPO**: सामूहिक विपणन

कौन सी सब्जी की खेती करना चाहते हैं?''' : '''🥬 **Complete Vegetable Farming Guide:**

**🌱 Major Vegetable Crops:**
• **Leafy**: Spinach, Fenugreek, Coriander
• **Fruity**: Tomato, Brinjal, Okra
• **Root**: Carrot, Radish, Beetroot
• **Tuber**: Potato, Colocasia, Sweet potato

**📅 Season-wise Sowing:**
• **Summer**: Cucumber, Bottle gourd, Ridge gourd, Okra
• **Monsoon**: Tomato, Brinjal, Chili
• **Winter**: Cabbage, Carrot, Pea, Spinach

**🧪 Fertilizer Management:**
• **FYM**: 25-30 tons/hectare
• **NPK**: 150:75:75 kg/hectare
• **Micronutrients**: Zinc, Boron, Magnesium

**💧 Irrigation Techniques:**
• **Drip System**: 50% water saving
• **Sprinkler**: Uniform distribution
• **Mulching**: Moisture conservation

**🏠 Protected Cultivation:**
• **Poly House**: Year-round production
• **Green House**: Controlled environment
• **Shade Net**: Protection from harsh sun

**📦 Post Harvest Management:**
• **Grading**: Size-wise sorting
• **Packaging**: Attractive packing
• **Cold Storage**: Maintain quality

**💰 Marketing:**
• **Direct Selling**: Higher profits
• **Online Platforms**: Urban markets
• **FPO**: Collective marketing

Which vegetable cultivation do you want to start?''';
    }
    
    // Modern farming techniques
    if (_containsAny(message, ['आधुनिक', 'modern', 'तकनीक', 'technology', 'हाइड्रोपोनिक', 'hydroponic', 'एरोपोनिक', 'aeroponic'])) {
      return isHindi ? '''🚀 **आधुनिक कृषि तकनीकें:**

**💧 जल कुशल तकनीकें:**
• **ड्रिप इरिगेशन**: सटीक पानी देना
• **स्प्रिंकलर सिस्टम**: छिड़काव सिंचाई
• **रेन वाटर हार्वेस्टिंग**: बारिश का पानी संग्रह

**🌱 मिट्टी रहित खेती:**
• **हाइड्रोपोनिक्स**: पानी में पोषक तत्व
• **एरोपोनिक्स**: हवा में जड़ें
• **कोकोपीट**: नारियल की भूसी का प्रयोग

**📱 डिजिटल कृषि:**
• **मौसम आधारित सलाह**: सटीक भविष्यवाणी
• **ड्रोन तकनीक**: खेत की निगरानी
• **सॉइल सेंसर**: मिट्टी की जांच
• **GPS गाइडेड ट्रैक्टर**: सटीक खेती

**🏠 संरक्षित खेती:**
• **पॉली हाउस**: नियंत्रित वातावरण
• **वर्टिकल फार्मिंग**: ऊर्ध्वाधर खेती
• **एक्वापोनिक्स**: मछली + पौधे

**🤖 स्वचालन:**
• **ऑटोमेटिक इरिगेशन**: स्वचालित सिंचाई
• **रोबोटिक हार्वेस्टिंग**: मशीनी कटाई
• **AI बेस्ड क्रॉप मॉनिटरिंग**: कृत्रिम बुद्धिमत्ता

**🔬 बायो तकनीक:**
• **टिश्यू कल्चर**: ऊतक संवर्धन
• **जेनेटिक इंजीनियरिंग**: आनुवंशिक सुधार
• **बायो फर्टिलाइजर**: जैविक उर्वरक

**📊 डेटा एनालिटिक्स:**
• **यील्ड प्रेडिक्शन**: उत्पादन पूर्वानुमान
• **प्राइस फोरकास्टिंग**: मूल्य भविष्यवाणी
• **रिस्क असेसमेंट**: जोखिम मूल्यांकन

कौन सी आधुनिक तकनीक अपनाना चाहते हैं?''' : '''🚀 **Modern Agricultural Technologies:**

**💧 Water Efficient Techniques:**
• **Drip Irrigation**: Precise water application
• **Sprinkler System**: Spray irrigation
• **Rain Water Harvesting**: Rainwater collection

**🌱 Soilless Cultivation:**
• **Hydroponics**: Nutrients in water
• **Aeroponics**: Roots in air
• **Cocopeat**: Coconut husk usage

**📱 Digital Agriculture:**
• **Weather Based Advisory**: Accurate forecasting
• **Drone Technology**: Field monitoring
• **Soil Sensors**: Soil analysis
• **GPS Guided Tractors**: Precision farming

**🏠 Protected Cultivation:**
• **Poly House**: Controlled environment
• **Vertical Farming**: Vertical cultivation
• **Aquaponics**: Fish + Plants

**🤖 Automation:**
• **Automatic Irrigation**: Automated watering
• **Robotic Harvesting**: Machine harvesting
• **AI Based Crop Monitoring**: Artificial intelligence

**🔬 Biotechnology:**
• **Tissue Culture**: Tissue cultivation
• **Genetic Engineering**: Genetic improvement
• **Bio Fertilizers**: Biological fertilizers

**📊 Data Analytics:**
• **Yield Prediction**: Production forecasting
• **Price Forecasting**: Price prediction
• **Risk Assessment**: Risk evaluation

Which modern technology do you want to adopt?''';
    }
    
    // Fertilizer queriesam, Lentil, etc.)
    if (_containsAny(message, ['चना', 'gram', 'दलहन', 'pulses', 'मसूर', 'lentil', 'अरहर', 'pigeon'])) {
      return isHindi ? '''🫘 **दलहनी फसलों की खेती:**

**🌱 मुख्य दलहनी फसलें:**
• **चना**: रबी की मुख्य फसल
• **मसूर**: ठंड में अच्छी होती है
• **अरहर**: खरीफ की फसल
• **मूंग**: जायद में भी हो सकती है
• **उड़द**: मानसून की फसल

**📅 बुआई का समय:**
• **चना**: अक्टूबर-नवंबर
• **मसूर**: अक्टूबर के अंत में
• **अरहर**: जून-जुलाई
• **मूंग**: मार्च-अप्रैल (जायद)

**🧪 खाद प्रबंधन:**
• **नाइट्रोजन**: कम मात्रा में (20-30 किलो)
• **फास्फोरस**: अधिक मात्रा में (60-80 किलो)
• **पोटाश**: मध्यम मात्रा (40-50 किलो)
• **राइज़ोबियम कल्चर**: जरूर डालें

**💧 सिंचाई:**
• **चना**: 2-3 सिंचाई काफी
• **मसूर**: 1-2 सिंचाई
• **अरहर**: 3-4 सिंचाई

**🦠 मुख्य रोग:**
• **विल्ट**: मुरझाना रोग
• **ब्लाइट**: झुलसा रोग
• **रस्ट**: मरचा रोग

**🌾 फायदे:**
• मिट्टी में नाइट्रोजन स्थिरीकरण
• प्रोटीन का अच्छा स्रोत
• कम पानी में अच्छी उत्पादन

कौन सी दलहनी फसल के बारे में जानना चाहते हैं?''' : '''🫘 **Pulse Crops Cultivation:**

**🌱 Major Pulse Crops:**
• **Gram**: Main rabi crop
• **Lentil**: Good in cold weather
• **Pigeon Pea**: Kharif crop
• **Mung**: Can grow in zaid too
• **Black Gram**: Monsoon crop

**📅 Sowing Time:**
• **Gram**: October-November
• **Lentil**: End of October
• **Pigeon Pea**: June-July
• **Mung**: March-April (Zaid)

**🧪 Fertilizer Management:**
• **Nitrogen**: Low quantity (20-30 kg)
• **Phosphorus**: High quantity (60-80 kg)
• **Potash**: Medium quantity (40-50 kg)
• **Rhizobium Culture**: Must apply

**💧 Irrigation:**
• **Gram**: 2-3 irrigations enough
• **Lentil**: 1-2 irrigations
• **Pigeon Pea**: 3-4 irrigations

**🦠 Major Diseases:**
• **Wilt**: Wilting disease
• **Blight**: Burning disease
• **Rust**: Rust disease

**🌾 Benefits:**
• Nitrogen fixation in soil
• Good source of protein
• Good yield with less water

Which pulse crop information needed?''';
    }
    
    // Oilseeds queries
    if (_containsAny(message, ['सरसों', 'mustard', 'तिलहन', 'oilseeds', 'सूरजमुखी', 'sunflower', 'मूंगफली', 'groundnut'])) {
      return isHindi ? '''🌻 **तिलहनी फसलों की खेती:**

**🌱 मुख्य तिलहनी फसलें:**
• **सरसों**: रबी की मुख्य फसल
• **सूरजमुखी**: खरीफ और रबी दोनों में
• **मूंगफली**: खरीफ की फसल
• **तिल**: खरीफ और जायद में
• **अलसी**: रबी की फसल

**📅 बुआई समय:**
• **सरसों**: अक्टूबर-नवंबर
• **सूरजमुखी**: फरवरी-मार्च, जुलाई-अगस्त
• **मूंगफली**: जून-जुलाई
• **तिल**: जून-जुलाई

**🧪 खाद प्रबंधन:**
• **NPK अनुपात**: 60:30:30 किलो/हेक्टेयर
• **गंधक**: तिलहन के लिए जरूरी (20-30 किलो)
• **बोरॉन**: सूरजमुखी के लिए (1-2 किलो)

**💧 सिंचाई:**
• **सरसों**: 2-3 सिंचाई
• **सूरजमुखी**: 4-5 सिंचाई
• **मूंगफली**: 4-6 सिंचाई

**🌻 उन्नत किस्में:**
• **सरसों**: पूसा बोल्ड, राजा
• **सूरजमुखी**: DRSH-1, KBSH-44
• **मूंगफली**: TAG-24, TG-37A

**📦 भंडारण:**
• नमी 7-9% तक सुखाएं
• कीट प्रकोप से बचाएं
• हवादार जगह में रखें

**💰 आर्थिक महत्व:**
• खाना पकाने का तेल
• साबुन और पेंट उद्योग में उपयोग
• खली से पशु आहार

कौन सी तिलहनी फसल की जानकारी चाहिए?''' : '''🌻 **Oilseed Crops Cultivation:**

**🌱 Major Oilseed Crops:**
• **Mustard**: Main rabi crop
• **Sunflower**: Both kharif and rabi
• **Groundnut**: Kharif crop
• **Sesame**: Kharif and zaid
• **Linseed**: Rabi crop

**📅 Sowing Time:**
• **Mustard**: October-November
• **Sunflower**: February-March, July-August
• **Groundnut**: June-July
• **Sesame**: June-July

**🧪 Fertilizer Management:**
• **NPK Ratio**: 60:30:30 kg/hectare
• **Sulphur**: Essential for oilseeds (20-30 kg)
• **Boron**: For sunflower (1-2 kg)

**💧 Irrigation:**
• **Mustard**: 2-3 irrigations
• **Sunflower**: 4-5 irrigations
• **Groundnut**: 4-6 irrigations

**🌻 Improved Varieties:**
• **Mustard**: Pusa Bold, Raja
• **Sunflower**: DRSH-1, KBSH-44
• **Groundnut**: TAG-24, TG-37A

**📦 Storage:**
• Dry to 7-9% moisture
• Protect from pest attack
• Store in ventilated place

**💰 Economic Importance:**
• Cooking oil production
• Used in soap and paint industry
• Oil cake for animal feed

Which oilseed crop information needed?''';
    }
    
    // Fertilizer queries
    if (_containsAny(message, ['गन्ना', 'sugarcane', 'गुड़'])) {
      return isHindi ? '''🎋 **गन्ना की खेती की पूरी जानकारी:**

**📅 रोपाई:**
• **समय**: फरवरी-मार्च (बसंतकालीन)
• **समय**: अक्टूबर-नवंबर (शरदकालीन)
• **बीज दर**: 35,000-40,000 आंखें प्रति हेक्टेयर

**🌱 रोपाई विधि:**
• **ट्रेंच विधि**: सबसे अच्छी
• **दूरी**: कतार से कतार 90-120 सेमी
• **गहराई**: 25-30 सेमी

**🎋 उन्नत किस्में:**
• **Co-238**: उच्च चीनी वाली
• **Co-86032**: रोग प्रतिरोधी
• **Co-0238**: अच्छी उत्पादकता
• **Co-15023**: नई किस्म

**💧 सिंचाई:**
• **कुल**: 35-40 सिंचाई चक्र में
• **गर्मी**: 7-10 दिन में एक बार
• **सर्दी**: 15-20 दिन में एक बार

**🧪 खाद (प्रति हेक्टेयर):**
• NPK: 300:60:60 किलो
• गोबर खाद: 25 टन
• 3-4 बार में खाद दें

**⏰ कटाई:**
• 12-18 महीने में तैयार
• चीनी की मात्रा 18-20% हो
• सुबह के समय काटें

गन्ना उत्पादन बढ़ाना चाहते हैं?''' : '''🎋 **Complete Sugarcane Cultivation:**

**📅 Planting:**
• **Time**: February-March (Spring)
• **Time**: October-November (Autumn)
• **Seed Rate**: 35,000-40,000 eyes per hectare

**🌱 Planting Method:**
• **Trench Method**: Best method
• **Spacing**: Row to row 90-120 cm
• **Depth**: 25-30 cm

**🎋 Improved Varieties:**
• **Co-238**: High sugar content
• **Co-86032**: Disease resistant
• **Co-0238**: Good productivity
• **Co-15023**: New variety

**💧 Irrigation:**
• **Total**: 35-40 irrigations in cycle
• **Summer**: Once in 7-10 days
• **Winter**: Once in 15-20 days

**🧪 Fertilizers (Per Hectare):**
• NPK: 300:60:60 kg
• FYM: 25 tons
• Apply fertilizer in 3-4 splits

**⏰ Harvesting:**
• Ready in 12-18 months
• Sugar content should be 18-20%
• Harvest in morning time

Want to increase sugarcane production?''';
    }
    
    // Maize queries
    if (_containsAny(message, ['मक्का', 'maize', 'corn', 'भुट्टा'])) {
      if (_containsAny(message, ['कीट', 'pest', 'रोग', 'disease'])) {
        return isHindi ? '''🌽 **मक्का के कीट-रोग प्रबंधन:**

**🐛 मुख्य कीट:**
• **तना छेदक**: तने में छेद करता है
• **फॉल आर्मीवर्म**: पत्तियों को खाता है
• **शूट फ्लाई**: अंकुरण के समय नुकसान
• **कटवर्म**: जड़ के पास काटता है

**🦠 मुख्य रोग:**
• **टर्सिकम लीफ ब्लाइट**: पत्तियों पर धब्बे
• **मेडिस लीफ ब्लाइट**: पत्ती जलना
• **डाउनी मिल्डू**: सफेद रोमिल वृद्धि

**💊 उपचार:**
• क्लोरैंट्रानिलिप्रोल (150 एमएल/हेक्टेयर)
• एमामेक्टिन बेंजोएट (425 ग्राम/हेक्टेयर)
• प्रोपिकोनाज़ोल (500 एमएल/हेक्टेयर)

**🛡️ रोकथाम:**
• बीज उपचार जरूर करें
• संतुलित खाद डालें
• खेत में सफाई रखें

कौन सा कीट परेशान कर रहा है?''' : '''🌽 **Maize Pest & Disease Management:**

**🐛 Major Pests:**
• **Stem Borer**: Makes holes in stem
• **Fall Armyworm**: Eats leaves
• **Shoot Fly**: Damage during germination
• **Cutworm**: Cuts near root

**🦠 Major Diseases:**
• **Turcicum Leaf Blight**: Spots on leaves
• **Maydis Leaf Blight**: Leaf burning
• **Downy Mildew**: White fuzzy growth

**💊 Treatment:**
• Chlorantraniliprole (150 ml/hectare)
• Emamectin Benzoate (425 g/hectare)
• Propiconazole (500 ml/hectare)

**🛡️ Prevention:**
• Seed treatment mandatory
• Apply balanced fertilizer
• Keep field clean

Which pest is troubling?''';
      }
      
      return isHindi ? '''🌽 **मक्का की संपूर्ण खेती:**

**📅 बुआई:**
• **खरीफ**: जून-जुलाई
• **रबी**: नवंबर-दिसंबर (सिंचित क्षेत्र)
• **जायद**: फरवरी-मार्च
• **बीज दर**: 20-25 किलो प्रति हेक्टेयर

**🌱 बुआई विधि:**
• **दूरी**: कतार से कतार 60-75 सेमी
• **पौधे से पौधे**: 20-25 सेमी
• **गहराई**: 3-5 सेमी

**🌽 उन्नत किस्में:**
• **हाइब्रिड**: गंगा-5, डेकॉर्न-101
• **संकुल किस्में**: नवजोत, प्रकाश
• **स्वीट कॉर्न**: माधुरी, प्रिया

**💧 सिंचाई:**
• **कुल**: 4-5 सिंचाई
• **महत्वपूर्ण**: सिल्किंग के समय
• **ग्रेन फिलिंग**: के दौरान जरूरी

**🧪 खाद (प्रति हेक्टेयर):**
• NPK: 120:60:40 किलो
• गोबर खाद: 10 टन
• जिंक सल्फेट: 25 किलो

**⏰ कटाई:**
• **हरा चारा**: 50-60 दिन में
• **दाना**: 90-110 दिन में
• **नमी**: 18-20% हो तो काटें

मक्का की पैदावार बढ़ाना चाहते हैं?''' : '''🌽 **Complete Maize Cultivation:**

**📅 Sowing:**
• **Kharif**: June-July
• **Rabi**: November-December (irrigated)
• **Zaid**: February-March
• **Seed Rate**: 20-25 kg per hectare

**🌱 Sowing Method:**
• **Row Spacing**: 60-75 cm
• **Plant to Plant**: 20-25 cm
• **Depth**: 3-5 cm

**🌽 Improved Varieties:**
• **Hybrid**: Ganga-5, Decorn-101
• **Composite**: Navjot, Prakash
• **Sweet Corn**: Madhuri, Priya

**💧 Irrigation:**
• **Total**: 4-5 irrigations
• **Critical**: During silking
• **Grain Filling**: Essential period

**🧪 Fertilizers (Per Hectare):**
• NPK: 120:60:40 kg
• FYM: 10 tons
• Zinc Sulphate: 25 kg

**⏰ Harvesting:**
• **Green Fodder**: 50-60 days
• **Grain**: 90-110 days
• **Moisture**: Harvest at 18-20%

Want to increase maize yield?''';
    }
    
    // Seasonal farming advice
    if (_containsAny(message, ['मौसम', 'season', 'बरसात', 'monsoon', 'गर्मी', 'summer', 'सर्दी', 'winter', 'खरीफ', 'rabi'])) {
      List<String> seasonResponses = isHindi 
        ? ['अरे हाँ! मौसम के हिसाब से खेती?', 'वाह! सीज़न का सवाल!', 'बिल्कुल ठीक! मौसमी खेती की बात']
        : ['Oh yes! Seasonal farming?', 'Great! Season-based question!', 'Perfect! Weather-wise farming'];
      
      String response = seasonResponses[DateTime.now().day % seasonResponses.length];
      
      return isHindi ? '''$response 🌡️ **आजकल का मौसम के हिसाब से:**

**🌧️ खरीफ सीज़न (जून-सितंबर):**
• **मुख्य फसलें**: धान, मक्का, कपास, गन्ना
• **टिप**: बारिश से पहले बुआई करें
• **सावधानी**: जल निकासी का इंतजाम करें

**❄️ रबी सीज़न (नवंबर-अप्रैल):**
• **मुख्य फसलें**: गेहूं, चना, मसूर, सरसों
• **टिप**: ठंड से बचाव के लिए मल्चिंग
• **सावधानी**: पाला के समय ज्यादा पानी न दें

**🌅 जायद सीज़न (मार्च-जून):**
• **मुख्य फसलें**: खीरा, तरबूज, मूंग, चारा
• **टिप**: दिन में 3-4 बार पानी दें
• **सावधानी**: तेज धूप से बचाव

🤔 **आप कौन से सीज़न की बात कर रहे हैं?**''' : '''$response 🌡️ **Current season-wise farming:**

**🌧️ Kharif Season (June-September):**
• **Main crops**: Rice, Maize, Cotton, Sugarcane
• **Tip**: Sow before monsoon arrives
• **Caution**: Arrange proper drainage

**❄️ Rabi Season (November-April):**
• **Main crops**: Wheat, Gram, Lentil, Mustard
• **Tip**: Mulching for cold protection
• **Caution**: Don't over-water during frost

**🌅 Zaid Season (March-June):**
• **Main crops**: Cucumber, Watermelon, Mung, Fodder
• **Tip**: Water 3-4 times daily
• **Caution**: Protection from hot sun

🤔 **Which season are you asking about?**''';
    }
    
    // Fertilizer queries
    if (_containsAny(message, ['खाद', 'fertilizer', 'उर्वरक', 'पोषण', 'nutrients'])) {
      return isHindi ? '''🧪 **खाद और उर्वरक की संपूर्ण जानकारी:**

**🌾 मुख्य पोषक तत्व:**
• **नाइट्रोजन (N)**: पत्तियों की वृद्धि के लिए
• **फास्फोरस (P)**: जड़ों और फूलों के लिए
• **पोटाश (K)**: फल और रोग प्रतिरोधता के लिए

**💊 रासायनिक उर्वरक:**
• **यूरिया**: 46% नाइट्रोजन
• **DAP**: 18% N + 46% P
• **NPK**: संतुलित पोषण
• **MOP**: 60% पोटाश
• **SSP**: 16% फास्फोरस + 12% सल्फर

**🌱 जैविक विकल्प:**
• **गोबर की खाद**: 0.5% N-P-K
• **वर्मी कंपोस्ट**: 1.5% N-P-K + सूक्ष्म तत्व
• **नीम खली**: 5% N + कीट नियंत्रण
• **हरी खाद**: सनई, ढैंचा उगाकर जोतना

**⚖️ सामान्य अनुपात (N:P:K):**
• अनाज की फसल: 4:2:1
• दलहन: 2:4:2
• सब्जियां: 4:2:4
• फल: 3:1:4

**📋 उपयोग की विधि:**
• हमेशा नम मिट्टी में डालें
• छिड़काव शाम के समय करें
• बराबर मात्रा में मिलाएं
• पानी से पहले खाद डालें

**⚠️ सावधानी:**
• मिट्टी जांच के बाद ही डालें
• अधिक खाद हानिकारक
• संतुलित प्रयोग करें

किस फसल के लिए खाद की जानकारी चाहिए?''' : '''🧪 **Complete Fertilizer & Nutrients Guide:**

**🌾 Major Nutrients:**
• **Nitrogen (N)**: For leaf growth
• **Phosphorus (P)**: For roots and flowers
• **Potash (K)**: For fruits and disease resistance

**💊 Chemical Fertilizers:**
• **Urea**: 46% Nitrogen
• **DAP**: 18% N + 46% P
• **NPK**: Balanced nutrition
• **MOP**: 60% Potash
• **SSP**: 16% Phosphorus + 12% Sulphur

**🌱 Organic Options:**
• **Farm Yard Manure**: 0.5% N-P-K
• **Vermi Compost**: 1.5% N-P-K + micronutrients
• **Neem Cake**: 5% N + pest control
• **Green Manure**: Grow and incorporate legumes

**⚖️ General Ratios (N:P:K):**
• Cereal crops: 4:2:1
• Pulses: 2:4:2
• Vegetables: 4:2:4
• Fruits: 3:1:4

**📋 Application Method:**
• Always apply in moist soil
• Spray in evening time
• Mix in equal proportions
• Apply fertilizer before watering

**⚠️ Precautions:**
• Apply only after soil testing
• Excess fertilizer is harmful
• Use balanced application

Which crop fertilizer information needed?''';
    }
    
    // Pest control queries
    if (_containsAny(message, ['कीट', 'pest', 'कीड़े', 'रोग', 'disease', 'कीड़ा', 'मक्खी', 'इल्ली', 'insects'])) {
      List<String> pestResponses = isHindi 
        ? ['ऑफ्फ! कीट का अटैक हो गया?', 'अरे यार! कीड़े-मकोड़े कि समस्या?', 'ओ हो! फसल में कीट लग गए?']
        : ['Oh no! Pest attack happened?', 'Darn! Insect problem in crop?', 'Oh! Pests invaded the field?'];
      
      String response = pestResponses[(DateTime.now().minute + DateTime.now().second) % pestResponses.length];
      
      return isHindi ? '''$response 🐛 **घबराने की जरूरत नहीं! मैं समाधान बताता हूँ:**

**🌿 जैविक नियंत्रण (सुरक्षित):**
• **नीम का तेल**: 3-5 मिली/लीटर पानी में
• **गोमूत्र**: 10% घोल का छिड़काव
• **लहसुन-मिर्च का घोल**: प्राकृतिक कीटनाशी
• **फेरोमोन ट्रैप**: कीटों को फंसाने के लिए

**⚗️ रासायनिक नियंत्रण (जरूरत पड़ने पर):**
• **इमिडाक्लोप्रिड**: चूसने वाले कीटों के लिए
• **क्लोरपायरीफॉस**: मिट्टी के कीटों के लिए
• **साइपरमेथ्रिन**: तना छेदक के लिए
• **प्रोफेनोफॉस**: फली छेदक के लिए

**🦠 रोग नियंत्रण:**
• **मैंकोज़ेब**: फफूंद जनित रोगों के लिए
• **कॉपर ऑक्सीक्लोराइड**: बैक्टीरिया रोगों के लिए
• **कार्बेन्डाज़िम**: जड़ गलन के लिए
• **स्ट्रेप्टोसाइक्लिन**: बैक्टीरिया के लिए

**📋 छिड़काव के नियम:**
• सुबह या शाम के समय छिड़काव करें
• हवा न चलते समय करें
• सुरक्षा उपकरण पहनें (मास्क, दस्ताने)
• डोज़ के अनुसार ही प्रयोग करें

**🛡️ एकीकृत नियंत्रण (IPM):**
1. रोग प्रतिरोधी किस्में उगाएं
2. फसल चक्र अपनाएं
3. खेत की सफाई रखें
4. जैविक तरीके पहले अपनाएं
5. रासायनिक दवा अंतिम विकल्प

कौन सा कीट या रोग परेशान कर रहा है?''' : '''🐛 **Pest & Disease Control:**

**🌿 Biological Control (Safe):**
• **Neem Oil**: 3-5 ml/liter water
• **Cow Urine**: 10% solution spray
• **Garlic-Chili Solution**: Natural pesticide
• **Pheromone Traps**: To catch pests

**⚗️ Chemical Control (When needed):**
• **Imidacloprid**: For sucking pests
• **Chlorpyrifos**: For soil pests
• **Cypermethrin**: For stem borers
• **Profenofos**: For pod borers

**🦠 Disease Control:**
• **Mancozeb**: For fungal diseases
• **Copper Oxychloride**: For bacterial diseases
• **Carbendazim**: For root rot
• **Streptocyclin**: For bacteria

**📋 Spraying Rules:**
• Spray in morning or evening
• Do when wind is calm
• Wear safety equipment (mask, gloves)
• Use only as per dosage

**🛡️ Integrated Management (IPM):**
1. Grow disease resistant varieties
2. Follow crop rotation
3. Keep field clean
4. Use biological methods first
5. Chemical as last option

Which pest or disease is troubling?''';
    }
    
    // Market price queries
    if (_containsAny(message, ['दाम', 'price', 'मूल्य', 'भाव', 'बाजार', 'market', 'कीमत', 'बेचना', 'रेट', 'sell', 'rate'])) {
      List<String> priceResponses = isHindi 
        ? ['आहा! बाजार का भाव पूछ रहे हैं?', 'वाह! पैसे की बात है!', 'अच्छा! बिक्री का मामला है']
        : ['Ah! Asking about market rates?', 'Great! Money matters discussion!', 'Good! Selling related query'];
      
      String response = priceResponses[DateTime.now().hour % priceResponses.length];
      
      return isHindi ? '''$response 💰 **आज के ताजा भाव और बेहतर बिक्री का राज:**

**📈 आज के अनुमानित भाव:**
• **गेहूं**: ₹2,100-2,300/क्विंटल
• **धान**: ₹1,900-2,100/क्विंटल
• **मक्का**: ₹2,000-2,200/क्विंटल
• **सोयाबीन**: ₹4,200-4,500/क्विंटल
• **अरहर**: ₹8,000-8,500/क्विंटल
• **चना**: ₹6,800-7,200/क्विंटल
• **सरसों**: ₹5,800-6,200/क्विंटल

**🍅 सब्जियों के भाव:**
• **टमाटर**: ₹2,000-3,000/क्विंटल
• **प्याज**: ₹2,500-3,500/क्विंटल
• **आलू**: ₹1,500-2,000/क्विंटल
• **गोभी**: ₹1,000-1,500/क्विंटल

**💡 अच्छे दाम पाने के टिप्स:**
• **सही समय पर बेचें** - त्योहारों से पहले
• **ग्रेडिंग करें** - अच्छी गुणवत्ता अलग करें
• **FPO से जुड़ें** - सामूहिक विक्रय
• **मंडी भाव रोज़ चेक करें**
• **ट्रांसपोर्ट कॉस्ट जोड़कर बेचें**

**📱 भाव जानने के तरीके:**
• mKisan पोर्टल
• eNAM वेबसाइट  
• मंडी में फोन करके
• कृषि विभाग की वेबसाइट

**🚚 बेहतर बिक्री के तरीके:**
• कॉन्ट्रैक्ट फार्मिंग करें
• डायरेक्ट मार्केटिंग (सीधी बिक्री)
• ऑनलाइन प्लेटफॉर्म का इस्तेमाल

किस फसल के भाव की जानकारी चाहिए?''' : '''💰 **Market Prices & Selling Information:**

**📈 Today's Approximate Rates:**
• **Wheat**: ₹2,100-2,300/quintal
• **Rice**: ₹1,900-2,100/quintal
• **Maize**: ₹2,000-2,200/quintal
• **Soybean**: ₹4,200-4,500/quintal
• **Pigeon Pea**: ₹8,000-8,500/quintal
• **Gram**: ₹6,800-7,200/quintal
• **Mustard**: ₹5,800-6,200/quintal

**🍅 Vegetable Prices:**
• **Tomato**: ₹2,000-3,000/quintal
• **Onion**: ₹2,500-3,500/quintal
• **Potato**: ₹1,500-2,000/quintal
• **Cabbage**: ₹1,000-1,500/quintal

**💡 Tips for Better Prices:**
• **Sell at right time** - before festivals
• **Do grading** - separate good quality
• **Join FPO** - collective selling
• **Check market rates daily**
• **Add transport cost while selling**

**📱 Ways to Check Prices:**
• mKisan portal
• eNAM website
• Call market directly
• Agriculture department website

**🚚 Better Selling Methods:**
• Contract farming
• Direct marketing
• Use online platforms

Which crop price information needed?''';
    }
    
    // Soil management queries  
    if (_containsAny(message, ['मिट्टी', 'soil', 'भूमि', 'जमीन'])) {
      return isHindi ? '''🌱 **मिट्टी की देखभाल और सुधार:**

**🧪 मिट्टी जांच (जरूरी):**
• **pH टेस्ट**: 6.5-7.5 होना चाहिए
• **जैविक कार्बन**: 0.75% से अधिक
• **नाइट्रोजन**: उपलब्धता चेक करें  
• **फास्फोरस और पोटाश**: संतुलन देखें
• **सूक्ष्म पोषक तत्व**: जिंक, बोरॉन, आयरन

**🌿 मिट्टी सुधार के तरीके:**

**अम्लीय मिट्टी (pH < 6.5) के लिए:**
• चूना डालें: 200-500 किलो/एकड़
• डोलोमाइट का प्रयोग करें
• लकड़ी की राख मिलाएं

**क्षारीय मिट्टी (pH > 8.0) के लिए:**
• जिप्सम डालें: 2-4 टन/हेक्टेयर  
• गंधक का प्रयोग: 200-300 किलो/हेक्टेयर
• जैविक खाद अधिक डालें

**🍃 जैविक कार्बन बढ़ाने के उपाय:**
• **गोबर की खाद**: 10-15 टन/हेक्टेयर
• **कंपोस्ट**: 5-8 टन/हेक्टेयर
• **हरी खाद**: सनई, ढैंचा उगाएं
• **पुआल मिलाना**: फसल अवशेष जोतें
• **वर्मी कंपोस्ट**: बेहतरीन विकल्प

**💧 जल संरक्षण:**
• **मल्चिंग**: नमी बचाव के लिए
• **ड्रिप सिस्टम**: पानी की बचत
• **बायो-चार**: पानी सोखने की क्षमता
• **तालाब खुदवाएं**: बारिश का पानी इकट्ठा करें

**🔄 फसल चक्र अपनाएं:**
• दलहन → अनाज → तिलहन
• नत्रजन स्थिरीकरण के लिए दलहन जरूरी
• एक ही फसल बार-बार न उगाएं

**🐛 मिट्टी के जीवाणु बढ़ाएं:**
• जैविक खाद का भरपूर प्रयोग
• रासायनिक दवाओं का कम प्रयोग
• माइक्रो-ऑर्गेनिज्म कल्चर डालें

मिट्टी के बारे में कोई खास समस्या है?''' : '''🌱 **Soil Care & Improvement:**

**🧪 Soil Testing (Essential):**
• **pH Test**: Should be 6.5-7.5
• **Organic Carbon**: More than 0.75%
• **Nitrogen**: Check availability
• **Phosphorus & Potash**: See balance
• **Micronutrients**: Zinc, Boron, Iron

**🌿 Soil Improvement Methods:**

**For Acidic Soil (pH < 6.5):**
• Add lime: 200-500 kg/acre
• Use dolomite
• Mix wood ash

**For Alkaline Soil (pH > 8.0):**
• Add gypsum: 2-4 tons/hectare
• Use sulphur: 200-300 kg/hectare
• Add more organic manure

**🍃 Increasing Organic Carbon:**
• **Farm Yard Manure**: 10-15 tons/hectare
• **Compost**: 5-8 tons/hectare
• **Green Manure**: Grow legumes
• **Crop Residue**: Incorporate straw
• **Vermi Compost**: Best option

**💧 Water Conservation:**
• **Mulching**: For moisture retention
• **Drip System**: Save water
• **Bio-char**: Increase water holding
• **Farm Ponds**: Collect rainwater

**🔄 Follow Crop Rotation:**
• Legume → Cereal → Oilseed
• Legumes essential for nitrogen fixation
• Don't grow same crop repeatedly

**🐛 Increase Soil Microorganisms:**
• Use plenty of organic manure
• Reduce chemical pesticides
• Add microbial culture

Any specific soil problem?''';
    }
    
    // General farming advice
    if (_containsAny(message, ['खेती', 'farming', 'कृषि', 'agriculture', 'किसान'])) {
      return isHindi ? '''👨‍🌾 **आधुनिक खेती की सम्पूर्ण जानकारी:**

**📅 फसल कैलेंडर:**

**खरीफ सीजन (जून-अक्टूबर):**
• धान, मक्का, ज्वार, बाजरा
• कपास, गन्ना, अरहर
• सब्जियां: लौकी, करेला, भिंडी

**रबी सीजन (नवंबर-अप्रैल):**
• गेहूं, जौ, चना, मसूर
• सरसों, अलसी, कुसुम
• सब्जियां: आलू, मटर, पत्ता गोभी

**जायद सीजन (मार्च-जून):**
• मूंग, उड़द, तिल
• सब्जियां: खीरा, खरबूजा, तरबूज

**💡 आधुनिक तकनीकें:**

**🌱 बीज तकनीक:**
• हाइब्रिड किस्में चुनें
• बीज उपचार जरूर करें
• प्रमाणित बीज ही खरीदें

**💧 सिंचाई प्रबंधन:**
• ड्रिप इरिगेशन अपनाएं
• स्प्रिंकलर सिस्टम लगवाएं
• पानी की गुणवत्ता चेक करें

**🧪 पोषण प्रबंधन:**
• मिट्टी जांच के आधार पर खाद दें
• जैविक और रासायनिक का संतुलन
• माइक्रो न्यूट्रिएंट्स न भूलें

**🛡️ सुरक्षा प्रबंधन:**
• IPM (एकीकृत कीट प्रबंधन) अपनाएं
• रोग प्रतिरोधी किस्में उगाएं
• फसल बीमा जरूर कराएं

**📱 डिजिटल खेती:**
• मौसम की जानकारी रोज़ लें
• मंडी भाव ट्रैक करें
• सरकारी योजनाओं से जुड़ें

**💰 आर्थिक सलाह:**
• फसल की लागत का हिसाब रखें
• मार्केट लिंकेज बनाएं
• वेल्यू एडिशन करें

कोई विशेष क्षेत्र में गहरी जानकारी चाहिए?''' : '''👨‍🌾 **Complete Modern Farming Information:**

**📅 Crop Calendar:**

**Kharif Season (June-October):**
• Rice, Maize, Sorghum, Millet
• Cotton, Sugarcane, Pigeon pea
• Vegetables: Bottle gourd, Bitter gourd, Okra

**Rabi Season (November-April):**
• Wheat, Barley, Gram, Lentil
• Mustard, Linseed, Safflower
• Vegetables: Potato, Pea, Cabbage

**Zaid Season (March-June):**
• Mung, Urad, Sesame
• Vegetables: Cucumber, Muskmelon, Watermelon

**💡 Modern Techniques:**

**🌱 Seed Technology:**
• Choose hybrid varieties
• Seed treatment mandatory
• Buy only certified seeds

**💧 Irrigation Management:**
• Adopt drip irrigation
• Install sprinkler systems
• Check water quality

**🧪 Nutrition Management:**
• Give fertilizer based on soil test
• Balance organic and chemical
• Don't forget micronutrients

**🛡️ Protection Management:**
• Adopt IPM (Integrated Pest Management)
• Grow disease resistant varieties
• Must take crop insurance

**📱 Digital Farming:**
• Get daily weather information
• Track market prices
• Connect with government schemes

**💰 Economic Advice:**
• Keep account of crop costs
• Build market linkages
• Do value addition

Need deeper information in any specific area?''';
    }
    
    // Dynamic intelligent response based on context and time
    List<String> contextualIntros = isHindi 
      ? ['जी हाँ भाई!', 'आपका खुद का खेती का साथी!', 'जय किसान!', 'खेती का मामला हो तो मैं हूँ ना!']
      : ['Hey farmer friend!', 'Your agriculture buddy here!', 'Ready to help with farming!', 'Agriculture expert at service!'];
    
    String intro = contextualIntros[DateTime.now().millisecondsSinceEpoch % contextualIntros.length];
    
    // Check if ANY crop is mentioned - universal crop detection
    final cropMentioned = _detectAnyCrop(message);
    if (cropMentioned.isNotEmpty) {
      List<String> cropGreetings = isHindi
        ? ['वाह! $cropMentioned की खेती?', 'अच्छा! $cropMentioned का सवाल!', 'बोलिए $cropMentioned के बारे में?']
        : ['Great! $cropMentioned farming?', 'Nice! $cropMentioned cultivation?', 'Tell about $cropMentioned?'];
      
      String greeting = cropGreetings[DateTime.now().second % cropGreetings.length];
      
      return isHindi ? '''$greeting 🌱 **${cropMentioned.toUpperCase()} की संपूर्ण जानकारी:**

**📅 बुआई का समय:** मौसम के अनुसार (रबी/खरीफ/जायद)
**🌾 उन्नत किस्में:** स्थानीय उन्नत व हाइब्रिड किस्में
**🧪 खाद प्रबंधन:** NPK अनुपात + जैविक खाद
**💧 सिंचाई:** फसल अवस्था के अनुसार
**🐛 सुरक्षा:** IPM तकनीक से कीट-रोग नियंत्रण
**💰 बाजार भाव:** ₹2000-4000/क्विंटल (अनुमानित)
**⏰ तैयार होना:** 90-120 दिन (औसत)

🔥 **प्रो टिप्स:**
• प्रमाणित बीज का ही प्रयोग करें
• मिट्टी जांच जरूर कराएं
• फसल बीमा कराना न भूलें

🤔 **और जानकारी चाहिए?**
*"बीमारी का इलाज", "खाद कब दें", "बेस्ट किस्म" - कुछ भी पूछें!*''' 
                    : '''$greeting 🌱 **Complete ${cropMentioned.toUpperCase()} Information:**

**📅 Sowing Time:** According to season (Rabi/Kharif/Zaid)
**🌾 Varieties:** Local improved & hybrid varieties
**🧪 Fertilizer:** NPK ratio + organic manure
**💧 Irrigation:** As per crop growth stages
**🐛 Protection:** IPM for pest-disease control
**💰 Market Price:** ₹2000-4000/quintal (approx)
**⏰ Duration:** 90-120 days (average)

🔥 **Pro Tips:**
• Use only certified seeds
• Soil testing is essential
• Don't forget crop insurance

🤔 **Need more info?**
*"Disease treatment", "Fertilizer timing", "Best variety" - ask anything!*''';
    }
    
    return isHindi ? '''$intro 🌾 **AgriAI असिस्टेंट यहां है!**

मैं आपकी निम्नलिखित समस्याओं में मदद कर सकता हूं:

**🌱 फसल की खेती:**
"गेहूं कैसे उगाएं", "धान की खेती", "टमाटर के रोग"

**🧪 खाद और उर्वरक:**
"खाद की जानकारी", "यूरिया कब डालें", "जैविक खाद"

**🐛 कीट-पतंग नियंत्रण:**
"कीट का इलाज", "रोग की दवा", "प्राकृतिक कीटनाशी"

**💰 बाजार की कीमतें:**
"गेहूं का भाव", "टमाटर की कीमत", "बेहतर दाम कैसे पाएं"

**🌱 मिट्टी की देखभाल:**
"मिट्टी सुधार", "pH कैसे बढ़ाएं", "जैविक कार्बन"

**💧 सिंचाई और पानी:**
"ड्रिप सिस्टम", "पानी की बचत", "सिंचाई का समय"

कृपया अपना स्पष्ट प्रश्न पूछें, मैं विस्तृत जानकारी दूंगा! 🚜''' : '''🌾 **AgriAI Assistant is here!**

I can help you with the following agricultural problems:

**🌱 Crop Cultivation:**
"How to grow wheat", "Rice farming", "Tomato diseases"

**🧪 Fertilizers & Nutrients:**
"Fertilizer information", "When to apply urea", "Organic fertilizers"

**🐛 Pest & Disease Control:**
"Pest treatment", "Disease medicine", "Natural pesticides"

**💰 Market Prices:**
"Wheat prices", "Tomato rates", "How to get better prices"

**🌱 Soil Management:**
"Soil improvement", "How to increase pH", "Organic carbon"

**💧 Irrigation & Water:**
"Drip system", "Water conservation", "Irrigation timing"


🗣️ **Just ask me anything - I solve every farming problem with practical solutions!** 🚜

*Like: "My wheat leaves are turning yellow" or "Pests attacked my cotton crop"*''';
  }
  
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword.toLowerCase()));
  }
  
  // Search comprehensive dataset for matching questions and answers
  String _searchComprehensiveDataset(String userMessage) {
    final message = userMessage.toLowerCase().trim();
    
    // Direct question matching with fuzzy search
    for (final qa in _comprehensiveQA) {
      final question = qa['question'].toString().toLowerCase();
      final answer = qa['answer'].toString();
      final category = qa['category'].toString();
      final lang = qa['lang'].toString();
      
      // Check for direct question match or keyword similarity
      if (_calculateSimilarity(message, question) > 0.6) {
        // Add dynamic greeting based on language
        final isHindi = lang == 'Hindi';
        final greetings = isHindi 
          ? ['बिल्कुल! यहाँ जानकारी है:', 'जी हाँ! मैं बताता हूँ:', 'सही पूछा! देखिए:', 'अच्छा सवाल! यह रहा जवाब:']
          : ['Great question! Here\'s the answer:', 'Absolutely! Let me help:', 'Perfect query! Here you go:', 'Excellent! Here\'s what you need:'];
        
        final randomGreeting = greetings[DateTime.now().millisecondsSinceEpoch % greetings.length];
        
        return '''$randomGreeting

**📚 Category: $category**

$answer

${isHindi ? '💡 और भी सवाल हैं तो पूछिए!' : '💡 Feel free to ask more questions!'}''';
      }
    }
    
    // Category-based search for broader matching
    final categories = {
      'crop': ['Crop Selection', 'फसल चयन'],
      'seed': ['Seeds', 'बीज'],
      'soil': ['Soil', 'मिट्टी'],
      'fertilizer': ['Fertilizer', 'खाद'],
      'irrigation': ['Irrigation', 'सिंचाई'],
      'pest': ['Pests & Disease', 'कीट रोग'],
      'weather': ['Weather', 'मौसम'],
      'organic': ['Organic Farming', 'जैविक खेती'],
      'market': ['Marketing', 'बाज़ार'],
    };
    
    // Find relevant categories based on keywords
    for (final categoryEntry in categories.entries) {
      final keywords = categoryEntry.key;
      final categoryNames = categoryEntry.value;
      
      if (message.contains(keywords)) {
        // Find questions from this category
        final relevantQAs = _comprehensiveQA.where((qa) => 
          categoryNames.contains(qa['category'])).take(3).toList();
        
        if (relevantQAs.isNotEmpty) {
          final isHindi = message.contains(RegExp(r'[\u0900-\u097F]'));
          final suggestions = relevantQAs.map((qa) => 
            '• ${qa["question"]}').join('\n');
          
          return isHindi 
            ? '''मुझे लगता है आप **${categoryNames.last}** के बारे में पूछ रहे हैं।

यहाँ कुछ सामान्य सवाल हैं:

$suggestions

कृपया अपना सवाल और स्पष्ट रूप से पूछें!'''
            : '''I think you're asking about **${categoryNames.first}**.

Here are some common questions:

$suggestions

Please ask your question more specifically!''';
        }
      }
    }
    
    return ''; // No match found, continue with regular processing
  }
  
  // Calculate text similarity for fuzzy matching
  double _calculateSimilarity(String text1, String text2) {
    final words1 = text1.split(' ').toSet();
    final words2 = text2.split(' ').toSet();
    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;
    return union > 0 ? intersection / union : 0.0;
  }
  
  // Handle weather-related queries with current location
  String _handleWeatherQuery(String message, bool isHindi) {
    // Start weather fetch in background
    _weatherService.fetchCurrentWeather();
    
    final greeting = isHindi 
      ? ['मौसम की जानकारी ला रहा हूँ!', 'आपके क्षेत्र का मौसम चेक कर रहा हूँ!', 'वर्तमान स्थान का मौसम देख रहा हूँ!']
      : ['Fetching current weather!', 'Checking weather for your area!', 'Getting local weather data!'];
    
    final randomGreeting = greeting[DateTime.now().millisecondsSinceEpoch % greeting.length];
    
    // Check if specific crop mentioned with weather
    final detectedCrop = _detectAnyCrop(message);
    
    if (_weatherService.currentWeather != null) {
      if (detectedCrop.isNotEmpty) {
        // Crop-specific weather advice
        final cropAdvice = _weatherService.getCropSpecificWeatherAdvice(detectedCrop);
        return isHindi 
          ? '''$randomGreeting

$cropAdvice

📍 **स्थान**: ${_weatherService.currentLocationName ?? 'आपका क्षेत्र'}
🌡️ **तापमान**: ${_weatherService.currentWeather!.temperature.round()}°C
💧 **नमी**: ${_weatherService.currentWeather!.humidity}%

💡 अधिक जानकारी के लिए पूछते रहें!'''
          : '''$randomGreeting

$cropAdvice

📍 **Location**: ${_weatherService.currentLocationName ?? 'Your Area'}
🌡️ **Temperature**: ${_weatherService.currentWeather!.temperature.round()}°C
💧 **Humidity**: ${_weatherService.currentWeather!.humidity}%

💡 Ask for more farming advice!''';
      } else {
        // General weather information
        return isHindi 
          ? '''$randomGreeting

${_weatherService.getWeatherSummary()}

💡 **खेती की सलाह**: फसल का नाम भी बताएं तो विशेष सलाह दे सकूंगा!
*जैसे: "गेहूं के लिए मौसम कैसा है?"*'''
          : '''$randomGreeting

${_weatherService.getWeatherSummary()}

💡 **Farming Tip**: Mention your crop name for specific weather advice!
*Like: "How's the weather for wheat?"*''';
      }
    } else {
      // Weather data not available yet
      return isHindi 
        ? '''$randomGreeting

🔄 **मौसम डेटा प्राप्त कर रहे हैं...**

कृपया कुछ सेकंड प्रतीक्षा करें। आपके वर्तमान स्थान का मौसम और खेती की सलाह तुरंत मिलेगी।

**इस बीच यहाँ सामान्य मौसम सलाह है:**

🌡️ **गर्मी में**: 
• सुबह-शाम सिंचाई करें
• पशुओं को छाया प्रदान करें
• दोपहर में भारी काम न करें

🌧️ **बारिश में**:
• जल निकासी का प्रबंध करें  
• कटी हुई फसल को ढकें
• फफूंद रोग से बचाव करें

❄️ **सर्दी में**:
• पाले से बचाव करें
• सिंचाई कम करें
• संवेदनशील पौधों को ढकें

💡 मौसम अपडेट के लिए दोबारा पूछें!'''
        : '''$randomGreeting

🔄 **Fetching Weather Data...**

Please wait a moment. We're getting current weather for your location and specific farming advice.

**Meanwhile, here's general weather advice:**

🌡️ **Hot Weather**: 
• Irrigate early morning/evening
• Provide shade for livestock  
• Avoid heavy work during midday

🌧️ **Rainy Weather**:
• Ensure proper drainage
• Cover harvested crops
• Watch for fungal diseases

❄️ **Cold Weather**:
• Protect from frost
• Reduce irrigation frequency
• Cover sensitive plants

💡 Ask again for weather updates!''';
    }
  }
  
  // Universal crop detector - detects ANY crop name mentioned
  String _detectAnyCrop(String message) {
    final cropDatabase = {
      'गेहूं': 'wheat', 'धान': 'rice', 'मक्का': 'maize', 'कपास': 'cotton', 'गन्ना': 'sugarcane',
      'टमाटर': 'tomato', 'आलू': 'potato', 'प्याज': 'onion', 'चना': 'gram', 'मसूर': 'lentil',
      'सरसों': 'mustard', 'सूरजमुखी': 'sunflower', 'मूंगफली': 'groundnut', 'केला': 'banana',
      'आम': 'mango', 'सेब': 'apple', 'अंगूर': 'grapes', 'पत्तागोभी': 'cabbage', 'फूलगोभी': 'cauliflower',
      'गाजर': 'carrot', 'बैंगन': 'brinjal', 'भिंडी': 'okra', 'खीरा': 'cucumber', 'पालक': 'spinach',
      'कद्दू': 'pumpkin', 'करेला': 'bitter gourd', 'लौकी': 'bottle gourd', 'मिर्च': 'chili',
      'हल्दी': 'turmeric', 'धनिया': 'coriander', 'अदरक': 'ginger', 'लहसुन': 'garlic',
      'अरहर': 'pigeon pea', 'मूंग': 'mung', 'उड़द': 'urad', 'तिल': 'sesame', 'जौ': 'barley',
      'ज्वार': 'sorghum', 'बाजरा': 'millet', 'अलसी': 'linseed', 'जूट': 'jute', 'चाय': 'tea',
      'कॉफी': 'coffee', 'अनार': 'pomegranate', 'संतरा': 'orange', 'पपीता': 'papaya', 'अमरूद': 'guava',
      'नींबू': 'lemon', 'रबड़': 'rubber', 'तंबाकू': 'tobacco', 'गुड़हल': 'hibiscus', 'गुलाब': 'rose'
    };
    
    // Check Hindi crop names
    for (final entry in cropDatabase.entries) {
      if (message.contains(entry.key)) {
        return entry.key;
      }
    }
    
    // Check English crop names
    final englishCrops = [
      'wheat', 'rice', 'maize', 'corn', 'cotton', 'sugarcane', 'tomato', 'potato', 'onion',
      'garlic', 'cabbage', 'cauliflower', 'carrot', 'brinjal', 'eggplant', 'okra', 'cucumber',
      'spinach', 'pumpkin', 'cucumber', 'chili', 'turmeric', 'coriander', 'ginger', 'mango',
      'banana', 'apple', 'grapes', 'guava', 'orange', 'lemon', 'papaya', 'pomegranate',
      'gram', 'lentil', 'chickpea', 'mustard', 'sunflower', 'groundnut', 'peanut', 'sesame',
      'barley', 'sorghum', 'millet', 'linseed', 'jute', 'tea', 'coffee', 'rubber', 'tobacco'
    ];
    
    for (final crop in englishCrops) {
      if (message.toLowerCase().contains(crop)) {
        return crop;
      }
    }
    
    return '';
  }

  void clearChat() {
    _messages.clear();
    initialize();
  }
}