import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../models/weather.dart';
import 'login_screen.dart';
import 'weather_screen.dart';
import 'disease_detection_screen.dart';
import 'agriai_chat_screen.dart';

import 'fertilizer_tips_screen.dart';
import 'market_price_screen.dart';
import 'fertilizer_recommendation_screen.dart';
import 'marketplace_screen.dart';
import 'soil_based_recommendation_screen.dart';
import '../models/user.dart' as app_user;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  app_user.User? _currentUser;
  Weather? _currentWeather;
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadWeatherData();
  }

  Future<void> _loadUserData() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? firebaseUser = auth.currentUser;
      
      if (firebaseUser != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        
        if (userData.exists) {
          final data = userData.data()!;
          setState(() {
            _currentUser = app_user.User(
              id: firebaseUser.uid,
              name: data['name'] ?? 'User',
              email: data['email'] ?? firebaseUser.email ?? 'user@example.com',
              phone: data['phone'] ?? '',
              soilType: data['soilType'] ?? 'Loamy',
              landAreaAcres: (data['landAreaAcres'] ?? 0.0).toDouble(),
              userType: data['userType'] ?? 'farmer',
              language: data['language'] ?? 'english',
              createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
            );
            _isLoading = false;
          });
        } else {
          print('User data not found in Firestore');
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeatherData() async {
    try {
      _currentWeather = await _apiService.fetchWeatherData('Pune');
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)?.dashboard ?? 'AgriAI Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                     
                      IconButton(
                        icon: Icon(Icons.person, color: Colors.white, size: 24),
                        onPressed: () {
                          _showProfileDialog();
                        },
                      ),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: Colors.white, size: 24),
                        onSelected: (value) async {
                          if (value == 'logout') {
                            await AuthService().signOut();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'logout',
                            child: Text(AppLocalizations.of(context)?.logout ?? 'Logout'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Welcome Card
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)?.welcome ?? 'Welcome back,',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _currentUser?.name ?? 'User',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'FARMER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.agriculture,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Info Cards Row
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickInfoCard(
                              AppLocalizations.of(context)?.weatherInfo ?? 'Weather',
                              _currentWeather != null ? '${_currentWeather!.temperature.toInt()}°C' : '26°C',
                              Icons.wb_sunny,
                              Color(0xFF2196F3),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickInfoCard(
                              AppLocalizations.of(context)?.soilType ?? 'Soil Type',
                              _currentUser?.soilType ?? 'Loamy',
                              Icons.eco,
                              Color(0xFF8BC34A),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickInfoCard(
                              'Land Area',
                              '${(_currentUser?.landAreaAcres ?? 0.0).toStringAsFixed(1)} acres',
                              Icons.grass,
                              Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Features Section
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Features',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              _buildFeatureCard(
                                'Fertilizer Tips',
                                'Find the right fertilizer for your crops',
                                Icons.science,
                                Color(0xFFFF9800),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => FertilizerTipsScreen()),
                                ),
                              ),
                              _buildFeatureCard(
                                'AI Fertilizer Recommendation',
                                'AI-powered NPK analysis & crop-specific recommendations',
                                Icons.psychology,
                                Color(0xFF4CAF50),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => FertilizerRecommendationScreen()),
                                ),
                              ),
                              _buildFeatureCard(
                                'Market Prices',
                                'Check latest crop prices in markets',
                                Icons.trending_up,
                                Color(0xFF2196F3),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MarketPriceScreen()),
                                ),
                              ),
                              _buildFeatureCard(
                                AppLocalizations.of(context)?.weatherInfo ?? 'Weather Info',
                                'Get weather updates and forecasts',
                                Icons.wb_sunny,
                                Color(0xFFFFEB3B),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => WeatherScreen()),
                                ),
                              ),
                              _buildFeatureCard(
                                AppLocalizations.of(context)?.diseaseDetection ?? 'Disease Detection',
                                'Identify crop diseases with AI',
                                Icons.local_hospital,
                                Color(0xFFF44336),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => DiseaseDetectionScreen()),
                                ),
                              ),
                              _buildFeatureCard(
                                AppLocalizations.of(context)?.cropRecommendation ?? 'Soil Based Recommendation',
                                'Get crop recommendations based on soil analysis',
                                Icons.bar_chart,
                                Color(0xFF009688),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SoilBasedRecommendationScreen()),
                                ),
                              ),
                              _buildFeatureCard(
                                'Marketplace',
                                'Buy and sell crops directly',
                                Icons.store,
                                Color(0xFF9C27B0),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MarketplaceScreen()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Recent Prices Section
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Prices',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MarketPriceScreen()),
                                ),
                                child: Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildPriceCard('Paddy(Dhan)(Common)', '₹2320/quintal', '+0.00%'),
                                _buildPriceCard('Paddy(Dhan)(Common)', '₹2340/quintal', '+0.00%'),
                                _buildPriceCard('Potato', '₹2100/quintal', '+0.00%'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Weather Today
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.weatherInfo ?? 'Weather Today',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => WeatherScreen()),
                                ),
                                child: Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _currentWeather != null 
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _currentWeather!.weatherIcon,
                                            style: TextStyle(fontSize: 40),
                                          ),
                                          SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${_currentWeather!.temperature.toInt()}°C',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                _currentWeather!.weatherCondition,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Humidity: ${_currentWeather!.humidity.toInt()}%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.lightbulb, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _currentWeather!.farmingAdvice,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.wb_sunny, color: Colors.white, size: 40),
                                          SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '26°C',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'scattered clouds',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Humidity: 68%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.lightbulb, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Good weather conditions for farming activities.',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Farming Tips
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Farming Tips',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildFarmingTip(
                            'Soil Health',
                            'Test your soil pH regularly for optimal crop growth',
                            Icons.eco,
                          ),
                          _buildFarmingTip(
                            'Water Management',
                            'Use drip irrigation to conserve water and improve yield',
                            Icons.water_drop,
                          ),
                          _buildFarmingTip(
                            'Crop Rotation',
                            'Rotate crops to maintain soil fertility and reduce pests',
                            Icons.autorenew,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgriAIChatScreen()),
          );
        },
        icon: Icon(Icons.chat, color: Colors.white),
        label: Text('${AppLocalizations.of(context)?.chatbot ?? 'AI Assistant'} 🤖', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildQuickInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (value.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(String crop, String price, String change) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            crop,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Text(
            price,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Color(0xFF4CAF50),
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmingTip(String title, String description, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF4CAF50), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show profile edit dialog
  void _showProfileDialog() {
    final TextEditingController nameController = TextEditingController(text: _currentUser?.name ?? '');
    final TextEditingController phoneController = TextEditingController(text: _currentUser?.phone ?? '');
    final TextEditingController landAreaController = TextEditingController(text: _currentUser?.landAreaAcres.toString() ?? '5.0');
    
    String selectedSoilType = _currentUser?.soilType ?? 'Loamy';
    
    final List<String> soilTypes = [
      'Alluvial',
      'Black',
      'Red',
      'Laterite',
      'Desert',
      'Mountain',
      'Loamy',
      'Sandy',
      'Clay',
      'Peaty',
      'Saline',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.person, color: Color(0xFF4CAF50)),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)?.edit ?? 'Edit Profile'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.fullName ?? 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.phoneNumber ?? 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSoilType,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.soilType ?? 'Soil Type',
                        prefixIcon: Icon(Icons.terrain),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: soilTypes.map((soil) {
                        return DropdownMenuItem(
                          value: soil,
                          child: Text(soil),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSoilType = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: landAreaController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Land Area (Acres)',
                        prefixIcon: Icon(Icons.landscape_outlined),
                        suffixText: 'acres',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _updateProfile(
                      nameController.text,
                      phoneController.text,
                      selectedSoilType,
                      double.tryParse(landAreaController.text) ?? 5.0,
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)?.save ?? 'Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Update user profile
  Future<void> _updateProfile(String name, String phone, String soilType, double landArea) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? firebaseUser = auth.currentUser;
      
      if (firebaseUser != null) {
        // Update in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .update({
          'name': name,
          'phone': phone,
          'soilType': soilType,
          'landAreaAcres': landArea,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update local user object
        setState(() {
          _currentUser = app_user.User(
            id: firebaseUser.uid,
            name: name,
            email: _currentUser?.email ?? firebaseUser.email ?? 'user@example.com',
            phone: phone,
            soilType: soilType,
            landAreaAcres: landArea,
            userType: _currentUser?.userType ?? 'farmer',
            language: _currentUser?.language ?? 'english',
            createdAt: _currentUser?.createdAt ?? DateTime.now(),
          );
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}