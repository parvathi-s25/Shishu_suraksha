// Module 7: Motor Assessment (3 rule-based tasks)
import 'dart:ui' show Offset;
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:shishu_suraksha/core/models/assessment_models.dart';
import 'package:shishu_suraksha/core/services/database_service.dart';
import 'package:shishu_suraksha/core/services/frame_processor.dart';
import 'package:shishu_suraksha/core/utils/landmark_math.dart';

class MotorAssessmentModule {
  final FrameProcessor frameProcessor;
  final DatabaseService database;

  // Thresholds for tasks
  static const double HIGH_VARIANCE_THRESHOLD = 50; // pixels
  static const double HIGH_ASYMMETRY_THRESHOLD = 30; // pixels

  MotorAssessmentModule({
    required this.frameProcessor,
    required this.database,
  });

  /// Task 1: Stand Still 10 Seconds
  /// Measure hip landmark variance over 10 seconds
  Future<double> assessBalanceTask(List<Offset> hipPositionsOver10Sec) async {
    if (hipPositionsOver10Sec.isEmpty) return 0;

    // Extract Y positions (vertical)
    final hipYPositions = hipPositionsOver10Sec.map((p) => p.dy).toList();
    
    // Calculate variance
    final variance = LandmarkMath.calculateVariance(hipYPositions);

    // Convert variance to score: lower variance = better balance
    final maxVariance = HIGH_VARIANCE_THRESHOLD;
    final score = ((maxVariance - variance.clamp(0, maxVariance)) / maxVariance) * 100;

    return score.clamp(0, 100).toDouble();
  }

  /// Task 2: Raise Both Arms
  /// Measure asymmetry between left and right elbow height
  Future<double> assessArmSymmetryTask(CameraImage cameraImage) async {
    try {
      final inputImage = await frameProcessor.convertToInputImage(cameraImage);
      final poses = await frameProcessor.processPose(inputImage);

      if (poses.isEmpty) return 0;

      final landmarks = poses.first.landmarks;
      final asymmetry = LandmarkMath.calculateElbowAsymmetry(landmarks);

      if (asymmetry == null) return 0;

      // Convert asymmetry to score: lower asymmetry = better score
      final maxAsymmetry = HIGH_ASYMMETRY_THRESHOLD;
      final score = ((maxAsymmetry - asymmetry.clamp(0, maxAsymmetry)) / maxAsymmetry) * 100;

      return score.clamp(0, 100).toDouble();
    } catch (e) {
      print('Arm symmetry assessment error: $e');
      return 0;
    }
  }

  /// Task 3: Walk Symmetry
  /// Track hip movement symmetry during a 5-step walk
  Future<double> assessWalkSymmetryTask(List<HipMovement> hipMovements) async {
    if (hipMovements.length < 5) return 0;

    // Calculate left vs right hip movement
    final leftMovements = hipMovements.map((h) => h.leftHipY).toList();
    final rightMovements = hipMovements.map((h) => h.rightHipY).toList();

    final leftVariance = LandmarkMath.calculateVariance(leftMovements);
    final rightVariance = LandmarkMath.calculateVariance(rightMovements);

    // Calculate asymmetry: difference between left and right variance
    final asymmetry = (leftVariance - rightVariance).abs();

    // Convert to score
    final maxAsymmetry = HIGH_VARIANCE_THRESHOLD;
    final score = ((maxAsymmetry - asymmetry.clamp(0, maxAsymmetry)) / maxAsymmetry) * 100;

    return score.clamp(0, 100).toDouble();
  }

  /// Calculate overall motor score
  double calculateOverallMotorScore({
    required double balanceScore,
    required double symmetryScore,
    required double walkSymmetryScore,
  }) {
    // Weighted average
    final overall =
        (balanceScore * 0.33) + (symmetryScore * 0.33) + (walkSymmetryScore * 0.34);
    return overall;
  }

  /// Complete motor assessment and save
  Future<void> completeMotorAssessment(
    String sessionId,
    double balanceScore,
    double symmetryScore,
    double walkSymmetryScore,
  ) async {
    final overallScore = calculateOverallMotorScore(
      balanceScore: balanceScore,
      symmetryScore: symmetryScore,
      walkSymmetryScore: walkSymmetryScore,
    );

    final result = PoseMotorResult(
      balanceScore: balanceScore,
      symmetryScore: symmetryScore,
      walkSymmetryScore: walkSymmetryScore,
      overallMotorScore: overallScore,
      timestamp: DateTime.now(),
    );

    await database.saveMotorResult(sessionId, result);
  }
}

/// Helper class for tracking hip movement
class HipMovement {
  final double leftHipY;
  final double rightHipY;

  HipMovement({
    required this.leftHipY,
    required this.rightHipY,
  });
}


