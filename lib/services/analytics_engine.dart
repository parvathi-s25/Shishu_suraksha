import '../models/child_model.dart';
import '../core/constants/app_constants.dart';

class AnalyticsEngine {
  static Map<String, int> getRiskDistribution(List<ChildModel> children) {
    int high = 0;
    int moderate = 0;
    int mild = 0;
    int normal = 0;

    for (var child in children) {
      switch (child.riskLevel) {
        case AppConstants.kRiskHigh:
          high++;
          break;
        case AppConstants.kRiskModerate:
          moderate++;
          break;
        case AppConstants.kRiskMild:
          mild++;
          break;
        default:
          normal++;
      }
    }

    return {
      AppConstants.kRiskHigh: high,
      AppConstants.kRiskModerate: moderate,
      AppConstants.kRiskMild: mild,
      AppConstants.kRiskNormal: normal,
    };
  }

  static double getAverageRiskScore(List<ChildModel> children) {
    if (children.isEmpty) return 0.0;
    // Map risk levels to numeric scores for averaging
    // Normal: 0, Mild: 1, Moderate: 2, High: 3
    double totalScore = 0;
    for (var child in children) {
      switch (child.riskLevel) {
        case AppConstants.kRiskHigh:
          totalScore += 3;
          break;
        case AppConstants.kRiskModerate:
          totalScore += 2;
          break;
        case AppConstants.kRiskMild:
          totalScore += 1;
          break;
        default:
          totalScore += 0;
      }
    }
    return totalScore / children.length;
  }
}
