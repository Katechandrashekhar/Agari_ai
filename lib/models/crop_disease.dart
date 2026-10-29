/// Model for crop disease information
class CropDisease {
  final String id;
  final String name;
  final String cropType;
  final String description;
  final String symptoms;
  final String treatment;
  final String prevention;
  final String imageUrl;
  double confidence;

  CropDisease({
    required this.id,
    required this.name,
    required this.cropType,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    this.imageUrl = '',
    this.confidence = 0.0,
  });

  /// Create from Firestore document
  factory CropDisease.fromFirestore(Map<String, dynamic> data, String documentId) {
    return CropDisease(
      id: documentId,
      name: data['name'] ?? '',
      cropType: data['cropType'] ?? '',
      description: data['description'] ?? '',
      symptoms: data['symptoms'] ?? '',
      treatment: data['treatment'] ?? '',
      prevention: data['prevention'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      confidence: data['confidence']?.toDouble() ?? 0.0,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'cropType': cropType,
      'description': description,
      'symptoms': symptoms,
      'treatment': treatment,
      'prevention': prevention,
      'imageUrl': imageUrl,
      'confidence': confidence,
    };
  }

  /// Create from JSON
  factory CropDisease.fromJson(Map<String, dynamic> json) {
    return CropDisease(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cropType: json['cropType'] ?? '',
      description: json['description'] ?? '',
      symptoms: json['symptoms'] ?? '',
      treatment: json['treatment'] ?? '',
      prevention: json['prevention'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toFirestore();
}