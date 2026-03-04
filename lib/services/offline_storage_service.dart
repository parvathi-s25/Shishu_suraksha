import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_model.dart';
import '../core/constants/app_constants.dart';

class OfflineStorageService {
  final Box _childrenBox = Hive.box(AppConstants.kBoxChildren);
  final Box _assessmentsBox = Hive.box(AppConstants.kBoxAssessments);
  final Box _pendingSyncBox = Hive.box(AppConstants.kBoxPendingSync);

  // --- Children ---
  Future<void> saveChild(ChildModel child) async {
    await _childrenBox.put(child.id, child);
  }

  List<ChildModel> getAllChildren() {
    return _childrenBox.values.cast<ChildModel>().toList();
  }

  ChildModel? getChild(String id) {
    return _childrenBox.get(id);
  }

  // --- Assessments ---
  Future<void> saveAssessment(String id, Map<String, dynamic> data) async {
    await _assessmentsBox.put(id, data);
    // Mark as pending sync if offline (logic to be handled in repository)
    await _pendingSyncBox.put(id, {'type': 'assessment', 'id': id, 'timestamp': DateTime.now().toIso8601String()});
  }

  List<dynamic> getAllAssessments() {
    return _assessmentsBox.values.toList();
  }

  // --- Sync ---
  List<dynamic> getPendingSyncItems() {
    return _pendingSyncBox.values.toList();
  }

  Future<void> clearPendingSync() async {
    await _pendingSyncBox.clear();
  }
}
