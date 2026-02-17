import '../models/child_model.dart';
import '../core/constants/app_constants.dart';

class RiskEngine {
  /// Calculates risk based on vitals and other factors.
  /// Returns one of: high, moderate, mild, normal
  static String calculateRisk(ChildModel child, {int? heartRate, double? spo2, double? temperature}) {
    // If no real-time data, use stored risk level (or recalculate based on static data)
    if (heartRate == null && spo2 == null && temperature == null) {
      return child.riskLevel;
    }

    int score = 0;

    // Heart Rate (bpm) - Infants: 80-160, Children: 70-120
    if (heartRate != null) {
      if (heartRate > 160 || heartRate < 60) score += 3; // Critical
      else if (heartRate > 140 || heartRate < 70) score += 1; // Warning
    }

    // SpO2 (%)
    if (spo2 != null) {
      if (spo2 < 90) score += 3;
      else if (spo2 < 95) score += 1;
    }

    // Temperature (Celsius)
    if (temperature != null) {
      if (temperature > 39.0) score += 3;
      else if (temperature > 37.5) score += 1;
    }

    // BMI / Malnutrition Check (simplified)
    double bmi = child.weight / ((child.height / 100) * (child.height / 100));
    if (bmi < 14) score += 2; // Severe thinness

    if (score >= 3) return AppConstants.kRiskHigh;
    if (score == 2) return AppConstants.kRiskModerate;
    if (score == 1) return AppConstants.kRiskMild;
    return AppConstants.kRiskNormal;
  }
}
