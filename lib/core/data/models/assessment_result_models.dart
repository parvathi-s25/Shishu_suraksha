import 'package:flutter/material.dart';

enum RiskLevel { low, medium, high }

/// Base class for all assessment results
abstract class AssessmentResult {
  final String id;
  final String childId;
  final DateTime date;
  final String type;

  AssessmentResult({
    required this.id,
    required this.childId,
    required this.date,
    required this.type,
  });
}

/// Detailed Motor Skills Assessment Result
class MotorAssessmentResult extends AssessmentResult {
  final double jumpScore;
  final double balanceScore;
  final double gaitScore;
  final double coordinationScore;
  final double totalScore;
  final int developmentalAgeMonths;

  MotorAssessmentResult({
    required String id,
    required String childId,
    required DateTime date,
    required this.jumpScore,
    required this.balanceScore,
    required this.gaitScore,
    required this.coordinationScore,
    required this.totalScore,
    required this.developmentalAgeMonths,
  }) : super(id: id, childId: childId, date: date, type: 'Motor');
}

/// Detailed Speech & Language Assessment Result
class SpeechAssessmentResult extends AssessmentResult {
  final double clarityScore;
  final double vocabularyScore;
  final double sentenceScore;
  final double fluencyScore;
  final double totalScore;
  final int developmentalAgeMonths;

  SpeechAssessmentResult({
    required String id,
    required String childId,
    required DateTime date,
    required this.clarityScore,
    required this.vocabularyScore,
    required this.sentenceScore,
    required this.fluencyScore,
    required this.totalScore,
    required this.developmentalAgeMonths,
  }) : super(id: id, childId: childId, date: date, type: 'Speech');
}

/// Detailed Cognitive Assessment Result
class CognitiveAssessmentResult extends AssessmentResult {
  final double memoryScore;
  final double patternScore;
  final double attentionScore;
  final double problemSolvingScore;
  final double totalScore;
  final int developmentalAgeMonths;

  CognitiveAssessmentResult({
    required String id,
    required String childId,
    required DateTime date,
    required this.memoryScore,
    required this.patternScore,
    required this.attentionScore,
    required this.problemSolvingScore,
    required this.totalScore,
    required this.developmentalAgeMonths,
  }) : super(id: id, childId: childId, date: date, type: 'Cognitive');
}

/// Social-Emotional Assessment Result
class SocialEmotionalAssessmentResult extends AssessmentResult {
  final double emotionalRegulationScore;
  final double socialInteractionScore;
  final double eyeContactScore;
  final double totalScore;
  final int developmentalAgeMonths;

  SocialEmotionalAssessmentResult({
    required String id,
    required String childId,
    required DateTime date,
    required this.emotionalRegulationScore,
    required this.socialInteractionScore,
    required this.eyeContactScore,
    required this.totalScore,
    required this.developmentalAgeMonths,
  }) : super(id: id, childId: childId, date: date, type: 'SocialEmotional');
}

/// Risk Factor identified during assessment
class RiskFactor {
  final String category;
  final double severity; // 0.0 to 1.0
  final String description;
  final int ageMonths;

  RiskFactor({
    required this.category,
    required this.severity,
    required this.description,
    required this.ageMonths,
  });
}

/// Risk Analysis & Stratification Result
class RiskStratification {
  final DateTime assessmentDate;
  final RiskLevel overallRisk;
  final List<RiskFactor> identifiedRisks;
  final int numberOfRiskFactors;
  final double riskScore; // 0-100 (100 = highest risk)
  final String recommendedAction;
  final bool requiresImmediateReferral;
  final String referralType;

  RiskStratification({
    required this.assessmentDate,
    required this.overallRisk,
    required this.identifiedRisks,
    required this.numberOfRiskFactors,
    required this.riskScore,
    required this.recommendedAction,
    required this.requiresImmediateReferral,
    required this.referralType,
  });
}

/// Comprehensive Assessment Result combining all domains
class ComprehensiveAssessmentResult extends AssessmentResult {
  final int chronologicalAgeMonths;
  
  // Domain Scores (0-100)
  final double motorScore;
  final double speechScore;
  final double cognitiveScore;
  final double socialEmotionalScore;
  final double healthScore;
  
  // Overall Analysis
  final double overallDevelopmentalScore;
  final RiskLevel overallRiskLevel;
  final int numberOfDelayedAreas;
  
  // Text Reports
  final String assessmentSummary;
  final String recommendations;
  
  // Next Steps
  final bool requiresReferral;
  final String referralSpecialist;
  final DateTime nextAssessmentDate;

  ComprehensiveAssessmentResult({
    required String childId,
    required DateTime assessmentDate,
    required this.chronologicalAgeMonths,
    required this.motorScore,
    required this.speechScore,
    required this.cognitiveScore,
    required this.socialEmotionalScore,
    required this.healthScore,
    required this.overallDevelopmentalScore,
    required this.overallRiskLevel,
    required this.numberOfDelayedAreas,
    required this.assessmentSummary,
    required this.recommendations,
    required this.requiresReferral,
    required this.referralSpecialist,
    required this.nextAssessmentDate,
  }) : super(
          id: 'COMP_${childId}_${assessmentDate.millisecondsSinceEpoch}',
          childId: childId,
          date: assessmentDate,
          type: 'Comprehensive',
        );
}

/// Predictive Analysis Result
class PredictiveInsights {
  final DateTime generatedDate;
  final String developmentalTrajectory; // "On Track", "Declining", etc.
  final double malnutritionRisk; // 0-1
  final String malnutritionRiskDescription;
  final double schoolReadiness; // 0-1 probability
  final String schoolReadinessDescription;
  final double interventionEffectiveness; // 0-1 estimated impact
  final List<String> earlyWarningAlerts;
  final bool requiresUrgentAttention;

  PredictiveInsights({
    required this.generatedDate,
    required this.developmentalTrajectory,
    required this.malnutritionRisk,
    required this.malnutritionRiskDescription,
    required this.schoolReadiness,
    required this.schoolReadinessDescription,
    required this.interventionEffectiveness,
    required this.earlyWarningAlerts,
    required this.requiresUrgentAttention,
  });
}
