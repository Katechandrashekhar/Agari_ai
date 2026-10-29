import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';

class LanguageDemo extends StatelessWidget {
  const LanguageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.appTitle ?? 'AgriAI'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Language Selection
            Text(
              l10n?.selectLanguage ?? 'Select Language',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => languageProvider.changeLanguage('en'),
                  child: Text(l10n?.english ?? 'English'),
                ),
                ElevatedButton(
                  onPressed: () => languageProvider.changeLanguage('hi'),
                  child: Text(l10n?.hindi ?? 'हिन्दी'),
                ),
                ElevatedButton(
                  onPressed: () => languageProvider.changeLanguage('mr'),
                  child: Text(l10n?.marathi ?? 'मराठी'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Dashboard elements preview
            Text('Dashboard: ${l10n?.dashboard ?? 'Dashboard'}'),
            Text('Login: ${l10n?.login ?? 'Login'}'),
            Text('Email: ${l10n?.email ?? 'Email'}'),
            Text('Password: ${l10n?.password ?? 'Password'}'),
            Text('Crop Recommendation: ${l10n?.cropRecommendation ?? 'Crop Recommendation'}'),
            Text('Disease Detection: ${l10n?.diseaseDetection ?? 'Disease Detection'}'),
            Text('Weather Info: ${l10n?.weatherInfo ?? 'Weather Information'}'),
            Text('AI Assistant: ${l10n?.chatbot ?? 'AI Assistant'}'),
            
            const SizedBox(height: 20),
            Text('Current: ${languageProvider.locale.languageCode}'),
          ],
        ),
      ),
    );
  }
}