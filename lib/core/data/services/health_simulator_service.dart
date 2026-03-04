import 'dart:async';
import 'dart:math';
import '../models/health_data_model.dart';
import 'package:flutter/foundation.dart';

class HealthSimulatorService extends ChangeNotifier {
  static final HealthSimulatorService _instance = HealthSimulatorService._internal();
  factory HealthSimulatorService() => _instance;
  HealthSimulatorService._internal();

  // Active stream controllers for each child
  final Map<String, StreamController<HealthData>> _controllers = {};
  final Map<String, Timer> _timers = {};
  
  // Current state for each child to allow smooth transitions
  final Map<String, HealthData> _currentData = {};

  // Simulation parameters
  final Random _random = Random();
  
  Stream<HealthData> getHealthStream(String childId) {
    if (!_controllers.containsKey(childId)) {
      _controllers[childId] = StreamController<HealthData>.broadcast();
      _startSimulation(childId);
    }
    return _controllers[childId]!.stream;
  }

  void _startSimulation(String childId) {
    // Initial baseline
    _currentData[childId] = HealthData(
      childId: childId,
      timestamp: DateTime.now(),
      heartRate: 85 + _random.nextInt(10), // Base 85-95
      spo2: 98,
      temperature: 36.6,
      stepCount: 1200,
      stressIndex: 15,
      sleepHours: 8.5,
      deviceStatus: 'Connected',
    );

    // Emit initial
    _controllers[childId]?.add(_currentData[childId]!);

    // Start periodic updates (Every 3 seconds as requested)
    _timers[childId] = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateVitals(childId);
    });
  }

  void _updateVitals(String childId) {
    final current = _currentData[childId]!;
    
    // 1. Heart Rate: Fluctuate slightly naturally
    // Drifts between -3 and +3
    int hrChange = _random.nextInt(7) - 3; 
    int newHr = (current.heartRate + hrChange).clamp(65, 140);
    
    // Simulate "Stress Spike" occasionally (1 in 20 chance)
    if (_random.nextInt(20) == 0) {
      newHr += 15; // Sudden spike
    }

    // 2. SpO2: Mostly stable, rare drops
    int newSpo2 = current.spo2;
    if (_random.nextInt(10) == 0) {
      // 10% chance to change
       newSpo2 = 95 + _random.nextInt(6); // 95-100
    }
    // Occasional drop logic
    if (newSpo2 < 90) newSpo2 = 90; 
    if (newSpo2 > 100) newSpo2 = 100;

    // 3. Temperature: Very slow drift
    double tempChange = (_random.nextDouble() - 0.5) * 0.1; // +/- 0.05
    double newTemp = (current.temperature + tempChange).clamp(36.0, 39.5);

    // 4. Steps: Increment randomly
    int stepsAdded = _random.nextInt(5); // 0-4 steps per 3 sec
    int newSteps = current.stepCount + stepsAdded;

    // 5. Stress: Linked to HR variability for 'smart' look
    int newStress = ((newHr - 70) / 1.5).round().clamp(0, 100);

    final newData = current.copyWith(
      timestamp: DateTime.now(),
      heartRate: newHr,
      spo2: newSpo2,
      temperature: double.parse(newTemp.toStringAsFixed(1)),
      stepCount: newSteps,
      stressIndex: newStress,
    );

    _currentData[childId] = newData;
    _controllers[childId]?.add(newData);
    notifyListeners();
  }

  // Feature: Manually Trigger specific modes for Demo
  void triggerStressMode(String childId) {
    if (!_currentData.containsKey(childId)) return;
    
    final current = _currentData[childId]!;
    _currentData[childId] = current.copyWith(
       heartRate: 135,
       stressIndex: 85,
    );
    // Force immediate update
    _controllers[childId]?.add(_currentData[childId]!);
  }

  void stopSimulation(String childId) {
    _timers[childId]?.cancel();
    _timers.remove(childId);
    _controllers[childId]?.close();
    _controllers.remove(childId);
    _currentData.remove(childId);
  }

  @override
  void dispose() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    for (var controller in _controllers.values) {
      controller.close();
    }
    super.dispose();
  }
}
