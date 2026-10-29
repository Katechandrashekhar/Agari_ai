import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'screens/crop_suggestion_screen.dart';
import 'screens/fertilizer_tips_screen.dart';
import 'screens/fertilizer_recommendation_screen.dart';
import 'screens/market_price_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/marketplace_screen.dart';
import 'services/crop_recommendation_service.dart';
import 'screens/soil_based_recommendation_screen.dart';
import 'screens/disease_detection_screen.dart';
import 'services/ai_chatbot_service.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  
  try {
   
    debugPrint('Firebase AppCheck disabled temporarily - will work without it');
  } catch (e) {
    // Handle App Check initialization errors gracefully
    debugPrint('Firebase AppCheck initialization failed: $e');
    debugPrint('App will continue without App Check. This is normal in development.');
  }
  
  // Initialize services
  final cropRecommendationService = CropRecommendationService();
  await cropRecommendationService.initialize();
  
  runApp(const AgriAIApp());
}
class AgriAIApp extends StatelessWidget {
  const AgriAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => AIChatbotService()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'AgriAI - Smart Farming Assistant',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.locale,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            home: Consumer<AuthService>(
              builder: (context, authService, child) {
                return authService.isSignedIn 
                    ? DashboardScreen()
                    : const LoginScreen();
              },
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/dashboard': (context) => DashboardScreen(),
              '/crop-suggestions': (context) => const CropSuggestionScreen(),
              '/fertilizer-tips': (context) => const FertilizerTipsScreen(),
              '/fertilizer-recommendation': (context) => const FertilizerRecommendationScreen(),
              '/market-price': (context) => const MarketPriceScreen(),
              '/weather': (context) => const WeatherScreen(),
              '/marketplace': (context) => const MarketplaceScreen(),
              '/soil-recommendation': (context) => const SoilBasedRecommendationScreen(),
              '/disease-detection': (context) => const DiseaseDetectionScreen(),
            },
          );
        },
      ),
    );
  }
}
