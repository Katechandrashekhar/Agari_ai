import 'dart:math' as math;
import '../models/soil_analysis.dart';
import '../models/fertilizer_recommendation.dart';

class FertilizerRecommendationService {
  static const String _tag = 'FertilizerRecommendationService';

  // Mock fertilizer products database
  static final List<FertilizerProduct> _fertilizerProducts = [
    FertilizerProduct(
      id: 'urea-001',
      name: 'Urea Fertilizer',
      brand: 'IFFCO',
      type: 'inorganic',
      npkComposition: NPKComposition(nitrogen: 46, phosphorus: 0, potassium: 0),
      pricePerKg: 25.0,
      recommendedQuantity: 0,
      totalCost: 0,
      availability: 'in-stock',
      rating: 4.2,
      description: 'High nitrogen content fertilizer ideal for vegetative growth',
      benefits: ['Fast nitrogen release', 'Promotes leaf growth', 'Cost effective'],
      imageUrl: 'https://example.com/urea.jpg',
    ),
    FertilizerProduct(
      id: 'dap-001',
      name: 'DAP (Di-Ammonium Phosphate)',
      brand: 'IFFCO',
      type: 'inorganic',
      npkComposition: NPKComposition(nitrogen: 18, phosphorus: 46, potassium: 0),
      pricePerKg: 30.0,
      recommendedQuantity: 0,
      totalCost: 0,
      availability: 'in-stock',
      rating: 4.5,
      description: 'Excellent source of phosphorus for root development',
      benefits: ['High phosphorus content', 'Improves root system', 'Quick availability'],
      imageUrl: 'https://example.com/dap.jpg',
    ),
    FertilizerProduct(
      id: 'mop-001',
      name: 'MOP (Muriate of Potash)',
      brand: 'IFFCO',
      type: 'inorganic',
      npkComposition: NPKComposition(nitrogen: 0, phosphorus: 0, potassium: 60),
      pricePerKg: 22.0,
      recommendedQuantity: 0,
      totalCost: 0,
      availability: 'in-stock',
      rating: 4.1,
      description: 'High potassium fertilizer for fruit and flower development',
      benefits: ['High potassium content', 'Improves fruit quality', 'Disease resistance'],
      imageUrl: 'https://example.com/mop.jpg',
    ),
    FertilizerProduct(
      id: 'npk-001',
      name: 'NPK Complex 19:19:19',
      brand: 'Coromandel',
      type: 'inorganic',
      npkComposition: NPKComposition(nitrogen: 19, phosphorus: 19, potassium: 19),
      pricePerKg: 35.0,
      recommendedQuantity: 0,
      totalCost: 0,
      availability: 'in-stock',
      rating: 4.3,
      description: 'Balanced NPK fertilizer for all growth stages',
      benefits: ['Balanced nutrition', 'All-in-one solution', 'Easy application'],
      imageUrl: 'https://example.com/npk.jpg',
    ),
    FertilizerProduct(
      id: 'organic-001',
      name: 'Organic Compost',
      brand: 'EcoFarm',
      type: 'organic',
      npkComposition: NPKComposition(nitrogen: 2, phosphorus: 1, potassium: 1),
      pricePerKg: 8.0,
      recommendedQuantity: 0,
      totalCost: 0,
      availability: 'in-stock',
      rating: 4.7,
      description: 'Natural organic fertilizer for sustainable farming',
      benefits: ['100% organic', 'Improves soil structure', 'Environmentally friendly'],
      imageUrl: 'https://example.com/organic.jpg',
    ),
  ];

