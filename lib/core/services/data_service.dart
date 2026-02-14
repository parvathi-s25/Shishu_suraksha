import 'dart:async';
import 'package:flutter/foundation.dart';

class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Streams for counts
  final _childCountController = StreamController<int>.broadcast();
  final _assessmentCountController = StreamController<int>.broadcast();
  final _taskCountController = StreamController<int>.broadcast();
  final _alertCountController = StreamController<int>.broadcast();

  Stream<int> get childCountStream => _childCountController.stream;
  Stream<int> get assessmentCountStream => _assessmentCountController.stream;
  Stream<int> get taskCountStream => _taskCountController.stream;
  Stream<int> get alertCountStream => _alertCountController.stream;

  // Mock initial data
  int _childCount = 42;
  int _assessmentCount = 5;
  int _taskCount = 12;
  int _alertCount = 3;

  void init() {
    _emitAll();
  }

  void _emitAll() {
    _childCountController.add(_childCount);
    _assessmentCountController.add(_assessmentCount);
    _taskCountController.add(_taskCount);
    _alertCountController.add(_alertCount);
  }

  void addChild() {
    _childCount++;
    _childCountController.add(_childCount);
    notifyListeners();
  }

  void addAssessment() {
    _assessmentCount++;
    _assessmentCountController.add(_assessmentCount);
    notifyListeners();
  }

  void addTask() {
    _taskCount++;
    _taskCountController.add(_taskCount);
    notifyListeners();
  }

  void addAlert() {
    _alertCount++;
    _alertCountController.add(_alertCount);
    notifyListeners();
  }

  @override
  void dispose() {
    _childCountController.close();
    _assessmentCountController.close();
    _taskCountController.close();
    _alertCountController.close();
    super.dispose();
  }
}
