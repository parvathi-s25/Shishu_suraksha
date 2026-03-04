import 'package:shishu_suraksha/l10n/generated/app_localizations.dart';
import '../models/alert_model.dart';

class AlertGenerator {
  /// Generates alerts from assessment data
  /// Returns a list of AlertModel objects categorized by risk level
  static List<AlertModel> generateAlerts(List<Map<String, dynamic>> childrenData, AppLocalizations t) {
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
        t: t,
      );

      if (alert != null) {
        alerts.add(alert);
      }
    }

    // Sort by risk level (high to normal)
    alerts.sort((a, b) => a.riskLevel.index.compareTo(b.riskLevel.index));

    return alerts;
  }

  /// Mock data generator for demonstration
  static List<AlertModel> getMockAlerts(AppLocalizations t) {
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

    return generateAlerts(mockChildren, t);
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
    required AppLocalizations t,
  }) {
    // HIGH RISK CONDITIONS
    if (hearingScore == 0) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.high,
        category: t.categoryHearing,
        description: t.descHearingHigh,
        recommendedAction: t.actionHearingHigh,
        assessmentData: assessmentData,
      );
    }

    if (speakingScore < 20) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.high,
        category: t.categorySpeech,
        description: t.descSpeechHigh,
        recommendedAction: t.actionSpeechHigh,
        assessmentData: assessmentData,
      );
    }

    if (mobilityScore < 20) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.high,
        category: t.categoryMotor,
        description: t.descMotorHigh,
        recommendedAction: t.actionMotorHigh,
        assessmentData: assessmentData,
      );
    }

    if (nutritionStatus == 'severe') {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.high,
        category: t.categoryNutrition,
        description: t.descNutritionHigh,
        recommendedAction: t.actionNutritionHigh,
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
        category: t.categorySpeech,
        description: t.descSpeechMod,
        recommendedAction: t.actionSpeechMod,
        assessmentData: assessmentData,
      );
    }

    if (mobilityScore >= 20 && mobilityScore < 50) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.moderate,
        category: t.categoryMotor,
        description: t.descMotorMod,
        recommendedAction: t.actionMotorMod,
        assessmentData: assessmentData,
      );
    }

    if (nutritionStatus == 'moderate' || nutritionStatus == 'underweight') {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.moderate,
        category: t.categoryNutrition,
        description: t.descNutritionMod,
        recommendedAction: t.actionNutritionMod,
        assessmentData: assessmentData,
      );
    }

    if (hearingScore > 0 && hearingScore < 50) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.moderate,
        category: t.categoryHearing,
        description: t.descHearingMod,
        recommendedAction: t.actionHearingMod,
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
        category: t.categorySpeech,
        description: t.descSpeechMild,
        recommendedAction: t.actionSpeechMild,
        assessmentData: assessmentData,
      );
    }

    if (developmentScore >= 50 && developmentScore < 75) {
      return AlertModel(
        childName: childName,
        childAge: childAge,
        childId: childId,
        riskLevel: RiskLevel.mild,
        category: t.categoryDevelopment,
        description: t.descDevMild,
        recommendedAction: t.actionDevMild,
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
        category: t.categoryHealth,
        description: t.descNormal,
        recommendedAction: t.actionNormal,
        assessmentData: assessmentData,
      );
    }

    // Default to normal if no specific conditions met
    return AlertModel(
      childName: childName,
      childAge: childAge,
      childId: childId,
      riskLevel: RiskLevel.normal,
      category: t.categoryHealth,
      description: t.descDefault,
      recommendedAction: t.actionDefault,
      assessmentData: assessmentData,
    );
  }
}
