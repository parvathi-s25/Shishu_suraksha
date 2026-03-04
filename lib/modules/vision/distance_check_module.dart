// Module 2: Distance Check (Rule-based, working)
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shishu_suraksha/core/models/assessment_models.dart';
import 'package:shishu_suraksha/core/services/database_service.dart';
import 'package:shishu_suraksha/core/services/frame_processor.dart';

class DistanceCheckModule {
  final FrameProcessor frameProcessor;
  final DatabaseService database;

  // Thresholds (experimental - adjust based on device testing)
  static const double TOO_CLOSE_THRESHOLD = 450; // pixels
  static const double TOO_FAR_THRESHOLD = 180; // pixels
  static const double IDEAL_MIN = 250;
  static const double IDEAL_MAX = 400;

  DistanceCheckModule({
    required this.frameProcessor,
    required this.database,
  });

  /// Get face bounding box height
  double? getFaceHeight(List<Face> faces) {
    if (faces.isEmpty) return null;
    final boundingBox = faces.first.boundingBox;
    return boundingBox.height;
  }

  /// Classify distance
  String classifyDistance(double faceHeight) {
    if (faceHeight > TOO_CLOSE_THRESHOLD) {
      return 'too_close';
    } else if (faceHeight < TOO_FAR_THRESHOLD) {
      return 'too_far';
    } else {
      return 'correct';
    }
  }

  /// Calculate score based on distance
  double calculateScore(double faceHeight) {
    // Perfect score at ideal middle point
    const idealCenter = (IDEAL_MIN + IDEAL_MAX) / 2;
    const idealRange = (IDEAL_MAX - IDEAL_MIN) / 2;

    final deviation = (faceHeight - idealCenter).abs();
    final score = ((idealRange - deviation) / idealRange) * 100;

    return score.clamp(0, 100).toDouble();
  }

  /// Process distance from camera frame
  Future<DistanceCheckResult?> processDistanceFrame(CameraImage cameraImage) async {
    try {
      final inputImage = await frameProcessor.convertToInputImage(cameraImage);
      final faces = await frameProcessor.processFace(inputImage);

      if (faces.isEmpty) {
        return DistanceCheckResult(
          faceHeightPixels: 0,
          status: 'no_face',
          score: 0,
          timestamp: DateTime.now(),
        );
      }

      final faceHeight = getFaceHeight(faces);
      if (faceHeight == null) {
        return DistanceCheckResult(
          faceHeightPixels: 0,
          status: 'invalid',
          score: 0,
          timestamp: DateTime.now(),
        );
      }

      final status = classifyDistance(faceHeight);
      final score = calculateScore(faceHeight);

      return DistanceCheckResult(
        faceHeightPixels: faceHeight,
        status: status,
        score: score,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Distance check error: $e');
      return null;
    }
  }

  /// Check if distance is correct
  bool isDistanceCorrect(DistanceCheckResult result) {
    return result.status == 'correct';
  }

  /// Complete distance assessment and save
  Future<void> completeDistanceAssessment(String sessionId, DistanceCheckResult result) async {
    await database.saveDistanceResult(sessionId, result);
  }
}


