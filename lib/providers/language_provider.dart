import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'), 
    Locale('mr'),
  ];
  
  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'mr': 'मराठी',
  };
  
  LanguageProvider() {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (supportedLocales.any((locale) => locale.languageCode == languageCode)) {
      _locale = Locale(languageCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
      notifyListeners();
    }
  }
  
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? 'Unknown';
  }
  
  List<Map<String, String>> getLanguageOptions() {
    return supportedLocales.map((locale) {
      return {
        'code': locale.languageCode,
        'name': languageNames[locale.languageCode] ?? locale.languageCode,
      };
    }).toList();
  }
}