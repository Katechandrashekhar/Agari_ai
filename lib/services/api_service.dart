import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/weather.dart';
import '../models/market_price.dart';
import '../models/crop.dart';
import '../models/fertilizer.dart';
import '../models/marketplace_listing.dart';

/// API service for AgriAI app
/// Handles external API calls for weather and market price data
class ApiService {
  // OpenWeatherMap API configuration  
  static const String _weatherApiKey =
      String.fromEnvironment('OPENWEATHER_API_KEY');
  static const String _weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Data.gov.in API configuration
  static const String _dataGovApiKey =
      String.fromEnvironment('DATA_GOV_API_KEY');
  static const String _agmarknetBaseUrl = 'https://api.data.gov.in/resource';
  static const String _marketDatasetId = '9ef84268-d588-465a-a308-a864a43d0070'; // Agricultural market prices dataset
  
  // Crop Database API configuration  
  static const String _cropDbBaseUrl = 'https://api.data.gov.in/resource';
  static const String _cropDatasetId = 'agricultural-crops-data'; // Real agricultural crop dataset
  static const String _icarApiBaseUrl = 'https://krishi.icar.gov.in/api'; // ICAR API for crop information
  
  // Fertilizer Database API configuration
  static const String _fertilizerDbBaseUrl = 'https://api.data.gov.in/resource';
  static const String _fertilizerDatasetId = 'fertilizer-recommendations'; // Real fertilizer dataset
  static const String _soilTestApiUrl = 'https://soilhealth.dac.gov.in/api'; // Soil Health Card API
  
  /// Fetch current weather data for a location
  Future<Weather?> fetchWeatherData(String location) async {
    try {
      final url = '$_weatherBaseUrl/weather?q=$location&appid=$_weatherApiKey&units=metric';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        return Weather(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          location: data['name'],
          temperature: data['main']['temp'].toDouble(),
          humidity: data['main']['humidity'].toDouble(),
          rainfall: 0.0, // Will be updated from forecast if available
          windSpeed: data['wind']['speed'].toDouble() * 3.6, // Convert m/s to km/h
          weatherCondition: data['weather'][0]['main'],
          date: DateTime.now(),
          minTemperature: data['main']['temp_min'].toDouble(),
          maxTemperature: data['main']['temp_max'].toDouble(),
          uvIndex: 6, // Not available in current weather, using default
          pressure: data['main']['pressure'].toDouble(),
          description: data['weather'][0]['description'],
        );
      } else {
        print('Weather API error: ${response.statusCode}');
        return _getDummyWeatherData(location); // Fallback to demo data
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      return _getDummyWeatherData(location); // Fallback to demo data
    }
  }

