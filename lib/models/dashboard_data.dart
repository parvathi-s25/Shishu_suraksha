import 'package:flutter/material.dart';

class DashboardStats {
  final int totalAssessed;
  final int highRisk;
  final int moderateRisk;
  final int mildRisk;
  final int normal;
  final int completedAssessments;
  final int pendingAssessments;
  final double avgDevelopmentScore;
  final double avgMobilityScore;
  final double avgCognitiveScore;
  
  // Trend indicators (mock values for UI)
  final double totalAssessedChange; // e.g., +5.2%
  final double highRiskChange; // e.g., -2.1%

  DashboardStats({
    required this.totalAssessed,
    required this.highRisk,
    required this.moderateRisk,
    required this.mildRisk,
    required this.normal,
    required this.completedAssessments,
    required this.pendingAssessments,
    required this.avgDevelopmentScore,
    required this.avgMobilityScore,
    required this.avgCognitiveScore,
    this.totalAssessedChange = 5.2,
    this.highRiskChange = -2.1,
  });
}

class ChartDataPoint {
  final String x; // Label (e.g., "Jan", "Feb")
  final double y; // Value
  
  ChartDataPoint(this.x, this.y);
}

class RiskDistribution {
  final int high;
  final int moderate;
  final int mild;
  final int normal;

  RiskDistribution({
    required this.high,
    required this.moderate,
    required this.mild,
    required this.normal,
  });
}

class InterventionOutcome {
  final int improved;
  final int underMonitoring;
  final int noImprovement;

  InterventionOutcome({
    required this.improved,
    required this.underMonitoring,
    required this.noImprovement,
  });
}
