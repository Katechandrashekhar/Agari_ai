import 'dart:io';
import 'package:flutter/material.dart';
import '../models/marketplace_listing.dart';
import '../models/user.dart' as app_user;
import '../services/api_service.dart';
import '../services/image_service.dart';

/// Add Marketplace Listing Screen with image upload
/// Allows farmers to create new marketplace listings with photos
class AddListingScreen extends StatefulWidget {
  final app_user.User currentUser;
  
  const AddListingScreen({super.key, required this.currentUser});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _stateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _varietyController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedUnit = 'quintal';
  String _selectedGrade = 'B';
  bool _isOrganic = false;
  bool _isLoading = false;
  final List<File> _selectedImages = [];

  final List<String> _units = ['quintal', 'kg', 'ton'];
  final List<String> _grades = ['A+', 'A', 'B', 'C'];
  final List<String> _states = [
    'Andhra Pradesh', 'Bihar', 'Gujarat', 'Haryana', 'Karnataka', 
    'Madhya Pradesh', 'Maharashtra', 'Punjab', 'Rajasthan', 'Tamil Nadu', 
    'Telangana', 'Uttar Pradesh', 'West Bengal'
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill contact phone with user's phone number
    _contactController.text = widget.currentUser.phone.replaceAll('+91', '').trim();
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _stateController.dispose();
    _descriptionController.dispose();
    _varietyController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  /// Add image
  Future<void> _addImage() async {
    if (_selectedImages.length >= 5) {
      _showSnackBar('Maximum 5 images allowed');
      return;
    }

    final File? image = await ImageService.showImageSourceDialog(context);
    
    if (image != null) {
      if (ImageService.isValidImageFile(image)) {
        if (ImageService.isFileSizeValid(image, maxSizeMB: 10.0)) {
          setState(() {
            _selectedImages.add(image);
          });
        } else {
          _showSnackBar('Image size should be less than 10MB');
        }
      } else {
        _showSnackBar('Please select a valid image file');
      }
    }
  }

  /// Remove image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// Submit listing
  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Use the passed current user
    final currentUser = widget.currentUser;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create marketplace listing
      final listing = MarketplaceListing(
        id: '', // Will be set by Firestore
        farmerId: currentUser.id,
        farmerName: currentUser.name,
        cropName: _cropNameController.text.trim(),
        quantity: double.parse(_quantityController.text),
        pricePerQuintal: double.parse(_priceController.text),
        unit: _selectedUnit,
        dateListed: DateTime.now(),
        location: _locationController.text.trim(),
        state: _stateController.text.trim(),
        description: _descriptionController.text.trim(),
        cropVariety: _varietyController.text.trim(),
        qualityGrade: _selectedGrade,
        isOrganic: _isOrganic,
        isAvailable: true,
        imageUrls: [], // Will be updated after upload
        contactPhone: _contactController.text.trim(),
        status: 'active',
      );

      // Add listing with images
      final apiService = ApiService();
      final String? listingId = await apiService.addMarketplaceListing(
        listing, 
        imageFiles: _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (listingId != null) {
        _showSnackBar('Listing created successfully!');
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        _showSnackBar('Failed to create listing. Please try again.');
      }
    } catch (e) {
      print('Error creating listing: $e');
      _showSnackBar('Error creating listing: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Listing'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Images section
            _buildImageSection(),
            const SizedBox(height: 24),

            // Crop details
            _buildCropDetails(),
            const SizedBox(height: 24),

            // Location details
            _buildLocationDetails(),
            const SizedBox(height: 24),

            // Contact details
            _buildContactDetails(),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitListing,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create Listing', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Images (${_selectedImages.length}/5)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: _addImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photo'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedImages.isEmpty)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, 
                         size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text('No images selected', 
                         style: TextStyle(color: Colors.grey.shade600)),
                    const Text('Add photos to showcase your crop'),
                  ],
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImages[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crop Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cropNameController,
              decoration: const InputDecoration(
                labelText: 'Crop Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter crop name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _varietyController,
              decoration: const InputDecoration(
                labelText: 'Variety',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter crop variety';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: _units.map((unit) {
                      return DropdownMenuItem(value: unit, child: Text(unit));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price per Quintal (₹)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedGrade,
              decoration: const InputDecoration(
                labelText: 'Quality Grade',
                border: OutlineInputBorder(),
              ),
              items: _grades.map((grade) {
                return DropdownMenuItem(value: grade, child: Text(grade));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGrade = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Organic'),
              value: _isOrganic,
              onChanged: (value) {
                setState(() {
                  _isOrganic = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location/City',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _stateController.text.isNotEmpty ? _stateController.text : null,
              decoration: const InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
              ),
              items: _states.map((state) {
                return DropdownMenuItem(value: state, child: Text(state));
              }).toList(),
              onChanged: (value) {
                _stateController.text = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select state';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Contact Phone',
                border: OutlineInputBorder(),
                prefixText: '+91 ',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contact phone';
                }
                if (value.length != 10) {
                  return 'Please enter valid 10-digit phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}