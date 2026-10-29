import 'package:flutter/material.dart';
import '../models/crop.dart';

/// Reusable widget for displaying crop information
/// Used in crop suggestion and dashboard screens
class CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onTap;
  final bool showRecommendation;

  const CropCard({
    super.key,
    required this.crop,
    this.onTap,
    this.showRecommendation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with crop name and season
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      crop.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSeasonColor(crop.season),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      crop.season.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Crop description
              Text(
                crop.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Crop details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.landscape,
                      label: 'Soil',
                      value: crop.soilType,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.schedule,
                      label: 'Duration',
                      value: '${crop.growthDuration} days',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Temperature and rainfall range
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.thermostat,
                      label: 'Temp',
                      value: '${crop.minTemperature.toInt()}-${crop.maxTemperature.toInt()}°C',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.water_drop,
                      label: 'Rainfall',
                      value: '${crop.minRainfall.toInt()}-${crop.maxRainfall.toInt()}mm',
                      color: Colors.blue[700]!,
                    ),
                  ),
                ],
              ),
              
              // Show recommendation if enabled
              if (showRecommendation) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recommended Fertilizer: ${crop.recommendedFertilizer}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Benefits section
              if (crop.benefits.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Benefits:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: crop.benefits.take(3).map((benefit) => 
                    Chip(
                      label: Text(
                        benefit,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.green[100],
                      labelStyle: TextStyle(color: Colors.green[800]),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build info chip widget
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get color based on season
  Color _getSeasonColor(String season) {
    switch (season.toLowerCase()) {
      case 'kharif':
        return Colors.green[700]!;
      case 'rabi':
        return Colors.orange[700]!;
      case 'summer':
        return Colors.red[700]!;
      default:
        return Colors.blue[700]!;
    }
  }
}