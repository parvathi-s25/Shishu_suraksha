import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseAnalyzer {
  /// Calculates the angle (in degrees) at the [middle] joint formed by [first] and [last].
  /// Returns 0.0 if any landmark is missing.
  double calculateAngle(PoseLandmark? first, PoseLandmark? middle, PoseLandmark? last) {
    if (first == null || middle == null || last == null) {
      return 0.0;
    }

    // Convert to radians
    final double angle = math.atan2(last.y - middle.y, last.x - middle.x) -
                         math.atan2(first.y - middle.y, first.x - middle.x);
    
    // Convert to degrees
    double degrees = angle * 180 / math.pi;

    // Normalize to [0, 180] (absolute value, handle wrap-around)
    degrees = degrees.abs(); 
    if (degrees > 180.0) {
      degrees = 360.0 - degrees;
    }

    return degrees;
  }

  /// Analyzes the [pose] and returns a list of warning messages.
  List<String> analyze(Pose pose) {
    final List<String> warnings = [];
    final landmarks = pose.landmarks;

    // 1. Back Posture Analysis (Left Side)
    // Angle: Left Shoulder -> Left Hip -> Left Knee
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    
    final double leftBodyAngle = calculateAngle(leftShoulder, leftHip, leftKnee);
    
    // 2. Back Posture Analysis (Right Side)
    // Angle: Right Shoulder -> Right Hip -> Right Knee
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];

    final double rightBodyAngle = calculateAngle(rightShoulder, rightHip, rightKnee);

    // Thresholds for "Bent Back" (Assuming standing)
    // Ideally ~180. If < 150, significant bend.
    if ((leftBodyAngle > 0 && leftBodyAngle < 150) || (rightBodyAngle > 0 && rightBodyAngle < 150)) {
      warnings.add("⚠ Back Bent Detected");
    }

    // 3. Knee Analysis (Left)
    // Angle: Left Hip -> Left Knee -> Left Ankle
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final double leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);

    // 4. Knee Analysis (Right)
    // Angle: Right Hip -> Right Knee -> Right Ankle
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final double rightKneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);

    // Knee issue (e.g., crouching or hyperextension not expected in simple standing)
    // This is context-dependent, but let's flag extreme crouching for now
    if ((leftKneeAngle > 0 && leftKneeAngle < 90) || (rightKneeAngle > 0 && rightKneeAngle < 90)) {
       warnings.add("⚠ Deep Crouch / Knee Issue");
    }
    
    // 5. Neck/Head Posture (Simple check: Ear -> Shoulder -> Hip)
    // Forward head posture often reduces this angle
    // Let's keep it simple for now as requested. 

    return warnings.toSet().toList(); // Remove duplicates
  }
}
