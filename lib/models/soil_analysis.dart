class SoilAnalysis {
  final String id;
  final String farmerId;
  final String cropType;
  final double nitrogen; // N level in mg/kg or ppm
  final double phosphorus; // P level in mg/kg or ppm
  final double potassium; // K level in mg/kg or ppm
  final double pH; // Soil pH level (3.0-10.0)
  final double organicMatter; // Percentage of organic content
  final double moistureContent; // Soil water content percentage
  final double fieldSize; // Field size in acres/hectares
  final String location; // GPS coordinates or address
  final DateTime testDate;
  final String? labReportUrl; // URL to uploaded soil report
  final Map<String, dynamic>? additionalParameters; // Extra soil parameters
  final String status; // 'pending', 'analyzed', 'completed'
  final DateTime createdAt;
  final DateTime updatedAt;

  SoilAnalysis({
    required this.id,
    required this.farmerId,
    required this.cropType,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.pH,
    required this.organicMatter,
    required this.moistureContent,
    required this.fieldSize,
    required this.location,
    required this.testDate,
    this.labReportUrl,
    this.additionalParameters,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory SoilAnalysis.fromJson(Map<String, dynamic> json) {
    return SoilAnalysis(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      cropType: json['cropType'] as String,
      nitrogen: (json['nitrogen'] as num).toDouble(),
      phosphorus: (json['phosphorus'] as num).toDouble(),
      potassium: (json['potassium'] as num).toDouble(),
      pH: (json['pH'] as num).toDouble(),
      organicMatter: (json['organicMatter'] as num).toDouble(),
      moistureContent: (json['moistureContent'] as num).toDouble(),
      fieldSize: (json['fieldSize'] as num).toDouble(),
      location: json['location'] as String,
      testDate: DateTime.parse(json['testDate'] as String),
      labReportUrl: json['labReportUrl'] as String?,
      additionalParameters: json['additionalParameters'] as Map<String, dynamic>?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'cropType': cropType,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'pH': pH,
      'organicMatter': organicMatter,
      'moistureContent': moistureContent,
      'fieldSize': fieldSize,
      'location': location,
      'testDate': testDate.toIso8601String(),
      'labReportUrl': labReportUrl,
      'additionalParameters': additionalParameters,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SoilAnalysis copyWith({
    String? id,
    String? farmerId,
    String? cropType,
    double? nitrogen,
    double? phosphorus,
    double? potassium,
    double? pH,
    double? organicMatter,
    double? moistureContent,
    double? fieldSize,
    String? location,
    DateTime? testDate,
    String? labReportUrl,
    Map<String, dynamic>? additionalParameters,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SoilAnalysis(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      cropType: cropType ?? this.cropType,
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      pH: pH ?? this.pH,
      organicMatter: organicMatter ?? this.organicMatter,
      moistureContent: moistureContent ?? this.moistureContent,
      fieldSize: fieldSize ?? this.fieldSize,
      location: location ?? this.location,
      testDate: testDate ?? this.testDate,
      labReportUrl: labReportUrl ?? this.labReportUrl,
      additionalParameters: additionalParameters ?? this.additionalParameters,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for validation
  bool get isNitrogenDeficient => nitrogen < getOptimalNPK()['nitrogen']!['min']!;
  bool get isPhosphorusDeficient => phosphorus < getOptimalNPK()['phosphorus']!['min']!;
  bool get isPotassiumDeficient => potassium < getOptimalNPK()['potassium']!['min']!;
  
  bool get isPHOptimal => pH >= 6.0 && pH <= 7.5;
  
  // Get optimal NPK ranges for the crop
  Map<String, Map<String, double>> getOptimalNPK() {
    const cropNPKRanges = {
      'Rice': {
        'nitrogen': {'min': 150.0, 'max': 250.0},
        'phosphorus': {'min': 20.0, 'max': 40.0},
        'potassium': {'min': 120.0, 'max': 200.0},
      },
      'Wheat': {
        'nitrogen': {'min': 120.0, 'max': 180.0},
        'phosphorus': {'min': 25.0, 'max': 45.0},
        'potassium': {'min': 100.0, 'max': 150.0},
      },
      'Corn': {
        'nitrogen': {'min': 180.0, 'max': 280.0},
        'phosphorus': {'min': 30.0, 'max': 50.0},
        'potassium': {'min': 150.0, 'max': 250.0},
      },
      'Cotton': {
        'nitrogen': {'min': 100.0, 'max': 160.0},
        'phosphorus': {'min': 20.0, 'max': 35.0},
        'potassium': {'min': 120.0, 'max': 180.0},
      },
      'Sugarcane': {
        'nitrogen': {'min': 200.0, 'max': 300.0},
        'phosphorus': {'min': 25.0, 'max': 45.0},
        'potassium': {'min': 150.0, 'max': 250.0},
      },
      'Soybean': {
        'nitrogen': {'min': 80.0, 'max': 120.0},
        'phosphorus': {'min': 30.0, 'max': 50.0},
        'potassium': {'min': 120.0, 'max': 180.0},
      },
      'Potato': {
        'nitrogen': {'min': 120.0, 'max': 180.0},
        'phosphorus': {'min': 35.0, 'max': 55.0},
        'potassium': {'min': 180.0, 'max': 280.0},
      },
      'Tomato': {
        'nitrogen': {'min': 150.0, 'max': 220.0},
        'phosphorus': {'min': 30.0, 'max': 50.0},
        'potassium': {'min': 200.0, 'max': 300.0},
      },
      'Onion': {
        'nitrogen': {'min': 100.0, 'max': 150.0},
        'phosphorus': {'min': 25.0, 'max': 40.0},
        'potassium': {'min': 120.0, 'max': 180.0},
      },
    };

    return cropNPKRanges[cropType] ?? cropNPKRanges['Rice']!;
  }
}