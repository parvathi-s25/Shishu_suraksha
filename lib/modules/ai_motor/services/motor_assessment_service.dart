
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
    
    // 3. Check for Slouching (Shoulder to Hip vertical alignment - Front View)
    final leftHip = landmarks[PoseLandmarkType.leftHip]!;
    final rightHip = landmarks[PoseLandmarkType.rightHip]!;
    
    double verticalAlignment = (leftShoulder.x - leftHip.x).abs();

    // 4. Check Hip Symmetry
    double hipSlope = (leftHip.y - rightHip.y).abs();

    // 5. Check Side Profile (Forward Head Posture / Kyphosis)
    // Needs Ear, Shoulder, Hip
    final leftEar = landmarks[PoseLandmarkType.leftEar];
    
    List<String> issues = [];
    
    // Front View Analysis
    if (shoulderSlope > 50) issues.add("Asymmetrical Shoulders (Potential Scoliosis Sign)");
    if (hipSlope > 50) issues.add("Uneven Hips (Leg Length Discrepancy Risk)");
    
    // Side View Analysis (if ear visible)
    if (_isPartVisible(leftEar)) {
        double neckAngle = _getAngle(leftEar!, leftShoulder, leftHip);
        // Straight line is 180. Forward head makes angle smaller < 160?
        if (neckAngle < 150) issues.add("Forward Head Posture (Neck Strain)");
    }
    
    if (verticalAlignment > 80) issues.add("Poor Torso Alignment / Slouching");

    return {
      'status': issues.isEmpty ? 'Normal' : 'Attention Needed',
      'issues': issues,
      'confidence': 0.85 
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
