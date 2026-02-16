
import 'dart:async';
import 'dart:math';
import '../../classroom_monitoring/models/classroom_environment.dart';
import '../../classroom_monitoring/services/classroom_service.dart';

class MockClassroomProvider {
  final ClassroomService _service = ClassroomService();
  final Random _random = Random();
  Timer? _timer;

  void startSimulation(String schoolId, String classroomId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final data = _generateMockEnvironment();
      _service.pushMockData(schoolId, classroomId, data);
    });
  }

  ClassroomEnvironment _generateMockEnvironment() {
    // Simulate realistic classroom environment
    final hour = DateTime.now().hour;
    
    // AQI varies by time (worse in afternoon)
    int baseAqi = hour > 12 && hour < 16 ? 80 : 50;
    int aqi = baseAqi + _random.nextInt(40);
    
    // Noise level (higher during class hours)
    double baseNoise = hour >= 9 && hour <= 15 ? 60 : 40;
    double noise = baseNoise + (_random.nextDouble() * 20);
    
    // Temperature (warmer in afternoon)
    double baseTemp = hour > 12 && hour < 16 ? 28 : 24;
    double temp = baseTemp + (_random.nextDouble() * 4);
    
    // Light intensity (higher during day)
    double light = hour >= 9 && hour <= 17 
        ? 400 + (_random.nextDouble() * 300)
        : 100 + (_random.nextDouble() * 200);

    return ClassroomEnvironment(
      aqi: aqi,
      noiseLevel: noise,
      temperature: temp,
      lightIntensity: light,
      timestamp: DateTime.now(),
    );
  }

  void stopSimulation() {
    _timer?.cancel();
  }
}
