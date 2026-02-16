
import 'package:cloud_firestore/cloud_firestore.dart';

class GrowthRecord {
  final double height; // cm
  final double weight; // kg
  final String notes;
  final DateTime date;

  GrowthRecord({
    required this.height,
    required this.weight,
    required this.notes,
    required this.date,
  });

  factory GrowthRecord.fromMap(Map<String, dynamic> data) {
    return GrowthRecord(
      height: (data['height'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      notes: data['notes'] ?? "",
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'weight': weight,
      'notes': notes,
      'date': Timestamp.fromDate(date),
    };
  }

  // Calculate BMI
  double get bmi {
    if (height <= 0) return 0;
    double hM = height / 100;
    return weight / (hM * hM);
  }

  String get bmiStatus {
    double b = bmi;
    if (b < 18.5) return "Underweight";
    if (b < 25) return "Healthy";
    if (b < 30) return "Overweight";
    return "Obese";
  }
  
  // Malnutrition Risk Score (0-100)
  // Simplified version - in production, use WHO child growth standards tables
  int getMalnutritionRisk(int ageMonths) {
    int risk = 0;
    
    // Weight-for-age assessment (simplified)
    double expectedWeight = 3.5 + (ageMonths * 0.5); // Very rough estimate
    double weightRatio = weight / expectedWeight;
    
    if (weightRatio < 0.7) risk += 50; // Severe malnutrition
    else if (weightRatio < 0.85) risk += 30; // Moderate malnutrition
    else if (weightRatio < 0.95) risk += 15; // Mild malnutrition
    
    // BMI assessment
    if (bmi < 14) risk += 40;
    else if (bmi < 16) risk += 20;
    
    return risk.clamp(0, 100);
  }
  
  String getMalnutritionStatus(int ageMonths) {
    int risk = getMalnutritionRisk(ageMonths);
    if (risk >= 60) return "Severe";
    if (risk >= 30) return "Moderate";
    if (risk >= 15) return "Mild";
    return "Normal";
  }
  
  // Nutrition Recommendations
  String getNutritionAdvice(int ageMonths) {
    int risk = getMalnutritionRisk(ageMonths);
    
    if (risk >= 60) {
      return "⚠️ URGENT: Severe malnutrition detected. Immediate medical intervention required. "
          "Provide high-protein diet with eggs, dal, milk, and fortified foods. "
          "Refer to nearest PHC for assessment.";
    } else if (risk >= 30) {
      return "⚠️ Moderate malnutrition. Increase protein intake with eggs, dal, milk, nuts, and seasonal fruits. "
          "Monitor weight weekly. Consider vitamin supplements after medical consultation.";
    } else if (risk >= 15) {
      return "Mild malnutrition risk. Ensure balanced diet with adequate protein (dal, eggs), "
          "fresh vegetables, and fruits. Monitor growth monthly.";
    } else if (bmi > 25) {
      return "Weight management needed. Reduce sugar and processed foods. "
          "Encourage physical activity and outdoor play. Focus on vegetables and whole grains.";
    } else {
      return "✅ Healthy growth! Maintain balanced diet with fresh fruits, vegetables, "
          "protein (dal, eggs, milk), and whole grains. Encourage regular physical activity.";
    }
  }
}
