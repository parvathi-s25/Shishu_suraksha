import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';

class PoseAnalysisResult {
  final List<Pose> poses;
  final double postureScore;
  final List<String> issues;
  final Map<String, double> angles; // For visualization
  final bool isGoodPosture;

  PoseAnalysisResult({
    required this.poses,
    required this.postureScore,
    required this.issues,
    required this.angles,
    required this.isGoodPosture,
  });
}

class PoseAnalysisService {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());

  Future<PoseAnalysisResult?> analyzeImage(InputImage inputImage) async {
    try {
      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) return null;

      // Analyze the first detected person
      return _analyzePose(poses.first, poses);
    } catch (e) {
      debugPrint("Error detecting pose: $e");
      return null;
    }
  }

  PoseAnalysisResult _analyzePose(Pose pose, List<Pose> allPoses) {
    List<String> issues = [];
    double score = 100.0;
    Map<String, double> angles = {};

    // Helper to get landmark
    PoseLandmark? getPoint(PoseLandmarkType type) {
      return pose.landmarks[type];
    }

    final nose = getPoint(PoseLandmarkType.nose);
    final leftShoulder = getPoint(PoseLandmarkType.leftShoulder);
    final rightShoulder = getPoint(PoseLandmarkType.rightShoulder);
    final leftEar = getPoint(PoseLandmarkType.leftEar);
    final rightEar = getPoint(PoseLandmarkType.rightEar);
    final leftHip = getPoint(PoseLandmarkType.leftHip);
    final rightHip = getPoint(PoseLandmarkType.rightHip);
    
    // 1. Shoulder Alignment Check
    if (leftShoulder != null && rightShoulder != null) {
      double dy = leftShoulder.y - rightShoulder.y;
      double dx = leftShoulder.x - rightShoulder.x;
      double shoulderAngle = (atan2(dy, dx) * 180 / pi).abs(); // 0 is horizontal
      
      angles['shoulder_angle'] = shoulderAngle;
      
      if (shoulderAngle > 5.0) { // Threshold
        score -= 15;
        issues.add("Uneven Shoulders");
      }
    }

    // 2. Head Tilt Check (Ear alignment relative to shoulders)
    if (leftEar != null && rightEar != null) {
       double dy = leftEar.y - rightEar.y;
       double dx = leftEar.x - rightEar.x;
       double headAngle = (atan2(dy, dx) * 180 / pi).abs();
       
       angles['head_tilt'] = headAngle;

       if (headAngle > 8.0) {
         score -= 10;
         issues.add("Head Tilt Detected");
       }
    }

    // 3. Spine/Trunk Alignment (Nose to Mid-Hip)
    // Approximate spine line
    if (nose != null && leftHip != null && rightHip != null) {
       double midHipX = (leftHip.x + rightHip.x) / 2;
       double deviation = (nose.x - midHipX).abs();
       
       // Normalize deviation by shoulder width?
       // Let's use simpler heuristic: vertical alignment check
       // If nose X is significantly far from hip center X
       
       double hipWidth = (leftHip.x - rightHip.x).abs();
       if (hipWidth > 0) {
          double deviationRatio = deviation / hipWidth;
          angles['spine_deviation'] = deviationRatio;
          
          if (deviationRatio > 0.3) {
             score -= 20;
             issues.add("Spine/Trunk Misalignment");
          }
       }
    }

    // Clamp score
    score = score.clamp(0.0, 100.0);

    return PoseAnalysisResult(
      poses: allPoses,
      postureScore: score,
      issues: issues,
      angles: angles,
      isGoodPosture: score >= 80,
    );
  }

  void close() {
    _poseDetector.close();
  }
}
