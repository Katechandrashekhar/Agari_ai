import 'package:flutter/material.dart';
import '../models/soil_analysis.dart';
import '../models/fertilizer_recommendation.dart';
import '../services/fertilizer_recommendation_service.dart';
import '../services/pdf_report_service.dart';


class FertilizerRecommendationScreen extends StatefulWidget {
  const FertilizerRecommendationScreen({super.key});

  @override
  State<FertilizerRecommendationScreen> createState() => _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState extends State<FertilizerRecommendationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  FertilizerRecommendation? _currentRecommendation;
  bool _isAnalyzing = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSoilAnalysisComplete(SoilAnalysis soilAnalysis) {
    // Generate recommendation
    _generateRecommendation(soilAnalysis);
  }

  Future<void> _generateRecommendation(SoilAnalysis soilAnalysis) async {
    setState(() {
      _isAnalyzing = true;
      _currentRecommendation = null;
    });

    try {
      final recommendation = await FertilizerRecommendationService.generateRecommendation(soilAnalysis);
      
      setState(() {
        _currentRecommendation = recommendation;
        _isAnalyzing = false;
      });
      
      // Move to results tab
      _tabController.animateTo(2);
      
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating recommendation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '🌱 Fertilizer Recommendation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.science, size: 20),
              text: 'Soil Test',
            ),
            Tab(
              icon: Icon(Icons.upload_file, size: 20),
              text: 'Upload Report',
            ),
            Tab(
              icon: Icon(Icons.analytics, size: 20),
              text: 'Analysis Results',
            ),
            Tab(
              icon: Icon(Icons.schedule, size: 20),
              text: 'Schedule',
            ),
            Tab(
              icon: Icon(Icons.shopping_cart, size: 20),
              text: 'Products',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Soil Test Tab
          SoilTestForm(
            onAnalysisComplete: _onSoilAnalysisComplete,
            isAnalyzing: _isAnalyzing,
          ),
          
          // Upload Report Tab
          const UploadReportTab(),
          
          // Analysis Results Tab
          AnalysisResultsTab(
            recommendation: _currentRecommendation,
            isAnalyzing: _isAnalyzing,
          ),
          
          // Schedule Tab
          ApplicationScheduleTab(
            recommendation: _currentRecommendation,
          ),
          
          // Products Tab
          ProductsTab(
            recommendation: _currentRecommendation,
          ),
        ],
      ),
    );
  }
}

// Soil Test Form Widget
class SoilTestForm extends StatefulWidget {
  final Function(SoilAnalysis) onAnalysisComplete;
  final bool isAnalyzing;

  const SoilTestForm({
    super.key,
    required this.onAnalysisComplete,
    required this.isAnalyzing,
  });

  @override
  State<SoilTestForm> createState() => _SoilTestFormState();
}

