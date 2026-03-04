import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/child_model.dart';
import '../core/constants/app_constants.dart';
import 'risk_engine.dart';

class SimulatorService {
  static final SimulatorService _instance = SimulatorService._internal();

  factory SimulatorService() {
    return _instance;
  }

  SimulatorService._internal();

  Timer? _timer;
  final ValueNotifier<Map<String, Map<String, dynamic>>> activeVitals = ValueNotifier({});
  bool _isSimulating = false;

  void startSimulation(List<ChildModel> children) {
    if (_isSimulating) return;
    _isSimulating = true;

    _timer = Timer.periodic(const Duration(milliseconds: AppConstants.kSimulationIntervalMs), (timer) {
      _updateVitals(children);
    });
  }

  void stopSimulation() {
    _timer?.cancel();
    _isSimulating = false;
  }

  void _updateVitals(List<ChildModel> children) {
    // Select a few children to update to avoid overwhelming UI
    final random = Random();
    final Map<String, Map<String, dynamic>> newVitals = Map.from(activeVitals.value);

    for (var child in children) {
      // Simulate Heart Rate: 70-130 normal range
      int heartRate = 70 + random.nextInt(60); 

      // Simulate SpO2: 90-100
      double spo2 = 90 + random.nextDouble() * 10;

      // Simulate Temp: 36.5 - 38.0
      double temperature = 36.5 + random.nextDouble() * 1.5;

      // Introduce occasional anomalies for "High Risk" simulation
      if (child.riskLevel == AppConstants.kRiskHigh && random.nextBool()) {
        heartRate += 30; // Tachycardia
        spo2 -= 5; // Hypoxia
        temperature += 1.0; // Fever
      }

      String currentRisk = RiskEngine.calculateRisk(child, 
        heartRate: heartRate, 
        spo2: spo2, 
        temperature: temperature
      );

      newVitals[child.id] = {
        'heartRate': heartRate,
        'spo2': double.parse(spo2.toStringAsFixed(1)),
        'temperature': double.parse(temperature.toStringAsFixed(1)),
        'risk': currentRisk,
        'lastUpdated': DateTime.now(),
      };
    }

    activeVitals.value = newVitals;
  }
}
