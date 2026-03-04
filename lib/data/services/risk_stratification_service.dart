import '../models/assessment_models.dart';
import '../models/assessment_result_models.dart';

/// Risk Stratification & Comprehensive Assessment Service
/// 
/// Orchestrates all assessment modules and generates comprehensive
/// risk stratification and intervention recommendations.
class RiskStratificationService {
  
  // Risk thresholds
  static const double lowRiskThreshold = 75.0; // 75+ = low risk (green)
  static const double mediumRiskThreshold = 50.0; // 50-74 = medium risk (yellow)
  // Below 50 = high risk (red)

  /// Stratifies risk based on individual assessment scores
  static RiskLevel stratifyRisk({
    required double motorScore,
    required double speechScore,
    required double cognitiveScore,
    required double socialEmotionalScore,
    required double healthScore,
  }) {
    final scores = [motorScore, speechScore, cognitiveScore, socialEmotionalScore, healthScore];
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;

    if (averageScore >= lowRiskThreshold) {
      return RiskLevel.low;
    } else if (averageScore >= mediumRiskThreshold) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.high;
    }
  }

  /// Identifies specific risk factors
  static List<RiskFactor> identifyRiskFactors({
    required double motorScore,
    required double speechScore,
    required double cognitiveScore,
    required double socialEmotionalScore,
    required double healthScore,
    required int ageMonths,
  }) {
    final riskFactors = <RiskFactor>[];

    // Motor risk
    if (motorScore < 50) {
      riskFactors.add(
        RiskFactor(
          category: 'motor',
          severity: _calculateSeverity(motorScore, 50),
          description: 'Motor skills significantly below age-appropriate level. '
              'Child may have balance, coordination, or gross motor delays.',
          ageMonths: ageMonths,
        ),
      );
    }

    // Speech risk
    if (speechScore < 50) {
      riskFactors.add(
        RiskFactor(
          category: 'speech',
          severity: _calculateSeverity(speechScore, 50),
          description: 'Speech and language development delayed. '
              'May have difficulty with vocabulary, pronunciation, or articulation.',
          ageMonths: ageMonths,
        ),
      );
    }

    // Cognitive risk
    if (cognitiveScore < 50) {
      riskFactors.add(
        RiskFactor(
          category: 'cognitive',
          severity: _calculateSeverity(cognitiveScore, 50),
          description: 'Cognitive development below expectations. '
              'Child may struggle with attention, memory, or problem-solving.',
          ageMonths: ageMonths,
        ),
      );
    }

    // Social-Emotional risk (potential autism indicators)
    if (socialEmotionalScore < 40) {
      riskFactors.add(
        RiskFactor(
          category: 'social_emotional',
          severity: _calculateSeverity(socialEmotionalScore, 40),
          description: 'Significant social-emotional delays detected. '
              'Consider evaluation for autism spectrum or emotional development concerns.',
          ageMonths: ageMonths,
        ),
      );
    }

    // Health risk
    if (healthScore < 60) {
      riskFactors.add(
        RiskFactor(
          category: 'health',
          severity: _calculateSeverity(healthScore, 60),
          description: 'Health concerns detected (vision, hearing, anemia, birth defects). '
              'Requires medical evaluation.',
          ageMonths: ageMonths,
        ),
      );
    }

    return riskFactors;
  }

  /// Generates comprehensive risk stratification
  static RiskStratification generateRiskStratification({
    required DateTime assessmentDate,
    required double motorScore,
    required double speechScore,
    required double cognitiveScore,
    required double socialEmotionalScore,
    required double healthScore,
    required int ageMonths,
  }) {
    final overallRisk = stratifyRisk(
      motorScore: motorScore,
      speechScore: speechScore,
      cognitiveScore: cognitiveScore,
      socialEmotionalScore: socialEmotionalScore,
      healthScore: healthScore,
    );

    final identifiedRisks = identifyRiskFactors(
      motorScore: motorScore,
      speechScore: speechScore,
      cognitiveScore: cognitiveScore,
      socialEmotionalScore: socialEmotionalScore,
      healthScore: healthScore,
      ageMonths: ageMonths,
    );

    // Calculate composite risk score (0-100)
    final scores = [motorScore, speechScore, cognitiveScore, socialEmotionalScore, healthScore];
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;
    final riskScore = 100 - averageScore; // Inverted: high score = high risk

    // Generate recommendation
    final recommendedAction = _generateRecommendation(overallRisk);

    // Determine if immediate referral needed
    final requiresImmediateReferral =
        healthScore < 40 || (identifiedRisks.length > 2 && overallRisk == RiskLevel.high);

    // Determine referral type
    final referralType = _determineReferralType(
      motorScore: motorScore,
      speechScore: speechScore,
      cognitiveScore: cognitiveScore,
      socialEmotionalScore: socialEmotionalScore,
      healthScore: healthScore,
    );

    return RiskStratification(
      assessmentDate: assessmentDate,
      overallRisk: overallRisk,
      identifiedRisks: identifiedRisks,
      numberOfRiskFactors: identifiedRisks.length,
      riskScore: riskScore.clamp(0, 100),
      recommendedAction: recommendedAction,
      requiresImmediateReferral: requiresImmediateReferral,
      referralType: referralType,
    );
  }

  /// Generates predictive insights
  static PredictiveInsights generatePredictiveInsights({
    required DateTime assessmentDate,
    required double motorScore,
    required double speechScore,
    required double cognitiveScore,
    required int ageMonths,
    required double? weight,
    required double? height,
    required List<double>? previousMotorScores,
    required List<double>? previousWeights,
  }) {
    // Developmental trajectory prediction
    final developmentalTrajectory = _predictDevelopmentalTrajectory(
      motorScore: motorScore,
      speechScore: speechScore,
      cognitiveScore: cognitiveScore,
      previousScores: previousMotorScores ?? [],
    );

    // Malnutrition risk assessment
    final malnutritionRiskData = _assessMalnutritionRisk(
      weight: weight,
      height: height,
      ageMonths: ageMonths,
      previousWeights: previousWeights ?? [],
    );

    // School readiness prediction
    final schoolReadiness = _predictSchoolReadiness(
      motorScore: motorScore,
      speechScore: speechScore,
      cognitiveScore: cognitiveScore,
      ageMonths: ageMonths,
    );

    // Intervention effectiveness estimate
    final interventionEffectiveness = _estimateInterventionEffectiveness(
      motorScore: motorScore,
      speechScore: speechScore,
      cognitiveScore: cognitiveScore,
    );

    // Early warning alerts
    final earlyWarningAlerts = _generateEarlyWarningAlerts(
      motorScore: motorScore,
      previousWeights: previousWeights,
      weight: weight,
    );

    return PredictiveInsights(
      generatedDate: assessmentDate,
      developmentalTrajectory: developmentalTrajectory,
      malnutritionRisk: malnutritionRiskData['risk'] as double,
      malnutritionRiskDescription: malnutritionRiskData['description'] as String,
      schoolReadiness: schoolReadiness['probability'] as double,
      schoolReadinessDescription: schoolReadiness['description'] as String,
      interventionEffectiveness: interventionEffectiveness,
      earlyWarningAlerts: earlyWarningAlerts,
      requiresUrgentAttention: earlyWarningAlerts.isNotEmpty,
    );
  }

  // ========================================================================
  // PRIVATE HELPER METHODS
  // ========================================================================

  static double _calculateSeverity(double currentScore, double threshold) {
    // Returns 0-1 severity level
    if (currentScore >= threshold) return 0;
    return ((threshold - currentScore) / threshold).clamp(0, 1);
  }

  static String _generateRecommendation(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return 'Routine monitoring every 3 months. Continue age-appropriate activities at home.';
      case RiskLevel.medium:
        return 'Enhanced monitoring with interventions. Retest in 1 month. '
            'Provide activity recommendations to parents/caregivers.';
      case RiskLevel.high:
        return 'URGENT: Immediate specialist referral required. '
            'Intensive intervention needed. Schedule follow-up within 2 weeks.';
    }
  }

  static String _determineReferralType({
    required double motorScore,
    required double speechScore,
    required double cognitiveScore,
    required double socialEmotionalScore,
    required double healthScore,
  }) {
    if (healthScore < 40) return 'PHC'; // Primary Health Center
    if (motorScore < 40) return 'Physiotherapist';
    if (speechScore < 40) return 'Speech Therapist';
    if (cognitiveScore < 40 || socialEmotionalScore < 40) return 'Specialist'; // Developmental/Pediatric specialist
    return 'None';
  }

  static String _predictDevelopmentalTrajectory({
    required double motorScore,
    required double speechScore,
    required double cognitiveScore,
    required List<double> previousScores,
  }) {
    final currentAverage =
        (motorScore + speechScore + cognitiveScore) / 3;

    if (previousScores.isEmpty) {
      if (currentAverage >= 75) {
        return 'On track for typical development. Expected to meet age-appropriate milestones.';
      } else if (currentAverage >= 50) {
        return 'Mild developmental delay observed. With intervention, '
            'child may catch up within 6-12 months.';
      } else {
        return 'Significant developmental delay detected. If current trend continues, '
            'child may need specialized education and support services.';
      }
    }

    // Calculate trend
    final avgPrevious = previousScores.reduce((a, b) => a + b) / previousScores.length;
    final trend = currentAverage - avgPrevious;

    if (trend > 5) {
      return 'POSITIVE TREND: Child is improving. Continue current interventions.';
    } else if (trend > -2 && trend <= 5) {
      return 'STABLE: Child maintaining current level. Monitor closely.';
    } else {
      return 'REGRESSION ALERT: Developmental scores have declined. '
          'Review current interventions and environment. Medical evaluation may be needed.';
    }
  }

  static Map<String, dynamic> _assessMalnutritionRisk({
    required double? weight,
    required double? height,
    required int ageMonths,
    required List<double> previousWeights,
  }) {
    if (weight == null || height == null) {
      return {
        'risk': 0.5,
        'description': 'Insufficient data for malnutrition risk assessment.'
      };
    }

    // Simple BMI-based assessment
    final heightM = height / 100;

    // WHO weight-for-age standards (simplified)
    final expectedWeight = _getExpectedWeightForAge(ageMonths);

    double riskScore = 0;
    String description = '';

    if (weight < expectedWeight * 0.7) {
      riskScore = 0.8;
      description = 'SEVERE malnutrition risk. Immediate nutritional intervention required.';
    } else if (weight < expectedWeight * 0.85) {
      riskScore = 0.6;
      description = 'MODERATE malnutrition risk. Enhanced nutrition monitoring needed.';
    } else if (weight < expectedWeight * 0.95) {
      riskScore = 0.3;
      description = 'MILD malnutrition risk. Standard nutritional guidance recommended.';
    } else {
      riskScore = 0.1;
      description = 'Weight within normal range for age.';
    }

    // Check for weight loss trend
    if (previousWeights.isNotEmpty) {
      final previousAvg =
          previousWeights.reduce((a, b) => a + b) / previousWeights.length;
      if (weight < previousAvg * 0.95) {
        riskScore = (riskScore + 0.2).clamp(0.0, 1.0);
        description += ' ALERT: Recent weight loss detected.';
      }
    }

    return {'risk': riskScore.clamp(0.0, 1.0), 'description': description};
  }

  static double _getExpectedWeightForAge(int ageMonths) {
    // WHO expected weights (in kg) - simplified
    const weights = {
      12: 9.5,
      18: 11.0,
      24: 12.5,
      36: 14.5,
      48: 16.5,
      60: 18.5,
    };

    if (weights.containsKey(ageMonths)) return weights[ageMonths]!;

    // Interpolate
    final before = weights.keys.where((k) => k < ageMonths).toList()..sort();
    final after = weights.keys.where((k) => k > ageMonths).toList()..sort();

    if (before.isEmpty) return weights[weights.keys.first]!;
    if (after.isEmpty) return weights[weights.keys.last]!;

    final beforeKey = before.last;
    final afterKey = after.first;
    final ratio =
        (ageMonths - beforeKey) / (afterKey - beforeKey);

    return weights[beforeKey]! +
        (weights[afterKey]! - weights[beforeKey]!) * ratio;
  }

  static Map<String, dynamic> _predictSchoolReadiness({
    required double motorScore,
    required double speechScore,
    required double cognitiveScore,
    required int ageMonths,
  }) {
    if (ageMonths < 60) {
      return {
        'probability': 0.5,
        'description': 'Child is ${72 - ageMonths} months away from school entry. '
            'Early indicators suggest moderate readiness potential.'
      };
    }

    // Calculate school readiness score
    final readinessScore =
        (motorScore * 0.2 + speechScore * 0.4 + cognitiveScore * 0.4);

    double probability = 0;
    String description = '';

    if (readinessScore >= 80) {
      probability = 0.9;
      description = 'HIGH READINESS: Child is well-prepared for primary school. '
          'Likely to adapt well to academic environment.';
    } else if (readinessScore >= 60) {
      probability = 0.6;
      description = 'MODERATE READINESS: Child has basic skills but may benefit '
          'from additional preparation before school entry.';
    } else {
      probability = 0.2;
      description = 'LOW READINESS: Child may struggle in primary school. '
          'Recommend pre-primary classroom or additional support.';
    }

    return {'probability': probability, 'description': description};
  }

  static double _estimateInterventionEffectiveness({
    required double motorScore,
    required double speechScore,
    required double cognitiveScore,
  }) {
    // Children with moderate delays show best intervention response
    final averageScore =
        (motorScore + speechScore + cognitiveScore) / 3;

    if (averageScore >= 80) {
      return 0.3; // Already doing well, less room for improvement
    } else if (averageScore >= 50) {
      return 0.8; // Moderate delay - good intervention potential
    } else if (averageScore >= 30) {
      return 0.6; // Severe delay - some improvement possible
    } else {
      return 0.4; // Very severe - may have underlying conditions
    }
  }

  static List<String> _generateEarlyWarningAlerts({
    required double motorScore,
    required List<double>? previousWeights,
    required double? weight,
  }) {
    final alerts = <String>[];

    if (motorScore < 30) {
      alerts.add('⚠️ SEVERE motor delay detected - may indicate cerebral palsy or other conditions.');
    }

    if (previousWeights != null && weight != null && previousWeights.isNotEmpty) {
      final previousAvg =
          previousWeights.reduce((a, b) => a + b) / previousWeights.length;
      if (weight < previousAvg * 0.90) {
        alerts.add('⚠️ Sudden weight loss detected - possible malnutrition or illness.');
      }
    }

    if (motorScore < 40 && motorScore < 30) {
      alerts.add('⚠️ Multiple risk factors combined - urgent specialist evaluation needed.');
    }

    return alerts;
  }
}