class _SoilTestFormState extends State<SoilTestForm> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _phController = TextEditingController();
  final _organicMatterController = TextEditingController();
  final _moistureController = TextEditingController();
  final _fieldSizeController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCrop = 'Rice';
  
  final List<String> _supportedCrops = [
    'Rice', 'Wheat', 'Corn', 'Cotton', 'Sugarcane',
    'Soybean', 'Potato', 'Tomato', 'Onion'
  ];

  @override
  void dispose() {
    _cropController.dispose();
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _phController.dispose();
    _organicMatterController.dispose();
    _moistureController.dispose();
    _fieldSizeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && !widget.isAnalyzing) {
      final soilAnalysis = SoilAnalysis(
        id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
        farmerId: 'demo_farmer', // TODO: Replace with actual user ID when auth is implemented
        cropType: _selectedCrop,
        nitrogen: double.parse(_nitrogenController.text),
        phosphorus: double.parse(_phosphorusController.text),
        potassium: double.parse(_potassiumController.text),
        pH: double.parse(_phController.text),
        organicMatter: double.parse(_organicMatterController.text),
        moistureContent: double.parse(_moistureController.text),
        fieldSize: double.parse(_fieldSizeController.text),
        location: _locationController.text,
        testDate: DateTime.now(),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      widget.onAnalysisComplete(soilAnalysis);
    }
  }

  Widget _buildSmartTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required double min,
    required double max,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[600]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          
          final doubleValue = double.tryParse(value);
          if (doubleValue == null) {
            return 'Please enter a valid number';
          }
          
          if (doubleValue < min || doubleValue > max) {
            return '$label should be between $min and $max $suffix';
          }
          
          return null;
        },
        onChanged: (value) {
          // Real-time validation feedback
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.green[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.science, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Soil Analysis Input',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Enter your soil test parameters for AI-powered fertilizer recommendations',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop Selection
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCrop,
                    decoration: InputDecoration(
                      labelText: 'Select Crop',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: _supportedCrops.map((crop) {
                      return DropdownMenuItem(
                        value: crop,
                        child: Text(crop),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCrop = value!;
                      });
                    },
                  ),
                ),
                
                // NPK Section
                const Text(
                  'NPK Levels (Soil Test Results)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildSmartTextField(
                  controller: _nitrogenController,
                  label: 'Nitrogen (N)',
                  hint: 'Enter nitrogen level',
                  suffix: 'mg/kg',
                  min: 0,
                  max: 500,
                ),
                
                _buildSmartTextField(
                  controller: _phosphorusController,
                  label: 'Phosphorus (P)',
                  hint: 'Enter phosphorus level',
                  suffix: 'mg/kg',
                  min: 0,
                  max: 100,
                ),
                
                _buildSmartTextField(
                  controller: _potassiumController,
                  label: 'Potassium (K)',
                  hint: 'Enter potassium level',
                  suffix: 'mg/kg',
                  min: 0,
                  max: 800,
                ),
                
                const SizedBox(height: 24),
                
                // Soil Properties Section
                const Text(
                  'Soil Properties',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildSmartTextField(
                  controller: _phController,
                  label: 'Soil pH',
                  hint: 'Enter pH level',
                  suffix: '',
                  min: 3.0,
                  max: 10.0,
                ),
                
                _buildSmartTextField(
                  controller: _organicMatterController,
                  label: 'Organic Matter',
                  hint: 'Enter organic matter content',
                  suffix: '%',
                  min: 0,
                  max: 10,
                ),
                
                _buildSmartTextField(
                  controller: _moistureController,
                  label: 'Moisture Content',
                  hint: 'Enter moisture content',
                  suffix: '%',
                  min: 0,
                  max: 100,
                ),
                
                const SizedBox(height: 24),
                
                // Field Information Section
                const Text(
                  'Field Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildSmartTextField(
                  controller: _fieldSizeController,
                  label: 'Field Size',
                  hint: 'Enter field size',
                  suffix: 'hectares',
                  min: 0.1,
                  max: 1000,
                ),
                
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      hintText: 'Enter field location or address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                  ),
                ),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: widget.isAnalyzing ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: widget.isAnalyzing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Analyzing Soil...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            '🧪 Analyze Soil & Get Recommendations',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder widgets for other tabs
class UploadReportTab extends StatelessWidget {
  const UploadReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Upload Soil Report',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon - Upload PDF/Image reports',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class AnalysisResultsTab extends StatelessWidget {
  final FertilizerRecommendation? recommendation;
  final bool isAnalyzing;

  const AnalysisResultsTab({
    super.key,
    required this.recommendation,
    required this.isAnalyzing,
  });

  @override
  Widget build(BuildContext context) {
    if (isAnalyzing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Analyzing soil data...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (recommendation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Analysis Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Complete soil test to see AI recommendations',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with confidence score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI Analysis Results',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(recommendation!.confidenceScore * 100).toInt()}% Confidence',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Crop: ${recommendation!.cropType} | Estimated Yield Increase: ${recommendation!.estimatedYieldIncrease.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // PDF Export Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _exportToPDF(context, recommendation!),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text(
                'Export PDF Report',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // NPK Analysis Section
          _buildNPKAnalysisSection(recommendation!),
          
          const SizedBox(height: 20),
          
          // Deficiency Analysis
          _buildDeficiencyAnalysis(recommendation!),
          
          const SizedBox(height: 20),
          
          // Fertilizer Recommendations
          _buildFertilizerRecommendations(recommendation!),
          
          const SizedBox(height: 20),
          
          // Sustainability Metrics
          _buildSustainabilityMetrics(recommendation!),
        ],
      ),
    );
  }

  Widget _buildNPKAnalysisSection(FertilizerRecommendation recommendation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Text(
                'NPK Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // NPK Bars
          _buildNPKBar(
            'Nitrogen (N)',
            recommendation.npkRecommendation.currentNitrogen,
            recommendation.npkRecommendation.requiredNitrogen,
            Colors.red,
          ),
          
          const SizedBox(height: 16),
          
          _buildNPKBar(
            'Phosphorus (P)',
            recommendation.npkRecommendation.currentPhosphorus,
            recommendation.npkRecommendation.requiredPhosphorus,
            Colors.orange,
          ),
          
          const SizedBox(height: 16),
          
          _buildNPKBar(
            'Potassium (K)',
            recommendation.npkRecommendation.currentPotassium,
            recommendation.npkRecommendation.requiredPotassium,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildNPKBar(String nutrient, double current, double optimal, Color color) {
    final percentage = (current / optimal * 100).clamp(0, 100);
    final deficiency = optimal - current;
    final isDeficient = current < optimal;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              nutrient,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '${current.toStringAsFixed(1)} / ${optimal.toStringAsFixed(1)} mg/kg',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDeficient ? Colors.red[300] : color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 4),
        
        if (isDeficient)
          Text(
            'Deficiency: ${deficiency.toStringAsFixed(1)} mg/kg',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text(
            'Adequate levels',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildDeficiencyAnalysis(FertilizerRecommendation recommendation) {
    final deficiencies = <String>[];
    
    if (recommendation.npkRecommendation.nitrogenDeficit > 0) {
      deficiencies.add('Nitrogen');
    }
    if (recommendation.npkRecommendation.phosphorusDeficit > 0) {
      deficiencies.add('Phosphorus');
    }
    if (recommendation.npkRecommendation.potassiumDeficit > 0) {
      deficiencies.add('Potassium');
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                deficiencies.isEmpty ? Icons.check_circle : Icons.warning,
                color: deficiencies.isEmpty ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Deficiency Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: deficiencies.isEmpty ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (deficiencies.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Great! Your soil has adequate nutrient levels for optimal crop growth.',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: deficiencies.map((nutrient) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$nutrient Deficiency Detected',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDeficiencyDescription(nutrient),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _getDeficiencyDescription(String nutrient) {
    switch (nutrient) {
      case 'Nitrogen':
        return 'May cause stunted growth, yellowing leaves, and reduced yield. Recommended: Apply nitrogen-rich fertilizers.';
      case 'Phosphorus':
        return 'Can lead to poor root development and delayed maturity. Recommended: Apply phosphorus fertilizers.';
      case 'Potassium':
        return 'May result in weak stems and increased disease susceptibility. Recommended: Apply potash fertilizers.';
      default:
        return 'Nutrient deficiency detected. Consider appropriate fertilizer application.';
    }
  }

  Widget _buildFertilizerRecommendations(FertilizerRecommendation recommendation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.agriculture, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Text(
                'Recommended Fertilizers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...recommendation.recommendedProducts.take(3).map((product) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.npkComposition.npkRatio,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Application Rate: ${product.recommendedQuantity.toStringAsFixed(1)} kg/ha',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    'Price: ₹${product.pricePerKg.toStringAsFixed(0)}/kg',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSustainabilityMetrics(FertilizerRecommendation recommendation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Text(
                'Sustainability Impact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Environmental Score',
                  '${recommendation.sustainabilityMetrics.environmentalScore.toStringAsFixed(1)}/10',
                  Icons.nature,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Cost Efficiency',
                  '₹${recommendation.estimatedCost.toStringAsFixed(0)}/ha',
                  Icons.monetization_on,
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Expected ROI',
                  '${recommendation.roi.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Soil Health',
                  '${((recommendation.sustainabilityMetrics.soilHealthImpact + 1) * 50).toInt()}%',
                  Icons.grass,
                  Colors.brown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPDF(BuildContext context, FertilizerRecommendation recommendation) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating PDF Report...'),
            ],
          ),
        ),
      );

      // Create a mock soil analysis for the PDF (in real app, this would be passed properly)
      final soilAnalysis = SoilAnalysis(
        id: 'temp_soil_analysis',
        farmerId: 'current_farmer',
        cropType: recommendation.cropType,
        nitrogen: recommendation.npkRecommendation.currentNitrogen,
        phosphorus: recommendation.npkRecommendation.currentPhosphorus,
        potassium: recommendation.npkRecommendation.currentPotassium,
        pH: 6.5, // Default value
        organicMatter: 3.5, // Default value
        moistureContent: 25.0, // Default value
        fieldSize: 2.0, // Default value
        location: 'Farm Location',
        testDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Generate PDF
      final pdfBytes = await PDFReportService.generateFertilizerReport(
        recommendation: recommendation,
        soilAnalysis: soilAnalysis,
        farmerName: 'Farmer Name', // You can get this from user context
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show options dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Report Generated'),
          content: const Text('What would you like to do with the report?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await PDFReportService.savePDF(pdfBytes, 'fertilizer_report_${DateTime.now().millisecondsSinceEpoch}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report saved successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving report: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await PDFReportService.sharePDF(pdfBytes, 'fertilizer_report_${DateTime.now().millisecondsSinceEpoch}');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sharing report: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Share'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await PDFReportService.printPDF(pdfBytes);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error printing report: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Print'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ApplicationScheduleTab extends StatelessWidget {
  final FertilizerRecommendation? recommendation;

  const ApplicationScheduleTab({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Schedule Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Complete soil analysis to get application schedule',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[600]!, Colors.orange[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Application Schedule',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Duration: ${recommendation!.applicationSchedule.totalDuration}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Schedule Timeline
          ...recommendation!.applicationSchedule.phases.asMap().entries.map((entry) {
            final index = entry.key;
            final phase = entry.value;
            final isCompleted = phase.isCompleted;
            final isLast = index == recommendation!.applicationSchedule.phases.length - 1;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.schedule,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Phase details
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCompleted ? Colors.green[200]! : Colors.orange[200]!,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200]!,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  phase.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCompleted ? Colors.green[100] : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isCompleted ? 'Completed' : 'Pending',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? Colors.green[700] : Colors.orange[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            phase.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Phase details
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Day ${phase.dayFromPlanting} (${phase.cropStage})',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 6),
                                
                                Row(
                                  children: [
                                    const Icon(Icons.fitness_center, size: 16, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Quantity: ${phase.quantity.toStringAsFixed(1)} kg/ha',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 6),
                                
                                Row(
                                  children: [
                                    const Icon(Icons.build, size: 16, color: Colors.purple),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Method: ${phase.method}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                if (phase.scheduledDate != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.event, size: 16, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Scheduled: ${_formatDate(phase.scheduledDate!)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          if (phase.instructions.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Instructions:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...phase.instructions.map((instruction) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.only(top: 6, right: 8),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      instruction,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                          
                          if (!isCompleted) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Mark as completed
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Feature coming soon: Mark application as completed'),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Mark as Completed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ProductsTab extends StatelessWidget {
  final FertilizerRecommendation? recommendation;

  const ProductsTab({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Products Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Complete soil analysis to see recommended fertilizers',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[600]!, Colors.purple[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Recommended Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'AI-selected fertilizers optimized for your soil and crop',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Cost Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Estimated Cost',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${recommendation!.estimatedCost.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Expected ROI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${recommendation!.roi.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Product List
          ...recommendation!.recommendedProducts.map((product) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Header
                  Row(
                    children: [
                      // Product Image Placeholder
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.brand,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(product.type).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _getTypeColor(product.type)),
                                  ),
                                  child: Text(
                                    product.type.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getTypeColor(product.type),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    product.npkComposition.npkRatio,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Availability Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getAvailabilityColor(product.availability).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getAvailabilityColor(product.availability)),
                        ),
                        child: Text(
                          product.availability.replaceAll('-', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getAvailabilityColor(product.availability),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Product Description
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Product Details
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                'Price per kg',
                                '₹${product.pricePerKg.toStringAsFixed(0)}',
                                Icons.currency_rupee,
                                Colors.blue,
                              ),
                            ),
                            Expanded(
                              child: _buildDetailItem(
                                'Recommended Qty',
                                '${product.recommendedQuantity.toStringAsFixed(1)} kg/ha',
                                Icons.fitness_center,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                'Total Cost',
                                '₹${product.totalCost.toStringAsFixed(0)}',
                                Icons.monetization_on,
                                Colors.orange,
                              ),
                            ),
                            Expanded(
                              child: _buildDetailItem(
                                'Rating',
                                '${product.rating.toStringAsFixed(1)} ⭐',
                                Icons.star,
                                Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Benefits
                  if (product.benefits.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Key Benefits:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...product.benefits.take(3).map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              benefit,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _showProductDetails(context, product);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: product.availability == 'in-stock' ? () {
                            _addToCart(context, product);
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'organic':
        return Colors.green;
      case 'inorganic':
        return Colors.blue;
      case 'mixed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getAvailabilityColor(String availability) {
    switch (availability.toLowerCase()) {
      case 'in-stock':
        return Colors.green;
      case 'limited':
        return Colors.orange;
      case 'out-of-stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showProductDetails(BuildContext context, FertilizerProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Brand: ${product.brand}'),
              const SizedBox(height: 8),
              Text('Type: ${product.type}'),
              const SizedBox(height: 8),
              Text('NPK Ratio: ${product.npkComposition.npkRatio}'),
              const SizedBox(height: 8),
              Text('Description: ${product.description}'),
              const SizedBox(height: 12),
              const Text(
                'Benefits:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...product.benefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text('• $benefit'),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, FertilizerProduct product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }
}