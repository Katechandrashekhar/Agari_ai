import 'package:flutter/material.dart';
import '../models/fertilizer.dart';

/// Reusable widget for displaying fertilizer information
/// Used in fertilizer tips and recommendation screens
class FertilizerCard extends StatelessWidget {
  final Fertilizer fertilizer;
  final VoidCallback? onTap;
  final double? acreage; // For cost calculation
  final bool showCostCalculation;

  const FertilizerCard({
    super.key,
    required this.fertilizer,
    this.onTap,
    this.acreage,
    this.showCostCalculation = false,
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
              // Header row with fertilizer name and type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fertilizer.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(fertilizer.type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      fertilizer.type.toUpperCase(),
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
              
              // Fertilizer description
              Text(
                fertilizer.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Crop type and NPK ratio
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.agriculture,
                      label: 'Crop Type',
                      value: fertilizer.cropType,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.science,
                      label: 'NPK Ratio',
                      value: fertilizer.npkRatio.toString(),
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Recommended quantity and price
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.scale,
                      label: 'Quantity',
                      value: '${fertilizer.recommendedQuantity} kg/acre',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.currency_rupee,
                      label: 'Price',
                      value: '₹${fertilizer.pricePerKg}/kg',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              
              // Application method and timing
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.blue[700], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Application Details',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Method: ${fertilizer.applicationMethod}',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                    Text(
                      'Timing: ${fertilizer.applicationTiming}',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
              
              // Cost calculation if acreage is provided
              if (showCostCalculation && acreage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Cost for ${acreage!.toStringAsFixed(1)} acres:',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${fertilizer.calculateCost(acreage!).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Benefits section
              if (fertilizer.benefits.isNotEmpty) ...[
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
                  children: fertilizer.benefits.take(3).map((benefit) => 
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
              
              // Precautions section
              if (fertilizer.precautions.isNotEmpty) ...[
                const SizedBox(height: 12),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'Precautions & Safety',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  leading: Icon(Icons.warning, color: Colors.red[700], size: 20),
                  children: [
                    ...fertilizer.precautions.map((precaution) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: Colors.red[700])),
                            Expanded(
                              child: Text(
                                precaution,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

  /// Get color based on fertilizer type
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'organic':
        return Colors.green[700]!;
      case 'inorganic':
        return Colors.blue[700]!;
      case 'bio-fertilizer':
        return Colors.purple[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}