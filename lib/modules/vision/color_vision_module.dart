// Module 5: Color Vision (Simple accuracy-based, working)
import 'package:shishu_suraksha/core/models/assessment_models.dart';
import 'package:shishu_suraksha/core/services/database_service.dart';

class ColorVisionModule {
  final DatabaseService database;

  // Accuracy threshold for normal vision
  static const double NORMAL_ACCURACY_THRESHOLD = 80; // percentage

  ColorVisionModule({
    required this.database,
  });

  /// Calculate accuracy
  double calculateAccuracy(int totalTests, int correctAnswers) {
    if (totalTests == 0) return 0;
    return (correctAnswers / totalTests) * 100;
  }

  /// Classify color vision
  String classifyColorVision(double accuracy) {
    if (accuracy >= NORMAL_ACCURACY_THRESHOLD) {
      return 'normal';
    } else {
      return 'abnormal';
    }
  }

  /// Convert accuracy to score (0-100)
  double convertToScore(double accuracy) {
    // If accuracy is 80%+, score is good
    // Below 80%, score decreases
    if (accuracy >= NORMAL_ACCURACY_THRESHOLD) {
      return accuracy;
    } else {
      return accuracy * 0.8; // Lower score for below-threshold accuracy
    }
  }

  /// Complete color vision assessment and save
  Future<void> completeColorVisionAssessment(
    String sessionId,
    int totalTests,
    int correctAnswers,
  ) async {
    final accuracy = calculateAccuracy(totalTests, correctAnswers);
    final status = classifyColorVision(accuracy);
    final score = convertToScore(accuracy);

    final result = ColorVisionResult(
      totalTestsGiven: totalTests,
      correctAnswers: correctAnswers,
      accuracy: accuracy,
      status: status,
      score: score,
      timestamp: DateTime.now(),
    );

    await database.saveColorVisionResult(sessionId, result);
  }
}


