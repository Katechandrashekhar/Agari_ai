/// Crop model for AgriAI app
/// Represents different crops with their characteristics and recommendations
class Crop {
  final String id;
  final String name;
  final String soilType;
  final String recommendedFertilizer;
  final String season; // 'kharif', 'rabi', 'summer'
  final double minTemperature;
  final double maxTemperature;
  final double minRainfall;
  final double maxRainfall;
  final int growthDuration; // in days
  final String description;
  final List<String> benefits;

  Crop({
    required this.id,
    required this.name,
    required this.soilType,
    required this.recommendedFertilizer,
    required this.season,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minRainfall,
    required this.maxRainfall,
    required this.growthDuration,
    required this.description,
    required this.benefits,
  });

  /// Create Crop from Firestore document
  factory Crop.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Crop(
      id: documentId,
      name: data['name'] ?? '',
      soilType: data['soilType'] ?? '',
      recommendedFertilizer: data['recommendedFertilizer'] ?? '',
      season: data['season'] ?? '',
      minTemperature: (data['minTemperature'] ?? 0).toDouble(),
      maxTemperature: (data['maxTemperature'] ?? 0).toDouble(),
      minRainfall: (data['minRainfall'] ?? 0).toDouble(),
      maxRainfall: (data['maxRainfall'] ?? 0).toDouble(),
      growthDuration: data['growthDuration'] ?? 0,
      description: data['description'] ?? '',
      benefits: List<String>.from(data['benefits'] ?? []),
    );
  }

  /// Convert Crop to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'soilType': soilType,
      'recommendedFertilizer': recommendedFertilizer,
      'season': season,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minRainfall': minRainfall,
      'maxRainfall': maxRainfall,
      'growthDuration': growthDuration,
      'description': description,
      'benefits': benefits,
    };
  }

  /// Convert Crop to JSON for Firebase
  Map<String, dynamic> toJson() => toFirestore();

  /// Create Crop from JSON/Firebase data
  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      soilType: json['soilType'] ?? '',
      recommendedFertilizer: json['recommendedFertilizer'] ?? '',
      season: json['season'] ?? '',
      minTemperature: (json['minTemperature'] ?? 0.0).toDouble(),
      maxTemperature: (json['maxTemperature'] ?? 0.0).toDouble(),
      minRainfall: (json['minRainfall'] ?? 0.0).toDouble(),
      maxRainfall: (json['maxRainfall'] ?? 0.0).toDouble(),
      growthDuration: json['growthDuration'] ?? 0,
      description: json['description'] ?? '',
      benefits: List<String>.from(json['benefits'] ?? []),
    );
  }

  /// Check if crop is suitable for given conditions
  bool isSuitableFor({
    required String soilType,
    required double temperature,
    required double rainfall,
  }) {
    return this.soilType.toLowerCase() == soilType.toLowerCase() &&
        temperature >= minTemperature &&
        temperature <= maxTemperature &&
        rainfall >= minRainfall &&
        rainfall <= maxRainfall;
  }
}