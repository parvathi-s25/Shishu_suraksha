import 'package:hive_flutter/hive_flutter.dart';
import 'package:shishu_suraksha/data/models/child_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  static const String childBoxName = 'children';

  Future<void> init() async {
    await Hive.initFlutter();
    // Adapters are registered in main.dart or here
    // await Hive.openBox<ChildModel>(childBoxName); 
  }

  Box<ChildModel> get _childBox => Hive.box<ChildModel>(childBoxName);

  List<ChildModel> getAllChildren() {
    return _childBox.values.toList();
  }

  Future<void> addChild(ChildModel child) async {
    await _childBox.put(child.id, child);
  }

  Future<void> updateChild(ChildModel child) async {
    await _childBox.put(child.id, child);
  }

  Future<void> deleteChild(String id) async {
    await _childBox.delete(id);
  }
}
