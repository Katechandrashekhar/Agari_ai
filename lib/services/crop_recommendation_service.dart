import 'package:flutter/services.dart';

class CropRecommendationService {
  // Singleton pattern
  static final CropRecommendationService _instance = CropRecommendationService._internal();
  factory CropRecommendationService() => _instance;
  CropRecommendationService._internal();

  // Store CSV data
  final List<Map<String, dynamic>> _cropData = [];
  bool _isInitialized = false;

  // Initialize data from CSV
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the CSV file from assets
      final String csvString = await rootBundle.loadString('Crop_recommendation.csv');
      
      // Parse the CSV data
      List<String> lines = csvString.split('\n');
      if (lines.isEmpty) {
        print('CSV file is empty');
        return;
      }

      // Get headers
      List<String> headers = lines[0].split(',');
      headers = headers.map((header) => header.trim()).toList();

      // Parse each row
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        
        List<String> values = lines[i].split(',');
        if (values.length != headers.length) continue;

        Map<String, dynamic> row = {};
        for (int j = 0; j < headers.length; j++) {
          // Try to parse as number if possible
          String value = values[j].trim();
          if (double.tryParse(value) != null) {
            row[headers[j]] = double.parse(value);
          } else {
            row[headers[j]] = value;
          }
        }
        _cropData.add(row);
      }

      _isInitialized = true;
      print('Loaded ${_cropData.length} crop recommendation records');
    } catch (e) {
      print('Error loading crop recommendation data: $e');
    }
  }

  // Get recommended crop based on input parameters
  Future<List<String>> getRecommendedCrops({
    required double nitrogen,
    required double phosphorus, 
    required double potassium,
    required double temperature,
    required double humidity,
    required double ph,
    required double rainfall,
  }) async {
    if (!_isInitialized) await initialize();
    
    if (_cropData.isEmpty) {
      return [];
    }

    // Simple recommendation algorithm - find crops with similar soil conditions
    // Calculate similarity score for each crop entry
    List<Map<String, dynamic>> scoredCrops = _cropData.map((crop) {
      double score = 0.0;
      
      // Soil nutrients match (higher weight) - 45% of total score
      score += (1 - (((crop['N'] - nitrogen).abs() / 100) * 3)) * 0.15;  // 15%
      score += (1 - (((crop['P'] - phosphorus).abs() / 100) * 3)) * 0.15;  // 15%
      score += (1 - (((crop['K'] - potassium).abs() / 100) * 3)) * 0.15;  // 15%
      
      // Environmental conditions match - 55% of total score
      score += (1 - (((crop['temperature'] - temperature).abs() / 40) * 2)) * 0.15;  // 15%
      score += (1 - (((crop['humidity'] - humidity).abs() / 100) * 2)) * 0.15;  // 15%
      score += (1 - (((crop['ph'] - ph).abs() / 14) * 2.5)) * 0.15;  // 15%
      score += (1 - (((crop['rainfall'] - rainfall).abs() / 300) * 2)) * 0.10;  // 10%
      
      // Normalize score (0-1)
      score = score < 0 ? 0 : score;
      if (score > 1) score = 1;
      
      return {
        'crop': crop['label'],
        'score': score * 10, // Score from 0-10 for display
        'confidence': score, // Confidence from 0-1
        'data': crop
      };
    }).toList();

    // Sort by score (descending)
    scoredCrops.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    
    // Return only top matches with good confidence (70% or higher)
    List<String> recommendations = scoredCrops
        .where((crop) => crop['confidence'] > 0.7)
        .take(5) // Limit to top 5 matches
        .map((crop) => crop['crop'] as String)
        .toList();
    
    // If we don't have any matches with high confidence, return top 3
    if (recommendations.isEmpty && scoredCrops.isNotEmpty) {
      recommendations = scoredCrops
          .take(3)
          .map((crop) => crop['crop'] as String)
          .toList();
    }
    
    return recommendations;
  }

  // Get all unique crops in the dataset
  List<String> getAllCrops() {
    if (!_isInitialized || _cropData.isEmpty) {
      return [];
    }
    
    Set<String> uniqueCrops = {};
    for (var crop in _cropData) {
      uniqueCrops.add(crop['label'] as String);
    }
    
    return uniqueCrops.toList()..sort();
  }

  // Get average values for a specific crop
  Map<String, dynamic>? getCropDetails(String cropName) {
    if (!_isInitialized || _cropData.isEmpty) {
      return null;
    }
    
    // Filter data for the specific crop
    List<Map<String, dynamic>> cropEntries = _cropData
        .where((crop) => crop['label'] == cropName)
        .toList();
    
    if (cropEntries.isEmpty) {
      return null;
    }
    
    // Calculate averages
    double avgN = 0, avgP = 0, avgK = 0, avgTemp = 0;
    double avgHumidity = 0, avgPh = 0, avgRainfall = 0;
    
    for (var entry in cropEntries) {
      avgN += entry['N'] as double;
      avgP += entry['P'] as double;
      avgK += entry['K'] as double;
      avgTemp += entry['temperature'] as double;
      avgHumidity += entry['humidity'] as double;
      avgPh += entry['ph'] as double;
      avgRainfall += entry['rainfall'] as double;
    }
    
    int count = cropEntries.length;
    return {
      'crop': cropName,
      'nitrogen': avgN / count,
      'phosphorus': avgP / count,
      'potassium': avgK / count,
      'temperature': avgTemp / count,
      'humidity': avgHumidity / count,
      'ph': avgPh / count,
      'rainfall': avgRainfall / count,
    };
  }
}