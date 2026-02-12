import '../models/alert_model.dart';

class AlertGenerator {
  /// Generates alerts from assessment data
  /// Returns a list of AlertModel objects categorized by risk level
  static List<AlertModel> generateAlerts(List<Map<String, dynamic>> childrenData) {
    List<AlertModel> alerts = [];

    for (var child in childrenData) {
      // Extract assessment data
      final assessmentData = child['assessment'] ?? {};
      final hearingScore = assessmentData['hearing'] ?? 100;
      final speakingScore = assessmentData['speaking'] ?? 100;
      final developmentScore = assessmentData['development'] ?? 100;
      final mobilityScore = assessmentData['mobility'] ?? 100;
      final nutritionStatus = assessmentData['nutrition'] ?? 'normal';

      // Determine risk level and generate appropriate alert
      AlertModel? alert = _analyzeAndCreateAlert(
        childName: child['name'] ?? 'Unknown',
        childAge: child['age'] ?? 'Unknown',
        childId: child['id'] ?? 'N/A',
        hearingScore: hearingScore,
        speakingScore: speakingScore,
        developmentScore: developmentScore,
        mobilityScore: mobilityScore,
        nutritionStatus: nutritionStatus,
        assessmentData: assessmentData,
      );

      if (alert != null) {
        alerts.add(alert);
      }
    }

    // Sort by risk level (high to normal)
    alerts.sort((a, b) => a.riskLevel.index.compareTo(b.riskLevel.index));

    return alerts;
  }

  static AlertModel? _analyzeAndCreateAlert({
    required String childName,
    required String childAge,
    required String childId,
    required int hearingScore,
    required int speakingScore,
    required int developmentScore,
    required int mobilityScore,
    required String nutritionStatus,
    required Map<String, dynamic> assessmentData,
  }) {
    // HIGH RISK CONDITIONS
    if (hearingScore == 0) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.high,
        category: 'Hearing',
        description: 'No response to hearing test detected',
        recommendedAction: 'Immediate referral to audiologist required',
        assessmentData: assessmentData,
      );
    }

    if (speakingScore < 20) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.high,
        category: 'Speech',
        description: 'Severe speech delay detected',
        recommendedAction: 'Refer to speech therapist immediately',
        assessmentData: assessmentData,
      );
    }

    if (mobilityScore < 20) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.high,
        category: 'Motor Skills',
        description: 'Motor movement absence or severe delay',
        recommendedAction: 'Refer to pediatric physiotherapist',
        assessmentData: assessmentData,
      );
    }

    if (nutritionStatus == 'severe') {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.high,
        category: 'Nutrition',
        description: 'Severe malnutrition detected',
        recommendedAction: 'Immediate medical intervention required',
        assessmentData: assessmentData,
      );
    }

    // MODERATE RISK CONDITIONS
    if (speakingScore >= 20 && speakingScore < 50) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.moderate,
        category: 'Speech',
        description: 'Slow speech formation and development',
        recommendedAction: 'Speech exercises and monitoring needed',
        assessmentData: assessmentData,
      );
    }

    if (mobilityScore >= 20 && mobilityScore < 50) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.moderate,
        category: 'Motor Skills',
        description: 'Delayed walking or motor development',
        recommendedAction: 'Physical activity exercises recommended',
        assessmentData: assessmentData,
      );
    }

    if (nutritionStatus == 'moderate' || nutritionStatus == 'underweight') {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.moderate,
        category: 'Nutrition',
        description: 'Low weight percentile for age',
        recommendedAction: 'Nutritional support and monitoring',
        assessmentData: assessmentData,
      );
    }

    if (hearingScore > 0 && hearingScore < 50) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.moderate,
        category: 'Hearing',
        description: 'Low response to hearing test',
        recommendedAction: 'Follow-up hearing assessment needed',
        assessmentData: assessmentData,
      );
    }

    // MILD OBSERVATION CONDITIONS
    if (speakingScore >= 50 && speakingScore < 75) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.mild,
        category: 'Speech',
        description: 'Minor pronunciation issues observed',
        recommendedAction: 'Continue monitoring, encourage verbal interaction',
        assessmentData: assessmentData,
      );
    }

    if (developmentScore >= 50 && developmentScore < 75) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.mild,
        category: 'Development',
        description: 'Slight attention or cognitive delay',
        recommendedAction: 'Engaging activities and regular assessment',
        assessmentData: assessmentData,
      );
    }

    // NORMAL - All scores above 75
    if (hearingScore >= 75 && speakingScore >= 75 && 
        developmentScore >= 75 && mobilityScore >= 75 &&
        nutritionStatus == 'normal') {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.normal,
        category: 'Overall Health',
        description: 'Child is developing normally',
        recommendedAction: 'Continue regular monitoring',
        assessmentData: assessmentData,
      );
    }

    // Default to normal if no specific conditions met
    return AlertModel(
      childName: childName,
      childAge: childAge,
      childId: childId,
      riskLevel: RiskLevel.normal,
      category: 'Overall Health',
      description: 'No significant concerns detected',
      recommendedAction: 'Continue routine check-ups',
      assessmentData: assessmentData,
    );
  }

  /// Mock data generator for demonstration
  static List<AlertModel> getMockAlerts() {
    final mockChildren = [
      {
        'name': 'Aarav Kumar',
        'age': '2.5 years',
        'id': 'A001',
        'assessment': {
          'hearing': 0,
          'speaking': 85,
          'development': 90,
          'mobility': 95,
          'nutrition': 'normal',
        }
      },
      {
        'name': 'Priya Sharma',
        'age': '3 years',
        'id': 'P002',
        'assessment': {
          'hearing': 80,
          'speaking': 15,
          'development': 70,
          'mobility': 85,
          'nutrition': 'normal',
        }
      },
      {
        'name': 'Reyansh Patel',
        'age': '1.5 years',
        'id': 'R003',
        'assessment': {
          'hearing': 75,
          'speaking': 65,
          'development': 60,
          'mobility': 80,
          'nutrition': 'normal',
        }
      },
      {
        'name': 'Ananya Singh',
        'age': '4 years',
        'id': 'A004',
        'assessment': {
          'hearing': 90,
          'speaking': 35,
          'development': 75,
          'mobility': 30,
          'nutrition': 'normal',
        }
      },
      {
        'name': 'Vivaan Reddy',
        'age': '2 years',
        'id': 'V005',
        'assessment': {
          'hearing': 95,
          'speaking': 90,
          'development': 85,
          'mobility': 90,
          'nutrition': 'normal',
        }
      },
      {
        'name': 'Ishaan Gupta',
        'age': '3.5 years',
        'id': 'I006',
        'assessment': {
          'hearing': 85,
          'speaking': 80,
          'development': 75,
          'mobility': 70,
          'nutrition': 'underweight',
        }
      },
    ];

    return generateAlerts(mockChildren);
  }
}
