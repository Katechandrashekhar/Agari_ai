/// Weather model for AgriAI app
/// Represents weather data for farming decisions
class Weather {
  final String id;
  final String location;
  final double temperature; // in Celsius
  final double humidity; // percentage
  final double rainfall; // in mm
  final double windSpeed; // in km/h
  final String weatherCondition; // 'sunny', 'cloudy', 'rainy', etc.
  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final int uvIndex;
  final double pressure; // in hPa
  final String description;

  Weather({
    required this.id,
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
    required this.weatherCondition,
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.uvIndex,
    required this.pressure,
    required this.description,
  });

  /// Create Weather from Firestore document
  factory Weather.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Weather(
      id: documentId,
      location: data['location'] ?? '',
      temperature: (data['temperature'] ?? 0).toDouble(),
      humidity: (data['humidity'] ?? 0).toDouble(),
      rainfall: (data['rainfall'] ?? 0).toDouble(),
      windSpeed: (data['windSpeed'] ?? 0).toDouble(),
      weatherCondition: data['weatherCondition'] ?? 'sunny',
      date: data['date']?.toDate() ?? DateTime.now(),
      minTemperature: (data['minTemperature'] ?? 0).toDouble(),
      maxTemperature: (data['maxTemperature'] ?? 0).toDouble(),
      uvIndex: data['uvIndex'] ?? 0,
      pressure: (data['pressure'] ?? 0).toDouble(),
      description: data['description'] ?? '',
    );
  }

  /// Convert Weather to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'location': location,
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      'windSpeed': windSpeed,
      'weatherCondition': weatherCondition,
      'date': date,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'uvIndex': uvIndex,
      'pressure': pressure,
      'description': description,
    };
  }

  /// Get farming advice based on weather conditions
  String get farmingAdvice {
    if (rainfall > 20) {
      return 'Heavy rainfall expected. Avoid fertilizer application and harvesting.';
    } else if (temperature > 35) {
      return 'High temperature. Ensure adequate irrigation and avoid midday farming activities.';
    } else if (humidity > 80) {
      return 'High humidity. Watch for fungal diseases and ensure proper ventilation.';
    } else if (windSpeed > 25) {
      return 'Strong winds expected. Secure light structures and avoid spraying operations.';
    } else {
      return 'Good weather conditions for farming activities.';
    }
  }

  /// Check if weather is suitable for specific farming activity
  bool isSuitableFor(String activity) {
    switch (activity.toLowerCase()) {
      case 'spraying':
        return windSpeed < 15 && rainfall < 1;
      case 'harvesting':
        return rainfall < 5 && windSpeed < 20;
      case 'sowing':
        return rainfall < 10 && temperature > 15 && temperature < 35;
      case 'irrigation':
        return rainfall < 5;
      default:
        return true;
    }
  }

  /// Get weather icon based on condition
  String get weatherIcon {
    switch (weatherCondition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return '☀️';
      case 'cloudy':
      case 'partly cloudy':
        return '☁️';
      case 'rainy':
      case 'rain':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'foggy':
      case 'mist':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}