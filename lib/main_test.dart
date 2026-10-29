import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'test_localization.dart';

void main() {
  runApp(const LocalizationTestApp());
}

class LocalizationTestApp extends StatelessWidget {
  const LocalizationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'AgriAI Localization Test',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.locale,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            home: const LocalizationTestPage(),
          );
        },
      ),
    );
  }
}