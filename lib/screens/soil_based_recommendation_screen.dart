import 'package:flutter/material.dart';
import '../services/crop_recommendation_service.dart';

class SoilBasedRecommendationScreen extends StatefulWidget {
  const SoilBasedRecommendationScreen({super.key});

  @override
  State<SoilBasedRecommendationScreen> createState() => _SoilBasedRecommendationScreenState();
}

class _SoilBasedRecommendationScreenState extends State<SoilBasedRecommendationScreen> {
  final CropRecommendationService _recommendationService = CropRecommendationService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  List<String> _recommendedCrops = [];

  // Form values
  double _nitrogen = 50.0;
  double _phosphorus = 50.0;
  double _potassium = 50.0;
  double _temperature = 25.0;
  double _humidity = 65.0;
  double _ph = 6.5;
  double _rainfall = 100.0;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() => _isLoading = true);
    
    try {
      await _recommendationService.initialize();
    } catch (e) {
      print('Error initializing crop recommendation service: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getRecommendations() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Debug the current soil parameters
      print('Fetching recommendations with parameters:');
      print('N: $_nitrogen, P: $_phosphorus, K: $_potassium');
      print('Temp: $_temperature, Humidity: $_humidity, pH: $_ph, Rainfall: $_rainfall');
      
      List<String> recommendations = await _recommendationService.getRecommendedCrops(
        nitrogen: _nitrogen,
        phosphorus: _phosphorus,
        potassium: _potassium,
        temperature: _temperature,
        humidity: _humidity,
        ph: _ph,
        rainfall: _rainfall,
      );
      
      print('Found ${recommendations.length} recommendations: $recommendations');
      
      setState(() {
        _recommendedCrops = recommendations;
      });
    } catch (e) {
      print('Error getting recommendations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting recommendations: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Based Crop Recommendation'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildForm(),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Finding the best crops for your soil...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Crop Recommendation Based on Soil Properties',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Using your soil analysis results and local climate conditions, we can recommend the best crops for you.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Soil and Climate Parameters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Nitrogen
              _buildSlider(
                title: 'Nitrogen (N) - kg/ha',
                value: _nitrogen,
                min: 0,
                max: 140,
                onChanged: (value) {
                  setState(() => _nitrogen = value);
                },
              ),
              
              // Phosphorus
              _buildSlider(
                title: 'Phosphorus (P) - kg/ha',
                value: _phosphorus,
                min: 0,
                max: 140,
                onChanged: (value) {
                  setState(() => _phosphorus = value);
                },
              ),
              
              // Potassium
              _buildSlider(
                title: 'Potassium (K) - kg/ha',
                value: _potassium,
                min: 0,
                max: 200,
                onChanged: (value) {
                  setState(() => _potassium = value);
                },
              ),
              
              // Temperature
              _buildSlider(
                title: 'Temperature (°C)',
                value: _temperature,
                min: 10,
                max: 40,
                onChanged: (value) {
                  setState(() => _temperature = value);
                },
              ),
              
              // Humidity
              _buildSlider(
                title: 'Humidity (%)',
                value: _humidity,
                min: 20,
                max: 100,
                onChanged: (value) {
                  setState(() => _humidity = value);
                },
              ),
              
              // pH
              _buildSlider(
                title: 'Soil pH',
                value: _ph,
                min: 3,
                max: 10,
                onChanged: (value) {
                  setState(() => _ph = value);
                },
              ),
              
              // Rainfall
              _buildSlider(
                title: 'Rainfall (mm)',
                value: _rainfall,
                min: 0,
                max: 300,
                onChanged: (value) {
                  setState(() => _rainfall = value);
                },
              ),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _getRecommendations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Get Crop Recommendations',
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
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ${value.toStringAsFixed(1)}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 5).round(),
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_recommendedCrops.isEmpty) {
      // Show an empty state if no recommendations have been requested yet
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Matching Crops Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try adjusting your soil parameters to find suitable crops for your conditions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Recommended Crops',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recommendedCrops.length,
              itemBuilder: (context, index) {
                final crop = _recommendedCrops[index];
                return _buildCropItem(crop, index + 1);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: These recommendations are based on the parameters you provided. For best results, please consult with your local agricultural expert.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropItem(String cropName, int rank) {
    Map<String, IconData> cropIcons = {
      'rice': Icons.grass,
      'wheat': Icons.grass,
      'maize': Icons.emoji_nature,
      'jute': Icons.emoji_nature,
      'cotton': Icons.emoji_nature,
      'coconut': Icons.emoji_nature,
      'papaya': Icons.emoji_food_beverage,
      'orange': Icons.emoji_food_beverage,
      'apple': Icons.emoji_food_beverage,
      'muskmelon': Icons.emoji_food_beverage,
      'watermelon': Icons.emoji_food_beverage,
      'grapes': Icons.emoji_food_beverage,
      'mango': Icons.emoji_food_beverage,
      'banana': Icons.emoji_food_beverage,
      'pomegranate': Icons.emoji_food_beverage,
      'lentil': Icons.emoji_nature,
      'blackgram': Icons.emoji_nature,
      'mungbean': Icons.emoji_nature,
      'mothbeans': Icons.emoji_nature,
      'pigeonpeas': Icons.emoji_nature,
      'kidneybeans': Icons.emoji_nature,
      'chickpea': Icons.emoji_nature,
      'coffee': Icons.emoji_food_beverage,
    };

    IconData cropIcon = cropIcons[cropName.toLowerCase()] ?? Icons.agriculture;
    
    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.green[700]!;
    } else if (rank == 2) {
      rankColor = Colors.green[500]!;
    } else if (rank == 3) {
      rankColor = Colors.green[300]!;
    } else {
      rankColor = Colors.grey;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: rankColor, width: 1),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rankColor.withValues(alpha: 0.2),
          child: Icon(cropIcon, color: rankColor),
        ),
        title: Text(
          cropName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          rank == 1 
              ? 'Most Optimal Crop'
              : rank == 2
                  ? 'Highly Recommended'
                  : rank == 3 
                      ? 'Recommended'
                      : 'Suitable Option',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showCropDetails(cropName),
        ),
      ),
    );
  }

  void _showCropDetails(String cropName) {
    final details = _recommendationService.getCropDetails(cropName);
    
    if (details == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crop details not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cropName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ideal Conditions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDetailItem('Nitrogen', '${details['nitrogen'].toStringAsFixed(1)} kg/ha'),
              _buildDetailItem('Phosphorus', '${details['phosphorus'].toStringAsFixed(1)} kg/ha'),
              _buildDetailItem('Potassium', '${details['potassium'].toStringAsFixed(1)} kg/ha'),
              _buildDetailItem('Temperature', '${details['temperature'].toStringAsFixed(1)} °C'),
              _buildDetailItem('Humidity', '${details['humidity'].toStringAsFixed(1)} %'),
              _buildDetailItem('pH', details['ph'].toStringAsFixed(1)),
              _buildDetailItem('Rainfall', '${details['rainfall'].toStringAsFixed(1)} mm'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}