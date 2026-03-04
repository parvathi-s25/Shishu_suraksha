/// Assessment Orchestration Service
/// 
/// Main entry point for all AI screening assessments.
/// Provides a unified interface for running comprehensive child development assessments.
import '../models/assessment_models.dart';
import '../models/assessment_result_models.dart';

import 'motor_skills_assessment_service.dart';
import 'speech_language_assessment_service.dart';
import 'cognitive_assessment_service.dart';

class AssessmentOrchestrationService {
  
  /// Runs a complete assessment for a child
  /// 
  /// Returns a comprehensive assessment result with all scores and recommendations
  static Future<ComprehensiveAssessmentResult> runFullAssessment({
    required String childId,
    required int chronologicalAgeMonths,
    required AssessmentInputData inputData,
  }) async {
    // Motor Skills Assessment
    final motorData = MotorSkillsAssessmentService.analyzeJumpTest(
      poseLandmarks: inputData.motorPoseLandmarks,
      jumpHeightCm: inputData.jumpHeightCm,
      ageMonths: chronologicalAgeMonths,
      notes: inputData.motorNotes,
    );

    final balanceData = MotorSkillsAssessmentService.analyzeBalanceTest(
      poseLandmarksSequence: inputData.motorPoseLandmarks,
      standDurationSeconds: inputData.standDurationSeconds,
      wobbleCount: inputData.wobbleCount,
      ageMonths: chronologicalAgeMonths,
    );

    final walkData = MotorSkillsAssessmentService.analyzeWalkTest(
      poseLandmarksSequence: inputData.motorPoseLandmarks,
      ageMonths: chronologicalAgeMonths,
    );

    final throwCatchData = MotorSkillsAssessmentService.analyzeThrowCatchTest(
      eyeHandCoordination: inputData.eyeHandCoordination,
      throwCatchTiming: inputData.throwCatchTiming,
      successCount: inputData.throwCatchSuccessCount,
      totalAttempts: inputData.throwCatchAttempts,
    );

    final motorScore = MotorSkillsAssessmentService.calculateOverallMotorScore(
      jumpScore: motorData.jumpScore ?? 0,
      balanceScore: balanceData.balanceScore ?? 0,
      walkScore: walkData.walkScore ?? 0,
      throwCatchScore: throwCatchData.throwCatchScore ?? 0,
    );

    final motorDevAge = MotorSkillsAssessmentService.calculateDevelopmentalAge(
      motorScore,
      chronologicalAgeMonths,
    );

    // Speech & Language Assessment
    final wordClarityData = SpeechLanguageAssessmentService.analyzeWordClarity(
      mfccFeatures: inputData.mfccFeatures,
      spectrogramData: inputData.spectrogramData,
      language: inputData.language,
      ageMonths: chronologicalAgeMonths,
    );

    final vocabularyData = SpeechLanguageAssessmentService.analyzeVocabularyLevel(
      detectedWords: inputData.detectedWords,
      language: inputData.language,
      ageMonths: chronologicalAgeMonths,
    );

    final sentenceData = SpeechLanguageAssessmentService.analyzeSentenceFormation(
      detectedSentences: inputData.detectedSentences,
      ageMonths: chronologicalAgeMonths,
    );

    final fluencyData = SpeechLanguageAssessmentService.analyzeFluency(
      speechTimingData: inputData.speechTimingData,
      speechRateWPM: inputData.speechRateWPM,
      ageMonths: chronologicalAgeMonths,
    );

    final speechScore = (
      (wordClarityData.wordClarity ?? 50) * 0.2 +
      (vocabularyData.vocabularyScore ?? 50) * 0.3 +
      (sentenceData.sentenceFormation ?? 50) * 0.25 +
      (fluencyData.fluencyScore ?? 50) * 0.25
    ).clamp(0, 100);

    final speechDevAge =
        vocabularyData.vocabularyAge ?? chronologicalAgeMonths;

    // Cognitive Assessment
    final memoryData = CognitiveAssessmentService.analyzeMemory(
      presentedItems: inputData.presentedItems,
      recalledItems: inputData.recalledItems,
      ageMonths: chronologicalAgeMonths,
      testType: 'immediate',
    );

    final patternData = CognitiveAssessmentService.analyzePatternRecognition(
      patterns: inputData.patterns,
      childResponses: inputData.patternResponses,
      ageMonths: chronologicalAgeMonths,
    );

    final problemData = CognitiveAssessmentService.analyzeProblemSolving(
      problems: inputData.problems,
      solutions: inputData.problemSolutions,
      solutionTimes: inputData.solutionTimes,
      ageMonths: chronologicalAgeMonths,
    );

    final attentionData = CognitiveAssessmentService.analyzeAttentionSpan(
      taskDurationSeconds: inputData.taskDurationSeconds,
      attentionPoints: inputData.attentionPoints,
      ageMonths: chronologicalAgeMonths,
    );

    final cognitiveScore = CognitiveAssessmentService.calculateOverallCognitiveScore(
      memoryScore: memoryData.memoryScore ?? 50,
      patternScore: patternData.patternRecognitionScore ?? 50,
      problemScore: problemData.problemSolvingScore ?? 50,
      attentionScore: attentionData.attentionScore ?? 50,
    );

    final cognitiveDevAge = CognitiveAssessmentService.calculateCognitiveAge(
      cognitiveScore,
      chronologicalAgeMonths,
    );

    // Social-Emotional Assessment (simplified - would need facial analysis)
    final socialEmotionalScore = (inputData.eyeContactScore * 0.3 +
            inputData.facialExpressionScore * 0.3 +
            inputData.interactionScore * 0.4)
        .clamp(0, 100);

    // Health assessment (simplified)
    final healthScore = (inputData.visionScore * 0.3 +
            inputData.hearingScore * 0.3 +
            inputData.anemiaScore * 0.4)
        .clamp(0.0, 100.0);

    // Generate comprehensive assessment result
    final result = await ComprehensiveAssessmentOrchestrator
        .generateComprehensiveAssessment(
      childId: childId,
      chronologicalAgeMonths: chronologicalAgeMonths,
      motorScore: motorScore.toDouble(),
      speechScore: speechScore.toDouble(),
      cognitiveScore: cognitiveScore.toDouble(),
      socialEmotionalScore: socialEmotionalScore.toDouble(),
      healthScore: healthScore.toDouble(),
      motorDevelopmentalAge: motorDevAge,
      speechDevelopmentalAge: speechDevAge,
      cognitiveDevelopmentalAge: cognitiveDevAge,
    );

    return result;
  }
}

