import 'dart:math';

/// Motor Skills Assessment Service
/// 
/// Processes motor skills assessments using pose detection data.
/// Works offline with cached ML models.
class MotorSkillsAssessmentService {
  
  // WHO Age-Appropriate Benchmarks (in months)
  static const Map<String, Map<int, double>> developmentalBenchmarks = {
    'jump_height': {
      24: 15, // 2 years: 15cm
      36: 25, // 3 years: 25cm
      48: 35, // 4 years: 35cm
      60: 45, // 5 years: 45cm
    },
    'standing_balance': {
      18: 10, // 18 months: 10 seconds
      24: 30, // 2 years: 30 seconds
      36: 60, // 3 years: 60 seconds
      48: 120, // 4 years: 120 seconds (2 minutes)
      60: 120, // 5 years: 120 seconds
    },
    'walk_test': {
      12: 60, // 12 months: can walk with support
      18: 70, // 18 months: independent walk
      24: 80, // 2 years: steady walk
      36: 90, // 3 years: coordinated walk
      48: 95, // 4 years: normal gait
    }
  };

  /// Analyzes jump test data
  /// 
  /// Input: pose landmarks from MediaPipe (body keypoints)
  /// Output: motor assessment scores
  static MotorSkillsAssessmentData analyzeJumpTest({
    required List<PoseLandmark> poseLandmarks,
    required double jumpHeightCm,
    required int ageMonths,
    required String notes,
  }) {
    // Calculate joint angles
    final shoulderAngle = _calculateAngle(
      point1: poseLandmarks[11], // left shoulder
      point2: poseLandmarks[13], // left elbow
      point3: poseLandmarks[15], // left wrist
    );

    final hipAngle = _calculateAngle(
      point1: poseLandmarks[11], // shoulder
      point2: poseLandmarks[23], // hip
      point3: poseLandmarks[25], // knee
    );

    // Arm swing quality (0-100)
    final armSwingQuality = _calculateArmSwingQuality(shoulderAngle);

    // Landing stability (0-100) - based on hip-knee-ankle alignment
    final landingStability = _calculateLandingStability(hipAngle);

    // Jump score (0-100) - based on height and technique
    final jumpBenchmark = developmentalBenchmarks['jump_height']?[ageMonths] ?? 30;
    final jumpScore = _normalizeScore(jumpHeightCm, jumpBenchmark, 0, 60);

    return MotorSkillsAssessmentData(
      jumpHeight: jumpHeightCm,
      jumpScore: jumpScore,
      armSwingQuality: armSwingQuality,
      landingStability: landingStability,
      notes: notes,
    );
  }

  /// Analyzes balance test data
  /// 
  /// Input: pose stability over time, wobble detection
  /// Output: balance scores
  static MotorSkillsAssessmentData analyzeBalanceTest({
    required List<PoseLandmark> poseLandmarksSequence,
    required double standDurationSeconds,
    required int wobbleCount,
    required int ageMonths,
  }) {
    // Stability calculation - how much body sway?
    final postureStability = _calculatePostureStability(poseLandmarksSequence);

    // Balance benchmark
    final balanceBenchmark =
        developmentalBenchmarks['standing_balance']?[ageMonths] ?? 60;

    // Balance score (0-100)
    final balanceScore = _normalizeScore(
      standDurationSeconds,
      balanceBenchmark,
      0,
      120,
    );

    // Adjust based on wobbles
    final wobbleAdjustment = (wobbleCount * 5).clamp(0, 30).toDouble();
    final adjustedBalanceScore = (balanceScore - wobbleAdjustment).clamp(0.0, 100.0);

    return MotorSkillsAssessmentData(
      singleLegStandDuration: standDurationSeconds,
      wobbleCount: wobbleCount,
      balanceScore: adjustedBalanceScore,
      postureStability: postureStability,
    );
  }

  /// Analyzes walk test data
  /// 
  /// Input: gait analysis from pose sequence
  /// Output: walk coordination scores
  static MotorSkillsAssessmentData analyzeWalkTest({
    required List<PoseLandmark> poseLandmarksSequence,
    required int ageMonths,
  }) {
    // Calculate gait symmetry (left vs right side)
    final gaitSymmetry = _calculateGaitSymmetry(poseLandmarksSequence);

    // Step coordination (smooth vs jerky steps)
    final stepCoordination = _calculateStepCoordination(poseLandmarksSequence);

    // Walk score (0-100)
    final walkBenchmark = developmentalBenchmarks['walk_test']?[ageMonths] ?? 85;
    final walkScore =
        _normalizeScore(gaitSymmetry, walkBenchmark, 50, 100);

    return MotorSkillsAssessmentData(
      gaitSymmetry: gaitSymmetry,
      stepCoordination: stepCoordination,
      walkScore: walkScore,
    );
  }

