
import 'dart:async';
import 'dart:math';
import '../models/device_data.dart';
import 'health_service.dart';

enum SimulationScenario {
  normal,      // Normal vitals
  fever,       // High temperature
  lowSpo2,     // Low oxygen
  highHR,      // High heart rate
  critical     // Multiple issues
}

class MockHealthProvider {
  final HealthService _service = HealthService();
  final Random _random = Random();
  Timer? _timer;
  SimulationScenario _scenario = SimulationScenario.normal;

  void startSimulation(String schoolId, String childId, {SimulationScenario? scenario}) {
    _scenario = scenario ?? SimulationScenario.normal;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final data = _generateMockData(schoolId, childId);
      _service.pushMockData(schoolId, childId, data);
    });
  }

  DeviceData _generateMockData(String schoolId, String childId) {
    double heartRate, spo2, temp;
    
    switch (_scenario) {
      case SimulationScenario.normal:
        heartRate = 70 + _random.nextInt(20).toDouble(); // 70-90 BPM
        spo2 = 96 + _random.nextInt(4).toDouble(); // 96-100%
        temp = 36.5 + (_random.nextDouble() * 0.8); // 36.5-37.3°C
        break;
      case SimulationScenario.fever:
        heartRate = 90 + _random.nextInt(30).toDouble(); // 90-120 BPM
        spo2 = 95 + _random.nextInt(5).toDouble(); // 95-100%
        temp = 38.0 + (_random.nextDouble() * 1.5); // 38.0-39.5°C
        break;
      case SimulationScenario.lowSpo2:
        heartRate = 80 + _random.nextInt(40).toDouble(); // 80-120 BPM
        spo2 = 88 + _random.nextInt(5).toDouble(); // 88-93%
        temp = 36.5 + (_random.nextDouble() * 1.0); // 36.5-37.5°C
        break;
      case SimulationScenario.highHR:
        heartRate = 120 + _random.nextInt(20).toDouble(); // 120-140 BPM
        spo2 = 95 + _random.nextInt(5).toDouble(); // 95-100%
        temp = 36.8 + (_random.nextDouble() * 0.7); // 36.8-37.5°C
        break;
      case SimulationScenario.critical:
        heartRate = 130 + _random.nextInt(20).toDouble(); // 130-150 BPM
        spo2 = 85 + _random.nextInt(5).toDouble(); // 85-90%
        temp = 39.0 + (_random.nextDouble() * 1.0); // 39.0-40.0°C
        break;
    }

    return DeviceData(
      deviceId: "DEVICE_${childId}_001",
      schoolId: schoolId,
      childId: childId,
      heartRate: heartRate,
      spo2: spo2,
      temp: temp,
      movement: _random.nextBool() ? "Active" : "Resting",
      batteryLevel: 60 + _random.nextInt(40), // 60-100%
      signalStrength: 70 + _random.nextInt(30), // 70-100%
      timestamp: DateTime.now(),
    );
  }

  void setScenario(SimulationScenario scenario) {
    _scenario = scenario;
  }

  void stopSimulation() {
    _timer?.cancel();
  }
}


