
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class OfflineDataService extends ChangeNotifier {
  static final OfflineDataService _instance = OfflineDataService._internal();
  
  factory OfflineDataService() {
    return _instance;
  }
  
  OfflineDataService._internal();

  final Box _settingsBox = Hive.box('settings');
  final Box _childrenBox = Hive.box('children');
  final Box _assessmentsBox = Hive.box('assessments');
  // Box for actions performed while offline to sync later
  final Box _syncQueueBox = Hive.box('pending_sync'); 

  // --- Settings / App State ---
  
  Future<void> saveLanguage(String langCode) async {
    await _settingsBox.put('language', langCode);
  }

  String? getLanguage() {
    return _settingsBox.get('language');
  }

  // --- Children Data ---

  Future<void> saveChildren(List<Map<String, dynamic>> children) async {
    // Clear existing cache and save new list? 
    // Or update/insert? For now, let's just cache the list.
    // Storing individually by ID allows easier updates.
    for (var child in children) {
      if (child.containsKey('id')) {
        await _childrenBox.put(child['id'], child);
      }
    }
  }

  Future<void> saveChild(Map<String, dynamic> child) async {
     if (child.containsKey('id')) {
        await _childrenBox.put(child['id'], child);
      }
  }

  List<Map<String, dynamic>> getAllChildren() {
    return _childrenBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // --- Sync Queue (for offline actions) ---

  Future<void> queueAction(String actionType, Map<String, dynamic> payload) async {
    final action = {
      'type': actionType, // e.g., 'ADD_CHILD', 'SUBMIT_ASSESSMENT'
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _syncQueueBox.add(action);
  }

  List<Map<String, dynamic>> getPendingActions() {
    return _syncQueueBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> clearPendingActions() async {
    await _syncQueueBox.clear();
  }
  
  bool get isOfflineMode => _settingsBox.get('offline_mode', defaultValue: false);
  
  Future<void> setOfflineMode(bool value) async {
    await _settingsBox.put('offline_mode', value);
    notifyListeners();
  }
}
