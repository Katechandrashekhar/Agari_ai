import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;
import '../models/crop.dart';
import '../models/fertilizer.dart';
import '../models/marketplace_listing.dart';

/// Service class for handling Firestore database operations
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User-related operations
  Future<app_user.User?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return app_user.User.fromJson(data);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  Future<void> createUser(app_user.User user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  Future<void> updateUser(app_user.User user) async {
    try {
      await _db.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Crop-related operations
  Future<List<Crop>> getCrops() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('crops').get();
      return querySnapshot.docs
          .map((doc) => Crop.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting crops: $e');
      return [];
    }
  }

  Future<void> addCrop(Crop crop) async {
    try {
      await _db.collection('crops').doc(crop.id).set(crop.toJson());
    } catch (e) {
      print('Error adding crop: $e');
    }
  }

  Future<List<Crop>> getCropsByType(String cropType) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('crops')
          .where('name', isEqualTo: cropType)
          .get();
      return querySnapshot.docs
          .map((doc) => Crop.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting crops by type: $e');
      return [];
    }
  }

  // Fertilizer-related operations
  Future<List<Fertilizer>> getFertilizers() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('fertilizers').get();
      return querySnapshot.docs
          .map((doc) => Fertilizer.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting fertilizers: $e');
      return [];
    }
  }

  Future<void> addFertilizer(Fertilizer fertilizer) async {
    try {
      await _db.collection('fertilizers').doc(fertilizer.id).set(fertilizer.toJson());
    } catch (e) {
      print('Error adding fertilizer: $e');
    }
  }

  Future<List<Fertilizer>> getFertilizersByCrop(String cropType) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('fertilizers')
          .where('cropType', isEqualTo: cropType)
          .get();
      return querySnapshot.docs
          .map((doc) => Fertilizer.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting fertilizers by crop: $e');
      return [];
    }
  }

  // Marketplace-related operations
  Future<List<MarketplaceListing>> getMarketplaceListings() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('marketplace_listings')
          .where('isAvailable', isEqualTo: true)
          .orderBy('dateListed', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => MarketplaceListing.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting marketplace listings: $e');
      return [];
    }
  }

  Future<List<MarketplaceListing>> getMarketplaceListingsByFarmer(String farmerId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('marketplace_listings')
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('dateListed', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => MarketplaceListing.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting farmer listings: $e');
      return [];
    }
  }

  Future<void> addMarketplaceListing(MarketplaceListing listing) async {
    try {
      await _db.collection('marketplace_listings').doc(listing.id).set(listing.toJson());
    } catch (e) {
      print('Error adding marketplace listing: $e');
    }
  }

  Future<void> updateMarketplaceListing(MarketplaceListing listing) async {
    try {
      await _db.collection('marketplace_listings').doc(listing.id).update(listing.toJson());
    } catch (e) {
      print('Error updating marketplace listing: $e');
    }
  }

  Future<void> deleteMarketplaceListing(String listingId) async {
    try {
      await _db.collection('marketplace_listings').doc(listingId).delete();
    } catch (e) {
      print('Error deleting marketplace listing: $e');
    }
  }

  // Helper method to initialize sample data
  Future<void> initializeSampleData() async {
    try {
      // Check if data already exists
      QuerySnapshot cropsSnapshot = await _db.collection('crops').limit(1).get();
      if (cropsSnapshot.docs.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      // Add sample crops
      List<Crop> sampleCrops = [
        Crop(
          id: '1',
          name: 'Rice',
          description: 'Staple grain crop suitable for tropical climate',
          soilType: 'Clay loam',
          recommendedFertilizer: 'NPK 20:10:10',
          season: 'Kharif',
          minTemperature: 20.0,
          maxTemperature: 35.0,
          minRainfall: 1000.0,
          maxRainfall: 2500.0,
          growthDuration: 120,
          benefits: ['High nutrition content', 'Good market demand', 'Multiple varieties available'],
        ),
        Crop(
          id: '2',
          name: 'Wheat',
          description: 'Major cereal grain for temperate regions',
          soilType: 'Loam',
          recommendedFertilizer: 'DAP + Urea',
          season: 'Rabi',
          minTemperature: 10.0,
          maxTemperature: 25.0,
          minRainfall: 300.0,
          maxRainfall: 1000.0,
          growthDuration: 120,
          benefits: ['Good protein content', 'High demand', 'Stable market price'],
        ),
      ];

      for (Crop crop in sampleCrops) {
        await addCrop(crop);
      }

      // Add sample fertilizers
      List<Fertilizer> sampleFertilizers = [
        Fertilizer(
          id: '1',
          name: 'NPK 20:10:10',
          cropType: 'Rice',
          recommendedQuantity: 125.0,
          type: 'inorganic',
          npkRatio: 20.0,
          applicationMethod: 'Broadcasting',
          applicationTiming: 'Basal application',
          pricePerKg: 25.0,
          description: 'Complete fertilizer with balanced NPK',
          benefits: ['Balanced nutrition', 'Improved tillering'],
          precautions: ['Store in dry place', 'Use protective gear'],
        ),
        Fertilizer(
          id: '2',
          name: 'Vermicompost',
          cropType: 'Vegetables',
          recommendedQuantity: 2000.0,
          type: 'organic',
          npkRatio: 2.0,
          applicationMethod: 'Soil mixing',
          applicationTiming: '2-3 weeks before sowing',
          pricePerKg: 8.0,
          description: 'Organic fertilizer rich in nutrients',
          benefits: ['Improves soil structure', 'Eco-friendly'],
          precautions: ['Ensure proper composting', 'Check for pests'],
        ),
      ];

      for (Fertilizer fertilizer in sampleFertilizers) {
        await addFertilizer(fertilizer);
      }

      print('Sample data initialized successfully');
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }
}