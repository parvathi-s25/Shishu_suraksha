// Module 1: Pose & Body Detection (Rule-based, working)
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:shishu_suraksha/core/models/assessment_models.dart';
import 'package:shishu_suraksha/core/services/database_service.dart';
import 'package:shishu_suraksha/core/services/frame_processor.dart';
import 'package:shishu_suraksha/core/utils/landmark_math.dart';

class PoseDetectionModule {
  final FrameProcessor frameProcessor;
  final DatabaseService database;

  PoseDetectionModule({
    required this.frameProcessor,
    required this.database,
  });

  /// Step 1: Validate person is fully in frame
  bool validatePersonInFrame(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    if (landmarks.isEmpty) return false;
    // Need at least 20 landmarks with sufficient confidence
    final validLandmarks = LandmarkMath.countValidLandmarks(landmarks, minConfidence: 0.3);
    return validLandmarks >= 20;
  }

  /// Step 2: Extract key features
  PoseFeatures extractFeatures(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final shoulderSlope = LandmarkMath.calculateShoulderSlope(landmarks) ?? 0;
    final hipSlope = LandmarkMath.calculateHipSlope(landmarks) ?? 0;
    final spineDeviation = LandmarkMath.calculateSpineDeviation(landmarks) ?? 0;
    final kneeAngleLeft = LandmarkMath.calculateKneeAngle(
      landmarks,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
    ) ?? 0;
    final kneeAngleRight = LandmarkMath.calculateKneeAngle(
      landmarks,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
    ) ?? 0;

    return PoseFeatures(
      shoulderSlope: shoulderSlope,
      hipSlope: hipSlope,
      spineDeviation: spineDeviation,
      kneeAngleLeft: kneeAngleLeft,
      kneeAngleRight: kneeAngleRight,
      landmarkCount: landmarks.length,
    );
  }

  /// Step 3: Rule-based classification
  PoseAnalysis analyzePosture(PoseFeatures features) {
    final issues = <String>[];
    int penaltyPoints = 0;

    // Rule 1: Shoulder imbalance
    if (features.shoulderSlope.abs() > 10) {
      issues.add('Shoulder imbalance detected');
      penaltyPoints += 15;
    }

    // Rule 2: Spinal deviation
    if (features.spineDeviation > 8) {
      issues.add('Spinal deviation detected');
      penaltyPoints += 20;
    }

    // Rule 3: Hip asymmetry
    if (features.hipSlope.abs() > 10) {
      issues.add('Hip asymmetry detected');
      penaltyPoints += 15;
    }

    // Rule 4: Knee angle abnormality (normal is ~170-180°)
    if (features.kneeAngleLeft < 160 || features.kneeAngleLeft > 190) {
      issues.add('Left knee angle abnormal');
      penaltyPoints += 10;
    }
    if (features.kneeAngleRight < 160 || features.kneeAngleRight > 190) {
      issues.add('Right knee angle abnormal');
      penaltyPoints += 10;
    }

    final score = (100 - penaltyPoints).clamp(0, 100).toDouble();

    return PoseAnalysis(
      features: features,
      issues: issues,
      score: score,
      severity: penaltyPoints > 40 ? 'high' : penaltyPoints > 20 ? 'medium' : 'low',
    );
  }

  /// Process pose from camera frame
  Future<PoseResult?> processPoseFrame(CameraImage cameraImage) async {
    try {
      final inputImage = await frameProcessor.convertToInputImage(cameraImage);
      final poses = await frameProcessor.processPose(inputImage);

      if (poses.isEmpty) {
        return PoseResult(
          shoulderSlope: 0,
          hipSlope: 0,
          spineDeviation: 0,
          kneeAngleLeft: 0,
          kneeAngleRight: 0,
          landmarkCount: 0,
          score: 0,
          issues: ['No person detected'],
          timestamp: DateTime.now(),
        );
      }

      final landmarks = poses.first.landmarks;

      if (!validatePersonInFrame(landmarks)) {
        return PoseResult(
          shoulderSlope: 0,
          hipSlope: 0,
          spineDeviation: 0,
          kneeAngleLeft: 0,
          kneeAngleRight: 0,
          landmarkCount: landmarks.length,
          score: 0,
          issues: ['Please stand fully in frame'],
          timestamp: DateTime.now(),
        );
      }

      final features = extractFeatures(landmarks);
      final analysis = analyzePosture(features);

      return PoseResult(
        shoulderSlope: analysis.features.shoulderSlope,
        hipSlope: analysis.features.hipSlope,
        spineDeviation: analysis.features.spineDeviation,
        kneeAngleLeft: analysis.features.kneeAngleLeft,
        kneeAngleRight: analysis.features.kneeAngleRight,
        landmarkCount: analysis.features.landmarkCount,
        score: analysis.score,
        issues: analysis.issues,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Pose analysis error: $e');
      return null;
    }
  }

  /// Complete pose assessment and save
  Future<void> completePoseAssessment(String sessionId, PoseResult result) async {
    await database.savePoseResult(sessionId, result);
  }
}

/// Intermediate data structures
class PoseFeatures {
  final double shoulderSlope;
  final double hipSlope;
  final double spineDeviation;
  final double kneeAngleLeft;
  final double kneeAngleRight;
  final int landmarkCount;

  PoseFeatures({
    required this.shoulderSlope,
    required this.hipSlope,
    required this.spineDeviation,
    required this.kneeAngleLeft,
    required this.kneeAngleRight,
    required this.landmarkCount,
  });
}

class PoseAnalysis {
  final PoseFeatures features;
  final List<String> issues;
  final double score;
  final String severity;

  PoseAnalysis({
    required this.features,
    required this.issues,
    required this.score,
    required this.severity,
  });
}
