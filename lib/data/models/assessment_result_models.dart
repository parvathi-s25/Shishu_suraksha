import 'package:hive/hive.dart';

// ============================================================================
// RISK STRATIFICATION & ANALYSIS MODELS
// ============================================================================

enum RiskLevel {
  low, // Green - All scores within normal range
  medium, // Yellow - 1-2 areas below age expectations
  high, // Red - Multiple severe delays or birth defect detected
}

@HiveType(typeId: 9)
class RiskFactor extends HiveObject {
  @HiveField(0)
  final String category; // 'motor', 'speech', 'cognitive', etc.

  @HiveField(1)
  final double severity; // 0-1 (0=none, 1=severe)

  @HiveField(2)
  final String description; // e.g., "Balance coordination below age-appropriate"

  @HiveField(3)
  final int ageMonths; // age when this risk was identified

  RiskFactor({
    required this.category,
    required this.severity,
    required this.description,
    required this.ageMonths,
  });
}

class RiskFactorAdapter extends TypeAdapter<RiskFactor> {
  @override
  final int typeId = 9;

  @override
  RiskFactor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiskFactor(
      category: fields[0] as String,
      severity: fields[1] as double,
      description: fields[2] as String,
      ageMonths: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RiskFactor obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.severity)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.ageMonths);
  }
}

@HiveType(typeId: 10)
class RiskStratification extends HiveObject {
  @HiveField(0)
  final DateTime assessmentDate;

  @HiveField(1)
  final RiskLevel overallRisk; // Low, Medium, High

  @HiveField(2)
  final List<RiskFactor> identifiedRisks;

  @HiveField(3)
  final int numberOfRiskFactors;

  @HiveField(4)
  final double riskScore; // 0-100 composite risk score

  @HiveField(5)
  final String recommendedAction;
  // Low: "Routine monitoring every 3 months"
  // Medium: "Enhanced monitoring, activity recommendations, retest in 1 month"
  // High: "Immediate specialist referral, intensive intervention"

  @HiveField(6)
  final bool requiresImmediateReferral;

  @HiveField(7)
  final String referralType; // 'PHC', 'Physiotherapist', 'Speech Therapist', 'Specialist', 'None'

  @HiveField(8)
  final String notes;

  RiskStratification({
    required this.assessmentDate,
    required this.overallRisk,
    required this.identifiedRisks,
    required this.numberOfRiskFactors,
    required this.riskScore,
    required this.recommendedAction,
    required this.requiresImmediateReferral,
    required this.referralType,
    this.notes = '',
  });
}

class RiskStratificationAdapter extends TypeAdapter<RiskStratification> {
  @override
  final int typeId = 10;

  @override
  RiskStratification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiskStratification(
      assessmentDate: fields[0] as DateTime,
      overallRisk: fields[1] as RiskLevel,
      identifiedRisks: (fields[2] as List?)?.cast<RiskFactor>() ?? [],
      numberOfRiskFactors: fields[3] as int,
      riskScore: fields[4] as double,
      recommendedAction: fields[5] as String,
      requiresImmediateReferral: fields[6] as bool,
      referralType: fields[7] as String,
      notes: fields[8] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, RiskStratification obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.assessmentDate)
      ..writeByte(1)
      ..write(obj.overallRisk)
      ..writeByte(2)
      ..write(obj.identifiedRisks)
      ..writeByte(3)
      ..write(obj.numberOfRiskFactors)
      ..writeByte(4)
      ..write(obj.riskScore)
      ..writeByte(5)
      ..write(obj.recommendedAction)
      ..writeByte(6)
      ..write(obj.requiresImmediateReferral)
      ..writeByte(7)
      ..write(obj.referralType)
      ..writeByte(8)
      ..write(obj.notes);
  }
}

// ============================================================================
// PREDICTIVE INSIGHTS MODEL
// ============================================================================

@HiveType(typeId: 11)
class PredictiveInsights extends HiveObject {
  @HiveField(0)
  final DateTime generatedDate;

  @HiveField(1)
  final String developmentalTrajectory;
  // e.g., "If current trend continues, child may need special education"

  @HiveField(2)
  final double malnutritionRisk; // 0-1 probability

  @HiveField(3)
  final String malnutritionRiskDescription;

  @HiveField(4)
  final double schoolReadiness; // 0-1 probability at age 6

  @HiveField(5)
  final String schoolReadinessDescription;

  @HiveField(6)
  final double interventionEffectiveness; // 0-1 expected improvement with recommended activities

  @HiveField(7)
  final List<String> earlyWarningAlerts;
  // e.g., ["Sudden weight loss detected", "Developmental regression"]

  @HiveField(8)
  final bool requiresUrgentAttention;

  @HiveField(9)
  final String notes;

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
    this.notes = '',
  });
}

class PredictiveInsightsAdapter extends TypeAdapter<PredictiveInsights> {
  @override
  final int typeId = 11;

