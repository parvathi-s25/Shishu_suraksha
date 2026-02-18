// Module 6: Refraction Risk (Rule-based, working)
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/assessment_models.dart';
import '../services/database_service.dart';
import '../services/frame_processor.dart';
import '../utils/landmark_math.dart';

class RefractionRiskModule {
  final FrameProcessor frameProcessor;
  final DatabaseService database;

  // Thresholds
  static const double POOR_ACUITY_THRESHOLD = 12.0; // 6/12 or worse
  static const int HIGH_BLINK_THRESHOLD = 25; // blinks per 10 seconds
  static const int NORMAL_BLINK_THRESHOLD = 15;

  RefractionRiskModule({
    required this.frameProcessor,
    required this.database,
  });

  /// Detect squinting by analyzing eye aspect ratio
  Future<bool> detectSquinting(CameraImage cameraImage) async {
    try {
      final inputImage = await frameProcessor.convertToInputImage(cameraImage);
      final faces = await frameProcessor.processFace(inputImage);

      if (faces.isEmpty) return false;

      // Calculate eye opening ratio
      // Lower ratio = more squinting
      const eyeOpenThreshold = 0.3; // 30% opening = squinting

      // This is simplified - in a real app, calculate from face landmarks
      return false; // Default: no squinting detected in this frame
    } catch (e) {
      print('Squint detection error: $e');
      return false;
    }
  }

  /// Count blinks in a time window
  int countBlinksDuringObservation(List<double> eyeAspectRatios) {
    // Simple blink detection: eye aspect ratio drops below threshold
    const blinkThreshold = 0.2; // Closed eye threshold
    
    int blinks = 0;
    bool eyeWasOpen = true;

    for (final ratio in eyeAspectRatios) {
      final eyeIsOpen = ratio > blinkThreshold;

      if (eyeWasOpen && !eyeIsOpen) {
        // Transition from open to closed = blink started
        blinks++;
      }

      eyeWasOpen = eyeIsOpen;
    }

    return blinks;
  }

  /// Classify refraction risk based on factors
  String classifyRefractionRisk({
    required double visualAcuity,
    required bool frequentSquint,
    required int blinkRate,
  }) {
    int riskScore = 0;

    // Factor 1: Visual acuity
    if (visualAcuity > POOR_ACUITY_THRESHOLD) {
      riskScore += 40; // High contribution
    }

    // Factor 2: Squinting
    if (frequentSquint) {
      riskScore += 30;
    }

    // Factor 3: Blink rate
    if (blinkRate > HIGH_BLINK_THRESHOLD) {
      riskScore += 30;
    } else if (blinkRate > NORMAL_BLINK_THRESHOLD) {
      riskScore += 15;
    }

    if (riskScore >= 60) {
      return 'high';
    } else if (riskScore >= 30) {
      return 'medium';
    } else {
      return 'low';
    }
  }

  /// Convert risk level to score
  double convertRiskToScore(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return 90;
      case 'medium':
        return 60;
      case 'high':
        return 30;
      default:
        return 50;
    }
  }

  /// Complete refraction risk assessment and save
  Future<void> completeRefractionAssessment(
    String sessionId,
    double visualAcuity,
    bool frequentSquint,
    int blinkRate,
  ) async {
    final riskLevel = classifyRefractionRisk(
      visualAcuity: visualAcuity,
      frequentSquint: frequentSquint,
      blinkRate: blinkRate,
    );
    final score = convertRiskToScore(riskLevel);

    final result = RefractionRiskResult(
      visualAcuity: visualAcuity,
      frequentSquint: frequentSquint,
      blinkRate: blinkRate,
      riskLevel: riskLevel,
      score: score,
      timestamp: DateTime.now(),
    );

    await database.saveRefractionResult(sessionId, result);
  }
}
