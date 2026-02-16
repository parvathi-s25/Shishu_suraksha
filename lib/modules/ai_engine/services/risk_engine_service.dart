
import '../../health_monitoring/models/device_data.dart';
import '../../growth_tracking/models/growth_record.dart';
import '../../classroom_monitoring/models/classroom_environment.dart';
import '../models/risk_assessment.dart';
import '../../ai_alerts/models/alert_model.dart';
import '../../ai_alerts/services/alerts_service.dart';

class RiskEngineService {
  final AlertsService _alertsService = AlertsService();

  // Calculate risk based on live vitals
  RiskAssessment evaluateHealthRisk(DeviceData data, {String? childName}) {
    int riskScore = 0;
    List<String> riskFactors = [];

    // 1. Heart Rate Analysis
    if (data.heartRate > 130) {
      riskScore += 50;
      riskFactors.add("Critical Heart Rate");
    } else if (data.heartRate > 110) {
      riskScore += 25;
      riskFactors.add("High Heart Rate");
    } else if (data.heartRate < 55) {
      riskScore += 40;
      riskFactors.add("Low Heart Rate");
    }

    // 2. SpO2 Analysis
    if (data.spo2 < 90) {
      riskScore += 60; // Critical
      riskFactors.add("Critical oxygen level");
    } else if (data.spo2 < 95) {
      riskScore += 30;
      riskFactors.add("Low SpO2");
    }

    // 3. Temperature Analysis
    if (data.temp > 38.5) {
      riskScore += 50;
      riskFactors.add("High Fever");
    } else if (data.temp > 37.5) {
      riskScore += 20;
      riskFactors.add("Mild Fever");
    }

    // Cap score at 100
    if (riskScore > 100) riskScore = 100;

    // Determine Level and Message
    RiskLevel level;
    String message;

    if (riskScore >= 70) {
      level = RiskLevel.high;
      message = "CRITICAL: ${riskFactors.join(', ')}";
      
      // Auto-Push Alert to Firestore
      _generateVitalsAlert(data, riskScore, message, childName);
      
    } else if (riskScore >= 35) {
      level = RiskLevel.medium;
      message = "WARNING: ${riskFactors.join(', ')}";
    } else {
      level = RiskLevel.low;
      message = "Vitals Stable";
    }

    return RiskAssessment(
      score: riskScore,
      level: level,
      message: message,
      timestamp: DateTime.now(),
    );
  }

  void _generateVitalsAlert(DeviceData data, int score, String message, String? childName) {
    final alert = AlertModel(
      id: "", // Let Firestore generate
      schoolId: data.schoolId,
      childId: data.childId,
      childName: childName,
      type: AlertType.health,
      severity: score >= 80 ? AlertSeverity.critical : AlertSeverity.high,
      title: "Health Vital Alert",
      message: message,
      actionRecommendation: _getRecommendation(message),
      timestamp: DateTime.now(),
    );
    
    _alertsService.pushAlert(data.schoolId, alert);
  }

  String _getRecommendation(String message) {
    if (message.contains("oxygen")) return "Provide supplementary oxygen and contact emergency services.";
    if (message.contains("Fever")) return "Administer paracetamol and sponge with lukewarm water.";
    if (message.contains("Heart Rate")) return "Ensure child is resting and keep them calm.";
    return "Monitor child closely and inform PHC worker.";
  }
}

