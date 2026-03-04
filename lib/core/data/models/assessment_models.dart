class MotorSkillsAssessment {
  final double jumpHeightCm;
  final double jumpScore;
  final double armSwingQuality;
  final double landingStability;
  final double balanceStabilityScore;
  final double balanceDurationSeconds;
  final int wobbleCount;
  final double gaitSymmetryScore;
  final double stepCoordinationScore;
  final double throwCatchScore;
  final int developmentalAgeMonths;
  final DateTime recordedAt;

  MotorSkillsAssessment({
    required this.jumpHeightCm,
    required this.jumpScore,
    required this.armSwingQuality,
    required this.landingStability,
    required this.balanceStabilityScore,
    required this.balanceDurationSeconds,
    required this.wobbleCount,
    required this.gaitSymmetryScore,
    required this.stepCoordinationScore,
    required this.throwCatchScore,
    required this.developmentalAgeMonths,
    required this.recordedAt,
  });
}

class AssessmentItem {
  final String id;
  AssessmentItem({required this.id});
}
