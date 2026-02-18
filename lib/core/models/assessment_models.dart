// Core data models for assessment system
import 'package:cloud_firestore/cloud_firestore.dart';

/// Assessment session state tracking
class AssessmentState {
  bool poseDone = false;
  bool distanceCheckDone = false;
  bool eyeAlignmentDone = false;
  bool pupilReflexDone = false;
  bool colorVisionDone = false;
  bool refractionRiskDone = false;
  bool motorAssessmentDone = false;

  bool get allComplete =>
      poseDone &&
      distanceCheckDone &&
      eyeAlignmentDone &&
      pupilReflexDone &&
      colorVisionDone &&
      refractionRiskDone &&
      motorAssessmentDone;

  Map<String, dynamic> toMap() => {
        'poseDone': poseDone,
        'distanceCheckDone': distanceCheckDone,
        'eyeAlignmentDone': eyeAlignmentDone,
        'pupilReflexDone': pupilReflexDone,
        'colorVisionDone': colorVisionDone,
        'refractionRiskDone': refractionRiskDone,
        'motorAssessmentDone': motorAssessmentDone,
      };

  void reset() {
    poseDone = false;
    distanceCheckDone = false;
    eyeAlignmentDone = false;
    pupilReflexDone = false;
    colorVisionDone = false;
    refractionRiskDone = false;
    motorAssessmentDone = false;
  }
}

/// Pose detection result
class PoseResult {
  final double shoulderSlope; // degrees
  final double hipSlope; // degrees
  final double spineDeviation; // degrees
  final double kneeAngleLeft; // degrees
  final double kneeAngleRight; // degrees
  final int landmarkCount;
  final double score; // 0-100
  final List<String> issues;
  final DateTime timestamp;

  PoseResult({
    required this.shoulderSlope,
    required this.hipSlope,
    required this.spineDeviation,
    required this.kneeAngleLeft,
    required this.kneeAngleRight,
    required this.landmarkCount,
    required this.score,
    required this.issues,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'shoulderSlope': shoulderSlope,
        'hipSlope': hipSlope,
        'spineDeviation': spineDeviation,
        'kneeAngleLeft': kneeAngleLeft,
        'kneeAngleRight': kneeAngleRight,
        'landmarkCount': landmarkCount,
        'score': score,
        'issues': issues,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Distance check result
class DistanceCheckResult {
  final double faceHeightPixels;
  final String status; // "too_close", "too_far", "correct"
  final double score; // 0-100
  final DateTime timestamp;

  DistanceCheckResult({
    required this.faceHeightPixels,
    required this.status,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'faceHeightPixels': faceHeightPixels,
        'status': status,
        'score': score,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Eye alignment result
class EyeAlignmentResult {
  final double leftEyeOffset;
  final double rightEyeOffset;
  final double asymmetryDifference;
  final String status; // "aligned", "misaligned"
  final double score; // 0-100
  final DateTime timestamp;

  EyeAlignmentResult({
    required this.leftEyeOffset,
    required this.rightEyeOffset,
    required this.asymmetryDifference,
    required this.status,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'leftEyeOffset': leftEyeOffset,
        'rightEyeOffset': rightEyeOffset,
        'asymmetryDifference': asymmetryDifference,
        'status': status,
        'score': score,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Pupil reflex result
class PupilReflexResult {
  final double brightnessChangeBefore;
  final double brightnessChangeAfter;
  final double brightnessDifference;
  final String status; // "normal", "abnormal", "slow"
  final double score; // 0-100
  final DateTime timestamp;

  PupilReflexResult({
    required this.brightnessChangeBefore,
    required this.brightnessChangeAfter,
    required this.brightnessDifference,
    required this.status,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'brightnessChangeBefore': brightnessChangeBefore,
        'brightnessChangeAfter': brightnessChangeAfter,
        'brightnessDifference': brightnessDifference,
        'status': status,
        'score': score,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Color vision result
class ColorVisionResult {
  final int totalTestsGiven;
  final int correctAnswers;
  final double accuracy; // percentage
  final String status; // "normal", "abnormal"
  final double score; // 0-100
  final DateTime timestamp;

  ColorVisionResult({
    required this.totalTestsGiven,
    required this.correctAnswers,
    required this.accuracy,
    required this.status,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'totalTestsGiven': totalTestsGiven,
        'correctAnswers': correctAnswers,
        'accuracy': accuracy,
        'status': status,
        'score': score,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Refraction risk result
class RefractionRiskResult {
  final double visualAcuity; // 6/X format as decimal
  final bool frequentSquint;
  final int blinkRate; // blinks per 10 seconds
  final String riskLevel; // "low", "medium", "high"
  final double score; // 0-100
  final DateTime timestamp;

  RefractionRiskResult({
    required this.visualAcuity,
    required this.frequentSquint,
    required this.blinkRate,
    required this.riskLevel,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'visualAcuity': visualAcuity,
        'frequentSquint': frequentSquint,
        'blinkRate': blinkRate,
        'riskLevel': riskLevel,
        'score': score,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Motor assessment result
class MotorAssessmentResult {
  final double balanceScore; // Task 1: Stand still
  final double symmetryScore; // Task 2: Raise arms
  final double walkSymmetryScore; // Task 3: Walk
  final double overallMotorScore; // 0-100
  final DateTime timestamp;

  MotorAssessmentResult({
    required this.balanceScore,
    required this.symmetryScore,
    required this.walkSymmetryScore,
    required this.overallMotorScore,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'balanceScore': balanceScore,
        'symmetryScore': symmetryScore,
        'walkSymmetryScore': walkSymmetryScore,
        'overallMotorScore': overallMotorScore,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Full assessment session
class AssessmentSession {
  final String id;
  final String childId;
  final DateTime createdAt;
  DateTime? completedAt;
  
  PoseResult? poseResult;
  DistanceCheckResult? distanceResult;
  EyeAlignmentResult? alignmentResult;
  PupilReflexResult? pupilResult;
  ColorVisionResult? colorVisionResult;
  RefractionRiskResult? refractionResult;
  MotorAssessmentResult? motorResult;

  AssessmentSession({
    required this.id,
    required this.childId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'childId': childId,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'poseResult': poseResult?.toMap(),
        'distanceResult': distanceResult?.toMap(),
        'alignmentResult': alignmentResult?.toMap(),
        'pupilResult': pupilResult?.toMap(),
        'colorVisionResult': colorVisionResult?.toMap(),
        'refractionResult': refractionResult?.toMap(),
        'motorResult': motorResult?.toMap(),
      };

  /// Calculate overall development score
  double calculateDevelopmentScore() {
    double score = 0;
    int validScores = 0;

    if (poseResult != null) {
      score += poseResult!.score * 0.20;
      validScores++;
    }
    if (motorResult != null) {
      score += motorResult!.overallMotorScore * 0.30;
      validScores++;
    }
    if (alignmentResult != null) {
      score += alignmentResult!.score * 0.15;
      validScores++;
    }
    if (colorVisionResult != null) {
      score += colorVisionResult!.score * 0.15;
      validScores++;
    }
    if (refractionResult != null) {
      score += (100 - (refractionResult!.riskLevel == 'high' ? 30 : refractionResult!.riskLevel == 'medium' ? 15 : 0)).toDouble() * 0.10;
      validScores++;
    }
    if (pupilResult != null) {
      score += pupilResult!.score * 0.10;
      validScores++;
    }

    return validScores > 0 ? score / validScores : 0;
  }
}