  @override
  PredictiveInsights read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PredictiveInsights(
      generatedDate: fields[0] as DateTime,
      developmentalTrajectory: fields[1] as String,
      malnutritionRisk: fields[2] as double,
      malnutritionRiskDescription: fields[3] as String,
      schoolReadiness: fields[4] as double,
      schoolReadinessDescription: fields[5] as String,
      interventionEffectiveness: fields[6] as double,
      earlyWarningAlerts: (fields[7] as List?)?.cast<String>() ?? [],
      requiresUrgentAttention: fields[8] as bool,
      notes: fields[9] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, PredictiveInsights obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.generatedDate)
      ..writeByte(1)
      ..write(obj.developmentalTrajectory)
      ..writeByte(2)
      ..write(obj.malnutritionRisk)
      ..writeByte(3)
      ..write(obj.malnutritionRiskDescription)
      ..writeByte(4)
      ..write(obj.schoolReadiness)
      ..writeByte(5)
      ..write(obj.schoolReadinessDescription)
      ..writeByte(6)
      ..write(obj.interventionEffectiveness)
      ..writeByte(7)
      ..write(obj.earlyWarningAlerts)
      ..writeByte(8)
      ..write(obj.requiresUrgentAttention)
      ..writeByte(9)
      ..write(obj.notes);
  }
}

// ============================================================================
// COMPREHENSIVE ASSESSMENT RESULT MODEL
// ============================================================================

@HiveType(typeId: 12)
class ComprehensiveAssessmentResult extends HiveObject {
  @HiveField(0)
  final String childId;

  @HiveField(1)
  final DateTime assessmentDate;

  @HiveField(2)
  final int chronologicalAgeMonths;

  @HiveField(3)
  final double motorScore; // 0-100

  @HiveField(4)
  final double speechScore; // 0-100

  @HiveField(5)
  final double cognitiveScore; // 0-100

  @HiveField(6)
  final double socialEmotionalScore; // 0-100

  @HiveField(7)
  final double healthScore; // 0-100 (vision, hearing, anemia, etc.)

  @HiveField(8)
  final double overallDevelopmentalScore; // 0-100 (weighted average)

  @HiveField(9)
  final RiskLevel overallRiskLevel;

  @HiveField(10)
  final int numberOfDelayedAreas; // how many areas are below age-appropriate

  @HiveField(11)
  final String assessmentSummary; // brief text summary

  @HiveField(12)
  final String recommendations; // actionable next steps

  @HiveField(13)
  final bool requiresReferral;

  @HiveField(14)
  final String referralSpecialist; // e.g., 'Physiotherapist', 'Speech Therapist'

  @HiveField(15)
  final DateTime? nextAssessmentDate;

  @HiveField(16)
  final String notes;

  @HiveField(17)
  final bool offline; // true if assessment conducted offline

  ComprehensiveAssessmentResult({
    required this.childId,
    required this.assessmentDate,
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
    this.nextAssessmentDate,
    this.notes = '',
    this.offline = false,
  });
}

class ComprehensiveAssessmentResultAdapter
    extends TypeAdapter<ComprehensiveAssessmentResult> {
  @override
  final int typeId = 12;

  @override
  ComprehensiveAssessmentResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComprehensiveAssessmentResult(
      childId: fields[0] as String,
      assessmentDate: fields[1] as DateTime,
      chronologicalAgeMonths: fields[2] as int,
      motorScore: fields[3] as double,
      speechScore: fields[4] as double,
      cognitiveScore: fields[5] as double,
      socialEmotionalScore: fields[6] as double,
      healthScore: fields[7] as double,
      overallDevelopmentalScore: fields[8] as double,
      overallRiskLevel: fields[9] as RiskLevel,
      numberOfDelayedAreas: fields[10] as int,
      assessmentSummary: fields[11] as String,
      recommendations: fields[12] as String,
      requiresReferral: fields[13] as bool,
      referralSpecialist: fields[14] as String,
      nextAssessmentDate: fields[15] as DateTime?,
      notes: fields[16] as String? ?? '',
      offline: fields[17] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ComprehensiveAssessmentResult obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.childId)
      ..writeByte(1)
      ..write(obj.assessmentDate)
      ..writeByte(2)
      ..write(obj.chronologicalAgeMonths)
      ..writeByte(3)
      ..write(obj.motorScore)
      ..writeByte(4)
      ..write(obj.speechScore)
      ..writeByte(5)
      ..write(obj.cognitiveScore)
      ..writeByte(6)
      ..write(obj.socialEmotionalScore)
      ..writeByte(7)
      ..write(obj.healthScore)
      ..writeByte(8)
      ..write(obj.overallDevelopmentalScore)
      ..writeByte(9)
      ..write(obj.overallRiskLevel)
      ..writeByte(10)
      ..write(obj.numberOfDelayedAreas)
      ..writeByte(11)
      ..write(obj.assessmentSummary)
      ..writeByte(12)
      ..write(obj.recommendations)
      ..writeByte(13)
      ..write(obj.requiresReferral)
      ..writeByte(14)
      ..write(obj.referralSpecialist)
      ..writeByte(15)
      ..write(obj.nextAssessmentDate)
      ..writeByte(16)
      ..write(obj.notes)
      ..writeByte(17)
      ..write(obj.offline);
  }
}
