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
  final _highRiskCountController = StreamController<int>.broadcast(); // Red Flag
  final _overdueCountController = StreamController<int>.broadcast();  // Last Visit

  Stream<int> get childCountStream => _childCountController.stream;
  Stream<int> get assessmentCountStream => _assessmentCountController.stream;
  Stream<int> get taskCountStream => _taskCountController.stream;
  Stream<int> get alertCountStream => _alertCountController.stream;
  Stream<int> get highRiskCountStream => _highRiskCountController.stream;
  Stream<int> get overdueCountStream => _overdueCountController.stream;

  // Mock initial data
  int _childCount = 42;
  int _assessmentCount = 5;
  int _taskCount = 12;
  int _alertCount = 3;
  int _highRiskCount = 3; // "3 Children Need Attention"
  int _overdueCount = 5;  // "5 children not checked in last 30 days"

  void init() {
    _emitAll();
  }

  void _emitAll() {
    _childCountController.add(_childCount);
    _assessmentCountController.add(_assessmentCount);
    _taskCountController.add(_taskCount);
    _alertCountController.add(_alertCount);
    _highRiskCountController.add(_highRiskCount);
    _overdueCountController.add(_overdueCount);
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

  void addHighRiskChild() {
    _highRiskCount++;
    _highRiskCountController.add(_highRiskCount);
    notifyListeners();
  }

  void resolveOverdue() {
    if (_overdueCount > 0) {
      _overdueCount--;
      _overdueCountController.add(_overdueCount);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _childCountController.close();
    _assessmentCountController.close();
    _taskCountController.close();
    _alertCountController.close();
    _highRiskCountController.close();
    _overdueCountController.close();
    super.dispose();
  }
}