/// Comprehensive Assessment Orchestration
/// 
/// Combines all assessment modules into a single unified assessment result
class ComprehensiveAssessmentOrchestrator {
  
  /// Generates comprehensive assessment report
  static Future<ComprehensiveAssessmentResult> generateComprehensiveAssessment({
    required String childId,
    required int chronologicalAgeMonths,
    required double motorScore,
    required double speechScore,
    required double cognitiveScore,
    required double socialEmotionalScore,
    required double healthScore,
    required int motorDevelopmentalAge,
    required int speechDevelopmentalAge,
    required int cognitiveDevelopmentalAge,
  }) async {
    // Calculate overall developmental score (weighted average)
    final overallScore = (motorScore * 0.25 +
            speechScore * 0.25 +
            cognitiveScore * 0.20 +
            socialEmotionalScore * 0.20 +
            healthScore * 0.10)
        .clamp(0.0, 100.0);

    // Determine risk level
    final riskLevel = RiskStratificationService.stratifyRisk(
      motorScore: motorScore,
      speechScore: speechScore,
      cognitiveScore: cognitiveScore,
      socialEmotionalScore: socialEmotionalScore,
      healthScore: healthScore,
    );

    // Count delayed areas
    int delayedAreas = 0;
    if (motorScore < 60) delayedAreas++;
    if (speechScore < 60) delayedAreas++;
    if (cognitiveScore < 60) delayedAreas++;
    if (socialEmotionalScore < 60) delayedAreas++;
    if (healthScore < 60) delayedAreas++;

    // Generate risk stratification
    final riskStrat =
        RiskStratificationService.generateRiskStratification(
      assessmentDate: DateTime.now(),
      motorScore: motorScore,
      speechScore: speechScore,
      cognitiveScore: cognitiveScore,
      socialEmotionalScore: socialEmotionalScore,
      healthScore: healthScore,
      ageMonths: chronologicalAgeMonths,
    );

    // Create summary
    final summary = _generateAssessmentSummary(
      motorScore: motorScore,
      speechScore: speechScore,
      cognitiveScore: cognitiveScore,
      socialEmotionalScore: socialEmotionalScore,
      healthScore: healthScore,
      overallScore: overallScore.toDouble(),
      riskLevel: riskLevel,
    );

    // Create recommendations
    final recommendations = _generateRecommendations(
      riskLevel: riskLevel,
      delayedAreas: delayedAreas,
      referralType: riskStrat.referralType,
    );

    final nextAssessmentDate =
        riskLevel == RiskLevel.low ? DateTime.now().add(Duration(days: 90)) : DateTime.now().add(Duration(days: 30));

    return ComprehensiveAssessmentResult(
      childId: childId,
      assessmentDate: DateTime.now(),
      chronologicalAgeMonths: chronologicalAgeMonths,
      motorScore: motorScore,
      speechScore: speechScore,
      cognitiveScore: cognitiveScore,
      socialEmotionalScore: socialEmotionalScore,
      healthScore: healthScore,
      overallDevelopmentalScore: overallScore,
      overallRiskLevel: riskLevel,
      numberOfDelayedAreas: delayedAreas,
      assessmentSummary: summary,
      recommendations: recommendations,
      requiresReferral: riskStrat.requiresImmediateReferral,
      referralSpecialist: riskStrat.referralType,
      nextAssessmentDate: nextAssessmentDate,
    );
  }

