// Math utilities for landmark-based calculations
import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class LandmarkMath {
  /// Calculate angle between three points (in degrees)
  /// A ← vertex → B
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

  /// Get landmark position by type
  static Offset? getLandmarkPosition(List<PoseLandmark> landmarks, PoseLandmarkType type) {
    try {
      final landmark = landmarks.firstWhere((l) => l.type == type);
      return Offset(landmark.position.x, landmark.position.y);
    } catch (e) {
      return null;
    }
  }

  /// Get face landmark position by index
  static Offset? getFaceLandmarkPosition(List<dynamic> landmarks, int index) {
    if (index < 0 || index >= landmarks.length) return null;
    final landmark = landmarks[index];
    if (landmark is NormalizedVisionPoint) {
      return Offset(landmark.x, landmark.y);
    }
    return null;
  }

  /// Calculate hip slope (for posture analysis)
  static double? calculateHipSlope(List<PoseLandmark> landmarks) {
    final leftHip = getLandmarkPosition(landmarks, PoseLandmarkType.leftHip);
    final rightHip = getLandmarkPosition(landmarks, PoseLandmarkType.rightHip);

    if (leftHip == null || rightHip == null) return null;
    return calculateSlope(leftHip, rightHip);
  }

  /// Calculate shoulder slope (for posture analysis)
  static double? calculateShoulderSlope(List<PoseLandmark> landmarks) {
    final leftShoulder = getLandmarkPosition(landmarks, PoseLandmarkType.leftShoulder);
    final rightShoulder = getLandmarkPosition(landmarks, PoseLandmarkType.rightShoulder);

    if (leftShoulder == null || rightShoulder == null) return null;
    return calculateSlope(leftShoulder, rightShoulder);
  }

  /// Calculate spine deviation (angle from vertical)
  static double? calculateSpineDeviation(List<PoseLandmark> landmarks) {
    final neck = getLandmarkPosition(landmarks, PoseLandmarkType.neck);
    final midHip = getLandmarkPosition(landmarks, PoseLandmarkType.midHip);

    if (neck == null || midHip == null) return null;

    // Calculate angle from vertical (0° = straight, 90° = horizontal)
    final slope = calculateSlope(midHip, neck);
    return (90 - slope.abs()).abs(); // 0° = vertical, increases as it deviates
  }

  /// Calculate knee angle (left or right)
  static double? calculateKneeAngle(
    List<PoseLandmark> landmarks,
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

  /// Calculate shoulder asymmetry (difference between left and right)
  static double? calculateShoulderAsymmetry(List<PoseLandmark> landmarks) {
    final leftShoulder = getLandmarkPosition(landmarks, PoseLandmarkType.leftShoulder);
    final rightShoulder = getLandmarkPosition(landmarks, PoseLandmarkType.rightShoulder);

    if (leftShoulder == null || rightShoulder == null) return null;

    final leftHeight = leftShoulder.dy;
    final rightHeight = rightShoulder.dy;
    return (leftHeight - rightHeight).abs();
  }

  /// Calculate hip asymmetry
  static double? calculateHipAsymmetry(List<PoseLandmark> landmarks) {
    final leftHip = getLandmarkPosition(landmarks, PoseLandmarkType.leftHip);
    final rightHip = getLandmarkPosition(landmarks, PoseLandmarkType.rightHip);

    if (leftHip == null || rightHip == null) return null;

    final leftHeight = leftHip.dy;
    final rightHeight = rightHip.dy;
    return (leftHeight - rightHeight).abs();
  }

  /// Calculate elbow asymmetry (for arm raising task)
  static double? calculateElbowAsymmetry(List<PoseLandmark> landmarks) {
    final leftElbow = getLandmarkPosition(landmarks, PoseLandmarkType.leftElbow);
    final rightElbow = getLandmarkPosition(landmarks, PoseLandmarkType.rightElbow);

    if (leftElbow == null || rightElbow == null) return null;

    final leftHeight = leftElbow.dy;
    final rightHeight = rightElbow.dy;
    return (leftHeight - rightHeight).abs();
  }

  /// Calculate hip movement variance (for balance assessment)
  static double calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
            values.length;
    return math.sqrt(variance);
  }

  /// Count landmarks with sufficient confidence
  static int countValidLandmarks(List<PoseLandmark> landmarks, {double minConfidence = 0.5}) {
    return landmarks.where((l) => l.inFrameLikelihood > minConfidence).length;
  }
}
