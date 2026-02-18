// Module 4: Pupil Light Reflex (Image processing, working)
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../models/assessment_models.dart';
import '../services/database_service.dart';
import '../services/frame_processor.dart';

class PupilReflexModule {
  final FrameProcessor frameProcessor;
  final DatabaseService database;

  // Brightness change threshold (adjust based on testing)
  static const double BRIGHTNESS_CHANGE_THRESHOLD = 40;

  PupilReflexModule({
    required this.frameProcessor,
    required this.database,
  });

  /// Capture image before light stimulus
  Future<double> captureBrightnessBeforeFlash(CameraImage image) async {
    try {
      final brightness = await frameProcessor.extractBrightness(image);
      return brightness;
    } catch (e) {
      print('Error capturing brightness before: $e');
      return 0;
    }
  }

  /// Capture image after light stimulus (usually white screen)
  Future<double> captureBrightnessAfterFlash(CameraImage image) async {
    try {
      final brightness = await frameProcessor.extractBrightness(image);
      return brightness;
    } catch (e) {
      print('Error capturing brightness after: $e');
      return 0;
    }
  }

  /// Calculate brightness difference
  double calculateBrightnessDifference(double before, double after) {
    return (after - before).abs();
  }

  /// Classify pupil response
  String classifyReflex(double brightnessDifference) {
    if (brightnessDifference < BRIGHTNESS_CHANGE_THRESHOLD) {
      return 'abnormal'; // Insufficient response
    } else if (brightnessDifference > BRIGHTNESS_CHANGE_THRESHOLD * 2) {
      return 'hyperactive'; // Excessive response
    } else {
      return 'normal';
    }
  }

  /// Calculate score
  double calculateScore(double brightnessDifference) {
    // Optimal difference is around BRIGHTNESS_CHANGE_THRESHOLD
    const optimal = BRIGHTNESS_CHANGE_THRESHOLD * 1.5;
    const range = BRIGHTNESS_CHANGE_THRESHOLD;

    final deviation = (brightnessDifference - optimal).abs();
    final score = ((range - deviation.clamp(0, range)) / range) * 100;

    return score.clamp(0, 100).toDouble();
  }

  /// Complete pupil reflex assessment and save
  Future<void> completePupilAssessment(
    String sessionId,
    double brightnessBeforeDouble,
    double brightnessAfterDouble,
  ) async {
    final brightnessDifference = calculateBrightnessDifference(
      brightnessBeforeDouble,
      brightnessAfterDouble,
    );
    final status = classifyReflex(brightnessDifference);
    final score = calculateScore(brightnessDifference);

    final result = PupilReflexResult(
      brightnessChangeBefore: brightnessBeforeDouble,
      brightnessChangeAfter: brightnessAfterDouble,
      brightnessDifference: brightnessDifference,
      status: status,
      score: score,
      timestamp: DateTime.now(),
    );

    await database.savePupilResult(sessionId, result);
  }
}
