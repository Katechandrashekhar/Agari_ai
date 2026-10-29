import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/api_service.dart';

/// Weather screen for AgriAI app
/// Shows current weather and forecast with farming advice
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _locationController = TextEditingController();
  
  Weather? _currentWeather;
  List<Weather> _forecast = [];
  bool _isLoading = true;
  String _currentLocation = 'Pune';

  @override
  void initState() {
    super.initState();
    _locationController.text = _currentLocation;
    _loadWeatherData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  /// Load weather data
  Future<void> _loadWeatherData() async {
    try {
      setState(() => _isLoading = true);
      
      _currentWeather = await _apiService.fetchWeatherData(_currentLocation);
      _forecast = await _apiService.fetchWeatherForecast(_currentLocation);
    } catch (e) {
      print('Error loading weather data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Search weather for new location
  Future<void> _searchLocation() async {
    final location = _locationController.text.trim();
    if (location.isNotEmpty && location != _currentLocation) {
      setState(() {
        _currentLocation = location;
      });
      await _loadWeatherData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Info'),
        backgroundColor: Colors.amber[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Location search
                  _buildLocationSearch(),
                  
                  // Current weather
                  if (_currentWeather != null) ...[
                    _buildCurrentWeather(),
                    
                    // Farming advice
                    _buildFarmingAdvice(),
                    
                    // Weather details
                    _buildWeatherDetails(),
                  ],
                  
                  // Forecast
                  if (_forecast.isNotEmpty) ...[
                    _buildForecastSection(),
                  ],
                  
                  // Farming activities
                  _buildFarmingActivities(),
                ],
              ),
            ),
    );
  }

  /// Build location search
  Widget _buildLocationSearch() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Enter location',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (_) => _searchLocation(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _searchLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  /// Build current weather
  Widget _buildCurrentWeather() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _currentLocation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentWeather!.weatherIcon,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_currentWeather!.temperature.toInt()}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentWeather!.weatherCondition,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Text(
            _currentWeather!.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherStat('Min', '${_currentWeather!.minTemperature.toInt()}°C'),
              _buildWeatherStat('Max', '${_currentWeather!.maxTemperature.toInt()}°C'),
              _buildWeatherStat('Humidity', '${_currentWeather!.humidity.toInt()}%'),
            ],
          ),
        ],
      ),
    );
  }

  /// Build weather stat
  Widget _buildWeatherStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build farming advice
  Widget _buildFarmingAdvice() {
    return Container(
      margin: const EdgeInsets.all(16),
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
            children: [
              Icon(Icons.lightbulb, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Farming Advice',
                style: TextStyle(
                  color: Colors.green[800],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentWeather!.farmingAdvice,
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Build weather details
  Widget _buildWeatherDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weather Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildDetailCard('Wind Speed', '${_currentWeather!.windSpeed.toInt()} km/h', Icons.air),
              _buildDetailCard('Pressure', '${_currentWeather!.pressure.toInt()} hPa', Icons.speed),
              _buildDetailCard('UV Index', '${_currentWeather!.uvIndex}', Icons.wb_sunny),
              _buildDetailCard('Rainfall', '${_currentWeather!.rainfall.toInt()} mm', Icons.water_drop),
            ],
          ),
        ],
      ),
    );
  }

  /// Build detail card
  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue[600], size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build forecast section
  Widget _buildForecastSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5-Day Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _forecast.length,
              itemBuilder: (context, index) {
                final weather = _forecast[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatDate(weather.date),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather.weatherIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weather.temperature.toInt()}°C',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
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
    );
  }

  /// Build farming activities
  Widget _buildFarmingActivities() {
    final activities = [
      {'name': 'Spraying', 'suitable': _currentWeather!.isSuitableFor('spraying')},
      {'name': 'Harvesting', 'suitable': _currentWeather!.isSuitableFor('harvesting')},
      {'name': 'Sowing', 'suitable': _currentWeather!.isSuitableFor('sowing')},
      {'name': 'Irrigation', 'suitable': _currentWeather!.isSuitableFor('irrigation')},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farming Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ...activities.map((activity) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: activity['suitable'] as bool ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: activity['suitable'] as bool ? Colors.green[200]! : Colors.red[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  activity['suitable'] as bool ? Icons.check_circle : Icons.cancel,
                  color: activity['suitable'] as bool ? Colors.green[600] : Colors.red[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    activity['name'] as String,
                    style: TextStyle(
                      color: activity['suitable'] as bool ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  activity['suitable'] as bool ? 'Suitable' : 'Not Suitable',
                  style: TextStyle(
                    color: activity['suitable'] as bool ? Colors.green[600] : Colors.red[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}