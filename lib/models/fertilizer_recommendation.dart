class FertilizerRecommendation {
  final String id;
  final String soilAnalysisId;
  final String cropType;
  final NPKRecommendation npkRecommendation;
  final List<FertilizerProduct> recommendedProducts;
  final ApplicationSchedule applicationSchedule;
  final double confidenceScore; // AI confidence level (0.0-1.0)
  final Map<String, dynamic> analysisDetails;
  final List<String> deficiencies;
  final List<String> excesses;
  final double estimatedYieldIncrease; // Percentage increase
  final double estimatedCost; // Total cost in local currency
  final double roi; // Return on investment
  final SustainabilityMetrics sustainabilityMetrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  FertilizerRecommendation({
    required this.id,
    required this.soilAnalysisId,
    required this.cropType,
    required this.npkRecommendation,
    required this.recommendedProducts,
    required this.applicationSchedule,
    required this.confidenceScore,
    required this.analysisDetails,
    required this.deficiencies,
    required this.excesses,
    required this.estimatedYieldIncrease,
    required this.estimatedCost,
    required this.roi,
    required this.sustainabilityMetrics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FertilizerRecommendation.fromJson(Map<String, dynamic> json) {
    return FertilizerRecommendation(
      id: json['id'] as String,
      soilAnalysisId: json['soilAnalysisId'] as String,
      cropType: json['cropType'] as String,
      npkRecommendation: NPKRecommendation.fromJson(json['npkRecommendation']),
      recommendedProducts: (json['recommendedProducts'] as List)
          .map((item) => FertilizerProduct.fromJson(item))
          .toList(),
      applicationSchedule: ApplicationSchedule.fromJson(json['applicationSchedule']),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      analysisDetails: json['analysisDetails'] as Map<String, dynamic>,
      deficiencies: List<String>.from(json['deficiencies']),
      excesses: List<String>.from(json['excesses']),
      estimatedYieldIncrease: (json['estimatedYieldIncrease'] as num).toDouble(),
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      roi: (json['roi'] as num).toDouble(),
      sustainabilityMetrics: SustainabilityMetrics.fromJson(json['sustainabilityMetrics']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'soilAnalysisId': soilAnalysisId,
      'cropType': cropType,
      'npkRecommendation': npkRecommendation.toJson(),
      'recommendedProducts': recommendedProducts.map((product) => product.toJson()).toList(),
      'applicationSchedule': applicationSchedule.toJson(),
      'confidenceScore': confidenceScore,
      'analysisDetails': analysisDetails,
      'deficiencies': deficiencies,
      'excesses': excesses,
      'estimatedYieldIncrease': estimatedYieldIncrease,
      'estimatedCost': estimatedCost,
      'roi': roi,
      'sustainabilityMetrics': sustainabilityMetrics.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class NPKRecommendation {
  final double requiredNitrogen; // kg per hectare
  final double requiredPhosphorus; // kg per hectare
  final double requiredPotassium; // kg per hectare
  final double currentNitrogen;
  final double currentPhosphorus;
  final double currentPotassium;
  final double nitrogenDeficit;
  final double phosphorusDeficit;
  final double potassiumDeficit;
  final Map<String, String> recommendations; // Detailed recommendations

  NPKRecommendation({
    required this.requiredNitrogen,
    required this.requiredPhosphorus,
    required this.requiredPotassium,
    required this.currentNitrogen,
    required this.currentPhosphorus,
    required this.currentPotassium,
    required this.nitrogenDeficit,
    required this.phosphorusDeficit,
    required this.potassiumDeficit,
    required this.recommendations,
  });

  factory NPKRecommendation.fromJson(Map<String, dynamic> json) {
    return NPKRecommendation(
      requiredNitrogen: (json['requiredNitrogen'] as num).toDouble(),
      requiredPhosphorus: (json['requiredPhosphorus'] as num).toDouble(),
      requiredPotassium: (json['requiredPotassium'] as num).toDouble(),
      currentNitrogen: (json['currentNitrogen'] as num).toDouble(),
      currentPhosphorus: (json['currentPhosphorus'] as num).toDouble(),
      currentPotassium: (json['currentPotassium'] as num).toDouble(),
      nitrogenDeficit: (json['nitrogenDeficit'] as num).toDouble(),
      phosphorusDeficit: (json['phosphorusDeficit'] as num).toDouble(),
      potassiumDeficit: (json['potassiumDeficit'] as num).toDouble(),
      recommendations: Map<String, String>.from(json['recommendations']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requiredNitrogen': requiredNitrogen,
      'requiredPhosphorus': requiredPhosphorus,
      'requiredPotassium': requiredPotassium,
      'currentNitrogen': currentNitrogen,
      'currentPhosphorus': currentPhosphorus,
      'currentPotassium': currentPotassium,
      'nitrogenDeficit': nitrogenDeficit,
      'phosphorusDeficit': phosphorusDeficit,
      'potassiumDeficit': potassiumDeficit,
      'recommendations': recommendations,
    };
  }
}

class FertilizerProduct {
  final String id;
  final String name;
  final String brand;
  final String type; // 'organic', 'inorganic', 'mixed'
  final NPKComposition npkComposition;
  final double pricePerKg;
  final double recommendedQuantity; // kg per hectare
  final double totalCost;
  final String availability; // 'in-stock', 'limited', 'out-of-stock'
  final double rating;
  final String description;
  final List<String> benefits;
  final String imageUrl;

  FertilizerProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.npkComposition,
    required this.pricePerKg,
    required this.recommendedQuantity,
    required this.totalCost,
    required this.availability,
    required this.rating,
    required this.description,
    required this.benefits,
    required this.imageUrl,
  });

  factory FertilizerProduct.fromJson(Map<String, dynamic> json) {
    return FertilizerProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      type: json['type'] as String,
      npkComposition: NPKComposition.fromJson(json['npkComposition']),
      pricePerKg: (json['pricePerKg'] as num).toDouble(),
      recommendedQuantity: (json['recommendedQuantity'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      availability: json['availability'] as String,
      rating: (json['rating'] as num).toDouble(),
      description: json['description'] as String,
      benefits: List<String>.from(json['benefits']),
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'type': type,
      'npkComposition': npkComposition.toJson(),
      'pricePerKg': pricePerKg,
      'recommendedQuantity': recommendedQuantity,
      'totalCost': totalCost,
      'availability': availability,
      'rating': rating,
      'description': description,
      'benefits': benefits,
      'imageUrl': imageUrl,
    };
  }
}

class NPKComposition {
  final double nitrogen; // Percentage
  final double phosphorus; // Percentage
  final double potassium; // Percentage
  final Map<String, double>? micronutrients; // Additional nutrients

  NPKComposition({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    this.micronutrients,
  });

  factory NPKComposition.fromJson(Map<String, dynamic> json) {
    return NPKComposition(
      nitrogen: (json['nitrogen'] as num).toDouble(),
      phosphorus: (json['phosphorus'] as num).toDouble(),
      potassium: (json['potassium'] as num).toDouble(),
      micronutrients: json['micronutrients'] != null
          ? Map<String, double>.from(json['micronutrients'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'micronutrients': micronutrients,
    };
  }

  String get npkRatio => '$nitrogen-$phosphorus-$potassium';
}

class ApplicationSchedule {
  final List<ApplicationPhase> phases;
  final String totalDuration;
  final Map<String, String> instructions;

  ApplicationSchedule({
    required this.phases,
    required this.totalDuration,
    required this.instructions,
  });

  factory ApplicationSchedule.fromJson(Map<String, dynamic> json) {
    return ApplicationSchedule(
      phases: (json['phases'] as List)
          .map((item) => ApplicationPhase.fromJson(item))
          .toList(),
      totalDuration: json['totalDuration'] as String,
      instructions: Map<String, String>.from(json['instructions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phases': phases.map((phase) => phase.toJson()).toList(),
      'totalDuration': totalDuration,
      'instructions': instructions,
    };
  }
}

class ApplicationPhase {
  final String id;
  final String name;
  final String description;
  final int dayFromPlanting;
  final String cropStage; // 'planting', 'vegetative', 'flowering', 'maturity'
  final double quantity; // kg per hectare
  final String method; // 'broadcasting', 'side-dressing', 'foliar'
  final List<String> instructions;
  final DateTime? scheduledDate;
  final bool isCompleted;

  ApplicationPhase({
    required this.id,
    required this.name,
    required this.description,
    required this.dayFromPlanting,
    required this.cropStage,
    required this.quantity,
    required this.method,
    required this.instructions,
    this.scheduledDate,
    this.isCompleted = false,
  });

  factory ApplicationPhase.fromJson(Map<String, dynamic> json) {
    return ApplicationPhase(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      dayFromPlanting: json['dayFromPlanting'] as int,
      cropStage: json['cropStage'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      method: json['method'] as String,
      instructions: List<String>.from(json['instructions']),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dayFromPlanting': dayFromPlanting,
      'cropStage': cropStage,
      'quantity': quantity,
      'method': method,
      'instructions': instructions,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}

class SustainabilityMetrics {
  final double carbonFootprint; // kg CO2 equivalent
  final double environmentalScore; // 0.0-10.0 scale
  final bool isOrganicCertified;
  final double waterEfficiency; // liters per kg yield
  final double soilHealthImpact; // -1.0 to 1.0 scale
  final List<String> sustainabilityFactors;

  SustainabilityMetrics({
    required this.carbonFootprint,
    required this.environmentalScore,
    required this.isOrganicCertified,
    required this.waterEfficiency,
    required this.soilHealthImpact,
    required this.sustainabilityFactors,
  });

  factory SustainabilityMetrics.fromJson(Map<String, dynamic> json) {
    return SustainabilityMetrics(
      carbonFootprint: (json['carbonFootprint'] as num).toDouble(),
      environmentalScore: (json['environmentalScore'] as num).toDouble(),
      isOrganicCertified: json['isOrganicCertified'] as bool,
      waterEfficiency: (json['waterEfficiency'] as num).toDouble(),
      soilHealthImpact: (json['soilHealthImpact'] as num).toDouble(),
      sustainabilityFactors: List<String>.from(json['sustainabilityFactors']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carbonFootprint': carbonFootprint,
      'environmentalScore': environmentalScore,
      'isOrganicCertified': isOrganicCertified,
      'waterEfficiency': waterEfficiency,
      'soilHealthImpact': soilHealthImpact,
      'sustainabilityFactors': sustainabilityFactors,
    };
  }
}