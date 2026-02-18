import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'dart:math';

import '../models/vision_result_model.dart';

class StrabismusService {
  final FaceMeshDetector _meshDetector = FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);

  // Key Landmark Indices for Face Mesh (468 points)
  // Left Eye: 33 (inner), 133 (outer), 468 (iris center)
  // Right Eye: 362 (inner), 263 (outer), 473 (iris center)
  // Note: Indices may vary slightly based on specific Face Mesh topology but these are standard for MediaPipe.
  
  static const int LEFT_IRIS_CENTER = 468;
  static const int RIGHT_IRIS_CENTER = 473;
  static const int LEFT_EYE_INNER = 133; // Inner/temporal ordering may vary
  static const int LEFT_EYE_OUTER = 33;  // Outer
  static const int RIGHT_EYE_INNER = 362; // Inner
  static const int RIGHT_EYE_OUTER = 263; // Outer

  Future<StrabismusResult?> analyzeImage(InputImage inputImage) async {
    try {
      final meshes = await _meshDetector.processImage(inputImage);
      if (meshes.isEmpty) return null;

      final mesh = meshes.first;
      
      // We need to compute the position of the iris relative to the eye corners.
      // Hirschberg test simulation.
      
      // Helper to get point geometry safely
      FaceMeshPoint? getPoint(int index) {
        if (mesh.points.isEmpty) return null;
        if (index >= 0 && index < mesh.points.length) return mesh.points[index];
        // Fallback: if IDs are not exact, try to find nearest index by id property if available
        return null;
      }

      final lIris = getPoint(LEFT_IRIS_CENTER);
      final rIris = getPoint(RIGHT_IRIS_CENTER);
      final lInner = getPoint(LEFT_EYE_INNER);
      final lOuter = getPoint(LEFT_EYE_OUTER);
      final rInner = getPoint(RIGHT_EYE_INNER);
      final rOuter = getPoint(RIGHT_EYE_OUTER);

      if (lIris == null || rIris == null || lInner == null || lOuter == null || rInner == null || rOuter == null) return null;
      
      // Calculate Horizontal Ratio (0.0 to 1.0)
      // 0.5 means centered.
      // Ratio = (Iris.x - Outer.x) / (Inner.x - Outer.x)
      
      double getRatio(FaceMeshPoint iris, FaceMeshPoint p1, FaceMeshPoint p2) {
        // Determine left/right bounds of the eye horizontally
        final leftX = min(p1.x, p2.x);
        final rightX = max(p1.x, p2.x);
        final eyeWidth = rightX - leftX;
        if (eyeWidth.abs() < 1e-6) return 0.5;
        final irisPos = (iris.x - leftX);
        return (irisPos / eyeWidth).clamp(0.0, 1.0);
      }

      // leftRatio / rightRatio: 0.5 means centered.
      double leftRatio = getRatio(lIris, lOuter, lInner);
      double rightRatio = getRatio(rIris, rOuter, rInner);
      
      // Calculate deviation in degrees (Mock approximation)
      // Assuming 0.5 is center (0 degrees)
      // Range 0.0-1.0 maps to approx -30 to +30 degrees?
      // Let's just store the deviation from 0.5
      
      // Express deviation as percent of eye width
      double leftDev = (leftRatio - 0.5).abs() * 100; // percent from center
      double rightDev = (rightRatio - 0.5).abs() * 100;
      
      // --- Head Pose Estimation (Heuristics) ---
      
      // 1. Roll (Tilt): Angle of line connecting irises
      double dy = rIris.y - lIris.y;
      double dx = rIris.x - lIris.x;
      double rollAngle = atan2(dy, dx) * 180 / pi;
      // Normal is 0 (horizontal). 
      bool isTilted = rollAngle.abs() > 5.0; 

      // 2. Yaw (Turn): Ratio of Eye Widths
      double lWidth = (lInner.x - lOuter.x).abs();
      double rWidth = (rInner.x - rOuter.x).abs();
      double yawRatio = (lWidth > 0) ? rWidth / lWidth : 1.0;
      
      // If facing straight, widths should be similar (Ratio ~ 1.0)
      // If turned, one eye shortens.
      bool isTurned = yawRatio < 0.8 || yawRatio > 1.2;

      // Check for Strabismus
      bool isAbnormal = false;
        if (!isTilted && !isTurned) {
          // If difference between eyes > 10% of eye width, flag as abnormal OR if either eye offset > 20%
          if ((leftDev - rightDev).abs() > 10.0 || leftDev > 20.0 || rightDev > 20.0) {
           isAbnormal = true;
          }
        }
      
      return StrabismusResult(
        leftEyeDeviation: leftDev,
        rightEyeDeviation: rightDev,
        isAbnormal: isAbnormal,
        headTilt: rollAngle,
        headTurnRatio: yawRatio,
        isHeadPositionCorrect: !isTilted && !isTurned,
      );
      
    } catch (e) {
      return null;
    }
  }

  void close() {
    _meshDetector.close();
  }
}
