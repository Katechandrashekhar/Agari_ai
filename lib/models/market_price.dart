/// Market Price model for AgriAI app
/// Represents current market prices for different crops
class MarketPrice {
  final String id;
  final String cropName;
  final double price; // price per quintal (100 kg)
  final String unit; // 'quintal', 'kg', 'ton'
  final DateTime date;
  final String market; // market name or location
  final String state;
  final double minPrice;
  final double maxPrice;
  final String priceType; // 'wholesale', 'retail', 'mandi'
  final double changePercentage; // price change from previous day

  MarketPrice({
    required this.id,
    required this.cropName,
    required this.price,
    required this.unit,
    required this.date,
    required this.market,
    required this.state,
    required this.minPrice,
    required this.maxPrice,
    required this.priceType,
    required this.changePercentage,
  });

  /// Create MarketPrice from Firestore document
  factory MarketPrice.fromFirestore(Map<String, dynamic> data, String documentId) {
    return MarketPrice(
      id: documentId,
      cropName: data['cropName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'quintal',
      date: data['date']?.toDate() ?? DateTime.now(),
      market: data['market'] ?? '',
      state: data['state'] ?? '',
      minPrice: (data['minPrice'] ?? 0).toDouble(),
      maxPrice: (data['maxPrice'] ?? 0).toDouble(),
      priceType: data['priceType'] ?? 'wholesale',
      changePercentage: (data['changePercentage'] ?? 0).toDouble(),
    );
  }

  /// Convert MarketPrice to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'cropName': cropName,
      'price': price,
      'unit': unit,
      'date': date,
      'market': market,
      'state': state,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'priceType': priceType,
      'changePercentage': changePercentage,
    };
  }

  /// Get formatted price string
  String get formattedPrice {
    return '₹${price.toStringAsFixed(2)} per $unit';
  }

  /// Get price trend indicator
  String get priceStatus {
    if (changePercentage > 0) {
      return 'up';
    } else if (changePercentage < 0) {
      return 'down';
    } else {
      return 'stable';
    }
  }

  /// Get formatted change percentage
  String get formattedChange {
    String sign = changePercentage >= 0 ? '+' : '';
    return '$sign${changePercentage.toStringAsFixed(2)}%';
  }

  /// Calculate profit margin for farmer
  double calculateProfitMargin(double costPrice) {
    return ((price - costPrice) / costPrice) * 100;
  }
}