  static String _generateAssessmentSummary({
    required double motorScore,
    required double speechScore,
    required double cognitiveScore,
    required double socialEmotionalScore,
    required double healthScore,
    required double overallScore,
    required RiskLevel riskLevel,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('ASSESSMENT SUMMARY\n');
    buffer.writeln('Overall Developmental Score: $overallScore/100');
    buffer.writeln('Risk Level: ${riskLevel.toString().split('.').last.toUpperCase()}');
    buffer.writeln('\nDetailed Scores:');
    buffer.writeln('• Motor Skills: $motorScore/100');
    buffer.writeln('• Speech & Language: $speechScore/100');
    buffer.writeln('• Cognitive: $cognitiveScore/100');
    buffer.writeln('• Social-Emotional: $socialEmotionalScore/100');
    buffer.writeln('• Health: $healthScore/100');

    return buffer.toString();
  }

  static String _generateRecommendations({
    required RiskLevel riskLevel,
    required int delayedAreas,
    required String referralType,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('RECOMMENDATIONS\n');

    if (riskLevel == RiskLevel.low) {
      buffer.writeln('✓ Continue routine activities');
      buffer.writeln('✓ Follow-up assessment in 3 months');
    } else if (riskLevel == RiskLevel.medium) {
      buffer.writeln('• Implement personalized intervention activities');
      buffer.writeln('• Monthly progress monitoring');
      buffer.writeln('• Parent/caregiver training for home activities');
      buffer.writeln('• Follow-up assessment in 1 month');
    } else {
      buffer.writeln('⚠️ URGENT referral to $referralType');
      buffer.writeln('⚠️ Intensive intervention program required');
      buffer.writeln('⚠️ Weekly or bi-weekly follow-up');
      buffer.writeln('⚠️ Medical evaluation may be needed');
    }

    return buffer.toString();
  }
}
