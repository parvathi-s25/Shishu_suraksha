import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';

class DistanceEstimator {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableClassification: false,
      enableLandmarks: false, // Landmarks not strictly needed for width
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  // Average face width of a child (in cm)
  // This is a rough approximation.
  static const double AVERAGE_FACE_WIDTH_CM = 13.0;
  
  // Focal length approximation (tuned for typical mobile front cameras)
  // This should ideally be calibrated per device or calculated from FOV.
  // F = (P * D) / W
  // P = Width in pixels, D = Distance, W = Real Width
  // Assume at 50cm, face width is ~200-300 pixels on 720p?
  // Let's use a calibrated constant for MVP.
  // Constant K = F * W
  // Distance = K / Pixels
  static const double CALIBRATION_CONSTANT = 12000.0; // Tuned for 720p resolution
  // Reference values: when face occupies ~22% of image height, distance ~150cm
  static const double REFERENCE_FACE_RATIO = 0.22;
  static const double REFERENCE_DISTANCE_CM = 150.0;

  Future<double?> estimateDistance(InputImage inputImage) async {
    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) return null;

      // Use the largest face found
      Face? largestFace;
      double maxArea = 0;
      for (var face in faces) {
        double area = face.boundingBox.width * face.boundingBox.height;
        if (area > maxArea) {
          maxArea = area;
          largestFace = face;
        }
      }

      if (largestFace == null) return null;

      // Use face height ratio relative to image height for a more robust estimate.
      final imageHeight = inputImage.metadata?.size.height ?? 0.0;
      final faceHeightPixels = largestFace.boundingBox.height;
      if (imageHeight <= 0 || faceHeightPixels <= 0) return null;

      final faceRatio = faceHeightPixels / imageHeight;

      // Estimate distance by scaling relative to reference ratio
      double estimatedDistanceCm = REFERENCE_DISTANCE_CM * (REFERENCE_FACE_RATIO / faceRatio);

      // Clamp to reasonable bounds
      if (estimatedDistanceCm.isInfinite || estimatedDistanceCm.isNaN) return null;
      estimatedDistanceCm = estimatedDistanceCm.clamp(20.0, 1000.0);

      return estimatedDistanceCm;
    } catch (e) {
      debugPrint("Error detecting face for distance: $e");
      return null;
    }
  }

  void close() {
    _faceDetector.close();
  }
}
