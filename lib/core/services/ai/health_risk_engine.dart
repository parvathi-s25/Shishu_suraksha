
import '../../data/models/child_model.dart';
import '../../data/models/assessment_result_models.dart';

class HealthRiskEngine {
  // WHO Standards (Simplified Mock Data for MVP)
  // In real app, load Z-Score tables
  
  /// Returns a risk assessment map
  Map<String, dynamic> assessPhysicalHealth(ChildModel child) {
    if (child.growthHistory.isEmpty) {
      return {'risk': 'Unknown', 'message': 'No growth data available'};
    }

    final latestRecord = child.growthHistory.last;
    final bmi = latestRecord.bmi;
    final ageMonths = child.ageMonths;

    String risk = 'Low';
    List<String> flags = [];

    // 1. Severe Acute Malnutrition (SAM) Check (Simplified)
    // WHO: BMI-for-age < -3 SD or Weight-for-Height < -3 SD
    // For MVP, using static BMI thresholds for < 5 years
    if (bmi < 11.5) {
      risk = 'High';
      flags.add('Severe Acute Malnutrition (SAM) Risk');
    } else if (bmi < 12.5) {
      risk = 'Moderate';
      flags.add('Moderate Acute Malnutrition (MAM) Risk');
    }

    // 2. Stunting Check (Height for Age) - Very rough approximation
    // Avg height at 2 years ~ 87cm. If < 75cm, likely stunted.
    if (ageMonths > 24 && latestRecord.height < 75) {
      if (risk != 'High') risk = 'Moderate';
      flags.add('Possible Stunting');
    }

    return {
      'risk': risk,
      'flags': flags,
      'bmi': bmi,
      'last_check': latestRecord.date,
    };
  }

  /// Assess developmental delays based on assessment results
  Map<String, dynamic> assessDevelopmentalDelays(List<AssessmentResult> assessments) {
    if (assessments.isEmpty) {
      return {'risk': 'Unknown', 'message': 'No assessments found'};
    }

    int highRiskCount = 0;
    List<String> delayAreas = [];

    for (var assessment in assessments) {
      if (assessment is MotorAssessmentResult && assessment.totalScore < 50) {
        highRiskCount++;
        delayAreas.add('Motor Delay');
      }
      // Add other assessment type checks here
      // e.g. if (assessment is SpeechAssessmentResult && score < threshold)
    }

    String risk = highRiskCount > 0 ? 'High' : 'Low';
    
    return {
      'risk': risk,
      'delay_areas': delayAreas,
      'assessments_reviewed': assessments.length
    };
  }
}
