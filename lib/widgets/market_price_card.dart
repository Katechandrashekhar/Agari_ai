import 'package:flutter/material.dart';
import '../models/market_price.dart';

/// Reusable widget for displaying market price information
/// Used in market price screen and dashboard
class MarketPriceCard extends StatelessWidget {
  final MarketPrice marketPrice;
  final VoidCallback? onTap;

  const MarketPriceCard({
    super.key,
    required this.marketPrice,
    this.onTap,
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
              // Header row with crop name and price change
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      marketPrice.cropName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriceChangeColor(marketPrice.changePercentage),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPriceChangeIcon(marketPrice.changePercentage),
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          marketPrice.formattedChange,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Current price display
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Current Price',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        marketPrice.formattedPrice,
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Price range
              Row(
                children: [
                  Expanded(
                    child: _buildPriceInfo(
                      'Minimum',
                      '₹${marketPrice.minPrice.toStringAsFixed(0)}',
                      Colors.red,
                      Icons.trending_down,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPriceInfo(
                      'Maximum',
                      '₹${marketPrice.maxPrice.toStringAsFixed(0)}',
                      Colors.green,
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Market information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue[700], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${marketPrice.market}, ${marketPrice.state}',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.category, color: Colors.blue[700], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              marketPrice.priceType.toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.blue[700], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(marketPrice.date),
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Price trend indicator
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _getTrendIcon(marketPrice.priceStatus),
                    color: _getTrendColor(marketPrice.priceStatus),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getTrendText(marketPrice.priceStatus),
                    style: TextStyle(
                      color: _getTrendColor(marketPrice.priceStatus),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build price info widget
  Widget _buildPriceInfo(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Get color based on price change
  Color _getPriceChangeColor(double changePercentage) {
    if (changePercentage > 0) {
      return Colors.green[600]!;
    } else if (changePercentage < 0) {
      return Colors.red[600]!;
    } else {
      return Colors.grey[600]!;
    }
  }

  /// Get icon based on price change
  IconData _getPriceChangeIcon(double changePercentage) {
    if (changePercentage > 0) {
      return Icons.trending_up;
    } else if (changePercentage < 0) {
      return Icons.trending_down;
    } else {
      return Icons.trending_flat;
    }
  }

  /// Get trend icon
  IconData _getTrendIcon(String status) {
    switch (status) {
      case 'up':
        return Icons.arrow_upward;
      case 'down':
        return Icons.arrow_downward;
      default:
        return Icons.horizontal_rule;
    }
  }

  /// Get trend color
  Color _getTrendColor(String status) {
    switch (status) {
      case 'up':
        return Colors.green[600]!;
      case 'down':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  /// Get trend text
  String _getTrendText(String status) {
    switch (status) {
      case 'up':
        return 'Price Rising';
      case 'down':
        return 'Price Falling';
      default:
        return 'Price Stable';
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}