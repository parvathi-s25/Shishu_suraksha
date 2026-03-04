class MotorSkillsAssessmentService {
  void saveAssessment() {}
  double analyzeJumpTest({
    required double jumpHeight,
    required double armSwingQuality,
    required double landingStability,
    required int ageMonths,
  }) {
    return (jumpHeight / 10.0).clamp(0.0, 100.0);
  }

  double analyzeBalanceTest({
    required double durationSeconds,
    required int wobbleCount,
    required int ageMonths,
  }) {
    return (durationSeconds - wobbleCount).clamp(0.0, 100.0);
  }

  double analyzeWalkTest({
    required double gaitSymmetry,
    required double stepCoordination,
    required int ageMonths,
  }) {
    return (gaitSymmetry + stepCoordination) / 2.0;
  }

  double analyzeThrowCatchTest({
    required int successfulCatches,
    required int totalAttempts,
    required int ageMonths,
  }) {
    if (totalAttempts == 0) return 0.0;
    return (successfulCatches / totalAttempts) * 100.0;
  }

  double calculateOverallMotorScore({
    required double jumpScore,
    required double balanceScore,
    required double walkScore,
    required double throwCatchScore,
  }) {
    return (jumpScore + balanceScore + walkScore + throwCatchScore) / 4.0;
  }

  int calculateDevelopmentalAge(double overallScore) {
    return (overallScore / 10).round();
  }
}
