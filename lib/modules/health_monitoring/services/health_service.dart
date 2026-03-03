
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_data.dart';

class HealthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream live vitals for a specific child
  Stream<DeviceData?> getLiveVitals(String schoolId, String childId) {
    return _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('children')
        .doc(childId)
        .collection('vitals')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return DeviceData.fromMap(snapshot.docs.first.data());
      }
      return null;
    });
  }
  // Stream vital history for charts
  Stream<List<DeviceData>> getVitalHistory(String schoolId, String childId) {
    return _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('children')
        .doc(childId)
        .collection('vitals')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => DeviceData.fromMap(doc.data())).toList();
    });
  }

  // Push mock data for testing
  Future<void> pushMockData(String schoolId, String childId, DeviceData data) async {
    await _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('children')
        .doc(childId)
        .collection('vitals')
        .add(data.toMap());
  }
}

