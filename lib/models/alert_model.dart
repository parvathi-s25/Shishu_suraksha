enum RiskLevel {
  high,
  moderate,
  mild,
  normal,
}

class AlertModel {
  final String childName;
  final String childAge;
  final String childId;
  final RiskLevel riskLevel;
  final String category;
  final String description;
  final String recommendedAction;
  final Map<String, dynamic> assessmentData;

  AlertModel({
    required this.childName,
    required this.childAge,
    required this.childId,
    required this.riskLevel,
    required this.category,
    required this.description,
    required this.recommendedAction,
    required this.assessmentData,
  });

  String get riskLevelText {
    switch (riskLevel) {
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.moderate:
        return 'Moderate Risk';
      case RiskLevel.mild:
        return 'Mild Observation';
      case RiskLevel.normal:
        return 'Normal';
    }
  }

  String get riskEmoji {
    switch (riskLevel) {
      case RiskLevel.high:
        return '🔴';
      case RiskLevel.moderate:
        return '🟠';
      case RiskLevel.mild:
        return '🟡';
      case RiskLevel.normal:
        return '🟢';
    }
  }
}
