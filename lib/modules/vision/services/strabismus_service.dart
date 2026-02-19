import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'dart:math';

import '../models/vision_result_model.dart';

/// Bundles a [StrabismusResult] with the raw iris-position ratios so the
/// real-time painter can visualise iris placement directly.
class StrabismusAnalysis {
  final StrabismusResult result;

  /// 0.0 = iris at far left of eye, 0.5 = centered, 1.0 = far right
  final double leftRatio;
  final double rightRatio;

  StrabismusAnalysis({
    required this.result,
    required this.leftRatio,
    required this.rightRatio,
  });
}

class StrabismusService {
  final FaceMeshDetector _meshDetector = FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);

  // Key Landmark Indices for Face Mesh (468 points)
  // Left Eye: 33 (inner), 133 (outer), 468 (iris center)
  // Right Eye: 362 (inner), 263 (outer), 473 (iris center)
  // Note: Indices may vary slightly based on specific Face Mesh topology but these are standard for MediaPipe.
  
  static const int LEFT_IRIS_CENTER = 468;
  static const int RIGHT_IRIS_CENTER = 473;
  static const int LEFT_EYE_INNER = 133;
  static const int LEFT_EYE_OUTER = 33;
  static const int RIGHT_EYE_INNER = 362;
  static const int RIGHT_EYE_OUTER = 263;

  /// Original method – kept for backward compatibility.
  Future<StrabismusResult?> analyzeImage(InputImage inputImage) async {
    final analysis = await analyzeImageWithRatios(inputImage);
    return analysis?.result;
  }

  /// Enhanced method that also returns raw iris ratios for real-time painting.
  Future<StrabismusAnalysis?> analyzeImageWithRatios(InputImage inputImage) async {
    try {
      final meshes = await _meshDetector.processImage(inputImage);
      if (meshes.isEmpty) return null;

      final mesh = meshes.first;
      
      // Helper to get point geometry safely
      FaceMeshPoint? getPoint(int index) {
        if (mesh.points.isEmpty) return null;
        if (index >= 0 && index < mesh.points.length) return mesh.points[index];
        return null;
      }

      if (mesh.points.length < 473) {
        debugPrint('StrabismusService: Detected mesh has only ${mesh.points.length} points. Iris detection requires 473+.');
      }

      final lIris = getPoint(LEFT_IRIS_CENTER);
      final lInner = getPoint(LEFT_EYE_INNER);
      final lOuter = getPoint(LEFT_EYE_OUTER);
      final rIris = getPoint(RIGHT_IRIS_CENTER);
      final rInner = getPoint(RIGHT_EYE_INNER);
      final rOuter = getPoint(RIGHT_EYE_OUTER);

      if (lIris == null || rIris == null || lInner == null || lOuter == null || rInner == null || rOuter == null) {
        debugPrint('StrabismusService: Missing critical eye landmarks.');
        return null;
      }
      
      // Horizontal Ratio (0.0 to 1.0, 0.5 = centered)
      double getRatio(FaceMeshPoint iris, FaceMeshPoint p1, FaceMeshPoint p2) {
        final leftX = min(p1.x, p2.x);
        final rightX = max(p1.x, p2.x);
        final eyeWidth = rightX - leftX;
        if (eyeWidth.abs() < 1e-6) return 0.5;
        final irisPos = (iris.x - leftX);
        return (irisPos / eyeWidth).clamp(0.0, 1.0);
      }

      double leftRatio = getRatio(lIris, lOuter, lInner);
      double rightRatio = getRatio(rIris, rOuter, rInner);
      
      // Deviation as percent of eye width from center
      double leftDev = (leftRatio - 0.5).abs() * 100;
      double rightDev = (rightRatio - 0.5).abs() * 100;
      
      // --- Head Pose Estimation (Heuristics) ---
      double dy = rIris.y - lIris.y;
      double dx = rIris.x - lIris.x;
      double rollAngle = atan2(dy, dx) * 180 / pi;
      bool isTilted = rollAngle.abs() > 5.0; 

      double lWidth = (lInner.x - lOuter.x).abs();
      double rWidth = (rInner.x - rOuter.x).abs();
      double yawRatio = (lWidth > 0) ? rWidth / lWidth : 1.0;
      bool isTurned = yawRatio < 0.8 || yawRatio > 1.2;

      // Check for Strabismus
      bool isAbnormal = false;
      if (!isTilted && !isTurned) {
        if ((leftDev - rightDev).abs() > 10.0 || leftDev > 20.0 || rightDev > 20.0) {
          isAbnormal = true;
        }
      }
      
      return StrabismusAnalysis(
        result: StrabismusResult(
          leftEyeDeviation: leftDev,
          rightEyeDeviation: rightDev,
          isAbnormal: isAbnormal,
          headTilt: rollAngle,
          headTurnRatio: yawRatio,
          isHeadPositionCorrect: !isTilted && !isTurned,
        ),
        leftRatio: leftRatio,
        rightRatio: rightRatio,
      );
      
    } catch (e) {
      return null;
    }
  }

  void close() {
    _meshDetector.close();
  }
}