  /// Analyzes throw/catch coordination
  /// 
  /// Input: hand-eye coordination from pose, timing data
  /// Output: coordination scores
  static MotorSkillsAssessmentData analyzeThrowCatchTest({
    required double eyeHandCoordination,
    required double throwCatchTiming,
    required int successCount,
    required int totalAttempts,
  }) {
    // Calculate throw accuracy (0-100)
    final throwCatchScore =
        (successCount / totalAttempts * 100).clamp(0, 100).toDouble();

    return MotorSkillsAssessmentData(
      eyeHandCoordination: eyeHandCoordination,
      throwCatchTiming: throwCatchTiming,
      throwCatchScore: throwCatchScore,
    );
  }

  /// Calculates overall motor score (weighted average)
  static double calculateOverallMotorScore({
    required double jumpScore,
    required double balanceScore,
    required double walkScore,
    required double throwCatchScore,
  }) {
    // Weighted average: 30% jump, 30% balance, 25% walk, 15% throw-catch
    return (jumpScore * 0.30 +
            balanceScore * 0.30 +
            walkScore * 0.25 +
            throwCatchScore * 0.15)
        .clamp(0.0, 100.0);
  }

  /// Calculates developmental age in months based on motor score
  static int calculateDevelopmentalAge(double motorScore, int chronologicalAge) {
    // Simple linear mapping: motor score to developmental age
    // This could be replaced with a more sophisticated ML model
    
    if (motorScore >= 95) {
      return chronologicalAge;
    } else if (motorScore >= 85) {
      return (chronologicalAge * 0.95).toInt();
    } else if (motorScore >= 75) {
      return (chronologicalAge * 0.90).toInt();
    } else if (motorScore >= 65) {
      return (chronologicalAge * 0.80).toInt();
    } else if (motorScore >= 50) {
      return (chronologicalAge * 0.70).toInt();
    } else {
      return (chronologicalAge * 0.60).toInt();
    }
  }

  // ========================================================================
  // PRIVATE HELPER METHODS
  // ========================================================================

  /// Calculates angle between three points (in degrees)
  static double _calculateAngle({
    required PoseLandmark point1,
    required PoseLandmark point2,
    required PoseLandmark point3,
  }) {
    final vector1 = (
      x: point1.x - point2.x,
      y: point1.y - point2.y,
    );
    final vector2 = (
      x: point3.x - point2.x,
      y: point3.y - point2.y,
    );

    final dotProduct = vector1.x * vector2.x + vector1.y * vector2.y;
    final magnitude1 = _vectorMagnitude(vector1.x, vector1.y);
    final magnitude2 = _vectorMagnitude(vector2.x, vector2.y);

    if (magnitude1 == 0 || magnitude2 == 0) return 0;

    final cosAngle = dotProduct / (magnitude1 * magnitude2);
    final angle = (acos(cosAngle.clamp(-1, 1)) * 180 / 3.14159);

    return angle;
  }

  static double _vectorMagnitude(double x, double y) {
    return sqrt(x * x + y * y);
  }

  static double _calculateArmSwingQuality(double shoulderAngle) {
    // Greater arm swing = better quality (0-100)
    // Optimal angle range: 80-120 degrees
    if (shoulderAngle < 40) return 20.0; // limited swing
    if (shoulderAngle < 80) return 50.0; // moderate swing
    if (shoulderAngle <= 130) return 100.0; // optimal swing
    return 80.0; // excessive swing
  }

  static double _calculateLandingStability(double hipAngle) {
    // Proper landing: hips slightly bent (110-130 degrees)
    // Optimal angle: 120 degrees
    if (hipAngle < 90) return 30.0; // too bent
    if (hipAngle < 110) return 70.0; // acceptable
    if (hipAngle <= 130) return 100.0; // optimal
    if (hipAngle <= 150) return 60.0; // underflexed
    return 20.0; // stuck legs
  }

  static double _calculatePostureStability(List<PoseLandmark> poseLandmarks) {
    // Calculate variance in center of mass position
    // Lower variance = more stable
    if (poseLandmarks.isEmpty) return 0;

    double xSum = 0, ySum = 0;
    for (final landmark in poseLandmarks) {
      xSum += landmark.x;
      ySum += landmark.y;
    }

    final centerX = xSum / poseLandmarks.length;
    final centerY = ySum / poseLandmarks.length;

    double variance = 0;
    for (final landmark in poseLandmarks) {
      variance += ((landmark.x - centerX) * (landmark.x - centerX) +
          (landmark.y - centerY) * (landmark.y - centerY));
    }

    variance /= poseLandmarks.length;

    // Convert variance to 0-100 score (lower variance = higher score)
    return (100 - (variance * 100).clamp(0.0, 100.0)).clamp(0.0, 100.0);
  }