  /// Generate AI-powered fertilizer recommendation based on soil analysis
  static Future<FertilizerRecommendation> generateRecommendation(SoilAnalysis soilAnalysis) async {
    print('$_tag: Generating fertilizer recommendation for ${soilAnalysis.cropType}');
    
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Get optimal NPK levels for the crop
    final optimalNPK = soilAnalysis.getOptimalNPK();
    
    // Calculate NPK requirements
    final npkRecommendation = _calculateNPKRequirements(soilAnalysis, optimalNPK);
    
    // Identify deficiencies and excesses
    final analysisResults = _analyzeNutrientLevels(soilAnalysis, optimalNPK);
    
    // Select appropriate fertilizer products
    final recommendedProducts = _selectFertilizerProducts(npkRecommendation, soilAnalysis.fieldSize);
    
    // Create application schedule
    final applicationSchedule = _createApplicationSchedule(soilAnalysis.cropType, npkRecommendation);
    
    // Calculate costs and ROI
    final totalCost = recommendedProducts.fold(0.0, (sum, product) => sum + product.totalCost);
    final estimatedYieldIncrease = _calculateYieldIncrease(analysisResults['deficiencies']);
    final roi = _calculateROI(estimatedYieldIncrease, totalCost, soilAnalysis.fieldSize);
    
    // Generate sustainability metrics
    final sustainabilityMetrics = _calculateSustainabilityMetrics(recommendedProducts);
    
    // Calculate confidence score based on data quality and analysis certainty
    final confidenceScore = _calculateConfidenceScore(soilAnalysis, analysisResults);
    
    return FertilizerRecommendation(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      soilAnalysisId: soilAnalysis.id,
      cropType: soilAnalysis.cropType,
      npkRecommendation: npkRecommendation,
      recommendedProducts: recommendedProducts,
      applicationSchedule: applicationSchedule,
      confidenceScore: confidenceScore,
      analysisDetails: analysisResults['analysisDetails'],
      deficiencies: analysisResults['deficiencies'],
      excesses: analysisResults['excesses'],
      estimatedYieldIncrease: estimatedYieldIncrease,
      estimatedCost: totalCost,
      roi: roi,
      sustainabilityMetrics: sustainabilityMetrics,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate NPK requirements based on soil analysis and optimal levels
  static NPKRecommendation _calculateNPKRequirements(
    SoilAnalysis soilAnalysis,
    Map<String, Map<String, double>> optimalNPK,
  ) {
    // Target levels (middle of optimal range)
    final targetN = (optimalNPK['nitrogen']!['min']! + optimalNPK['nitrogen']!['max']!) / 2;
    final targetP = (optimalNPK['phosphorus']!['min']! + optimalNPK['phosphorus']!['max']!) / 2;
    final targetK = (optimalNPK['potassium']!['min']! + optimalNPK['potassium']!['max']!) / 2;
    
    // Calculate deficits (how much is needed)
    final nDeficit = math.max(0.0, targetN - soilAnalysis.nitrogen);
    final pDeficit = math.max(0.0, targetP - soilAnalysis.phosphorus);
    final kDeficit = math.max(0.0, targetK - soilAnalysis.potassium);
    
    // Convert to kg per hectare (assuming soil test values are in mg/kg)
    final nRequired = nDeficit * 2.24; // Conversion factor for nitrogen
    final pRequired = pDeficit * 1.8;  // Conversion factor for phosphorus
    final kRequired = kDeficit * 1.2;  // Conversion factor for potassium
    
    return NPKRecommendation(
      requiredNitrogen: nRequired,
      requiredPhosphorus: pRequired,
      requiredPotassium: kRequired,
      currentNitrogen: soilAnalysis.nitrogen,
      currentPhosphorus: soilAnalysis.phosphorus,
      currentPotassium: soilAnalysis.potassium,
      nitrogenDeficit: nDeficit,
      phosphorusDeficit: pDeficit,
      potassiumDeficit: kDeficit,
      recommendations: {
        'nitrogen': _getNitrogenRecommendation(nDeficit, soilAnalysis.cropType),
        'phosphorus': _getPhosphorusRecommendation(pDeficit, soilAnalysis.cropType),
        'potassium': _getPotassiumRecommendation(kDeficit, soilAnalysis.cropType),
        'pH': _getPHRecommendation(soilAnalysis.pH),
        'organic_matter': _getOrganicMatterRecommendation(soilAnalysis.organicMatter),
      },
    );
  }

  /// Analyze nutrient levels and identify deficiencies/excesses
  static Map<String, dynamic> _analyzeNutrientLevels(
    SoilAnalysis soilAnalysis,
    Map<String, Map<String, double>> optimalNPK,
  ) {
    final deficiencies = <String>[];
    final excesses = <String>[];
    final analysisDetails = <String, dynamic>{};
    
    // Check nitrogen
    if (soilAnalysis.nitrogen < optimalNPK['nitrogen']!['min']!) {
      deficiencies.add('Nitrogen');
      analysisDetails['nitrogen_status'] = 'deficient';
      analysisDetails['nitrogen_level'] = 'low';
    } else if (soilAnalysis.nitrogen > optimalNPK['nitrogen']!['max']!) {
      excesses.add('Nitrogen');
      analysisDetails['nitrogen_status'] = 'excess';
      analysisDetails['nitrogen_level'] = 'high';
    } else {
      analysisDetails['nitrogen_status'] = 'adequate';
      analysisDetails['nitrogen_level'] = 'optimal';
    }
    
    // Check phosphorus
    if (soilAnalysis.phosphorus < optimalNPK['phosphorus']!['min']!) {
      deficiencies.add('Phosphorus');
      analysisDetails['phosphorus_status'] = 'deficient';
      analysisDetails['phosphorus_level'] = 'low';
    } else if (soilAnalysis.phosphorus > optimalNPK['phosphorus']!['max']!) {
      excesses.add('Phosphorus');
      analysisDetails['phosphorus_status'] = 'excess';
      analysisDetails['phosphorus_level'] = 'high';
    } else {
      analysisDetails['phosphorus_status'] = 'adequate';
      analysisDetails['phosphorus_level'] = 'optimal';
    }
    
    // Check potassium
    if (soilAnalysis.potassium < optimalNPK['potassium']!['min']!) {
      deficiencies.add('Potassium');
      analysisDetails['potassium_status'] = 'deficient';
      analysisDetails['potassium_level'] = 'low';
    } else if (soilAnalysis.potassium > optimalNPK['potassium']!['max']!) {
      excesses.add('Potassium');
      analysisDetails['potassium_status'] = 'excess';
      analysisDetails['potassium_level'] = 'high';
    } else {
      analysisDetails['potassium_status'] = 'adequate';
      analysisDetails['potassium_level'] = 'optimal';
    }
    
    // Check pH
    if (soilAnalysis.pH < 6.0) {
      analysisDetails['pH_status'] = 'acidic';
      analysisDetails['pH_recommendation'] = 'Add lime to increase pH';
    } else if (soilAnalysis.pH > 7.5) {
      analysisDetails['pH_status'] = 'alkaline';
      analysisDetails['pH_recommendation'] = 'Add sulfur to decrease pH';
    } else {
      analysisDetails['pH_status'] = 'optimal';
      analysisDetails['pH_recommendation'] = 'pH level is ideal for most crops';
    }
    
    // Check organic matter
    if (soilAnalysis.organicMatter < 2.0) {
      analysisDetails['organic_matter_status'] = 'low';
      analysisDetails['organic_matter_recommendation'] = 'Add compost or organic matter';
    } else if (soilAnalysis.organicMatter > 5.0) {
      analysisDetails['organic_matter_status'] = 'high';
      analysisDetails['organic_matter_recommendation'] = 'Organic matter level is excellent';
    } else {
      analysisDetails['organic_matter_status'] = 'adequate';
      analysisDetails['organic_matter_recommendation'] = 'Maintain current organic matter level';
    }
    
    return {
      'deficiencies': deficiencies,
      'excesses': excesses,
      'analysisDetails': analysisDetails,
    };
  }

  /// Select appropriate fertilizer products based on NPK requirements
  static List<FertilizerProduct> _selectFertilizerProducts(
    NPKRecommendation npkRecommendation,
    double fieldSize,
  ) {
    final selectedProducts = <FertilizerProduct>[];
    
    // Select nitrogen source if needed
    if (npkRecommendation.nitrogenDeficit > 10) {
      final urea = _fertilizerProducts.firstWhere((p) => p.id == 'urea-001');
      final quantity = (npkRecommendation.requiredNitrogen / (urea.npkComposition.nitrogen / 100)) * fieldSize;
      selectedProducts.add(urea.copyWith(
        recommendedQuantity: quantity,
        totalCost: quantity * urea.pricePerKg,
      ));
    }
    
    // Select phosphorus source if needed
    if (npkRecommendation.phosphorusDeficit > 5) {
      final dap = _fertilizerProducts.firstWhere((p) => p.id == 'dap-001');
      final quantity = (npkRecommendation.requiredPhosphorus / (dap.npkComposition.phosphorus / 100)) * fieldSize;
      selectedProducts.add(dap.copyWith(
        recommendedQuantity: quantity,
        totalCost: quantity * dap.pricePerKg,
      ));
    }
    
    // Select potassium source if needed
    if (npkRecommendation.potassiumDeficit > 10) {
      final mop = _fertilizerProducts.firstWhere((p) => p.id == 'mop-001');
      final quantity = (npkRecommendation.requiredPotassium / (mop.npkComposition.potassium / 100)) * fieldSize;
      selectedProducts.add(mop.copyWith(
        recommendedQuantity: quantity,
        totalCost: quantity * mop.pricePerKg,
      ));
    }
    
    // If multiple deficiencies, suggest complex fertilizer as alternative
    if (selectedProducts.length > 1) {
      final npkComplex = _fertilizerProducts.firstWhere((p) => p.id == 'npk-001');
      final maxDeficit = math.max(math.max(npkRecommendation.nitrogenDeficit, npkRecommendation.phosphorusDeficit), npkRecommendation.potassiumDeficit);
      final quantity = (maxDeficit * 2.0) * fieldSize; // Estimated quantity
      selectedProducts.add(npkComplex.copyWith(
        recommendedQuantity: quantity,
        totalCost: quantity * npkComplex.pricePerKg,
      ));
    }
    
    // Always recommend organic matter
    final organic = _fertilizerProducts.firstWhere((p) => p.id == 'organic-001');
    final organicQuantity = 1000 * fieldSize; // 1 ton per hectare
    selectedProducts.add(organic.copyWith(
      recommendedQuantity: organicQuantity,
      totalCost: organicQuantity * organic.pricePerKg,
    ));
    
    return selectedProducts;
  }

  /// Create application schedule based on crop type and requirements
  static ApplicationSchedule _createApplicationSchedule(String cropType, NPKRecommendation npkRecommendation) {
    final phases = <ApplicationPhase>[];
    
    // Base application at planting
    phases.add(ApplicationPhase(
      id: 'phase_1',
      name: 'Base Application',
      description: 'Apply phosphorus and part of potassium at planting',
      dayFromPlanting: 0,
      cropStage: 'planting',
      quantity: npkRecommendation.requiredPhosphorus * 0.8,
      method: 'broadcasting',
      instructions: [
        'Apply before planting or at the time of sowing',
        'Mix with soil thoroughly',
        'Ensure uniform distribution across the field',
      ],
    ));
    
    // Vegetative stage application
    phases.add(ApplicationPhase(
      id: 'phase_2',
      name: 'Vegetative Stage',
      description: 'Apply nitrogen for vegetative growth',
      dayFromPlanting: _getVegetativeStageDay(cropType),
      cropStage: 'vegetative',
      quantity: npkRecommendation.requiredNitrogen * 0.5,
      method: 'side-dressing',
      instructions: [
        'Apply when plants are actively growing',
        'Side-dress along crop rows',
        'Water immediately after application',
      ],
    ));
    
    // Reproductive stage application
    phases.add(ApplicationPhase(
      id: 'phase_3',
      name: 'Reproductive Stage',
      description: 'Apply remaining nutrients for flowering and fruiting',
      dayFromPlanting: _getReproductiveStageDay(cropType),
      cropStage: 'flowering',
      quantity: npkRecommendation.requiredPotassium * 0.6,
      method: 'foliar',
      instructions: [
        'Apply during early morning or evening',
        'Use foliar spray for better absorption',
        'Ensure good coverage of leaves',
      ],
    ));
    
    return ApplicationSchedule(
      phases: phases,
      totalDuration: '${_getCropDuration(cropType)} days',
      instructions: {
        'general': 'Follow the recommended schedule for optimal results',
        'weather': 'Avoid application during rainy weather',
        'safety': 'Use protective equipment during application',
        'storage': 'Store fertilizers in dry, cool place',
      },
    );
  }

  /// Calculate confidence score based on various factors
  static double _calculateConfidenceScore(SoilAnalysis soilAnalysis, Map<String, dynamic> analysisResults) {
    double score = 0.8; // Base confidence
    
    // Adjust based on data completeness
    if (soilAnalysis.labReportUrl != null) score += 0.1;
    if (soilAnalysis.pH > 0) score += 0.05;
    if (soilAnalysis.organicMatter > 0) score += 0.05;
    
    // Adjust based on analysis certainty
    final deficiencyCount = (analysisResults['deficiencies'] as List).length;
    if (deficiencyCount == 0) {
      score += 0.1;
    } else if (deficiencyCount > 3) score -= 0.1;
    
    return math.min(1.0, math.max(0.0, score));
  }

  /// Calculate estimated yield increase based on deficiencies addressed
  static double _calculateYieldIncrease(List<String> deficiencies) {
    double increase = 0.0;
    
    for (final deficiency in deficiencies) {
      switch (deficiency) {
        case 'Nitrogen':
          increase += 15.0; // 15% increase for addressing nitrogen deficiency
          break;
        case 'Phosphorus':
          increase += 10.0; // 10% increase for addressing phosphorus deficiency
          break;
        case 'Potassium':
          increase += 8.0;  // 8% increase for addressing potassium deficiency
          break;
      }
    }
    
    return math.min(40.0, increase); // Cap at 40% increase
  }

  /// Calculate ROI based on yield increase and costs
  static double _calculateROI(double yieldIncrease, double totalCost, double fieldSize) {
    // Assume average crop value per hectare
    const avgCropValuePerHectare = 80000.0; // INR per hectare
    final totalCropValue = avgCropValuePerHectare * fieldSize;
    final additionalIncome = totalCropValue * (yieldIncrease / 100);
    
    if (totalCost == 0) return 0.0;
    return ((additionalIncome - totalCost) / totalCost) * 100;
  }

  /// Calculate sustainability metrics
  static SustainabilityMetrics _calculateSustainabilityMetrics(List<FertilizerProduct> products) {
    double carbonFootprint = 0.0;
    double environmentalScore = 8.0; // Base score
    bool hasOrganic = false;
    
    for (final product in products) {
      if (product.type == 'organic') {
        hasOrganic = true;
        environmentalScore += 1.0;
        carbonFootprint += product.recommendedQuantity * 0.1; // Low carbon for organic
      } else {
        carbonFootprint += product.recommendedQuantity * 2.5; // Higher carbon for synthetic
        environmentalScore -= 0.5;
      }
    }
    
    return SustainabilityMetrics(
      carbonFootprint: carbonFootprint,
      environmentalScore: math.min(10.0, environmentalScore),
      isOrganicCertified: hasOrganic,
      waterEfficiency: 85.0 + (hasOrganic ? 10.0 : 0.0),
      soilHealthImpact: hasOrganic ? 0.8 : 0.2,
      sustainabilityFactors: [
        if (hasOrganic) 'Organic fertilizers included',
        'Balanced nutrition approach',
        'Soil health considered',
        'Reduced chemical dependency',
      ],
    );
  }

  // Helper methods for crop-specific recommendations
  static String _getNitrogenRecommendation(double deficit, String cropType) {
    if (deficit < 10) return 'Nitrogen levels are adequate';
    if (deficit < 50) return 'Apply nitrogen fertilizer in split doses during vegetative growth';
    return 'Significant nitrogen deficiency. Apply urea or ammonium sulfate in multiple applications';
  }

  static String _getPhosphorusRecommendation(double deficit, String cropType) {
    if (deficit < 5) return 'Phosphorus levels are adequate';
    if (deficit < 20) return 'Apply DAP or single super phosphate at planting';
    return 'Low phosphorus levels. Apply high-phosphorus fertilizer before planting';
  }

  static String _getPotassiumRecommendation(double deficit, String cropType) {
    if (deficit < 10) return 'Potassium levels are adequate';
    if (deficit < 40) return 'Apply muriate of potash during reproductive stage';
    return 'Potassium deficiency detected. Apply potassium fertilizer in split doses';
  }

  static String _getPHRecommendation(double pH) {
    if (pH < 5.5) return 'Soil is too acidic. Apply lime to increase pH to 6.0-7.0';
    if (pH > 8.0) return 'Soil is too alkaline. Apply sulfur or organic matter to reduce pH';
    return 'Soil pH is in optimal range for most crops';
  }

  static String _getOrganicMatterRecommendation(double organicMatter) {
    if (organicMatter < 1.5) return 'Very low organic matter. Apply compost regularly';
    if (organicMatter < 2.5) return 'Low organic matter. Add organic amendments';
    return 'Organic matter level is adequate for healthy soil';
  }

  static int _getVegetativeStageDay(String cropType) {
    switch (cropType) {
      case 'Rice': return 25;
      case 'Wheat': return 30;
      case 'Corn': return 20;
      case 'Cotton': return 35;
      case 'Sugarcane': return 45;
      default: return 30;
    }
  }

  static int _getReproductiveStageDay(String cropType) {
    switch (cropType) {
      case 'Rice': return 65;
      case 'Wheat': return 75;
      case 'Corn': return 50;
      case 'Cotton': return 80;
      case 'Sugarcane': return 90;
      default: return 60;
    }
  }

  static int _getCropDuration(String cropType) {
    switch (cropType) {
      case 'Rice': return 120;
      case 'Wheat': return 150;
      case 'Corn': return 100;
      case 'Cotton': return 180;
      case 'Sugarcane': return 365;
      default: return 120;
    }
  }
}

// Extension to add copyWith method to FertilizerProduct
extension FertilizerProductExtension on FertilizerProduct {
  FertilizerProduct copyWith({
    String? id,
    String? name,
    String? brand,
    String? type,
    NPKComposition? npkComposition,
    double? pricePerKg,
    double? recommendedQuantity,
    double? totalCost,
    String? availability,
    double? rating,
    String? description,
    List<String>? benefits,
    String? imageUrl,
  }) {
    return FertilizerProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      npkComposition: npkComposition ?? this.npkComposition,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      recommendedQuantity: recommendedQuantity ?? this.recommendedQuantity,
      totalCost: totalCost ?? this.totalCost,
      availability: availability ?? this.availability,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      benefits: benefits ?? this.benefits,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}