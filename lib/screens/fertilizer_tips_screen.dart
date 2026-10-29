import 'package:flutter/material.dart';
import '../models/fertilizer.dart';
import '../widgets/fertilizer_card.dart';
import '../services/api_service.dart';

/// Fertilizer tips screen for AgriAI app
/// Provides fertilizer recommendations and information
class FertilizerTipsScreen extends StatefulWidget {
  const FertilizerTipsScreen({super.key});

  @override
  State<FertilizerTipsScreen> createState() => _FertilizerTipsScreenState();
}

class _FertilizerTipsScreenState extends State<FertilizerTipsScreen> {
  final ApiService _apiService = ApiService();
  
  List<Fertilizer> _allFertilizers = [];
  List<Fertilizer> _filteredFertilizers = [];
  bool _isLoading = true;
  String _selectedCropType = '';
  String _selectedFertilizerType = '';
  double _acreage = 1.0;

  final List<String> _cropTypes = [
    'Rice',
    'Wheat',
    'Maize',
    'Cotton',
    'Sugarcane',
    'Vegetables',
    'Fruits',
    'Pulses',
    'Oilseeds',
    'Spices',
    'Fodder Crops',
    'Cash Crops',
    'Millets',
    'Barley',
    'Sorghum',
    'Groundnut',
    'Soybean',
    'Mustard',
    'Turmeric',
    'Ginger',
  ];

  final List<String> _fertilizerTypes = [
    'organic',
    'inorganic',
    'bio-fertilizer',
    'liquid-fertilizer',
    'slow-release',
    'micronutrient',
    'foliar-spray',
  ];

  @override
  void initState() {
    super.initState();
    _loadFertilizers();
  }

