// Math utilities for landmark-based calculations
import 'dart:math' as math;
import 'dart:ui' show Offset;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class LandmarkMath {
  /// Calculate angle between three points (in degrees)
  /// A <- vertex -> B
  static double calculateAngle(Offset a, Offset vertex, Offset b) {
    final radians = math.atan2(b.dy - vertex.dy, b.dx - vertex.dx) -
        math.atan2(a.dy - vertex.dy, a.dx - vertex.dx);
    var angle = radians * 180 / math.pi;
    angle = angle.abs();
    if (angle > 180) {
      angle = 360 - angle;
    }
    return angle;
  }

  /// Calculate distance between two points
  static double distance(Offset p1, Offset p2) {
    return math.sqrt(math.pow(p1.dx - p2.dx, 2) + math.pow(p1.dy - p2.dy, 2));
  }

  /// Calculate slope in degrees (-90 to 90)
  static double calculateSlope(Offset p1, Offset p2) {
    if (p2.dx == p1.dx) return 90;
    final slope = (p2.dy - p1.dy) / (p2.dx - p1.dx);
    return math.atan(slope) * 180 / math.pi;
  }

  /// Get landmark position by type from a Map (google_mlkit_pose_detection v0.12+)
  static Offset? getLandmarkPosition(Map<PoseLandmarkType, PoseLandmark> landmarks, PoseLandmarkType type) {
    final landmark = landmarks[type];
    if (landmark == null) return null;
    return Offset(landmark.x, landmark.y);
  }

  /// Get face landmark position by index (generic dynamic list)
  static Offset? getFaceLandmarkPosition(List<dynamic> landmarks, int index) {
    if (index < 0 || index >= landmarks.length) return null;
    final landmark = landmarks[index];
    try {
      return Offset((landmark.x as num).toDouble(), (landmark.y as num).toDouble());
    } catch (_) {
      return null;
    }
  }

  /// Calculate hip slope (for posture analysis)
  static double? calculateHipSlope(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftHip = getLandmarkPosition(landmarks, PoseLandmarkType.leftHip);
    final rightHip = getLandmarkPosition(landmarks, PoseLandmarkType.rightHip);
    if (leftHip == null || rightHip == null) return null;
    return calculateSlope(leftHip, rightHip);
  }

  /// Calculate shoulder slope (for posture analysis)
  static double? calculateShoulderSlope(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftShoulder = getLandmarkPosition(landmarks, PoseLandmarkType.leftShoulder);
    final rightShoulder = getLandmarkPosition(landmarks, PoseLandmarkType.rightShoulder);
    if (leftShoulder == null || rightShoulder == null) return null;
    return calculateSlope(leftShoulder, rightShoulder);
  }

  /// Calculate spine deviation (angle from vertical).
  /// Uses nose as neck approximation; midHip = average of leftHip and rightHip.
  static double? calculateSpineDeviation(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final nose = getLandmarkPosition(landmarks, PoseLandmarkType.nose);
    final leftHip = getLandmarkPosition(landmarks, PoseLandmarkType.leftHip);
    final rightHip = getLandmarkPosition(landmarks, PoseLandmarkType.rightHip);
    if (nose == null || leftHip == null || rightHip == null) return null;
    final midHip = Offset((leftHip.dx + rightHip.dx) / 2, (leftHip.dy + rightHip.dy) / 2);
    final slope = calculateSlope(midHip, nose);
    return (90 - slope.abs()).abs();
  }

  /// Calculate knee angle (left or right)
  static double? calculateKneeAngle(
    Map<PoseLandmarkType, PoseLandmark> landmarks,
    PoseLandmarkType hip,
    PoseLandmarkType knee,
    PoseLandmarkType ankle,
  ) {
    final hipPos = getLandmarkPosition(landmarks, hip);
    final kneePos = getLandmarkPosition(landmarks, knee);
    final anklePos = getLandmarkPosition(landmarks, ankle);
    if (hipPos == null || kneePos == null || anklePos == null) return null;
    return calculateAngle(hipPos, kneePos, anklePos);
  }

  /// Calculate shoulder asymmetry
  static double? calculateShoulderAsymmetry(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftShoulder = getLandmarkPosition(landmarks, PoseLandmarkType.leftShoulder);
    final rightShoulder = getLandmarkPosition(landmarks, PoseLandmarkType.rightShoulder);
    if (leftShoulder == null || rightShoulder == null) return null;
    return (leftShoulder.dy - rightShoulder.dy).abs();
  }

  /// Calculate hip asymmetry
  static double? calculateHipAsymmetry(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftHip = getLandmarkPosition(landmarks, PoseLandmarkType.leftHip);
    final rightHip = getLandmarkPosition(landmarks, PoseLandmarkType.rightHip);
    if (leftHip == null || rightHip == null) return null;
    return (leftHip.dy - rightHip.dy).abs();
  }

  /// Calculate elbow asymmetry
  static double? calculateElbowAsymmetry(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftElbow = getLandmarkPosition(landmarks, PoseLandmarkType.leftElbow);
    final rightElbow = getLandmarkPosition(landmarks, PoseLandmarkType.rightElbow);
    if (leftElbow == null || rightElbow == null) return null;
    return (leftElbow.dy - rightElbow.dy).abs();
  }

  /// Calculate variance (for balance/tremor assessment)
  static double calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
            values.length;
    return math.sqrt(variance);
  }

  /// Count landmarks with sufficient confidence
  static int countValidLandmarks(Map<PoseLandmarkType, PoseLandmark> landmarks, {double minConfidence = 0.5}) {
    return landmarks.values.where((l) => l.likelihood > minConfidence).length;
  }
}
