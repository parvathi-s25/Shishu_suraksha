import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vision_result_model.dart';
import 'vision_scoring_service.dart';

class VisionRepository {
  final CollectionReference _collection = 
      FirebaseFirestore.instance.collection('vision_screenings');

  Future<void> saveScreeningResult(VisionResultModel result) async {
    try {
      // Ensure risk score is calculated if not already
      double finalScore = result.riskScore;
      if (finalScore == 0.0) {
         finalScore = VisionScoreService.calculateOverallRisk(
            acuity: result.acuityResult,
            strabismus: result.strabismusResult,
            color: result.colorResult,
         );
      }
      
      final String label = VisionScoreService.getRiskLabel(finalScore);
      
      // Create new document reference if ID not provided
      DocumentReference docRef;
      if (result.id.isEmpty) {
        docRef = _collection.doc();
      } else {
        docRef = _collection.doc(result.id);
      }
      
      final finalResult = VisionResultModel(
         id: docRef.id,
         childId: result.childId,
         conductedBy: result.conductedBy,
         timestamp: result.timestamp,
         acuityResult: result.acuityResult,
         strabismusResult: result.strabismusResult,
         colorResult: result.colorResult,
         riskScore: finalScore,
         riskLabel: label,
      );

      await docRef.set(finalResult.toJson());
      
    } catch (e) {
      throw Exception('Failed to save vision result: $e');
    }
  }

  Stream<List<VisionResultModel>> getScreeningsForChild(String childId) {
    return _collection
        .where('childId', isEqualTo: childId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VisionResultModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}