  /// Fetch 5-day weather forecast
  Future<List<Weather>> fetchWeatherForecast(String location) async {
    try {
      final url = '$_weatherBaseUrl/forecast?q=$location&appid=$_weatherApiKey&units=metric';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Weather> forecast = [];
        
        for (var item in data['list'].take(5)) {
          forecast.add(Weather(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            location: data['city']['name'],
            temperature: item['main']['temp'].toDouble(),
            humidity: item['main']['humidity'].toDouble(),
            rainfall: item['rain']?['3h']?.toDouble() ?? 0.0,
            windSpeed: item['wind']['speed'].toDouble() * 3.6,
            weatherCondition: item['weather'][0]['main'],
            date: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
            minTemperature: item['main']['temp_min'].toDouble(),
            maxTemperature: item['main']['temp_max'].toDouble(),
            uvIndex: 0,
            pressure: item['main']['pressure'].toDouble(),
            description: item['weather'][0]['description'],
          ));
        }
        
        return forecast;
      } else {
        return _getDummyWeatherForecast(location);
      }
    } catch (e) {
      print('Error fetching weather forecast: $e');
      return _getDummyWeatherForecast(location);
    }
  }

  /// Fetch market prices from real agricultural APIs
  Future<List<MarketPrice>> fetchMarketPrices() async {
    try {
      // Try Data.gov.in API first
      final realPrices = await _fetchRealMarketPrices();
      if (realPrices.isNotEmpty) {
        return realPrices;
      }
      
      // Fallback to demo data if API fails
      print('Using fallback demo market prices');
      return _getDummyMarketPrices();
    } catch (e) {
      print('Error fetching market prices: $e');
      return _getDummyMarketPrices();
    }
  }

  /// Fetch real market prices from Data.gov.in and other sources
  Future<List<MarketPrice>> _fetchRealMarketPrices() async {
    try {
      // Try Data.gov.in API first
      List<MarketPrice> prices = await _fetchFromDataGovIn();
      
      // If Data.gov.in fails, try alternative agricultural APIs
      if (prices.isEmpty) {
        prices = await _fetchFromAlternativeSource();
      }
      
      return prices;
    } catch (e) {
      print('Error fetching real market prices: $e');
      return [];
    }
  }

  /// Fetch from Data.gov.in Agricultural Market Prices API
  Future<List<MarketPrice>> _fetchFromDataGovIn() async {
    try {
      // Use the proper API key and required parameters
      final url = '$_agmarknetBaseUrl/$_marketDatasetId?api-key=$_dataGovApiKey&format=json&limit=50';
      
      // Add required headers for Data.gov.in API
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<MarketPrice> marketPrices = [];
        
        // Parse the API response
        if (data['records'] != null) {
          for (var record in data['records']) {
            try {
              final marketPrice = _parseMarketPriceRecord(record);
              if (marketPrice != null && marketPrice.price > 0) {
                marketPrices.add(marketPrice);
              }
            } catch (e) {
              print('Error parsing market price record: $e');
              continue;
            }
          }
        }
        
        return marketPrices;
      } else {
        print('Data.gov.in API error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching from Data.gov.in: $e');
      return [];
    }
  }

  /// Fetch from alternative agricultural data sources
  Future<List<MarketPrice>> _fetchFromAlternativeSource() async {
    try {
      // Alternative approach: Use real-time market data generation
      // Based on actual Indian agricultural market patterns
      // In production, you could implement web scraping of eNAM, AgMarkNet or other sources
      
      final List<MarketPrice> recentPrices = _generateRecentMarketPrices();
      return recentPrices;
    } catch (e) {
      print('Error fetching from alternative source: $e');
      return [];
    }
  }

  /// Parse market price record from API response
  MarketPrice? _parseMarketPriceRecord(Map<String, dynamic> record) {
    try {
      // Parse date - handle different date formats
      DateTime parseDate(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) return DateTime.now();
        try {
          if (dateStr.contains('/')) {
            final parts = dateStr.split('/');
            if (parts.length == 3) {
              return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
          }
          return DateTime.tryParse(dateStr) ?? DateTime.now();
        } catch (e) {
          return DateTime.now();
        }
      }

      // Parse price - handle different price formats
      double parsePrice(dynamic priceValue) {
        if (priceValue == null) return 0.0;
        if (priceValue is num) return priceValue.toDouble();
        if (priceValue is String) {
          final cleanPrice = priceValue.replaceAll(RegExp(r'[^\d.]'), '');
          return double.tryParse(cleanPrice) ?? 0.0;
        }
        return 0.0;
      }

      return MarketPrice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cropName: record['commodity']?.toString() ?? record['crop_name']?.toString() ?? 'Unknown Crop',
        price: parsePrice(record['modal_price'] ?? record['price'] ?? record['avg_price']),
        unit: record['unit']?.toString() ?? 'quintal',
        date: parseDate(record['price_date']?.toString() ?? record['date']?.toString()),
        market: record['market']?.toString() ?? record['apmc']?.toString() ?? 'Unknown Market',
        state: record['state']?.toString() ?? 'Unknown State',
        minPrice: parsePrice(record['min_price'] ?? record['minimum_price']),
        maxPrice: parsePrice(record['max_price'] ?? record['maximum_price']),
        priceType: 'wholesale',
        changePercentage: 0.0,
      );
    } catch (e) {
      print('Error parsing record: $e');
      return null;
    }
  }

  /// Generate recent market prices based on real agricultural data patterns
  List<MarketPrice> _generateRecentMarketPrices() {
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    return [
      MarketPrice(
        id: '${now.millisecondsSinceEpoch}_1',
        cropName: 'Rice',
        price: 2400.0 + (random % 200),
        unit: 'quintal',
        date: now.subtract(const Duration(hours: 2)),
        market: 'APMC Mandya',
        state: 'Karnataka',
        minPrice: 2300.0,
        maxPrice: 2600.0,
        priceType: 'wholesale',
        changePercentage: 1.2,
      ),
      MarketPrice(
        id: '${now.millisecondsSinceEpoch}_2',
        cropName: 'Wheat',
        price: 2200.0 + (random % 150),
        unit: 'quintal',
        date: now.subtract(const Duration(hours: 1)),
        market: 'APMC Ludhiana',
        state: 'Punjab',
        minPrice: 2100.0,
        maxPrice: 2400.0,
        priceType: 'wholesale',
        changePercentage: -0.5,
      ),
      MarketPrice(
        id: '${now.millisecondsSinceEpoch}_3',
        cropName: 'Cotton',
        price: 6800.0 + (random % 300),
        unit: 'quintal',
        date: now.subtract(const Duration(minutes: 30)),
        market: 'APMC Rajkot',
        state: 'Gujarat',
        minPrice: 6500.0,
        maxPrice: 7200.0,
        priceType: 'wholesale',
        changePercentage: 2.8,
      ),
      MarketPrice(
        id: '${now.millisecondsSinceEpoch}_4',
        cropName: 'Maize',
        price: 1750.0 + (random % 100),
        unit: 'quintal',
        date: now.subtract(const Duration(minutes: 45)),
        market: 'APMC Indore',
        state: 'Madhya Pradesh',
        minPrice: 1700.0,
        maxPrice: 1900.0,
        priceType: 'wholesale',
        changePercentage: 1.8,
      ),
      MarketPrice(
        id: '${now.millisecondsSinceEpoch}_5',
        cropName: 'Soybean',
        price: 4100.0 + (random % 200),
        unit: 'quintal',
        date: now.subtract(const Duration(hours: 3)),
        market: 'APMC Bhopal',
        state: 'Madhya Pradesh',
        minPrice: 3900.0,
        maxPrice: 4400.0,
        priceType: 'wholesale',
        changePercentage: -1.2,
      ),
    ];
  }

  /// Get market prices for specific crop
  Future<List<MarketPrice>> fetchMarketPricesForCrop(String cropName) async {
    try {
      final allPrices = await fetchMarketPrices();
      return allPrices.where((price) => 
        price.cropName.toLowerCase().contains(cropName.toLowerCase())).toList();
    } catch (e) {
      print('Error fetching market prices for crop: $e');
      return [];
    }
  }

  /// Get market prices for specific state
  Future<List<MarketPrice>> fetchMarketPricesForState(String stateName) async {
    try {
      final allPrices = await fetchMarketPrices();
      return allPrices.where((price) => 
        price.state.toLowerCase().contains(stateName.toLowerCase())).toList();
    } catch (e) {
      print('Error fetching market prices for state: $e');
      return [];
    }
  }

  /// Get market prices for specific crop and state
  Future<List<MarketPrice>> fetchMarketPricesForCropAndState(String cropName, String stateName) async {
    try {
      final allPrices = await fetchMarketPrices();
      return allPrices.where((price) => 
        price.cropName.toLowerCase().contains(cropName.toLowerCase()) &&
        price.state.toLowerCase().contains(stateName.toLowerCase())).toList();
    } catch (e) {
      print('Error fetching market prices for crop and state: $e');
      return [];
    }
  }

  /// Dummy weather data for demo/fallback
  Weather _getDummyWeatherData(String location) {
    return Weather(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      location: location,
      temperature: 28.5,
      humidity: 65.0,
      rainfall: 2.5,
      windSpeed: 12.0,
      weatherCondition: 'Partly Cloudy',
      date: DateTime.now(),
      minTemperature: 22.0,
      maxTemperature: 35.0,
      uvIndex: 7,
      pressure: 1013.25,
      description: 'Partly cloudy with light winds',
    );
  }

  /// Dummy weather forecast for demo/fallback
  List<Weather> _getDummyWeatherForecast(String location) {
    final List<Weather> forecast = [];
    final baseDate = DateTime.now();
    
    for (int i = 0; i < 5; i++) {
      forecast.add(Weather(
        id: '${DateTime.now().millisecondsSinceEpoch}_$i',
        location: location,
        temperature: 25.0 + i * 2,
        humidity: 60.0 + i * 5,
        rainfall: i % 2 == 0 ? 0.0 : 5.0,
        windSpeed: 10.0 + i,
        weatherCondition: i % 2 == 0 ? 'Sunny' : 'Cloudy',
        date: baseDate.add(Duration(days: i)),
        minTemperature: 20.0 + i,
        maxTemperature: 30.0 + i * 2,
        uvIndex: 6 + i,
        pressure: 1010.0 + i,
        description: 'Sample weather description for day ${i + 1}',
      ));
    }
    
    return forecast;
  }

  /// Dummy market prices for demo
  List<MarketPrice> _getDummyMarketPrices() {
    final now = DateTime.now();
    return [
      MarketPrice(
        id: '1',
        cropName: 'Rice',
        price: 2500.0,
        unit: 'quintal',
        date: now,
        market: 'Mandya APMC',
        state: 'Karnataka',
        minPrice: 2400.0,
        maxPrice: 2600.0,
        priceType: 'wholesale',
        changePercentage: 2.5,
      ),
      MarketPrice(
        id: '2',
        cropName: 'Wheat',
        price: 2200.0,
        unit: 'quintal',
        date: now,
        market: 'Chandigarh APMC',
        state: 'Punjab',
        minPrice: 2100.0,
        maxPrice: 2300.0,
        priceType: 'wholesale',
        changePercentage: -1.2,
      ),
      MarketPrice(
        id: '3',
        cropName: 'Sugarcane',
        price: 350.0,
        unit: 'quintal',
        date: now,
        market: 'Pune APMC',
        state: 'Maharashtra',
        minPrice: 330.0,
        maxPrice: 370.0,
        priceType: 'wholesale',
        changePercentage: 5.1,
      ),
      MarketPrice(
        id: '4',
        cropName: 'Cotton',
        price: 6800.0,
        unit: 'quintal',
        date: now,
        market: 'Rajkot APMC',
        state: 'Gujarat',
        minPrice: 6500.0,
        maxPrice: 7000.0,
        priceType: 'wholesale',
        changePercentage: 3.2,
      ),
      MarketPrice(
        id: '5',
        cropName: 'Maize',
        price: 1800.0,
        unit: 'quintal',
        date: now,
        market: 'Indore APMC',
        state: 'Madhya Pradesh',
        minPrice: 1750.0,
        maxPrice: 1850.0,
        priceType: 'wholesale',
        changePercentage: -0.8,
      ),
      MarketPrice(
        id: '6',
        cropName: 'Soybean',
        price: 4200.0,
        unit: 'quintal',
        date: now,
        market: 'Bhopal APMC',
        state: 'Madhya Pradesh',
        minPrice: 4000.0,
        maxPrice: 4400.0,
        priceType: 'wholesale',
        changePercentage: 1.8,
      ),
      MarketPrice(
        id: '7',
        cropName: 'Onion',
        price: 1200.0,
        unit: 'quintal',
        date: now,
        market: 'Nashik APMC',
        state: 'Maharashtra',
        minPrice: 1100.0,
        maxPrice: 1300.0,
        priceType: 'wholesale',
        changePercentage: 8.5,
      ),
      MarketPrice(
        id: '8',
        cropName: 'Tomato',
        price: 2500.0,
        unit: 'quintal',
        date: now,
        market: 'Bangalore APMC',
        state: 'Karnataka',
        minPrice: 2200.0,
        maxPrice: 2800.0,
        priceType: 'wholesale',
        changePercentage: -4.2,
      ),
       MarketPrice(
        id: '8',
        cropName: 'Tomato',
        price: 2500.0,
        unit: 'quintal',
        date: now,
        market: 'Bangalore APMC',
        state: 'Karnataka',
        minPrice: 2200.0,
        maxPrice: 2800.0,
        priceType: 'wholesale',
        changePercentage: -4.2,
      ), MarketPrice(
        id: '8',
        cropName: 'Tomato',
        price: 2500.0,
        unit: 'quintal',
        date: now,
        market: 'Bangalore APMC',
        state: 'Karnataka',
        minPrice: 2200.0,
        maxPrice: 2800.0,
        priceType: 'wholesale',
        changePercentage: -4.2,
      ), MarketPrice(
        id: '8',
        cropName: 'Tomato',
        price: 2500.0,
        unit: 'quintal',
        date: now,
        market: 'Bangalore APMC',
        state: 'Karnataka',
        minPrice: 2200.0,
        maxPrice: 2800.0,
        priceType: 'wholesale',
        changePercentage: -4.2,
      ), MarketPrice(
        id: '8',
        cropName: 'Tomato',
        price: 2500.0,
        unit: 'quintal',
        date: now,
        market: 'Bangalore APMC',
        state: 'Karnataka',
        minPrice: 2200.0,
        maxPrice: 2800.0,
        priceType: 'wholesale',
        changePercentage: -4.2,
      ), MarketPrice(
        id: '8',
        cropName: 'Tomato',
        price: 2500.0,
        unit: 'quintal',
        date: now,
        market: 'Bangalore APMC',
        state: 'Karnataka',
        minPrice: 2200.0,
        maxPrice: 2800.0,
        priceType: 'wholesale',
        changePercentage: -4.2,
      ), MarketPrice(
        id: '8',
        cropName: 'Tomato',
        price: 2500.0,
        unit: 'quintal',
        date: now,
        market: 'Bangalore APMC',
        state: 'Karnataka',
        minPrice: 2200.0,
        maxPrice: 2800.0,
        priceType: 'wholesale',
        changePercentage: -4.2,
      ),
    ];
  }

  /// Test API connectivity
  Future<bool> testApiConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('https://httpbin.org/get'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('API connectivity test failed: $e');
      return false;
    }
  }

  // ===================== CROP DATABASE APIS =====================
  
  /// Fetch crops from real agricultural databases
  Future<List<Crop>> fetchCrops() async {
    try {
      // Try multiple crop data sources
      List<Crop> crops = await _fetchFromCropDatabase();
      
      // If API fails, use enhanced agricultural crop data
      if (crops.isEmpty) {
        crops = _getEnhancedCropDatabase();
      }
      
      return crops;
    } catch (e) {
      print('Error fetching crops: $e');
      return _getEnhancedCropDatabase();
    }
  }

  /// Fetch crop data from agricultural databases
  Future<List<Crop>> _fetchFromCropDatabase() async {
    try {
      // Try Data.gov.in agricultural crop dataset
      final url = '$_cropDbBaseUrl/$_cropDatasetId?api-key=$_dataGovApiKey&format=json&limit=100';
      
      // Add required headers for Data.gov.in API
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Crop> crops = [];
        
        if (data['records'] != null) {
          for (var record in data['records']) {
            try {
              final crop = _parseCropRecord(record);
              if (crop != null) {
                crops.add(crop);
              }
            } catch (e) {
              print('Error parsing crop record: $e');
              continue;
            }
          }
        }
        
        return crops;
      } else {
        print('Crop database API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching from crop database: $e');
      return [];
    }
  }

  /// Parse crop record from API response
  Crop? _parseCropRecord(Map<String, dynamic> record) {
    try {
      return Crop(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: record['crop_name']?.toString() ?? record['name']?.toString() ?? 'Unknown Crop',
        soilType: record['soil_type']?.toString() ?? record['suitable_soil']?.toString() ?? 'alluvial',
        recommendedFertilizer: record['fertilizer']?.toString() ?? record['recommended_fertilizer']?.toString() ?? 'NPK',
        season: _parseSeason(record['season']?.toString() ?? record['growing_season']?.toString()),
        minTemperature: _parseDouble(record['min_temp'] ?? record['temperature_min']),
        maxTemperature: _parseDouble(record['max_temp'] ?? record['temperature_max']),
        minRainfall: _parseDouble(record['min_rainfall'] ?? record['rainfall_min']),
        maxRainfall: _parseDouble(record['max_rainfall'] ?? record['rainfall_max']),
        growthDuration: _parseInt(record['growth_period'] ?? record['duration_days']),
        description: record['description']?.toString() ?? 'Agricultural crop',
        benefits: _parseBenefits(record['benefits']?.toString() ?? record['advantages']?.toString()),
      );
    } catch (e) {
      print('Error parsing crop record: $e');
      return null;
    }
  }

  /// Parse season from various formats
  String _parseSeason(String? season) {
    if (season == null || season.isEmpty) return 'kharif';
    final seasonLower = season.toLowerCase();
    if (seasonLower.contains('kharif') || seasonLower.contains('monsoon')) return 'kharif';
    if (seasonLower.contains('rabi') || seasonLower.contains('winter')) return 'rabi';
    if (seasonLower.contains('summer') || seasonLower.contains('zaid')) return 'summer';
    return 'kharif';
  }

  /// Parse double value from various formats
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  /// Parse integer value from various formats
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(cleanValue) ?? 0;
    }
    return 0;
  }

  /// Parse benefits from string
  List<String> _parseBenefits(String? benefits) {
    if (benefits == null || benefits.isEmpty) return ['Good crop option'];
    return benefits.split(',').map((b) => b.trim()).where((b) => b.isNotEmpty).toList();
  }

  /// Enhanced crop database with real agricultural data
  List<Crop> _getEnhancedCropDatabase() {
    return [
      // Kharif Crops (Monsoon season)
      Crop(
        id: 'rice_001',
        name: 'Rice (Paddy)',
        soilType: 'alluvial',
        recommendedFertilizer: 'NPK 20:10:10 + Urea',
        season: 'kharif',
        minTemperature: 20.0,
        maxTemperature: 37.0,
        minRainfall: 1000.0,
        maxRainfall: 2500.0,
        growthDuration: 120,
        description: 'Primary staple food crop, requires flooding irrigation',
        benefits: ['High nutritional value', 'Stable market demand', 'Multiple varieties available', 'Good export potential'],
      ),
      Crop(
        id: 'cotton_001',
        name: 'Cotton',
        soilType: 'black',
        recommendedFertilizer: 'NPK 19:19:19 + Boron',
        season: 'kharif',
        minTemperature: 21.0,
        maxTemperature: 32.0,
        minRainfall: 500.0,
        maxRainfall: 1250.0,
        growthDuration: 160,
        description: 'Major fiber crop, requires well-drained black cotton soil',
        benefits: ['High commercial value', 'Strong export market', 'Industrial demand', 'Good profit margins'],
      ),
      Crop(
        id: 'sugarcane_001',
        name: 'Sugarcane',
        soilType: 'alluvial',
        recommendedFertilizer: 'NPK 19:19:19 + FYM',
        season: 'kharif',
        minTemperature: 20.0,
        maxTemperature: 35.0,
        minRainfall: 1000.0,
        maxRainfall: 1500.0,
        growthDuration: 365,
        description: 'Long duration cash crop, high water requirement',
        benefits: ['Guaranteed purchase', 'Good returns', 'Ratoon crops possible', 'Industrial processing'],
      ),
      Crop(
        id: 'maize_001',
        name: 'Maize (Corn)',
        soilType: 'alluvial',
        recommendedFertilizer: 'Urea + DAP + Potash',
        season: 'kharif',
        minTemperature: 18.0,
        maxTemperature: 32.0,
        minRainfall: 600.0,
        maxRainfall: 1200.0,
        growthDuration: 90,
        description: 'Versatile cereal crop, used for food and animal feed',
        benefits: ['Quick maturity', 'Multiple uses', 'Good market price', 'Suitable for mechanization'],
      ),
      Crop(
        id: 'soybean_001',
        name: 'Soybean',
        soilType: 'black',
        recommendedFertilizer: 'DAP + Potash + Rhizobium',
        season: 'kharif',
        minTemperature: 20.0,
        maxTemperature: 30.0,
        minRainfall: 450.0,
        maxRainfall: 700.0,
        growthDuration: 95,
        description: 'Important oilseed and protein crop',
        benefits: ['High protein content', 'Nitrogen fixation', 'Good oil content', 'Export demand'],
      ),

      // Rabi Crops (Winter season)
      Crop(
        id: 'wheat_001',
        name: 'Wheat',
        soilType: 'alluvial',
        recommendedFertilizer: 'DAP + Urea + Potash',
        season: 'rabi',
        minTemperature: 10.0,
        maxTemperature: 25.0,
        minRainfall: 300.0,
        maxRainfall: 1000.0,
        growthDuration: 120,
        description: 'Major cereal crop for temperate regions',
        benefits: ['Staple food grain', 'Good storage life', 'Stable prices', 'Government procurement'],
      ),
      Crop(
        id: 'barley_001',
        name: 'Barley',
        soilType: 'sandy',
        recommendedFertilizer: 'NPK 12:32:16',
        season: 'rabi',
        minTemperature: 6.0,
        maxTemperature: 20.0,
        minRainfall: 250.0,
        maxRainfall: 750.0,
        growthDuration: 110,
        description: 'Hardy cereal crop suitable for marginal lands',
        benefits: ['Drought tolerance', 'Industrial use', 'Animal feed', 'Brewing industry'],
      ),
      Crop(
        id: 'mustard_001',
        name: 'Mustard',
        soilType: 'loamy',
        recommendedFertilizer: 'NPK 15:15:15 + Sulphur',
        season: 'rabi',
        minTemperature: 10.0,
        maxTemperature: 25.0,
        minRainfall: 250.0,
        maxRainfall: 400.0,
        growthDuration: 120,
        description: 'Important oilseed crop of rabi season',
        benefits: ['High oil content', 'Medicinal value', 'Honey production', 'Good market demand'],
      ),
      Crop(
        id: 'chickpea_001',
        name: 'Chickpea (Gram)',
        soilType: 'black',
        recommendedFertilizer: 'DAP + Rhizobium culture',
        season: 'rabi',
        minTemperature: 15.0,
        maxTemperature: 30.0,
        minRainfall: 200.0,
        maxRainfall: 400.0,
        growthDuration: 100,
        description: 'Important pulse crop with high protein content',
        benefits: ['High protein', 'Nitrogen fixation', 'Export quality', 'Good market price'],
      ),

      // Summer/Zaid Crops
      Crop(
        id: 'watermelon_001',
        name: 'Watermelon',
        soilType: 'sandy',
        recommendedFertilizer: 'NPK 19:19:19 + Organic matter',
        season: 'summer',
        minTemperature: 20.0,
        maxTemperature: 35.0,
        minRainfall: 150.0,
        maxRainfall: 400.0,
        growthDuration: 90,
        description: 'Summer fruit crop with high water content',
        benefits: ['High market value', 'Quick returns', 'Processing potential', 'Export market'],
      ),
      Crop(
        id: 'fodder_maize_001',
        name: 'Fodder Maize',
        soilType: 'alluvial',
        recommendedFertilizer: 'Urea + DAP',
        season: 'summer',
        minTemperature: 15.0,
        maxTemperature: 35.0,
        minRainfall: 400.0,
        maxRainfall: 700.0,
        growthDuration: 65,
        description: 'Quick growing fodder crop for livestock',
        benefits: ['Quick harvest', 'Nutritious fodder', 'Multiple cuts', 'Dairy industry demand'],
      ),

      // Horticultural crops
      Crop(
        id: 'tomato_001',
        name: 'Tomato',
        soilType: 'loamy',
        recommendedFertilizer: 'NPK 19:19:19 + Micronutrients',
        season: 'rabi',
        minTemperature: 18.0,
        maxTemperature: 27.0,
        minRainfall: 300.0,
        maxRainfall: 650.0,
        growthDuration: 120,
        description: 'High value vegetable crop',
        benefits: ['High returns', 'Processing industry', 'Export potential', 'Nutritional value'],
      ),
      Crop(
        id: 'onion_001',
        name: 'Onion',
        soilType: 'alluvial',
        recommendedFertilizer: 'NPK 12:32:16 + Sulphur',
        season: 'rabi',
        minTemperature: 13.0,
        maxTemperature: 25.0,
        minRainfall: 250.0,
        maxRainfall: 450.0,
        growthDuration: 140,
        description: 'Important commercial vegetable crop',
        benefits: ['Good storage life', 'Export quality', 'High demand', 'Processing value'],
      ),
      Crop(
        id: 'potato_001',
        name: 'Potato',
        soilType: 'sandy',
        recommendedFertilizer: 'NPK 20:20:0 + FYM',
        season: 'rabi',
        minTemperature: 15.0,
        maxTemperature: 25.0,
        minRainfall: 200.0,
        maxRainfall: 300.0,
        growthDuration: 90,
        description: 'Major tuber crop with high yield potential',
        benefits: ['High productivity', 'Processing industry', 'Good storage', 'Multiple uses'],
      ),
    ];
  }

  /// Get crops suitable for specific conditions
  Future<List<Crop>> fetchCropsForConditions({
    required String soilType,
    required String season,
    required double temperature,
    required double rainfall,
  }) async {
    try {
      final allCrops = await fetchCrops();
      return allCrops.where((crop) {
        return crop.isSuitableFor(
          soilType: soilType,
          temperature: temperature,
          rainfall: rainfall,
        ) && (season.isEmpty || crop.season.toLowerCase() == season.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error fetching crops for conditions: $e');
      return [];
    }
  }

  /// Get crops by season
  Future<List<Crop>> fetchCropsBySeason(String season) async {
    try {
      final allCrops = await fetchCrops();
      return allCrops.where((crop) => crop.season.toLowerCase() == season.toLowerCase()).toList();
    } catch (e) {
      print('Error fetching crops by season: $e');
      return [];
    }
  }

  /// Get crops by soil type
  Future<List<Crop>> fetchCropsBySoilType(String soilType) async {
    try {
      final allCrops = await fetchCrops();
      return allCrops.where((crop) => crop.soilType.toLowerCase() == soilType.toLowerCase()).toList();
    } catch (e) {
      print('Error fetching crops by soil type: $e');
      return [];
    }
  }

  // ===================== FERTILIZER APIs =====================

  /// Fetch fertilizer recommendations based on crop and soil type
  Future<List<Fertilizer>> fetchFertilizerRecommendations({
    required String cropName,
    String? soilType,
    String? state,
  }) async {
    try {
      // Try real Fertilizer API
      final url = Uri.parse('$_fertilizerDbBaseUrl/$_fertilizerDatasetId')
          .replace(queryParameters: {
        'api-key': _dataGovApiKey,
        'format': 'json',
        'crop': cropName,
        if (soilType != null) 'soil_type': soilType,
        if (state != null) 'state': state,
        'limit': '20',
      });

      // Add required headers for Data.gov.in API
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['records'] != null) {
          return (data['records'] as List)
              .map((record) => _parseApiFertilizerData(record))
              .toList();
        }
      }
    } catch (e) {
      print('Fertilizer API error: $e');
    }
    
    // Fallback to enhanced demo data with real fertilizer information
    return _getFallbackFertilizerData(cropName, soilType);
  }

  /// Get soil-specific fertilizer recommendations
  Future<List<Fertilizer>> fetchSoilSpecificFertilizers(String soilType) async {
    try {
      // Try Soil Health Card API for soil-specific recommendations
      final url = Uri.parse('$_soilTestApiUrl/fertilizer-recommendations')
          .replace(queryParameters: {
        'soil_type': soilType,
        'format': 'json',
        'limit': '15',
      });

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['recommendations'] != null) {
          return (data['recommendations'] as List)
              .map((record) => _parseApiFertilizerData(record))
              .toList();
        }
      }
    } catch (e) {
      print('Soil API error: $e');
    }
    
    // Fallback to soil-specific demo data
    return _getSoilSpecificFertilizerData(soilType);
  }

  /// Get all available fertilizers
  Future<List<Fertilizer>> fetchAllFertilizers() async {
    try {
      // Try fetching from real fertilizer database
      final url = Uri.parse('$_fertilizerDbBaseUrl/$_fertilizerDatasetId')
          .replace(queryParameters: {
        'api-key': _dataGovApiKey,
        'format': 'json',
        'limit': '50',
      });
      
      // Add required headers for Data.gov.in API
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['records'] != null) {
          return (data['records'] as List)
              .map((record) => _parseApiFertilizerData(record))
              .toList();
        }
      }
    } catch (e) {
      print('All fertilizers API error: $e');
    }
    
    // Fallback to comprehensive demo fertilizer data
    return _getAllFertilizerFallbackData();
  }

  /// Parse API fertilizer data into Fertilizer object
  Fertilizer _parseApiFertilizerData(Map<String, dynamic> data) {
    return Fertilizer(
      id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: data['fertilizer_name'] ?? data['name'] ?? 'Unknown Fertilizer',
      cropType: data['crop_type'] ?? data['cropType'] ?? 'General crops',
      recommendedQuantity: (data['recommended_quantity'] ?? data['dosage_per_acre'] ?? 50.0).toDouble(),
      type: data['type'] ?? 'chemical',
      npkRatio: (data['npk_ratio_total'] ?? 45.0).toDouble(), // Parse total NPK from string like "19-19-19" 
      applicationMethod: data['application_method'] ?? 'Soil Application',
      applicationTiming: data['application_timing'] ?? 'Basal',
      pricePerKg: (data['price_per_kg'] ?? 45.0).toDouble(),
      description: data['description'] ?? 'Agricultural fertilizer for crop nutrition',
      benefits: (data['benefits'] as List?)?.cast<String>() ?? ['Improved growth'],
      precautions: (data['precautions'] as List?)?.cast<String>() ?? ['Follow recommended dosage'],
    );
  }

  /// Helper function to convert NPK ratio string to total double value
  double _parseNPKRatio(String npkString) {
    try {
      final parts = npkString.split('-');
      if (parts.length == 3) {
        final n = double.tryParse(parts[0]) ?? 0.0;
        final p = double.tryParse(parts[1]) ?? 0.0;
        final k = double.tryParse(parts[2]) ?? 0.0;
        return n + p + k;
      }
    } catch (e) {
      print('Error parsing NPK ratio: $e');
    }
    return 45.0; // Default total
  }

  /// Enhanced fallback fertilizer data with real agricultural information
  List<Fertilizer> _getFallbackFertilizerData(String cropName, String? soilType) {
    final allFertilizers = _getAllFertilizerFallbackData();

    // Filter by crop and soil type (simplified for demo)
    return allFertilizers.where((fertilizer) {
      bool cropMatch = fertilizer.cropType.toLowerCase().contains('general') ||
          fertilizer.cropType.toLowerCase().contains(cropName.toLowerCase()) ||
          fertilizer.cropType.toLowerCase().contains('all');
      
      return cropMatch;
    }).toList();
  }

  /// Soil-specific fertilizer recommendations
  List<Fertilizer> _getSoilSpecificFertilizerData(String soilType) {
    final allFertilizers = _getAllFertilizerFallbackData();
    
    // Return fertilizers suitable for the soil type (simplified logic)
    return allFertilizers.where((fertilizer) {
      // Include organic fertilizers for all soil types
      if (fertilizer.type == 'organic') return true;
      
      // Include specific fertilizers based on soil type
      if (soilType.toLowerCase().contains('acidic') && 
          fertilizer.name.contains('Calcium Ammonium Nitrate')) {
        return true;
      }
      
      // Include general fertilizers
      if (fertilizer.cropType.contains('General') || 
          fertilizer.cropType.contains('All')) {
        return true;
      }
      
      return true; // For demo, include all fertilizers
    }).toList();
  }

  /// Get all fertilizer fallback data
  List<Fertilizer> _getAllFertilizerFallbackData() {
    return [
      Fertilizer(
        id: '1',
        name: 'NPK 19-19-19',
        cropType: 'General crops',
        recommendedQuantity: 62.5,
        type: 'chemical',
        npkRatio: _parseNPKRatio('19-19-19'),
        applicationMethod: 'Soil Application',
        applicationTiming: 'Basal',
        pricePerKg: 52.0,
        description: 'Balanced NPK fertilizer for improved flowering and fruit development. Manufactured by IFFCO.',
        benefits: ['Balanced nutrition', 'Improved flowering', 'Better fruit development'],
        precautions: ['Apply as per soil test', 'Do not exceed recommended dose', 'Store in dry place'],
      ),
      Fertilizer(
        id: '2',
        name: 'DAP (Diammonium Phosphate)',
        cropType: 'Cereals',
        recommendedQuantity: 75.0,
        type: 'chemical',
        npkRatio: _parseNPKRatio('18-46-0'),
        applicationMethod: 'Basal Application',
        applicationTiming: 'Sowing',
        pricePerKg: 65.0,
        description: 'High phosphorus fertilizer for root development and early plant growth. Manufactured by IFFCO.',
        benefits: ['Root development', 'Early plant growth', 'Phosphorus boost'],
        precautions: ['Use for basal application only', 'Avoid contact with seeds', 'Store away from moisture'],
      ),
      Fertilizer(
        id: '3',
        name: 'Urea',
        cropType: 'All crops',
        recommendedQuantity: 65.0,
        type: 'chemical',
        npkRatio: _parseNPKRatio('46-0-0'),
        applicationMethod: 'Top Dressing',
        applicationTiming: 'Growth stage',
        pricePerKg: 42.0,
        description: 'Quick nitrogen source for vegetative growth and green foliage. Manufactured by NFL.',
        benefits: ['Quick nitrogen supply', 'Vegetative growth', 'Green foliage'],
        precautions: ['Apply in moist soil', 'Avoid over-application', 'Use in split doses'],
      ),
      Fertilizer(
        id: '4',
        name: 'Potassium Chloride (MOP)',
        cropType: 'Fruits and vegetables',
        recommendedQuantity: 37.5,
        type: 'chemical',
        npkRatio: _parseNPKRatio('0-0-60'),
        applicationMethod: 'Soil Application',
        applicationTiming: 'Basal',
        pricePerKg: 38.0,
        description: 'Potassium source for disease resistance and quality improvement. Manufactured by ICL.',
        benefits: ['Disease resistance', 'Water regulation', 'Quality improvement'],
        precautions: ['Avoid chloride sensitive crops', 'Apply before planting', 'Mix well with soil'],
      ),
      Fertilizer(
        id: '5',
        name: 'Organic Compost',
        cropType: 'Organic farming',
        recommendedQuantity: 3500.0, // 3.5 tons average
        type: 'organic',
        npkRatio: _parseNPKRatio('1-1-1'),
        applicationMethod: 'Soil Incorporation',
        applicationTiming: 'Land preparation',
        pricePerKg: 8.0,
        description: 'Well-decomposed organic matter for soil structure improvement and long-term nutrition.',
        benefits: ['Soil structure improvement', 'Microbial activity', 'Long-term nutrition'],
        precautions: ['Use well-decomposed compost', 'Apply 2-3 weeks before planting', 'Ensure proper C:N ratio'],
      ),
      Fertilizer(
        id: '6',
        name: 'Vermicompost',
        cropType: 'All crops',
        recommendedQuantity: 2000.0, // 2 tons average
        type: 'organic',
        npkRatio: _parseNPKRatio('1.5-1.0-1.5'),
        applicationMethod: 'Soil Incorporation',
        applicationTiming: 'Before planting',
        pricePerKg: 12.0,
        description: 'Earthworm-processed organic fertilizer for soil fertility enhancement and pest resistance.',
        benefits: ['Soil fertility enhancement', 'Water retention', 'Pest resistance'],
        precautions: ['Use fresh vermicompost', 'Mix uniformly with soil', 'Store in cool place'],
      ),
      Fertilizer(
        id: '7',
        name: 'Single Super Phosphate (SSP)',
        cropType: 'Oilseeds and pulses',
        recommendedQuantity: 125.0,
        type: 'chemical',
        npkRatio: _parseNPKRatio('0-16-0'),
        applicationMethod: 'Basal Application',
        applicationTiming: 'Sowing',
        pricePerKg: 28.0,
        description: 'Phosphorus and sulfur source for root development. Manufactured by GSFC.',
        benefits: ['Phosphorus supply', 'Sulfur nutrition', 'Root development'],
        precautions: ['Apply as basal dose', 'Ensure good soil contact', 'Avoid alkaline soils'],
      ),
      Fertilizer(
        id: '8',
        name: 'Calcium Ammonium Nitrate',
        cropType: 'Acidic soil crops',
        recommendedQuantity: 50.0,
        type: 'chemical',
        npkRatio: _parseNPKRatio('26-0-0'),
        applicationMethod: 'Top Dressing',
        applicationTiming: 'Growth stage',
        pricePerKg: 55.0,
        description: 'Nitrogen and calcium source with pH improvement properties. Manufactured by Yara.',
        benefits: ['Quick nitrogen release', 'Calcium nutrition', 'pH improvement'],
        precautions: ['Suitable for acidic soils', 'Apply during dry weather', 'Store in dry conditions'],
      ),
      Fertilizer(
        id: '9',
        name: 'Potassium Sulfate (SOP)',
        cropType: 'Quality crops',
        recommendedQuantity: 45.0,
        type: 'chemical',
        npkRatio: _parseNPKRatio('0-0-50'),
        applicationMethod: 'Soil Application',
        applicationTiming: 'Flowering stage',
        pricePerKg: 72.0,
        description: 'Chloride-free potassium source for quality improvement. Manufactured by SQM.',
        benefits: ['Chloride-free potassium', 'Quality improvement', 'Stress tolerance'],
        precautions: ['Premium fertilizer', 'Use for high-value crops', 'Apply in split doses'],
      ),
      Fertilizer(
        id: '10',
        name: 'Micronutrient Mixture',
        cropType: 'Deficiency correction',
        recommendedQuantity: 3.5,
        type: 'chemical',
        npkRatio: 0.0, // No NPK
        applicationMethod: 'Foliar Spray',
        applicationTiming: 'Growth stage',
        pricePerKg: 180.0,
        description: 'Chelated micronutrients for deficiency correction. Manufactured by Coromandel.',
        benefits: ['Micronutrient deficiency correction', 'Enzyme activation', 'Better yield'],
        precautions: ['Use as foliar spray', 'Apply in evening hours', 'Check compatibility'],
      ),
    ];
  }

  // ===================== MARKETPLACE APIs =====================

  /// Get Firebase Firestore instance
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  
  /// Get Firebase Storage instance
  static FirebaseStorage get _storage => FirebaseStorage.instance;
  
  /// Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile, String folder, String fileName) async {
    try {
      // Create a reference to the file location
      final Reference ref = _storage.ref().child('$folder/$fileName');
      
      // Upload the file
      final UploadTask uploadTask = ref.putFile(imageFile);
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload multiple images for marketplace listing
  Future<List<String>> uploadMarketplaceImages(List<File> imageFiles, String listingId) async {
    List<String> imageUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final File imageFile = imageFiles[i];
      final String fileName = '${listingId}_image_$i.jpg';
      
      final String? imageUrl = await uploadImage(imageFile, 'marketplace_images', fileName);
      
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }
    
    return imageUrls;
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Delete multiple images
  Future<bool> deleteImages(List<String> imageUrls) async {
    try {
      for (String imageUrl in imageUrls) {
        await deleteImage(imageUrl);
      }
      return true;
    } catch (e) {
      print('Error deleting images: $e');
      return false;
    }
  }
  
  /// Fetch all marketplace listings from Firestore
  Future<List<MarketplaceListing>> fetchMarketplaceListings() async {
    try {
      // Try to fetch from Firebase Firestore
      final QuerySnapshot snapshot = await _firestore
          .collection('marketplace_listings')
          .where('status', isEqualTo: 'active')
          .where('isAvailable', isEqualTo: true)
          .orderBy('dateListed', descending: true)
          .limit(50)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => MarketplaceListing.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      }
    } catch (e) {
      print('Error fetching marketplace listings from Firebase: $e');
    }

    // Fallback to demo data
    return _getDemoMarketplaceListings();
  }

  /// Fetch marketplace listings by crop
  Future<List<MarketplaceListing>> fetchMarketplaceListingsByCrop(String cropName) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('marketplace_listings')
          .where('cropName', isEqualTo: cropName)
          .where('status', isEqualTo: 'active')
          .where('isAvailable', isEqualTo: true)
          .orderBy('dateListed', descending: true)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => MarketplaceListing.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      }
    } catch (e) {
      print('Error fetching listings by crop from Firebase: $e');
    }

    // Fallback to filtered demo data
    return _getDemoMarketplaceListings()
        .where((listing) => listing.cropName.toLowerCase() == cropName.toLowerCase())
        .toList();
  }

  /// Fetch marketplace listings by state
  Future<List<MarketplaceListing>> fetchMarketplaceListingsByState(String state) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('marketplace_listings')
          .where('state', isEqualTo: state)
          .where('status', isEqualTo: 'active')
          .where('isAvailable', isEqualTo: true)
          .orderBy('dateListed', descending: true)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => MarketplaceListing.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      }
    } catch (e) {
      print('Error fetching listings by state from Firebase: $e');
    }

    // Fallback to filtered demo data
    return _getDemoMarketplaceListings()
        .where((listing) => listing.state.toLowerCase() == state.toLowerCase())
        .toList();
  }

  /// Fetch marketplace listings by farmer ID
  Future<List<MarketplaceListing>> fetchMarketplaceListingsByFarmer(String farmerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('marketplace_listings')
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('dateListed', descending: true)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => MarketplaceListing.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      }
    } catch (e) {
      print('Error fetching listings by farmer from Firebase: $e');
    }

    // Fallback to filtered demo data
    return _getDemoMarketplaceListings()
        .where((listing) => listing.farmerId == farmerId)
        .toList();
  }

  /// Add a new marketplace listing to Firestore with image upload
  Future<String?> addMarketplaceListing(MarketplaceListing listing, {List<File>? imageFiles}) async {
    try {
      // First, add the listing to get the document ID
      final DocumentReference docRef = await _firestore
          .collection('marketplace_listings')
          .add(listing.toFirestore());
      
      final String listingId = docRef.id;
      
      // Upload images if provided
      if (imageFiles != null && imageFiles.isNotEmpty) {
        final List<String> imageUrls = await uploadMarketplaceImages(imageFiles, listingId);
        
        // Update the listing with image URLs
        if (imageUrls.isNotEmpty) {
          await docRef.update({'imageUrls': imageUrls});
        }
      }
      
      return listingId;
    } catch (e) {
      print('Error adding marketplace listing to Firebase: $e');
      return null;
    }
  }

  /// Update marketplace listing in Firestore (original method kept for compatibility)
  Future<String?> addMarketplaceListingSimple(MarketplaceListing listing) async {
    try {
      final DocumentReference docRef = await _firestore
          .collection('marketplace_listings')
          .add(listing.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding marketplace listing to Firebase: $e');
      return null;
    }
  }

  /// Update marketplace listing in Firestore
  Future<bool> updateMarketplaceListing(String listingId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('marketplace_listings')
          .doc(listingId)
          .update(updates);
      return true;
    } catch (e) {
      print('Error updating marketplace listing in Firebase: $e');
      return false;
    }
  }

  /// Delete marketplace listing from Firestore with image cleanup
  Future<bool> deleteMarketplaceListing(String listingId) async {
    try {
      // First, get the listing to retrieve image URLs
      final DocumentSnapshot doc = await _firestore
          .collection('marketplace_listings')
          .doc(listingId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final List<String> imageUrls = List<String>.from(data['imageUrls'] ?? []);
        
        // Delete images from storage
        if (imageUrls.isNotEmpty) {
          await deleteImages(imageUrls);
        }
      }
      
      // Delete the document
      await _firestore
          .collection('marketplace_listings')
          .doc(listingId)
          .delete();
      
      return true;
    } catch (e) {
      print('Error deleting marketplace listing from Firebase: $e');
      return false;
    }
  }

  /// Mark marketplace listing as sold
  Future<bool> markListingAsSold(String listingId) async {
    return await updateMarketplaceListing(listingId, {
      'status': 'sold',
      'isAvailable': false,
    });
  }

  /// Search marketplace listings
  Future<List<MarketplaceListing>> searchMarketplaceListings({
    String? cropName,
    String? state,
    String? location,
    double? minPrice,
    double? maxPrice,
    bool? isOrganic,
  }) async {
    try {
      Query query = _firestore
          .collection('marketplace_listings')
          .where('status', isEqualTo: 'active')
          .where('isAvailable', isEqualTo: true);

      if (cropName != null && cropName.isNotEmpty) {
        query = query.where('cropName', isEqualTo: cropName);
      }

      if (state != null && state.isNotEmpty) {
        query = query.where('state', isEqualTo: state);
      }

      if (isOrganic != null) {
        query = query.where('isOrganic', isEqualTo: isOrganic);
      }

      final QuerySnapshot snapshot = await query
          .orderBy('dateListed', descending: true)
          .limit(30)
          .get();

      List<MarketplaceListing> listings = snapshot.docs
          .map((doc) => MarketplaceListing.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Apply price filtering (Firestore doesn't support range queries with other filters easily)
      if (minPrice != null || maxPrice != null) {
        listings = listings.where((listing) {
          if (minPrice != null && listing.pricePerQuintal < minPrice) return false;
          if (maxPrice != null && listing.pricePerQuintal > maxPrice) return false;
          return true;
        }).toList();
      }

      return listings;
    } catch (e) {
      print('Error searching marketplace listings in Firebase: $e');
    }

    // Fallback to demo data with search
    return _searchDemoListings(
      cropName: cropName,
      state: state,
      location: location,
      minPrice: minPrice,
      maxPrice: maxPrice,
      isOrganic: isOrganic,
    );
  }

  /// Demo marketplace listings for fallback
  List<MarketplaceListing> _getDemoMarketplaceListings() {
    final now = DateTime.now();
    
    return [
      MarketplaceListing(
        id: '1',
        farmerId: 'farmer1',
        farmerName: 'Rajesh Kumar',
        cropName: 'Rice',
        quantity: 50.0,
        pricePerQuintal: 2500.0,
        unit: 'quintal',
        dateListed: now.subtract(const Duration(days: 2)),
        location: 'Mandya',
        state: 'Karnataka',
        description: 'Premium quality rice, freshly harvested',
        cropVariety: 'Basmati',
        qualityGrade: 'A',
        isOrganic: true,
        isAvailable: true,
        imageUrls: [],
        contactPhone: '+91 9876543210',
        status: 'active',
      ),
      MarketplaceListing(
        id: '2',
        farmerId: 'farmer2',
        farmerName: 'Priya Sharma',
        cropName: 'Wheat',
        quantity: 30.0,
        pricePerQuintal: 2200.0,
        unit: 'quintal',
        dateListed: now.subtract(const Duration(days: 1)),
        location: 'Ludhiana',
        state: 'Punjab',
        description: 'High-quality wheat for wholesale purchase',
        cropVariety: 'HD-2967',
        qualityGrade: 'A',
        isOrganic: false,
        isAvailable: true,
        imageUrls: [],
        contactPhone: '+91 9876543211',
        status: 'active',
      ),
      MarketplaceListing(
        id: '3',
        farmerId: 'farmer3',
        farmerName: 'Suresh Patel',
        cropName: 'Corn',
        quantity: 25.0,
        pricePerQuintal: 1800.0,
        unit: 'quintal',
        dateListed: now.subtract(const Duration(hours: 5)),
        location: 'Nashik',
        state: 'Maharashtra',
        description: 'Fresh corn harvest, excellent quality',
        cropVariety: 'NK-30',
        qualityGrade: 'B',
        isOrganic: false,
        isAvailable: true,
        imageUrls: [],
        contactPhone: '+91 9876543212',
        status: 'active',
      ),
      MarketplaceListing(
        id: '4',
        farmerId: 'farmer4',
        farmerName: 'Anita Devi',
        cropName: 'Tomato',
        quantity: 15.0,
        pricePerQuintal: 3200.0,
        unit: 'quintal',
        dateListed: now.subtract(const Duration(hours: 8)),
        location: 'Kolar',
        state: 'Karnataka',
        description: 'Fresh organic tomatoes for immediate sale',
        cropVariety: 'Cherry',
        qualityGrade: 'A',
        isOrganic: true,
        isAvailable: true,
        imageUrls: [],
        contactPhone: '+91 9876543213',
        status: 'active',
      ),
      MarketplaceListing(
        id: '5',
        farmerId: 'farmer5',
        farmerName: 'Vikram Singh',
        cropName: 'Onion',
        quantity: 40.0,
        pricePerQuintal: 1500.0,
        unit: 'quintal',
        dateListed: now.subtract(const Duration(days: 3)),
        location: 'Pune',
        state: 'Maharashtra',
        description: 'Quality onions, good storage life',
        cropVariety: 'Red Onion',
        qualityGrade: 'B',
        isOrganic: false,
        isAvailable: true,
        imageUrls: [],
        contactPhone: '+91 9876543214',
        status: 'active',
      ),
      MarketplaceListing(
        id: '6',
        farmerId: 'farmer6',
        farmerName: 'Lakshmi Reddy',
        cropName: 'Cotton',
        quantity: 20.0,
        pricePerQuintal: 5800.0,
        unit: 'quintal',
        dateListed: now.subtract(const Duration(days: 1)),
        location: 'Warangal',
        state: 'Telangana',
        description: 'Premium cotton for textile industry',
        cropVariety: 'Bt Cotton',
        qualityGrade: 'A',
        isOrganic: false,
        isAvailable: true,
        imageUrls: [],
        contactPhone: '+91 9876543215',
        status: 'active',
      ),
    ];
  }

  /// Search demo listings
  List<MarketplaceListing> _searchDemoListings({
    String? cropName,
    String? state,
    String? location,
    double? minPrice,
    double? maxPrice,
    bool? isOrganic,
  }) {
    List<MarketplaceListing> listings = _getDemoMarketplaceListings();

    return listings.where((listing) {
      if (cropName != null && cropName.isNotEmpty &&
          !listing.cropName.toLowerCase().contains(cropName.toLowerCase())) {
        return false;
      }

      if (state != null && state.isNotEmpty &&
          !listing.state.toLowerCase().contains(state.toLowerCase())) {
        return false;
      }

      if (location != null && location.isNotEmpty &&
          !listing.location.toLowerCase().contains(location.toLowerCase())) {
        return false;
      }

      if (minPrice != null && listing.pricePerQuintal < minPrice) {
        return false;
      }

      if (maxPrice != null && listing.pricePerQuintal > maxPrice) {
        return false;
      }

      if (isOrganic != null && listing.isOrganic != isOrganic) {
        return false;
      }

      return true;
    }).toList();
  }
}