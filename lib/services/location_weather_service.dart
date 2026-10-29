import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class WeatherInfo {
  final String location;
  final String description;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String icon;
  final List<ForecastDay> forecast;

  WeatherInfo({
    required this.location,
    required this.description,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.forecast,
  });
}

class ForecastDay {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String description;
  final String icon;
  final int humidity;

  ForecastDay({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.icon,
    required this.humidity,
  });
}

class LocationWeatherService extends ChangeNotifier {
  static const String _weatherApiKey =
      String.fromEnvironment('OPENWEATHER_API_KEY');
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  WeatherInfo? _currentWeather;
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentPosition;
  String? _currentLocationName;

  WeatherInfo? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentLocationName => _currentLocationName;

  // Request location permissions
  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorMessage = 'Location permission denied. Please enable location access in settings.';
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _errorMessage = 'Location permission permanently denied. Please enable in device settings.';
      await openAppSettings();
      return false;
    }

    return true;
  }

  // Get current location
  Future<Position?> _getCurrentLocation() async {
    try {
      if (!await _requestLocationPermission()) {
        return null;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services disabled. Please enable GPS.';
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get location name
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentLocationName = '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
      }

      return position;
    } catch (e) {
      _errorMessage = 'Failed to get location: ${e.toString()}';
      return null;
    }
  }

  // Fetch weather data from API
  Future<void> fetchCurrentWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location
      _currentPosition = await _getCurrentLocation();
      if (_currentPosition == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch current weather
      final weatherUrl = '$_baseUrl/weather?lat=${_currentPosition!.latitude}&lon=${_currentPosition!.longitude}&appid=$_weatherApiKey&units=metric';
      final weatherResponse = await http.get(Uri.parse(weatherUrl));

      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        
        // Fetch 5-day forecast
        final forecastUrl = '$_baseUrl/forecast?lat=${_currentPosition!.latitude}&lon=${_currentPosition!.longitude}&appid=$_weatherApiKey&units=metric';
        final forecastResponse = await http.get(Uri.parse(forecastUrl));
        
        List<ForecastDay> forecast = [];
        if (forecastResponse.statusCode == 200) {
          final forecastData = json.decode(forecastResponse.body);
          forecast = _parseForecast(forecastData);
        }

        _currentWeather = WeatherInfo(
          location: _currentLocationName ?? 'Unknown Location',
          description: weatherData['weather'][0]['description'],
          temperature: weatherData['main']['temp'].toDouble(),
          humidity: weatherData['main']['humidity'],
          windSpeed: weatherData['wind']['speed'].toDouble(),
          icon: weatherData['weather'][0]['icon'],
          forecast: forecast,
        );

        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to fetch weather data. Please check your internet connection.';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Parse forecast data
  List<ForecastDay> _parseForecast(Map<String, dynamic> forecastData) {
    List<ForecastDay> forecast = [];
    Map<String, List<dynamic>> dailyData = {};

    // Group forecast by date
    for (var item in forecastData['list']) {
      String date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).toString().split(' ')[0];
      if (!dailyData.containsKey(date)) {
        dailyData[date] = [];
      }
      dailyData[date]!.add(item);
    }

    // Create daily forecast (next 5 days)
    int count = 0;
    for (var entry in dailyData.entries) {
      if (count >= 5) break;
      
      List<dynamic> dayData = entry.value;
      double maxTemp = dayData.map<double>((item) => item['main']['temp_max'].toDouble()).reduce((a, b) => a > b ? a : b);
      double minTemp = dayData.map<double>((item) => item['main']['temp_min'].toDouble()).reduce((a, b) => a < b ? a : b);
      
      // Use midday data for description and icon
      var midDayData = dayData.length > 2 ? dayData[dayData.length ~/ 2] : dayData[0];
      
      forecast.add(ForecastDay(
        date: entry.key,
        maxTemp: maxTemp,
        minTemp: minTemp,
        description: midDayData['weather'][0]['description'],
        icon: midDayData['weather'][0]['icon'],
        humidity: midDayData['main']['humidity'],
      ));
      
      count++;
    }

    return forecast;
  }

  // Get farming advice based on weather
  String getFarmingAdvice() {
    if (_currentWeather == null) return '';

    String advice = '';
    final temp = _currentWeather!.temperature;
    final humidity = _currentWeather!.humidity;
    final description = _currentWeather!.description.toLowerCase();

    // Temperature-based advice
    if (temp > 35) {
      advice += '🌡️ **High Temperature Alert**: Very hot weather (${temp.round()}°C)\n';
      advice += '• Provide shade for livestock\n';
      advice += '• Increase irrigation frequency\n';
      advice += '• Avoid heavy field work during midday\n';
      advice += '• Check water levels regularly\n\n';
    } else if (temp < 10) {
      advice += '❄️ **Cold Weather Alert**: Cold conditions (${temp.round()}°C)\n';
      advice += '• Protect sensitive crops from frost\n';
      advice += '• Reduce watering frequency\n';
      advice += '• Consider covering young plants\n\n';
    }

    // Weather condition-based advice
    if (description.contains('rain') || description.contains('drizzle')) {
      advice += '🌧️ **Rain Forecast**: ${_currentWeather!.description}\n';
      advice += '• Postpone irrigation\n';
      advice += '• Ensure proper drainage\n';
      advice += '• Cover harvested crops\n';
      advice += '• Good time for transplanting\n\n';
    } else if (description.contains('clear') || description.contains('sun')) {
      advice += '☀️ **Clear Weather**: Perfect for farming activities\n';
      advice += '• Good conditions for spraying\n';
      advice += '• Ideal for harvesting\n';
      advice += '• Monitor soil moisture\n\n';
    }

    // Humidity-based advice
    if (humidity > 80) {
      advice += '💧 **High Humidity**: $humidity% humidity\n';
      advice += '• Watch for fungal diseases\n';
      advice += '• Improve air circulation\n';
      advice += '• Delay fungicide application\n\n';
    } else if (humidity < 30) {
      advice += '🏜️ **Low Humidity**: $humidity% humidity\n';
      advice += '• Increase irrigation\n';
      advice += '• Mulch around plants\n';
      advice += '• Monitor for pest attacks\n\n';
    }

    // Wind-based advice
    if (_currentWeather!.windSpeed > 10) {
      advice += '💨 **High Wind**: ${_currentWeather!.windSpeed.round()} m/s wind speed\n';
      advice += '• Avoid pesticide spraying\n';
      advice += '• Support tall crops\n';
      advice += '• Check greenhouse structures\n\n';
    }

    return advice.isNotEmpty ? advice : 'Current weather conditions are favorable for normal farming activities.';
  }

  // Get crop-specific weather advice
  String getCropSpecificWeatherAdvice(String cropName) {
    if (_currentWeather == null) return '';

    final temp = _currentWeather!.temperature;
    final humidity = _currentWeather!.humidity;
    final description = _currentWeather!.description.toLowerCase();
    
    String advice = '🌾 **Weather Advice for ${cropName.toUpperCase()}**:\n\n';

    switch (cropName.toLowerCase()) {
      case 'wheat':
      case 'गेहूं':
        if (temp > 25) {
          advice += '⚠️ Temperature too high for wheat (${temp.round()}°C)\n';
          advice += '• Increase irrigation frequency\n';
          advice += '• Apply mulch to reduce soil temperature\n';
        }
        if (description.contains('rain') && temp > 20) {
          advice += '🌧️ Rain during warm weather may cause rust disease\n';
          advice += '• Apply fungicide if necessary\n';
        }
        break;

      case 'rice':
      case 'धान':
        if (temp < 15 || temp > 35) {
          advice += '⚠️ Temperature not ideal for rice (${temp.round()}°C)\n';
          advice += '• Monitor crop stress\n';
        }
        if (!description.contains('rain') && humidity < 70) {
          advice += '💧 Rice needs high humidity and water\n';
          advice += '• Maintain standing water in fields\n';
        }
        break;

      case 'cotton':
      case 'कपास':
        if (temp > 32) {
          advice += '🌡️ Hot weather good for cotton fiber development\n';
          advice += '• Ensure adequate water supply\n';
        }
        if (humidity > 85) {
          advice += '💧 High humidity may cause boll rot\n';
          advice += '• Improve drainage\n';
          advice += '• Monitor for fungal diseases\n';
        }
        break;

      case 'tomato':
      case 'टमाटर':
        if (temp > 30 || temp < 15) {
          advice += '⚠️ Temperature stress for tomatoes (${temp.round()}°C)\n';
          advice += '• Provide shade during hot hours\n';
        }
        if (humidity > 80) {
          advice += '💧 High humidity increases disease risk\n';
          advice += '• Improve ventilation\n';
          advice += '• Apply preventive fungicide\n';
        }
        break;

      default:
        advice += '📊 Current conditions:\n';
        advice += '• Temperature: ${temp.round()}°C\n';
        advice += '• Humidity: $humidity%\n';
        advice += '• Weather: ${_currentWeather!.description}\n';
        advice += getFarmingAdvice();
    }

    return advice;
  }

  // Format weather for chat display
  String getWeatherSummary() {
    if (_currentWeather == null) return 'Weather data not available';

    return '''📍 **${_currentWeather!.location}**

🌡️ **Temperature**: ${_currentWeather!.temperature.round()}°C
🌤️ **Condition**: ${_currentWeather!.description}
💧 **Humidity**: ${_currentWeather!.humidity}%
💨 **Wind Speed**: ${_currentWeather!.windSpeed.round()} m/s

**5-Day Forecast:**
${_currentWeather!.forecast.map((day) => 
  '${day.date}: ${day.maxTemp.round()}°/${day.minTemp.round()}°C - ${day.description}'
).join('\n')}

${getFarmingAdvice()}''';
  }
}