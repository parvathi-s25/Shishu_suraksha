
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math' as math;

class MotorAssessmentService {
  
  /// Analyze a single pose frame for motor delay indicators
  Map<String, dynamic> analyzePose(Pose pose) {
    final landmarks = pose.landmarks;
    
    // 1. Check Visibility of Key Parts
    bool leftSideVisible = _isPartVisible(landmarks[PoseLandmarkType.leftShoulder]) && 
                           _isPartVisible(landmarks[PoseLandmarkType.leftHip]);
    bool rightSideVisible = _isPartVisible(landmarks[PoseLandmarkType.rightShoulder]) && 
                            _isPartVisible(landmarks[PoseLandmarkType.rightHip]);

    if (!leftSideVisible || !rightSideVisible) {
      return {
        'status': 'Incomplete',
        'message': 'Ensure full body is visible'
      };
    }

    // 2. Check Symmetry (Shoulder Alignment)
    // Simple check: Difference in Y coordinates of shoulders
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder]!;
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder]!;
    
    double shoulderSlope = (leftShoulder.y - rightShoulder.y).abs();
    
    // 3. Check for Slouching (Shoulder to Hip vertical alignment)
    // Ideally shoulder x should be close to hip x when standing straight facing camera
    final leftHip = landmarks[PoseLandmarkType.leftHip]!;
    
    double verticalAlignment = (leftShoulder.x - leftHip.x).abs();

    List<String> issues = [];
    if (shoulderSlope > 50) { // Threshold depends on resolution/distance, this is rough
      issues.add("Asymmetrical Posture (Shoulder Tilt)");
    }
    
    if (verticalAlignment > 80) {
      issues.add("Poor Posture / Slouching Detected");
    }

    return {
      'status': issues.isEmpty ? 'Normal' : 'Attention Needed',
      'issues': issues,
      'confidence': 0.85 // Mock confidence
    };
  }

  bool _isPartVisible(PoseLandmark? landmark) {
    return landmark != null && landmark.likelihood > 0.5;
  }
  
  // Angle calculation helper
  double _getAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    double result =
        math.atan2(last.y - mid.y, last.x - mid.x) -
        math.atan2(first.y - mid.y, first.x - mid.x);
    result = result * 180 / math.pi;
    result = result.abs(); // Angle should never be negative
    if (result > 180) {
      result = 360.0 - result; // Always get the smaller angle
    }
    return result;
  }
}
