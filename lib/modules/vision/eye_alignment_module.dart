// Module 3: Eye Alignment / Strabismus Detection (Rule-based, working)
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui' as ui;
import '../models/assessment_models.dart';
import '../services/database_service.dart';
import '../services/frame_processor.dart';
import '../utils/landmark_math.dart';

class EyeAlignmentModule {
  final FrameProcessor frameProcessor;
  final DatabaseService database;

  // Threshold for misalignment (pixels)
  static const double MISALIGNMENT_THRESHOLD = 15;

  EyeAlignmentModule({
    required this.frameProcessor,
    required this.database,
  });

  /// Extract eye and nose positions from face landmarks
  EyeLandmarks? extractEyeLandmarks(Face face) {
    final contours = face.contours;
    
    // Eye landmarks in ML Kit Face Detector
    // Left eye: contour 1, Right eye: contour 2
    if (contours.isEmpty) return null;

    ui.Offset? leftEyePosition;
    ui.Offset? rightEyePosition;
    ui.Offset? nosePosition;

    // Get landmark positions
    // Note: ML Kit Face Detection provides:
    // - face.boundingBox for overall face
    // - face.landmarks for key points
    
    // Use face.landmarks to get eye/nose positions
    for (var landmark in face.landmarks) {
      switch (landmark.type) {
        case FaceLandmarkType.leftEye:
          leftEyePosition = ui.Offset(landmark.position.x, landmark.position.y);
          break;
        case FaceLandmarkType.rightEye:
          rightEyePosition = ui.Offset(landmark.position.x, landmark.position.y);
          break;
        case FaceLandmarkType.noseBase:
          nosePosition = ui.Offset(landmark.position.x, landmark.position.y);
          break;
        default:
          break;
      }
    }

    if (leftEyePosition == null || rightEyePosition == null || nosePosition == null) {
      return null;
    }

    return EyeLandmarks(
      leftEye: leftEyePosition,
      rightEye: rightEyePosition,
      nose: nosePosition,
    );
  }

  /// Calculate offset of each eye from nose
  void calculateOffsets(EyeLandmarks landmarks, AlignmentAnalysis analysis) {
    analysis.leftEyeOffset = LandmarkMath.distance(landmarks.leftEye, landmarks.nose);
    analysis.rightEyeOffset = LandmarkMath.distance(landmarks.rightEye, landmarks.nose);
    analysis.asymmetryDifference = (analysis.leftEyeOffset - analysis.rightEyeOffset).abs();
  }

  /// Classify alignment
  String classifyAlignment(AlignmentAnalysis analysis) {
    if (analysis.asymmetryDifference > MISALIGNMENT_THRESHOLD) {
      return 'misaligned';
    }
    return 'aligned';
  }

  /// Calculate score
  double calculateScore(AlignmentAnalysis analysis) {
    // Perfect alignment at 0 difference
    final maxPenalty = MISALIGNMENT_THRESHOLD * 2;
    final penalty = (analysis.asymmetryDifference).clamp(0, maxPenalty);
    final score = ((maxPenalty - penalty) / maxPenalty) * 100;

    return score.clamp(0, 100).toDouble();
  }

  /// Process eye alignment from camera frame
  Future<EyeAlignmentResult?> processAlignmentFrame(CameraImage cameraImage) async {
    try {
      final inputImage = await frameProcessor.convertToInputImage(cameraImage);
      final faces = await frameProcessor.processFace(inputImage);

      if (faces.isEmpty) {
        return EyeAlignmentResult(
          leftEyeOffset: 0,
          rightEyeOffset: 0,
          asymmetryDifference: 0,
          status: 'no_face',
          score: 0,
          timestamp: DateTime.now(),
        );
      }

      final landmarks = extractEyeLandmarks(faces.first);
      if (landmarks == null) {
        return EyeAlignmentResult(
          leftEyeOffset: 0,
          rightEyeOffset: 0,
          asymmetryDifference: 0,
          status: 'invalid',
          score: 0,
          timestamp: DateTime.now(),
        );
      }

      final analysis = AlignmentAnalysis();
      calculateOffsets(landmarks, analysis);
      final status = classifyAlignment(analysis);
      final score = calculateScore(analysis);

      return EyeAlignmentResult(
        leftEyeOffset: analysis.leftEyeOffset,
        rightEyeOffset: analysis.rightEyeOffset,
        asymmetryDifference: analysis.asymmetryDifference,
        status: status,
        score: score,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Eye alignment error: $e');
      return null;
    }
  }

  /// Complete alignment assessment and save
  Future<void> completeAlignmentAssessment(String sessionId, EyeAlignmentResult result) async {
    await database.saveAlignmentResult(sessionId, result);
  }
}

class EyeLandmarks {
  final ui.Offset leftEye;
  final ui.Offset rightEye;
  final ui.Offset nose;

  EyeLandmarks({
    required this.leftEye,
    required this.rightEye,
    required this.nose,
  });
}

class AlignmentAnalysis {
  double leftEyeOffset = 0;
  double rightEyeOffset = 0;
  double asymmetryDifference = 0;
}
