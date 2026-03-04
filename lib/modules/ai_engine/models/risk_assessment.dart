
import 'package:flutter/material.dart';

enum RiskLevel {
  low,      // Score 0-30
  medium,   // Score 31-60
  high      // Score 61-100
}

class RiskAssessment {
  final int score;
  final RiskLevel level;
  final String message;
  final DateTime timestamp;

  RiskAssessment({
    required this.score,
    required this.level,
    required this.message,
    required this.timestamp,
  });

  Color get color {
    switch (level) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  factory RiskAssessment.normal() {
    return RiskAssessment(
      score: 0,
      level: RiskLevel.low,
      message: "Vitals within normal range.",
      timestamp: DateTime.now(),
    );
  }
}
