/// Marketplace Listing model for AgriAI app
/// Represents farmer listings of crops for sale in the marketplace
class MarketplaceListing {
  final String id;
  final String farmerId;
  final String farmerName;
  final String cropName;
  final double quantity; // in quintals
  final double pricePerQuintal;
  final String unit; // 'quintal', 'kg', 'ton'
  final DateTime dateListed;
  final String location;
  final String state;
  final String description;
  final String cropVariety;
  final String qualityGrade; // 'A', 'B', 'C'
  final bool isOrganic;
  final bool isAvailable;
  final List<String> imageUrls;
  final String contactPhone;
  final String status; // 'active', 'sold', 'expired'
  final DateTime? expiryDate;

  MarketplaceListing({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.cropName,
    required this.quantity,
    required this.pricePerQuintal,
    required this.unit,
    required this.dateListed,
    required this.location,
    required this.state,
    required this.description,
    required this.cropVariety,
    required this.qualityGrade,
    required this.isOrganic,
    required this.isAvailable,
    required this.imageUrls,
    required this.contactPhone,
    required this.status,
    this.expiryDate,
  });

  /// Create MarketplaceListing from Firestore document
  factory MarketplaceListing.fromFirestore(Map<String, dynamic> data, String documentId) {
    return MarketplaceListing(
      id: documentId,
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? '',
      cropName: data['cropName'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      pricePerQuintal: (data['pricePerQuintal'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'quintal',
      dateListed: data['dateListed']?.toDate() ?? DateTime.now(),
      location: data['location'] ?? '',
      state: data['state'] ?? '',
      description: data['description'] ?? '',
      cropVariety: data['cropVariety'] ?? '',
      qualityGrade: data['qualityGrade'] ?? 'B',
      isOrganic: data['isOrganic'] ?? false,
      isAvailable: data['isAvailable'] ?? true,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      contactPhone: data['contactPhone'] ?? '',
      status: data['status'] ?? 'active',
      expiryDate: data['expiryDate']?.toDate(),
    );
  }

  /// Convert MarketplaceListing to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'cropName': cropName,
      'quantity': quantity,
      'pricePerQuintal': pricePerQuintal,
      'unit': unit,
      'dateListed': dateListed,
      'location': location,
      'state': state,
      'description': description,
      'cropVariety': cropVariety,
      'qualityGrade': qualityGrade,
      'isOrganic': isOrganic,
      'isAvailable': isAvailable,
      'imageUrls': imageUrls,
      'contactPhone': contactPhone,
      'status': status,
      'expiryDate': expiryDate,
    };
  }

  /// Convert MarketplaceListing to JSON for Firebase
  Map<String, dynamic> toJson() => toFirestore();

  /// Create MarketplaceListing from JSON/Firebase data
  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    return MarketplaceListing(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      cropName: json['cropName'] ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      pricePerQuintal: (json['pricePerQuintal'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? 'quintal',
      dateListed: json['dateListed']?.toDate() ?? DateTime.now(),
      location: json['location'] ?? '',
      state: json['state'] ?? '',
      description: json['description'] ?? '',
      cropVariety: json['cropVariety'] ?? '',
      qualityGrade: json['qualityGrade'] ?? 'A',
      isOrganic: json['isOrganic'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      contactPhone: json['contactPhone'] ?? '',
      status: json['status'] ?? 'active',
      expiryDate: json['expiryDate']?.toDate(),
    );
  }

  /// Get total value of the listing
  double get totalValue {
    return quantity * pricePerQuintal;
  }

  /// Get formatted price string
  String get formattedPrice {
    return '₹${pricePerQuintal.toStringAsFixed(2)} per $unit';
  }

  /// Get formatted total value
  String get formattedTotalValue {
    return '₹${totalValue.toStringAsFixed(2)}';
  }

  /// Check if listing is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Get days since listed
  int get daysSinceListed {
    return DateTime.now().difference(dateListed).inDays;
  }

  /// Get organic badge text
  String get organicBadge {
    return isOrganic ? 'Organic' : 'Conventional';
  }

  /// Create a copy with updated fields
  MarketplaceListing copyWith({
    String? status,
    bool? isAvailable,
    double? quantity,
    double? pricePerQuintal,
    String? description,
  }) {
    return MarketplaceListing(
      id: id,
      farmerId: farmerId,
      farmerName: farmerName,
      cropName: cropName,
      quantity: quantity ?? this.quantity,
      pricePerQuintal: pricePerQuintal ?? this.pricePerQuintal,
      unit: unit,
      dateListed: dateListed,
      location: location,
      state: state,
      description: description ?? this.description,
      cropVariety: cropVariety,
      qualityGrade: qualityGrade,
      isOrganic: isOrganic,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrls: imageUrls,
      contactPhone: contactPhone,
      status: status ?? this.status,
      expiryDate: expiryDate,
    );
  }
}