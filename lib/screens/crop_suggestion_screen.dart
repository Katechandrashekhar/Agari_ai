import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crop.dart';
import '../models/user.dart' as app_user;
import '../models/weather.dart';
import '../services/api_service.dart';
import '../widgets/crop_card.dart';

/// Crop suggestion screen for AgriAI app
/// Provides crop recommendations based on soil type, weather, and user preferences
class CropSuggestionScreen extends StatefulWidget {
  const CropSuggestionScreen({super.key});

  @override
  State<CropSuggestionScreen> createState() => _CropSuggestionScreenState();
}

class _CropSuggestionScreenState extends State<CropSuggestionScreen> {
  final ApiService _apiService = ApiService();

  List<Crop> _allCrops = [];
  List<Crop> _recommendedCrops = [];
  List<Crop> _filteredCrops = [];
  app_user.User? _currentUser;
  Weather? _currentWeather;
  bool _isLoading = true;
  // Selected values
  String _selectedSoilType = 'alluvial';
  String _selectedSeason = '';
  double _temperature = 25.0;
  double _rainfall = 100.0;

  final List<String> _soilTypes = [
    'alluvial',
    'black', 
    'red',
    'laterite',
    'desert',
    'mountain',
    'loamy',
    'sandy',
    'clay',
    'peaty',
    'saline',
    'alkaline',
    'coastal',
    'volcanic',
  ];

  final List<String> _seasons = [
    'kharif',
    'rabi',
    'summer',
    'zaid',
    'perennial',
    'winter',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load crops and user data
  Future<void> _loadData() async {
    try {
      // Load actual user data from Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userData.exists) {
          final data = userData.data()!;
          _currentUser = app_user.User(
            id: user.uid,
            name: data['name'] ?? 'Demo User',
            email: data['email'] ?? user.email ?? 'demo@example.com',
            phone: data['phone'] ?? '1234567890',
            soilType: data['soilType'] ?? 'Loamy',
            landAreaAcres: (data['landAreaAcres'] ?? 5.0).toDouble(),
            userType: data['userType'] ?? 'farmer',
            language: data['language'] ?? 'english',
            createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
          );
        } else {
          // Fallback to demo user if no data found
          _currentUser = app_user.User(
            id: user.uid,
            name: 'Demo User',
            email: user.email ?? 'demo@example.com',
            phone: '1234567890',
            soilType: 'Loamy',
            landAreaAcres: 5.0,
            userType: 'farmer',
            language: 'english',
            createdAt: DateTime.now(),
          );
        }
      } else {
        // Fallback to demo user if not logged in
        _currentUser = app_user.User(
          id: 'demo_user',
          name: 'Demo User',
          email: 'demo@example.com',
          phone: '1234567890',
          soilType: 'Loamy',
          landAreaAcres: 5.0,
          userType: 'farmer',
          language: 'english',
          createdAt: DateTime.now(),
        );
      }

      // Load weather data
      try {
        _currentWeather = await _apiService.fetchWeatherData('Bangalore');
      } catch (e) {
        print('Error loading weather: $e');
        // Demo weather data if API fails
        _currentWeather = Weather(
          id: 'demo_weather_1',
          location: 'Bangalore',
          temperature: 25.0,
          humidity: 65,
          rainfall: 100.0,
          windSpeed: 10.0,
          weatherCondition: 'partly_cloudy',
          date: DateTime.now(),
          minTemperature: 20.0,
          maxTemperature: 30.0,
          uvIndex: 5,
          pressure: 1013.0,
          description: 'Partly Cloudy',
        );
      }

      // Load real crops from API
      try {
        _allCrops = await _apiService.fetchCrops();
        if (_allCrops.isEmpty) {
          print('No crops loaded from API, using enhanced crop database');
          // API returns enhanced crop database as fallback
        }
        print('Loaded ${_allCrops.length} crops from API');
      } catch (e) {
        print('Error loading crops from API: $e');
        // API service will return enhanced crop database as fallback
        _allCrops = await _apiService.fetchCrops();
      }

      // Set initial values with extra safety checks
      String userSoilType = (_currentUser?.soilType ?? 'alluvial').toLowerCase().trim();
      // Ensure the value is valid, otherwise default to 'alluvial'
      _selectedSoilType = _soilTypes.contains(userSoilType) ? userSoilType : 'alluvial';
      _temperature = _currentWeather?.temperature ?? 25.0;
      _rainfall = _currentWeather?.rainfall ?? 100.0;

      // Generate recommendations
      _generateRecommendations();
    } catch (e) {
      print('Error loading data: $e');
      // Ensure we have crop data from API service (it has enhanced database)
      if (_allCrops.isEmpty) {
        _allCrops = await _apiService.fetchCrops();
      }
      _generateRecommendations();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Generate crop recommendations using real-time API data
  void _generateRecommendations() {
    _recommendedCrops = _allCrops.where((crop) {
      return crop.isSuitableFor(
        soilType: _selectedSoilType,
        temperature: _temperature,
        rainfall: _rainfall,
      );
    }).toList();

    // Sort by growth duration (shorter duration first)
    _recommendedCrops.sort((a, b) => a.growthDuration.compareTo(b.growthDuration));

    // Sort by growth duration for better recommendations
    _recommendedCrops.sort((a, b) => a.growthDuration.compareTo(b.growthDuration));

    _filteredCrops = List.from(_recommendedCrops);
  }

  /// Generate enhanced recommendations using API
  Future<void> _generateEnhancedRecommendations() async {
    try {
      setState(() => _isLoading = true);
      
      // Get crops suited for current conditions from API
      final suitableCrops = await _apiService.fetchCropsForConditions(
        soilType: _selectedSoilType,
        season: _selectedSeason,
        temperature: _temperature,
        rainfall: _rainfall,
      );
      
      if (suitableCrops.isNotEmpty) {
        _allCrops = suitableCrops;
        _generateRecommendations();
      }
    } catch (e) {
      print('Error generating enhanced recommendations: $e');
      // Fall back to regular recommendations
      _generateRecommendations();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Filter crops by season
  void _filterBySeason() {
    if (_selectedSeason.isEmpty) {
      _filteredCrops = List.from(_recommendedCrops);
    } else {
      _filteredCrops = _recommendedCrops
          .where((crop) => crop.season.toLowerCase() == _selectedSeason.toLowerCase())
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Suggestion'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Current conditions header
                  _buildConditionsHeader(),
                  
                  // Filters section
                  _buildFiltersSection(),
                  
                  // Recommendations section
                  _buildRecommendationsSection(),
                ],
              ),
            ),
    );
  }

