import 'package:flutter/foundation.dart';

class ModuleStatusService {
  ModuleStatusService._private();
  static final ModuleStatusService instance = ModuleStatusService._private();

  final Map<String, bool> _status = {
    'pose': false,
    'vision': false,
    'vision_alignment': false,
    'vision_reflex': false,
    'vision_color': false,
    'vision_refraction': false,
    'hearing': false,
    'speech': false,
    'injury': false,
    'signs': false,
    'thermal': false,
  };

  final ValueNotifier<Map<String, bool>> _notifier = ValueNotifier({});

  ModuleStatusService._init() : _notifier = ValueNotifier({});

  ValueListenable<Map<String, bool>> get snapshotListenable => _notifier;

  bool isCompleted(String key) => _status[key] ?? false;

  void markCompleted(String key, [bool value = true]) {
    _status[key] = value;
    _notifier.value = Map.from(_status);
  }
}
