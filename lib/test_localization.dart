import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';

class LocalizationTestPage extends StatelessWidget {
  const LocalizationTestPage({super.key});

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.welcome ?? 'Welcome to AgriAI',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Text(
              l10n?.selectLanguage ?? 'Select Language',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            
            // Language selector buttons
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
            
            // Sample localized text
            Text('Dashboard: ${l10n?.dashboard ?? 'Dashboard'}'),
            Text('Login: ${l10n?.login ?? 'Login'}'),
            Text('Email: ${l10n?.email ?? 'Email'}'),
            Text('Password: ${l10n?.password ?? 'Password'}'),
          ],
        ),
      ),
    );
  }
}