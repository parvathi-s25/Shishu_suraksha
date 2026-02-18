import '../models/vision_result_model.dart';

class VisionScoreService {
  
  static double calculateOverallRisk({
    required AcuityResult? acuity,
    required StrabismusResult? strabismus,
    required ColorVisionResult? color,
    // Future: PupilResult, FieldResult
  }) {
    double score = 0.0;
    
    // Weights normalized to available tests
    // If all present: 
    // Acuity (40%), Strabismus (30%), Color (10%), Others (20%)
    
    if (acuity != null) {
      double acuityRisk = _calculateAcuityRisk(acuity);
      score += (0.40 * acuityRisk);
    }

    if (strabismus != null) {
      double strabismusRisk = strabismus.isAbnormal ? 1.0 : 0.0;
      if (strabismus.leftEyeDeviation > 8 || strabismus.rightEyeDeviation > 8) {
         strabismusRisk = max(strabismusRisk, 0.7); 
      }
      score += (0.30 * strabismusRisk);
    }

    if (color != null) {
      double colorRisk = 0.0;
      if (color.totalPlates > 0) {
         colorRisk = (color.totalPlates - color.score) / color.totalPlates;
      }
      score += (0.10 * colorRisk);
    }
    
    // Placeholder for missing modules (assume normal for now to avoid false high risk)
    // In production, we'd require all tests.

    return score.clamp(0.0, 1.0);
  }

  static double _calculateAcuityRisk(AcuityResult result) {
    // Basic logic: if not 6/6 or 6/9, risk increases
    // Parse strings like "6/6", "6/12"
    // For now, return mock risk
    if (result.leftEyeScore == "6/6" && result.rightEyeScore == "6/6") return 0.0;
    if (result.leftEyeScore == "6/9" && result.rightEyeScore == "6/9") return 0.2;
    return 0.8; // High risk if worse
  }

  static String getRiskLabel(double score) {
    if (score < 0.3) return 'Low Risk';
    if (score < 0.7) return 'Moderate Risk';
    return 'High Risk';
  }
}
