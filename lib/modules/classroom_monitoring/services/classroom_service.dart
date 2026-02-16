
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/classroom_environment.dart';

class ClassroomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream live environment data
  Stream<ClassroomEnvironment?> getLiveEnvironment(String schoolId, String classroomId) {
    return _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('environment_logs')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return ClassroomEnvironment.fromMap(snapshot.docs.first.data());
      }
      return null;
    });
  }

  // Push mock data for testing
  Future<void> pushMockData(String schoolId, String classroomId, ClassroomEnvironment data) async {
    await _firestore
        .collection('schools')
        .doc(schoolId)
        .collection('classrooms')
        .doc(classroomId)
        .collection('environment_logs')
        .add(data.toMap());
  }
}
