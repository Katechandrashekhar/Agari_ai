import 'dart:io';
import 'package:flutter/material.dart';
import '../services/disease_detection_service.dart';
import '../models/crop_disease.dart';

/// Screen for crop disease detection using camera/image upload
class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final DiseaseDetectionService _diseaseService = DiseaseDetectionService();
  File? _selectedImage;
  CropDisease? _detectedDisease;
  bool _isLoading = false;
  bool _showHistory = false;
  List<CropDisease> _detectionHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _diseaseService.initializeModel();
  }

  /// Load detection history
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final history = await _diseaseService.getDetectionHistory();
      setState(() {
        _detectionHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Take a photo using camera
  Future<void> _takePhoto() async {
    final File? imageFile = await _diseaseService.takePhoto();
    if (imageFile != null) {
      setState(() {
        _selectedImage = imageFile;
        _detectedDisease = null;
      });
      _detectDisease(imageFile);
    }
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    final File? imageFile = await _diseaseService.pickImage();
    if (imageFile != null) {
      setState(() {
        _selectedImage = imageFile;
        _detectedDisease = null;
      });
      _detectDisease(imageFile);
    }
  }

  /// Detect disease in the selected image
  Future<void> _detectDisease(File imageFile) async {
    setState(() => _isLoading = true);
    
    try {
      final disease = await _diseaseService.detectDisease(imageFile);
      setState(() {
        _detectedDisease = disease;
        _isLoading = false;
        // Refresh history after detection
        _loadHistory();
      });
    } catch (e) {
      debugPrint('Error detecting disease: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error detecting disease. Please try again.')),
        );
      }
    }
  }

  /// Show image capture options
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Disease Detection'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showHistory ? Icons.camera_alt : Icons.history),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
                if (_showHistory) {
                  _loadHistory();
                }
              });
            },
            tooltip: _showHistory ? 'New Detection' : 'Detection History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showHistory
              ? _buildHistoryView()
              : _buildDetectionView(),
      floatingActionButton: !_showHistory
          ? FloatingActionButton(
              onPressed: _showImageOptions,
              backgroundColor: Colors.green,
              child: const Icon(Icons.add_a_photo, color: Colors.white),
            )
          : null,
    );
  }

  /// Build the detection view
  Widget _buildDetectionView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview area
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Take or select a photo of your crop',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _showImageOptions,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Add Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            
            if (_detectedDisease != null) ...[
              const SizedBox(height: 24),
              _buildDiseaseDetails(_detectedDisease!),
            ],
          ],
        ),
      ),
    );
  }

  /// Build the history view
  Widget _buildHistoryView() {
    if (_detectionHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No detection history available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _detectionHistory.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final disease = _detectionHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: InkWell(
            onTap: () {
              setState(() {
                _detectedDisease = disease;
                _showHistory = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: disease.name.toLowerCase().contains('healthy')
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          disease.name.toLowerCase().contains('healthy')
                              ? Icons.check_circle
                              : Icons.warning,
                          color: disease.name.toLowerCase().contains('healthy')
                              ? Colors.green[700]
                              : Colors.red[700],
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              disease.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Crop: ${disease.cropType}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(disease.confidence),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(disease.confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build disease details section
  Widget _buildDiseaseDetails(CropDisease disease) {
    final isHealthy = disease.name.toLowerCase().contains('healthy');
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHealthy ? Colors.green[100] : Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isHealthy ? Icons.check_circle : Icons.warning,
                    color: isHealthy ? Colors.green[700] : Colors.red[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disease.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Crop: ${disease.cropType}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(disease.confidence),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Confidence: ${(disease.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailSection('Description', disease.description),
            _buildDetailSection('Symptoms', disease.symptoms),
            _buildDetailSection('Treatment', disease.treatment),
            _buildDetailSection('Prevention', disease.prevention),
          ],
        ),
      ),
    );
  }

  /// Build a detail section
  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Get confidence indicator color
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}