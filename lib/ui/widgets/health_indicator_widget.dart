import 'package:flutter/material.dart';

enum HealthStatus {
  excellent,
  good,
  needsAttention,
  critical,
}

class HealthIndicatorWidget extends StatelessWidget {
  final HealthStatus status;
  final String label;
  final String? value;
  final bool showBadge;

  const HealthIndicatorWidget({
    super.key,
    required this.status,
    required this.label,
    this.value,
    this.showBadge = true,
  });

  Color get _statusColor {
    switch (status) {
      case HealthStatus.excellent:
        return const Color(0xFF4CAF50); // Green
      case HealthStatus.good:
        return const Color(0xFF2196F3); // Blue
      case HealthStatus.needsAttention:
        return const Color(0xFFFF9800); // Orange
      case HealthStatus.critical:
        return const Color(0xFFF44336); // Red
    }
  }

  String get _statusText {
    switch (status) {
      case HealthStatus.excellent:
        return 'Excellent';
      case HealthStatus.good:
        return 'Good';
      case HealthStatus.needsAttention:
        return 'Needs Attention';
      case HealthStatus.critical:
        return 'Critical';
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case HealthStatus.excellent:
        return Icons.check_circle;
      case HealthStatus.good:
        return Icons.thumb_up;
      case HealthStatus.needsAttention:
        return Icons.warning;
      case HealthStatus.critical:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showBadge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _statusColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_statusIcon, size: 16, color: _statusColor),
            const SizedBox(width: 6),
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _statusColor.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon, size: 20, color: _statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      if (value != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          value!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _statusColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