/// Assessment input data container
class AssessmentInputData {
  // Motor Skills
  final List<PoseLandmark> motorPoseLandmarks;
  final double jumpHeightCm;
  final double standDurationSeconds;
  final int wobbleCount;
  final double eyeHandCoordination;
  final double throwCatchTiming;
  final int throwCatchSuccessCount;
  final int throwCatchAttempts;
  final String motorNotes;

  // Speech Language  
  final List<double> mfccFeatures;
  final List<double> spectrogramData;
  final String language;
  final List<String> detectedWords;
  final List<String> detectedSentences;
  final List<double> speechTimingData;
  final double speechRateWPM;

  // Cognitive
  final List<String> presentedItems;
  final List<String> recalledItems;
  final List<Pattern> patterns;
  final List<String> patternResponses;
  final List<Problem> problems;
  final List<String> problemSolutions;
  final List<int> solutionTimes;
  final double taskDurationSeconds;
  final List<int> attentionPoints;

  // Social-Emotional
  final double eyeContactScore;
  final double facialExpressionScore;
  final double interactionScore;

  // Health
  final double visionScore;
  final double hearingScore;
  final double anemiaScore;

  AssessmentInputData({
    required this.motorPoseLandmarks,
    required this.jumpHeightCm,
    required this.standDurationSeconds,
    required this.wobbleCount,
    required this.eyeHandCoordination,
    required this.throwCatchTiming,
    required this.throwCatchSuccessCount,
    required this.throwCatchAttempts,
    required this.motorNotes,
    required this.mfccFeatures,
    required this.spectrogramData,
    required this.language,
    required this.detectedWords,
    required this.detectedSentences,
    required this.speechTimingData,
    required this.speechRateWPM,
    required this.presentedItems,
    required this.recalledItems,
    required this.patterns,
    required this.patternResponses,
    required this.problems,
    required this.problemSolutions,
    required this.solutionTimes,
    required this.taskDurationSeconds,
    required this.attentionPoints,
    required this.eyeContactScore,
    required this.facialExpressionScore,
    required this.interactionScore,
    required this.visionScore,
    required this.hearingScore,
    required this.anemiaScore,
  });
}

/// Helper class to generate comprehensive assessment results
class ComprehensiveAssessmentOrchestrator {
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
    // Calculate overall developmental score
    final overallScore = (motorScore * 0.25 +
            speechScore * 0.25 +
            cognitiveScore * 0.25 +
            socialEmotionalScore * 0.15 +
            healthScore * 0.10)
        .clamp(0.0, 100.0);

    // Determine risk level
    RiskLevel riskLevel = RiskLevel.low;
    int delayedAreas = 0;

    if (motorScore < 70) delayedAreas++;
    if (speechScore < 70) delayedAreas++;
    if (cognitiveScore < 70) delayedAreas++;
    if (socialEmotionalScore < 70) delayedAreas++;

    if (delayedAreas >= 3 || overallScore < 60) {
      riskLevel = RiskLevel.high;
    } else if (delayedAreas >= 1 || overallScore < 75) {
      riskLevel = RiskLevel.medium;
    }

    // Generate summary and recommendations
    final summary = _generateSummary(
      overallScore,
      riskLevel,
      delayedAreas,
    );

    final recommendations = _generateRecommendations(
      motorScore,
      speechScore,
      cognitiveScore,
    );

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
      requiresReferral: riskLevel == RiskLevel.high,
      referralSpecialist:
          riskLevel == RiskLevel.high ? 'Pediatrician / Specialist' : 'None',
    );
  }

  static String _generateSummary(
    double score,
    RiskLevel risk,
    int delayedAreas,
  ) {
    if (risk == RiskLevel.high) {
      return 'Critical delays identified in $delayedAreas areas. Immediate attention required.';
    } else if (risk == RiskLevel.medium) {
      return 'Mild delays detected. Targeted activities recommended.';
    } else {
      return 'Development is on track. Continue with routine engagement.';
    }
  }

  static String _generateRecommendations(
    double motor,
    double speech,
    double cognitive,
  ) {
    final recs = <String>[];
    if (motor < 70) recs.add('Focus on gross motor activities like jumping/balancing.');
    if (speech < 70) recs.add('Engage in more storytelling and conversation.');
    if (cognitive < 70) recs.add('Practice puzzles and memory games.');
    
    if (recs.isEmpty) return 'Maintain current activity schedule.';
    return recs.join(' ');
  }
}
