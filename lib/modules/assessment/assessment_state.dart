import 'package:flutter/foundation.dart';

class AssessmentState extends ChangeNotifier {
  final Map<String, bool> _completed = {
    'pose': false,
    'vision': false,
    'hearing': false,
    'speech': false,
    'injury': false,
    'signs': false,
    'thermal': false,
  };

  bool isCompleted(String module) => _completed[module] ?? false;

  void markCompleted(String module, [bool value = true]) {
    if ((_completed[module] ?? false) == value) return;
    _completed[module] = value;
    notifyListeners();
  }

  bool get allCompleted => _completed.values.every((v) => v == true);

  Map<String, bool> get snapshot => Map.from(_completed);
}
