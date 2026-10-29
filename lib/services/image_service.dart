import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Image service for AgriAI app
/// Handles image picking, uploading, and management
class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Pick single image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick single image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      // Limit the number of images
      final List<XFile> limitedImages = images.take(maxImages).toList();
      
      return limitedImages.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  /// Show image source selection dialog
  static Future<File?> showImageSourceDialog(context) async {
    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final File? image = await pickImageFromGallery();
                  Navigator.of(context).pop(image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final File? image = await pickImageFromCamera();
                  Navigator.of(context).pop(image);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Upload image to Firebase Storage
  static Future<String?> uploadImage(File imageFile, String folder, String fileName) async {
    try {
      // Create a reference to the file location
      final Reference ref = _storage.ref().child('$folder/$fileName');
      
      // Upload the file with metadata
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'max-age=86400', // Cache for 1 day
        ),
      );
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload multiple images
  static Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, 
    String folder, 
    String baseFileName,
  ) async {
    List<String> imageUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final File imageFile = imageFiles[i];
      final String fileName = '${baseFileName}_$i.jpg';
      
      final String? imageUrl = await uploadImage(imageFile, folder, fileName);
      
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }
    
    return imageUrls;
  }

  /// Delete image from Firebase Storage
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Delete multiple images
  static Future<bool> deleteMultipleImages(List<String> imageUrls) async {
    try {
      for (String imageUrl in imageUrls) {
        await deleteImage(imageUrl);
      }
      return true;
    } catch (e) {
      print('Error deleting images: $e');
      return false;
    }
  }

  /// Generate unique filename with timestamp
  static String generateFileName(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp.$extension';
  }

  /// Validate image file
  static bool isValidImageFile(File file) {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif'].contains(extension);
    } catch (e) {
      return false;
    }
  }

  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    try {
      final bytes = file.lengthSync();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if file size is within limit
  static bool isFileSizeValid(File file, {double maxSizeMB = 10.0}) {
    final double fileSizeMB = getFileSizeInMB(file);
    return fileSizeMB <= maxSizeMB;
  }
}