
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';

class AlertsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream alerts for a specific school
  Stream<List<AlertModel>> getAlerts(String schoolId) {
    return _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('ai_alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AlertModel.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Acknowledge an alert
  Future<void> acknowledgeAlert(String schoolId, String alertId, String teacherName) async {
    await _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('ai_alerts')
        .doc(alertId)
        .update({
      'acknowledged': true,
      'acknowledged_by': teacherName,
      'acknowledged_at': Timestamp.now(),
    });
  }

  // Push a new alert (internal use by AI engine or simulation)
  Future<void> pushAlert(String schoolId, AlertModel alert) async {
    await _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('ai_alerts')
        .add(alert.toMap());
  }
}
