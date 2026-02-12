import 'dart:math';
import '../models/dashboard_data.dart';
import '../models/alert_model.dart'; // Reusing RiskLevel enum if needed, or mapping strings

class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  DashboardStats getDashboardStats() {
    // Return mock data for the dashboard
    return DashboardStats(
      totalAssessed: 1248,
      highRisk: 42,
      moderateRisk: 156,
      mildRisk: 312,
      normal: 738,
      completedAssessments: 1248,
      pendingAssessments: 85,
      avgDevelopmentScore: 78.5,
      avgMobilityScore: 82.3,
      avgCognitiveScore: 76.9,
    );
  }

  RiskDistribution getRiskDistribution() {
    // Corresponds to stats above
    return RiskDistribution(
      high: 42,
      moderate: 156,
      mild: 312,
      normal: 738,
    );
  }

  List<ChartDataPoint> getAssessmentTrend() {
    // Mock 6-month trend
    return [
      ChartDataPoint('Jan', 120),
      ChartDataPoint('Feb', 145),
      ChartDataPoint('Mar', 132),
      ChartDataPoint('Apr', 168),
      ChartDataPoint('May', 190),
      ChartDataPoint('Jun', 215),
    ];
  }

  List<ChartDataPoint> getAgeDistribution() {
    return [
      ChartDataPoint('0-6m', 150),
      ChartDataPoint('6m-1y', 220),
      ChartDataPoint('1-2y', 310),
      ChartDataPoint('2-3y', 280),
      ChartDataPoint('3-4y', 180),
      ChartDataPoint('4-5y', 80),
      ChartDataPoint('5-6y', 28),
    ];
  }

  Map<String, double> getDevelopmentScores() {
    return {
      'Cognitive': 76.9,
      'Mobility': 82.3,
      'Hearing': 88.5,
      'Speech': 72.1,
    };
  }

  InterventionOutcome getInterventionOutcomes() {
    return InterventionOutcome(
      improved: 65,
      underMonitoring: 30,
      noImprovement: 5,
    );
  }
}
