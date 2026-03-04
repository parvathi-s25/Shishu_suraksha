
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceData {
  final String deviceId;
  final String schoolId;
  final String childId;
  final double heartRate;
  final double spo2;
  final double temp;
  final String movement;
  final int batteryLevel; // 0-100
  final int signalStrength; // 0-100
  final DateTime timestamp;

  DeviceData({
    required this.deviceId,
    required this.schoolId,
    required this.childId,
    required this.heartRate,
    required this.spo2,
    required this.temp,
    required this.movement,
    required this.batteryLevel,
    required this.signalStrength,
    required this.timestamp,
  });

  factory DeviceData.fromMap(Map<String, dynamic> data) {
    return DeviceData(
      deviceId: data['device_id'] ?? "unknown",
      schoolId: data['school_id'] ?? "",
      childId: data['child_id'] ?? "",
      heartRate: (data['heart_rate'] ?? 0).toDouble(),
      spo2: (data['spo2'] ?? 0).toDouble(),
      temp: (data['temp'] ?? 0).toDouble(),
      movement: data['movement'] ?? "Unknown",
      batteryLevel: data['battery_level'] ?? 100,
      signalStrength: data['signal_strength'] ?? 100,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
      'school_id': schoolId,
      'child_id': childId,
      'heart_rate': heartRate,
      'spo2': spo2,
      'temp': temp,
      'movement': movement,
      'battery_level': batteryLevel,
      'signal_strength': signalStrength,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Validation methods
  bool get isHeartRateNormal => heartRate >= 60 && heartRate <= 100;
  bool get isSpo2Normal => spo2 >= 95;
  bool get isTempNormal => temp >= 36.5 && temp <= 37.5;
  bool get isDeviceHealthy => batteryLevel > 20 && signalStrength > 30;
  
  bool get hasAnyAlert => !isHeartRateNormal || !isSpo2Normal || !isTempNormal;
  
  String get heartRateStatus {
    if (heartRate > 130) return "Very High";
    if (heartRate > 100) return "High";
    if (heartRate < 50) return "Very Low";
    if (heartRate < 60) return "Low";
    return "Normal";
  }
  
  String get spo2Status {
    if (spo2 < 90) return "Critical";
    if (spo2 < 95) return "Low";
    return "Normal";
  }
  
  String get tempStatus {
    if (temp > 38.0) return "High Fever";
    if (temp > 37.5) return "Mild Fever";
    if (temp < 36.0) return "Low";
    return "Normal";
  }
}
