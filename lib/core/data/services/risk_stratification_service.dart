import '../models/health_data_model.dart';

class RiskStratificationService {
  // Returns a risk score between 0 and 100
  // 0-30: Low Risk (Normal)
  // 31-60: Moderate Risk (Monitor)
  // 61-100: High Risk (Alert)
  
  Map<String, dynamic> calculateRisk(HealthData data) {
    int score = 0;
    List<String> riskFactors = [];

    // 1. Heart Rate Analysis
    if (data.heartRate > 130) {
      score += 20;
      riskFactors.add("Tachycardia (HR > 130)");
    } else if (data.heartRate < 60) {
      score += 15;
      riskFactors.add("Bradycardia (HR < 60)");
    }

    // 2. SpO2 Analysis
    if (data.spo2 < 94) {
      score += 30;
      riskFactors.add("Hypoxia (SpO2 < 94%)");
    } else if (data.spo2 < 90) {
      score += 50; // Critical
      riskFactors.add("Critical Hypoxia (SpO2 < 90%)");
    }

    // 3. Temperature Analysis
    if (data.temperature > 38.0) {
      score += 40;
      riskFactors.add("Fever (Temp > 38°C)");
    } else if (data.temperature < 35.5) {
      score += 20;
      riskFactors.add("Hypothermia (Temp < 35.5°C)");
    }

    // 4. Movement Analysis (Sedentary check)
    if (data.stepCount < 100 && data.timestamp.hour > 10) {
       // Only relevant if day time and very low movement
       score += 10;
       riskFactors.add("Low Activity Level");
    }

    // Cap score at 100
    if (score > 100) score = 100;

    return {
      'score': score,
      'level': _getRiskLevel(score),
      'factors': riskFactors,
      'color_hex': _getRiskColorHex(score),
    };
  }

  String _getRiskLevel(int score) {
    if (score < 30) return 'Normal';
    if (score < 60) return 'Monitor';
    return 'High Risk';
  }
  
  String _getRiskColorHex(int score) {
    if (score < 30) return '0xFF4CAF50'; // Green
    if (score < 60) return '0xFFFF9800'; // Orange
    return '0xFFF44336'; // Red
  }
}