  static double _calculateGaitSymmetry(List<PoseLandmark> poseLandmarks) {
    // Compare left vs right side movements
    // 100% = perfectly symmetric
    if (poseLandmarks.length < 2) return 0;

    double leftVariance = 0, rightVariance = 0;

    // Left side: landmarks 11, 13, 15, 23, 25, 27 (shoulder, elbow, wrist, hip, knee, ankle)
    // Right side: landmarks 12, 14, 16, 24, 26, 28

    for (int i = 0; i < poseLandmarks.length - 1; i++) {
      if (i % 2 == 0) {
        // Left side
        leftVariance += ((poseLandmarks[i + 1].x - poseLandmarks[i].x) *
            (poseLandmarks[i + 1].x - poseLandmarks[i].x));
      } else {
        // Right side
        rightVariance += ((poseLandmarks[i + 1].x - poseLandmarks[i].x) *
            (poseLandmarks[i + 1].x - poseLandmarks[i].x));
      }
    }

    leftVariance /= (poseLandmarks.length / 2);
    rightVariance /= (poseLandmarks.length / 2);

    final symmetryRatio =
        1 - ((leftVariance - rightVariance).abs() / (leftVariance + rightVariance + 0.01));

    return (symmetryRatio * 100).clamp(0.0, 100.0);
  }

  static double _calculateStepCoordination(List<PoseLandmark> poseLandmarks) {
    // Measure smoothness of step transitions
    // Jerky steps = lower score, smooth steps = higher score

    if (poseLandmarks.length < 3) return 0;

    double smoothness = 0;
    for (int i = 1; i < poseLandmarks.length - 1; i++) {
      final dx1 = poseLandmarks[i].x - poseLandmarks[i - 1].x;
      final dy1 = poseLandmarks[i].y - poseLandmarks[i - 1].y;
      final dx2 = poseLandmarks[i + 1].x - poseLandmarks[i].x;
      final dy2 = poseLandmarks[i + 1].y - poseLandmarks[i].y;

      // Check for smooth transitions (acceleration should be minimal)
      final acceleration = sqrt((dx2 - dx1) * (dx2 - dx1) + (dy2 - dy1) * (dy2 - dy1));
      smoothness += acceleration;
    }

    smoothness /= (poseLandmarks.length - 2);

    // Convert to 0-100 score (lower acceleration = higher score)
    return (100 - (smoothness * 10).clamp(0.0, 100.0)).clamp(0.0, 100.0);
  }

  static double _normalizeScore(
    double value,
    double benchmark,
    double min,
    double max,
  ) {
    if (value <= min) return 20.0;
    if (value >= max) return 100.0;

    // Linear interpolation between benchmark (75 points) and max (100 points)
    if (value < benchmark) {
      return 20 + (value - min) / (benchmark - min) * 55;
    } else {
      return 75 + (value - benchmark) / (max - benchmark) * 25;
    }
  }
}

// ============================================================================
// HELPER MODELS & TYPES
// ============================================================================

/// Pose landmark from MediaPipe
class PoseLandmark {
  final double x;
  final double y;
  final double z;
  final double confidence;

  PoseLandmark({
    required this.x,
    required this.y,
    required this.z,
    required this.confidence,
  });
}

/// Motor assessment data holder
class MotorSkillsAssessmentData {
  final double? jumpHeight;
  final double? jumpScore;
  final double? armSwingQuality;
  final double? landingStability;
  final double? singleLegStandDuration;
  final int? wobbleCount;
  final double? balanceScore;
  final double? postureStability;
  final double? gaitSymmetry;
  final double? stepCoordination;
  final double? walkScore;
  final double? eyeHandCoordination;
  final double? throwCatchTiming;
  final double? throwCatchScore;
  final String? notes;

  MotorSkillsAssessmentData({
    this.jumpHeight,
    this.jumpScore,
    this.armSwingQuality,
    this.landingStability,
    this.singleLegStandDuration,
    this.wobbleCount,
    this.balanceScore,
    this.postureStability,
    this.gaitSymmetry,
    this.stepCoordination,
    this.walkScore,
    this.eyeHandCoordination,
    this.throwCatchTiming,
    this.throwCatchScore,
    this.notes,
  });
}
