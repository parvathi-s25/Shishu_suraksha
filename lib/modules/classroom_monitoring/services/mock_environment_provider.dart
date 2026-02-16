
import 'dart:async';
import 'dart:math';
import '../models/classroom_environment.dart';
import 'classroom_service.dart';

class MockEnvironmentProvider {
  final ClassroomService _service = ClassroomService();
  final Random _random = Random();
  Timer? _timer;

  void startSimulation(String schoolId, String classroomId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final data = ClassroomEnvironment(
        aqi: 40 + _random.nextInt(30), // 40-70 AQI (Good)
        noiseLevel: 50 + _random.nextInt(25).toDouble(), // 50-75 dB
        temperature: 24 + _random.nextDouble() * 2, // 24-26 C
        lightIntensity: 300 + _random.nextInt(100).toDouble(), // 300-400 Lux
        timestamp: DateTime.now(),
      );
      _service.pushMockData(schoolId, classroomId, data);
    });
  }

  void stopSimulation() {
    _timer?.cancel();
  }
}
