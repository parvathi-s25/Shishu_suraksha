import 'package:flutter/material.dart';

class QuickStatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? trend;
  final bool? trendPositive;

  const QuickStatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.trend,
    this.trendPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Use min size
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20), // Reduced icon size
              ),
              const Spacer(),
              if (trend != null && trendPositive != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced padding
                  decoration: BoxDecoration(
                    color: (trendPositive!
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendPositive!
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 12, // Reduced icon size
                        color: trendPositive!
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                      ),
                      const SizedBox(width: 2), // Reduced spacing
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 10, // Reduced font size
                          fontWeight: FontWeight.bold,
                          color: trendPositive!
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(), // Push content to bottom
          FittedBox( // Ensure value fits
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24, // Slightly reduced font size
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12, // Reduced font size
              color: Colors.grey[600],
              overflow: TextOverflow.ellipsis, // Handle long labels
            ),
            maxLines: 1, // Limit lines
          ),
        ],
      ),
    );
  }
}
