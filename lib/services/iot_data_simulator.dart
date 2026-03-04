
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/health_monitoring/models/device_data.dart';
import '../modules/health_monitoring/services/health_service.dart';
import '../modules/classroom_monitoring/models/classroom_environment.dart';
import '../modules/classroom_monitoring/services/classroom_service.dart';
import '../modules/growth_tracking/models/growth_record.dart';
import '../modules/growth_tracking/services/growth_service.dart';

/// Comprehensive IoT Data Simulator
/// Simulates multiple children with wearable devices and classroom sensors
class IoTDataSimulator {
  final HealthService _healthService = HealthService();
  final ClassroomService _classroomService = ClassroomService();
  final GrowthService _growthService = GrowthService();
  final Random _random = Random();
  
  Timer? _healthTimer;
  Timer? _classroomTimer;
  
  final String schoolId;
  final List<Map<String, dynamic>> children;
  
  IoTDataSimulator({
    required this.schoolId,
    required this.children,
  });

  /// Start simulating all IoT devices
  void startAll() {
    startHealthMonitoring();
    startClassroomMonitoring();
  }

  /// Simulate wearable devices for all children
  void startHealthMonitoring() {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      for (var child in children) {
        final data = _generateHealthData(child);
        _healthService.pushMockData(schoolId, child['id'], data);
      }
    });
  }

  /// Simulate classroom environment sensors
  void startClassroomMonitoring() {
    _classroomTimer?.cancel();
    _classroomTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final data = _generateClassroomData();
      _classroomService.pushMockData(schoolId, "CLASSROOM_01", data);
    });
  }

  /// Generate realistic health data with occasional anomalies
  DeviceData _generateHealthData(Map<String, dynamic> child) {
    // 10% chance of anomaly
    bool hasAnomaly = _random.nextDouble() < 0.1;
    
    double heartRate, spo2, temp;
    
    if (hasAnomaly) {
      // Simulate various health issues
      int anomalyType = _random.nextInt(3);
      switch (anomalyType) {
        case 0: // Fever
          heartRate = 90 + _random.nextInt(30).toDouble();
          spo2 = 95 + _random.nextInt(5).toDouble();
          temp = 38.0 + (_random.nextDouble() * 1.5);
          break;
        case 1: // Low SpO2
          heartRate = 80 + _random.nextInt(40).toDouble();
          spo2 = 88 + _random.nextInt(5).toDouble();
          temp = 36.5 + (_random.nextDouble() * 1.0);
          break;
        case 2: // High heart rate
          heartRate = 120 + _random.nextInt(20).toDouble();
          spo2 = 95 + _random.nextInt(5).toDouble();
          temp = 36.8 + (_random.nextDouble() * 0.7);
          break;
        default:
          heartRate = 70 + _random.nextInt(20).toDouble();
          spo2 = 96 + _random.nextInt(4).toDouble();
          temp = 36.5 + (_random.nextDouble() * 0.8);
      }
    } else {
      // Normal vitals
      heartRate = 70 + _random.nextInt(20).toDouble();
      spo2 = 96 + _random.nextInt(4).toDouble();
      temp = 36.5 + (_random.nextDouble() * 0.8);
    }

    return DeviceData(
      deviceId: "DEVICE_${child['id']}_001",
      schoolId: schoolId,
      childId: child['id'],
      heartRate: heartRate,
      spo2: spo2,
      temp: temp,
      movement: _random.nextBool() ? "Active" : "Resting",
      batteryLevel: 60 + _random.nextInt(40),
      signalStrength: 70 + _random.nextInt(30),
      timestamp: DateTime.now(),
    );
  }

  /// Generate realistic classroom environment data
  ClassroomEnvironment _generateClassroomData() {
    final hour = DateTime.now().hour;
    
    // AQI varies by time
    int baseAqi = hour > 12 && hour < 16 ? 80 : 50;
    int aqi = baseAqi + _random.nextInt(40);
    
    // Noise level
    double baseNoise = hour >= 9 && hour <= 15 ? 60 : 40;
    double noise = baseNoise + (_random.nextDouble() * 20);
    
    // Temperature
    double baseTemp = hour > 12 && hour < 16 ? 28 : 24;
    double temp = baseTemp + (_random.nextDouble() * 4);
    
    // Light intensity
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

  /// Add initial growth records for children
  Future<void> seedGrowthData() async {
    for (var child in children) {
      final ageMonths = child['age_months'] ?? 36;
      
      // Generate realistic height/weight based on age
      double height = (50 + (ageMonths * 0.8)).toDouble(); // Rough estimate
      double weight = (3.5 + (ageMonths * 0.4)).toDouble(); // Rough estimate
      
      final record = GrowthRecord(
        height: height + (_random.nextDouble() * 5 - 2.5), // ±2.5cm variation
        weight: weight + (_random.nextDouble() * 2 - 1), // ±1kg variation
        notes: "Initial measurement",
        date: DateTime.now().subtract(Duration(days: 30)),
      );
      
      await _growthService.addGrowthRecord(schoolId, child['id'], record);
    }
  }

  void stopAll() {
    _healthTimer?.cancel();
    _classroomTimer?.cancel();
  }
}

/// Demo data generator
class DemoDataGenerator {
  static List<Map<String, dynamic>> getDemoChildren() {
    return [
      {'id': 'C001', 'name': 'Rahul Kumar', 'age_months': 36},
      {'id': 'C002', 'name': 'Priya Sharma', 'age_months': 42},
      {'id': 'C003', 'name': 'Amit Patel', 'age_months': 30},
      {'id': 'C004', 'name': 'Sneha Singh', 'age_months': 48},
      {'id': 'C005', 'name': 'Arjun Reddy', 'age_months': 38},
    ];
  }
  
  static IoTDataSimulator createDemoSimulator() {
    return IoTDataSimulator(
      schoolId: "DEMO_SCHOOL_01",
      children: getDemoChildren(),
    );
  }
}