  /// Build current conditions header
  Widget _buildConditionsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Conditions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildConditionItem(
                  '🌱',
                  'Soil Type',
                  _selectedSoilType.toUpperCase(),
                ),
              ),
              Expanded(
                child: _buildConditionItem(
                  '🌡️',
                  'Temperature',
                  '${_temperature.toInt()}°C',
                ),
              ),
              Expanded(
                child: _buildConditionItem(
                  '🌧️',
                  'Rainfall',
                  '${_rainfall.toInt()}mm',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build condition item
  Widget _buildConditionItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build filters section
  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adjust Parameters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Soil type dropdown
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _soilTypes.contains(_selectedSoilType) ? _selectedSoilType : null,
                  decoration: InputDecoration(
                    labelText: 'Soil Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  items: _soilTypes.map((soil) {
                    return DropdownMenuItem(
                      value: soil,
                      child: Text(soil.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSoilType = value!;
                    });
                    _generateEnhancedRecommendations();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedSeason.isEmpty ? null : _selectedSeason,
                  decoration: InputDecoration(
                    labelText: 'Season (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('All Seasons'),
                    ),
                    ..._seasons.map((season) {
                      return DropdownMenuItem(
                        value: season,
                        child: Text(season.toUpperCase()),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSeason = value ?? '';
                      _filterBySeason();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Temperature slider
          Text('Temperature: ${_temperature.toInt()}°C'),
          Slider(
            value: _temperature,
            min: 10.0,
            max: 45.0,
            divisions: 35,
            label: '${_temperature.toInt()}°C',
            onChanged: (value) {
              setState(() {
                _temperature = value;
                _generateRecommendations();
                _filterBySeason();
              });
            },
          ),
          
          // Rainfall slider
          Text('Rainfall: ${_rainfall.toInt()}mm'),
          Slider(
            value: _rainfall,
            min: 0.0,
            max: 300.0,
            divisions: 30,
            label: '${_rainfall.toInt()}mm',
            onChanged: (value) {
              setState(() {
                _rainfall = value;
                _generateRecommendations();
                _filterBySeason();
              });
            },
          ),
        ],
      ),
    );
  }

  /// Build recommendations section
  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended Crops',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_filteredCrops.length} crops',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        if (_filteredCrops.isEmpty) ...[
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.orange[400]),
                const SizedBox(height: 12),
                Text(
                  'No crops found for current conditions',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting the soil type, temperature, or rainfall parameters.',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredCrops.length,
            itemBuilder: (context, index) {
              final crop = _filteredCrops[index];
              return CropCard(
                crop: crop,
                showRecommendation: true,
                onTap: () => _showCropDetails(crop),
              );
            },
          ),
        ],
      ],
    );
  }

  /// Show detailed crop information
  void _showCropDetails(Crop crop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(crop.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(crop.description),
                const SizedBox(height: 16),
                Text(
                  'Details:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Season: ${crop.season.toUpperCase()}'),
                Text('Soil Type: ${crop.soilType.toUpperCase()}'),
                Text('Growth Duration: ${crop.growthDuration} days'),
                Text('Temperature Range: ${crop.minTemperature.toInt()}-${crop.maxTemperature.toInt()}°C'),
                Text('Rainfall Range: ${crop.minRainfall.toInt()}-${crop.maxRainfall.toInt()}mm'),
                Text('Recommended Fertilizer: ${crop.recommendedFertilizer}'),
                const SizedBox(height: 16),
                if (crop.benefits.isNotEmpty) ...[
                  const Text(
                    'Benefits:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...crop.benefits.map((benefit) => Text('• $benefit')),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${crop.name} added to your preferred crops!'),
                    backgroundColor: Colors.green[600],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Add to Preferences'),
            ),
          ],
        );
      },
    );
  }
}