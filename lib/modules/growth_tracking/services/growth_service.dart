
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/growth_record.dart';

class GrowthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream growth history
  Stream<List<GrowthRecord>> getGrowthHistory(String schoolId, String childId) {
    return _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('children')
        .doc(childId)
        .collection('growth_records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GrowthRecord.fromMap(doc.data())).toList();
    });
  }

  // Add new record
  Future<void> addGrowthRecord(String schoolId, String childId, GrowthRecord record) async {
    await _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('children')
        .doc(childId)
        .collection('growth_records')
        .add(record.toMap());
  }

  // AI Nutrition Suggestion based on latest BMI
  String getNutritionAdvice(double bmi) {
    if (bmi < 18.5) {
      return "High-protein diet recommended. Include eggs, dal, milk, and nuts in daily meals.";
    } else if (bmi < 25) {
      return "Healthy growth! Maintain balanced diet with fresh fruits and vegetables.";
    } else {
      return "Monitor sugar intake. Encourage physical activity and reduce processed foods.";
    }
  }
}

