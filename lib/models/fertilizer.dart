/// Fertilizer model for AgriAI app
/// Represents different fertilizers with their properties and recommendations
class Fertilizer {
  final String id;
  final String name;
  final String cropType;
  final double recommendedQuantity; // kg per acre
  final String type; // 'organic', 'inorganic', 'bio-fertilizer'
  final double npkRatio; // Nitrogen-Phosphorus-Potassium ratio
  final String applicationMethod;
  final String applicationTiming;
  final double pricePerKg;
  final String description;
  final List<String> benefits;
  final List<String> precautions;

  Fertilizer({
    required this.id,
    required this.name,
    required this.cropType,
    required this.recommendedQuantity,
    required this.type,
    required this.npkRatio,
    required this.applicationMethod,
    required this.applicationTiming,
    required this.pricePerKg,
    required this.description,
    required this.benefits,
    required this.precautions,
  });

  /// Create Fertilizer from Firestore document
  factory Fertilizer.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Fertilizer(
      id: documentId,
      name: data['name'] ?? '',
      cropType: data['cropType'] ?? '',
      recommendedQuantity: (data['recommendedQuantity'] ?? 0).toDouble(),
      type: data['type'] ?? '',
      npkRatio: (data['npkRatio'] ?? 0).toDouble(),
      applicationMethod: data['applicationMethod'] ?? '',
      applicationTiming: data['applicationTiming'] ?? '',
      pricePerKg: (data['pricePerKg'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      benefits: List<String>.from(data['benefits'] ?? []),
      precautions: List<String>.from(data['precautions'] ?? []),
    );
  }

  /// Convert Fertilizer to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'cropType': cropType,
      'recommendedQuantity': recommendedQuantity,
      'type': type,
      'npkRatio': npkRatio,
      'applicationMethod': applicationMethod,
      'applicationTiming': applicationTiming,
      'pricePerKg': pricePerKg,
      'description': description,
      'benefits': benefits,
      'precautions': precautions,
    };
  }

  /// Convert Fertilizer to JSON for Firebase
  Map<String, dynamic> toJson() => toFirestore();

  /// Create Fertilizer from JSON/Firebase data
  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    return Fertilizer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cropType: json['cropType'] ?? '',
      recommendedQuantity: (json['recommendedQuantity'] ?? 0.0).toDouble(),
      type: json['type'] ?? '',
      npkRatio: (json['npkRatio'] ?? 0.0).toDouble(),
      applicationMethod: json['applicationMethod'] ?? '',
      applicationTiming: json['applicationTiming'] ?? '',
      pricePerKg: (json['pricePerKg'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      benefits: List<String>.from(json['benefits'] ?? []),
      precautions: List<String>.from(json['precautions'] ?? []),
    );
  }

  /// Calculate total cost for given acreage
  double calculateCost(double acreage) {
    return recommendedQuantity * acreage * pricePerKg;
  }

  /// Get formatted NPK ratio string
  String get formattedNpkRatio {
    return 'NPK: $npkRatio';
  }
}