  /// Load fertilizers data
  Future<void> _loadFertilizers() async {
    try {
      // Load real fertilizers from API
      _allFertilizers = await _apiService.fetchAllFertilizers();
      
      // If API fails, fallback to demo data
      if (_allFertilizers.isEmpty) {
        _loadDemoFertilizers();
      }
      
      _filteredFertilizers = List.from(_allFertilizers);
    } catch (e) {
      print('Error loading fertilizers: $e');
      // Fallback to demo data on error
      _loadDemoFertilizers();
      _filteredFertilizers = List.from(_allFertilizers);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Load demo fertilizers
  void _loadDemoFertilizers() {
    _allFertilizers = [
      // NPK Fertilizers
      Fertilizer(
        id: '1',
        name: 'NPK 20:10:10',
        cropType: 'Rice',
        recommendedQuantity: 125.0,
        type: 'inorganic',
        npkRatio: 20.0,
        applicationMethod: 'Broadcasting and soil incorporation',
        applicationTiming: 'Basal application before transplanting',
        pricePerKg: 25.0,
        description: 'Complete fertilizer with balanced NPK for rice cultivation',
        benefits: ['Balanced nutrition', 'Improved tillering', 'Better grain filling'],
        precautions: ['Store in dry place', 'Avoid contact with skin', 'Use protective gear'],
      ),
      Fertilizer(
        id: '2',
        name: 'NPK 19:19:19',
        cropType: 'Vegetables',
        recommendedQuantity: 150.0,
        type: 'inorganic',
        npkRatio: 19.0,
        applicationMethod: 'Drip irrigation or broadcasting',
        applicationTiming: 'Multiple applications during growth',
        pricePerKg: 28.0,
        description: 'Balanced NPK fertilizer ideal for vegetable crops',
        benefits: ['Complete nutrition', 'Improves fruit quality', 'Increases yield'],
        precautions: ['Follow recommended dosage', 'Ensure soil moisture', 'Wear gloves'],
      ),
      Fertilizer(
        id: '3',
        name: 'NPK 15:15:15',
        cropType: 'Fruits',
        recommendedQuantity: 200.0,
        type: 'inorganic',
        npkRatio: 15.0,
        applicationMethod: 'Ring application around trees',
        applicationTiming: 'Before flowering and fruit development',
        pricePerKg: 22.0,
        description: 'Balanced fertilizer for fruit trees and orchards',
        benefits: ['Promotes flowering', 'Improves fruit size', 'Better fruit quality'],
        precautions: ['Apply away from trunk', 'Water thoroughly', 'Store in cool place'],
      ),
      
      // Organic Fertilizers
      Fertilizer(
        id: '4',
        name: 'Vermicompost',
        cropType: 'Vegetables',
        recommendedQuantity: 2000.0,
        type: 'organic',
        npkRatio: 2.0,
        applicationMethod: 'Soil mixing before planting',
        applicationTiming: '2-3 weeks before sowing',
        pricePerKg: 8.0,
        description: 'Organic fertilizer rich in nutrients and beneficial microorganisms',
        benefits: ['Improves soil structure', 'Enhances water retention', 'Eco-friendly'],
        precautions: ['Ensure proper composting', 'Check for pests', 'Store in ventilated area'],
      ),
      Fertilizer(
        id: '5',
        name: 'Cow Dung Manure',
        cropType: 'Fruits',
        recommendedQuantity: 5000.0,
        type: 'organic',
        npkRatio: 0.5,
        applicationMethod: 'Broadcasting and incorporation',
        applicationTiming: '4-6 weeks before planting',
        pricePerKg: 3.0,
        description: 'Traditional organic manure for soil enrichment',
        benefits: ['Improves soil fertility', 'Increases organic matter', 'Slow nutrient release'],
        precautions: ['Ensure complete decomposition', 'Avoid fresh manure', 'Mix well with soil'],
      ),
      Fertilizer(
        id: '6',
        name: 'Neem Cake',
        cropType: 'Cotton',
        recommendedQuantity: 250.0,
        type: 'organic',
        npkRatio: 5.0,
        applicationMethod: 'Soil application with irrigation',
        applicationTiming: 'At sowing and 45 days after',
        pricePerKg: 15.0,
        description: 'Organic fertilizer with pest control properties',
        benefits: ['Nutrient supply', 'Pest deterrent', 'Improves soil health'],
        precautions: ['Store away from moisture', 'Apply evenly', 'Avoid direct seed contact'],
      ),
      
      // Single Nutrient Fertilizers
      Fertilizer(
        id: '7',
        name: 'Urea',
        cropType: 'Wheat',
        recommendedQuantity: 87.0,
        type: 'inorganic',
        npkRatio: 46.0,
        applicationMethod: 'Broadcasting with irrigation',
        applicationTiming: 'Split application - 3 times',
        pricePerKg: 6.0,
        description: 'High nitrogen fertilizer for cereal crops',
        benefits: ['Quick nitrogen release', 'Promotes vegetative growth', 'Cost effective'],
        precautions: ['Avoid over-application', 'Apply with moisture', 'Store away from heat'],
      ),
      Fertilizer(
        id: '8',
        name: 'Single Super Phosphate (SSP)',
        cropType: 'Pulses',
        recommendedQuantity: 125.0,
        type: 'inorganic',
        npkRatio: 16.0,
        applicationMethod: 'Basal application in furrows',
        applicationTiming: 'At the time of sowing',
        pricePerKg: 8.5,
        description: 'Phosphorus fertilizer essential for root development',
        benefits: ['Strong root system', 'Better nodulation', 'Improved seed formation'],
        precautions: ['Apply in root zone', 'Ensure soil contact', 'Store in dry conditions'],
      ),
      Fertilizer(
        id: '9',
        name: 'Muriate of Potash (MOP)',
        cropType: 'Sugarcane',
        recommendedQuantity: 100.0,
        type: 'inorganic',
        npkRatio: 60.0,
        applicationMethod: 'Side dressing and earthing up',
        applicationTiming: '2-3 months after planting',
        pricePerKg: 18.0,
        description: 'Potassium fertilizer for improved quality and disease resistance',
        benefits: ['Better sugar content', 'Disease resistance', 'Improved quality'],
        precautions: ['Avoid chloride sensitive crops', 'Apply with irrigation', 'Store properly'],
      ),
      
      // Bio-Fertilizers
      Fertilizer(
        id: '10',
        name: 'Rhizobium Bio-fertilizer',
        cropType: 'Pulses',
        recommendedQuantity: 2.0,
        type: 'bio-fertilizer',
        npkRatio: 0.0,
        applicationMethod: 'Seed treatment before sowing',
        applicationTiming: 'At sowing time',
        pricePerKg: 40.0,
        description: 'Bacterial inoculant for nitrogen fixation in legumes',
        benefits: ['Nitrogen fixation', 'Cost savings', 'Eco-friendly'],
        precautions: ['Use within expiry', 'Store in cool place', 'Avoid chemical treatment'],
      ),
      Fertilizer(
        id: '11',
        name: 'PSB (Phosphate Solubilizing Bacteria)',
        cropType: 'Rice',
        recommendedQuantity: 2.0,
        type: 'bio-fertilizer',
        npkRatio: 0.0,
        applicationMethod: 'Seed treatment or soil application',
        applicationTiming: 'At sowing and transplanting',
        pricePerKg: 35.0,
        description: 'Bacterial culture for phosphorus solubilization',
        benefits: ['Phosphorus availability', 'Root development', 'Natural process'],
        precautions: ['Maintain cold chain', 'Use fresh culture', 'Avoid pesticide mixing'],
      ),
      
      // Micronutrient Fertilizers
      Fertilizer(
        id: '12',
        name: 'Zinc Sulphate',
        cropType: 'Maize',
        recommendedQuantity: 25.0,
        type: 'micronutrient',
        npkRatio: 0.0,
        applicationMethod: 'Soil application or foliar spray',
        applicationTiming: 'Before sowing or at 30 days',
        pricePerKg: 45.0,
        description: 'Micronutrient fertilizer for zinc deficiency correction',
        benefits: ['Corrects zinc deficiency', 'Improves grain quality', 'Better plant growth'],
        precautions: ['Follow recommended dose', 'Test soil before use', 'Avoid overdose'],
      ),
      Fertilizer(
        id: '13',
        name: 'Boron Fertilizer',
        cropType: 'Mustard',
        recommendedQuantity: 2.0,
        type: 'micronutrient',
        npkRatio: 0.0,
        applicationMethod: 'Foliar spray at flowering',
        applicationTiming: 'Pre-flowering and pod filling',
        pricePerKg: 120.0,
        description: 'Essential micronutrient for flowering and seed formation',
        benefits: ['Better flowering', 'Improved seed formation', 'Quality enhancement'],
        precautions: ['Very low dose required', 'Avoid leaf burn', 'Use in evening'],
      ),
      
      // Liquid Fertilizers
      Fertilizer(
        id: '14',
        name: 'Liquid NPK 12:12:12',
        cropType: 'Vegetables',
        recommendedQuantity: 5.0,
        type: 'liquid-fertilizer',
        npkRatio: 12.0,
        applicationMethod: 'Fertigation through drip system',
        applicationTiming: 'Weekly application during growth',
        pricePerKg: 85.0,
        description: 'Liquid fertilizer for drip irrigation systems',
        benefits: ['Easy application', 'Quick absorption', 'Precise nutrition'],
        precautions: ['Dilute properly', 'Clean filters regularly', 'Store away from sunlight'],
      ),
      
      // Specialty Fertilizers
      Fertilizer(
        id: '15',
        name: 'Calcium Nitrate',
        cropType: 'Tomato',
        recommendedQuantity: 75.0,
        type: 'inorganic',
        npkRatio: 15.5,
        applicationMethod: 'Fertigation or soil application',
        applicationTiming: 'During fruit development',
        pricePerKg: 35.0,
        description: 'Calcium and nitrogen source for quality fruit production',
        benefits: ['Prevents blossom end rot', 'Improves fruit quality', 'Strong cell walls'],
        precautions: ['Highly soluble', 'Avoid mixing with sulphates', 'Store in dry place'],
      ),
      
      // Organic Compost Variants
      Fertilizer(
        id: '16',
        name: 'Poultry Manure',
        cropType: 'Vegetables',
        recommendedQuantity: 1500.0,
        type: 'organic',
        npkRatio: 3.0,
        applicationMethod: 'Broadcasting and incorporation',
        applicationTiming: '3-4 weeks before planting',
        pricePerKg: 5.0,
        description: 'High nutrient organic manure from poultry waste',
        benefits: ['High nutrient content', 'Quick nutrient release', 'Soil enrichment'],
        precautions: ['Ensure complete composting', 'Avoid fresh application', 'Mix thoroughly'],
      ),
      Fertilizer(
        id: '17',
        name: 'Seaweed Extract',
        cropType: 'Fruits',
        recommendedQuantity: 10.0,
        type: 'organic',
        npkRatio: 1.0,
        applicationMethod: 'Foliar spray or soil drench',
        applicationTiming: 'Every 15 days during growth',
        pricePerKg: 200.0,
        description: 'Natural growth enhancer from marine algae',
        benefits: ['Plant growth regulator', 'Stress tolerance', 'Better fruit quality'],
        precautions: ['Dilute as per instructions', 'Apply in cool hours', 'Store in cool place'],
      ),
    ];
  }

  /// Filter fertilizers
  void _filterFertilizers() {
    _filteredFertilizers = _allFertilizers.where((fertilizer) {
      bool matchesCrop = _selectedCropType.isEmpty || 
          fertilizer.cropType.toLowerCase().contains(_selectedCropType.toLowerCase());
      bool matchesType = _selectedFertilizerType.isEmpty || 
          fertilizer.type.toLowerCase() == _selectedFertilizerType.toLowerCase();
      return matchesCrop && matchesType;
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertilizer Tips'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filters section
                _buildFiltersSection(),
                
                // Fertilizers list
                Expanded(
                  child: _buildFertilizersList(),
                ),
              ],
            ),
    );
  }

  /// Build filters section
  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Fertilizers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCropType.isEmpty ? null : _selectedCropType,
                  decoration: InputDecoration(
                    labelText: 'Crop Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('All Crops'),
                    ),
                    ..._cropTypes.map((crop) {
                      return DropdownMenuItem(
                        value: crop,
                        child: Text(crop),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCropType = value ?? '';
                      _filterFertilizers();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedFertilizerType.isEmpty ? null : _selectedFertilizerType,
                  decoration: InputDecoration(
                    labelText: 'Fertilizer Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('All Types'),
                    ),
                    ..._fertilizerTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFertilizerType = value ?? '';
                      _filterFertilizers();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text('Farm Size: ${_acreage.toStringAsFixed(1)} acres'),
          Slider(
            value: _acreage,
            min: 0.5,
            max: 20.0,
            divisions: 39,
            label: '${_acreage.toStringAsFixed(1)} acres',
            onChanged: (value) {
              setState(() {
                _acreage = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Build fertilizers list
  Widget _buildFertilizersList() {
    if (_filteredFertilizers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No fertilizers found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredFertilizers.length,
      itemBuilder: (context, index) {
        final fertilizer = _filteredFertilizers[index];
        return FertilizerCard(
          fertilizer: fertilizer,
          acreage: _acreage,
          showCostCalculation: true,
          onTap: () => _showFertilizerDetails(fertilizer),
        );
      },
    );
  }

  /// Show fertilizer details
  void _showFertilizerDetails(Fertilizer fertilizer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(fertilizer.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(fertilizer.description),
                const SizedBox(height: 16),
                
                Text(
                  'Application Details:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Method: ${fertilizer.applicationMethod}'),
                Text('Timing: ${fertilizer.applicationTiming}'),
                Text('Recommended Quantity: ${fertilizer.recommendedQuantity} kg/acre'),
                const SizedBox(height: 16),
                
                if (fertilizer.benefits.isNotEmpty) ...[
                  const Text(
                    'Benefits:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...fertilizer.benefits.map((benefit) => Text('• $benefit')),
                  const SizedBox(height: 16),
                ],
                
                if (fertilizer.precautions.isNotEmpty) ...[
                  const Text(
                    'Precautions:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  ...fertilizer.precautions.map((precaution) => Text('• $precaution')),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}