class DynamicResponseHelper {
  static List<String> hindiGreetings = [
    'आप का स्वागत है!', 
    'दोस्त, मैं यहाँ हूँ!', 
    'बहुत खुशी हुई!', 
    'हाँ भाई, बताइए!', 
    'जरूर मदद करूंगा!',
    'ये भी कोई बात है!',
    'बिल्कुल ठीक सवाल!',
    'चलिए बात करते हैं!'
  ];
  
  static List<String> englishGreetings = [
    'Great to help you!', 
    'I\'m here for you!', 
    'Happy to assist!', 
    'Sure, let me help!', 
    'Absolutely, tell me more!',
    'Perfect question!',
    'Let\'s talk farming!',
    'Ready to assist!'
  ];
  
  static List<String> hindiProblemResponses = [
    'अरे हाँ! समस्या है क्या?',
    'हम्म, कोई दिक्कत दिख रही है?', 
    'जी हाँ! मैं समझ गया',
    'ओके! क्या हो रहा है?',
    'अरे यार! कुछ गड़बड़ है?',
    'हाँ हाँ! बताओ क्या बात है'
  ];
  
  static List<String> englishProblemResponses = [
    'Oh! What\'s the issue?',
    'Hmm, some problem?', 
    'Sure! I understand',
    'Okay! What\'s happening?',
    'Oh no! Something wrong?',
    'Yes yes! Tell me more'
  ];
  
  static List<String> hindiEncouragements = [
    'घबराने की जरूरत नहीं!',
    'समाधान मिल जाएगा!',
    'बस थोड़ा धैर्य रखें!',
    'सब ठीक हो जाएगा!',
    'मैं हूं ना!',
    'चिंता मत करें!'
  ];
  
  static List<String> englishEncouragements = [
    'Don\'t worry!',
    'Solution will be found!',
    'Just be patient!',
    'Everything will be fine!',
    'I\'m here to help!',
    'No need to stress!'
  ];
  
  static String getRandomGreeting(bool isHindi) {
    final greetings = isHindi ? hindiGreetings : englishGreetings;
    return greetings[DateTime.now().millisecondsSinceEpoch % greetings.length];
  }
  
  static String getRandomProblemResponse(bool isHindi) {
    final responses = isHindi ? hindiProblemResponses : englishProblemResponses;
    return responses[(DateTime.now().second + DateTime.now().minute) % responses.length];
  }
  
  static String getRandomEncouragement(bool isHindi) {
    final encouragements = isHindi ? hindiEncouragements : englishEncouragements;
    return encouragements[DateTime.now().hour % encouragements.length];
  }
  
  static String getContextualIntro(bool isHindi) {
    final intros = isHindi 
      ? ['जी हाँ भाई!', 'आपका खुद का खेती का साथी!', 'जय किसान!', 'खेती का मामला हो तो मैं हूं ना!']
      : ['Hey farmer friend!', 'Your agriculture buddy here!', 'Ready to help with farming!', 'Agriculture expert at service!'];
    return intros[DateTime.now().millisecondsSinceEpoch % intros.length];
  }
  
  static List<String> getPersonalizedTips(bool isHindi) {
    return isHindi 
      ? [
          'प्रो टिप: हमेशा मिट्टी जांच कराएं!',
          'याद रखें: सही समय पर पानी देना जरूरी है!', 
          'सुझाव: जैविक खाद का भी इस्तेमाल करें!',
          'टिप: रोग से बचाव इलाज से बेहतर है!',
          'सलाह: मौसम की जानकारी रोज लें!'
        ]
      : [
          'Pro tip: Always get soil tested!',
          'Remember: Right timing for water is crucial!',
          'Suggestion: Use organic fertilizers too!', 
          'Tip: Prevention is better than cure!',
          'Advice: Check weather daily!'
        ];
  }
}