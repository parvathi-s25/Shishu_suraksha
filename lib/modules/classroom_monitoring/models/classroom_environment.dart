
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassroomEnvironment {
  final int aqi;
  final double noiseLevel;
  final double temperature;
  final double lightIntensity;
  final DateTime timestamp;

  ClassroomEnvironment({
    required this.aqi,
    required this.noiseLevel,
    required this.temperature,
    required this.lightIntensity,
    required this.timestamp,
  });

  factory ClassroomEnvironment.fromMap(Map<String, dynamic> data) {
    return ClassroomEnvironment(
      aqi: data['aqi'] ?? 0,
      noiseLevel: (data['noise_level'] ?? 0).toDouble(),
      temperature: (data['temperature'] ?? 0).toDouble(),
      lightIntensity: (data['light_intensity'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'aqi': aqi,
      'noise_level': noiseLevel,
      'temperature': temperature,
      'light_intensity': lightIntensity,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Helper getters for status
  String get aqiStatus {
    if (aqi <= 50) return "Excellent";
    if (aqi <= 100) return "Good";
    if (aqi <= 150) return "Moderate";
    return "Poor";
  }

  String get noiseStatus {
    if (noiseLevel < 50) return "Quiet";
    if (noiseLevel < 70) return "Moderate";
    return "Noisy";
  }
  
  String get tempStatus {
    if (temperature < 18) return "Too Cold";
    if (temperature > 32) return "Too Hot";
    if (temperature < 22 || temperature > 28) return "Moderate";
    return "Comfortable";
  }
  
  String get lightStatus {
    if (lightIntensity < 300) return "Too Dark";
    if (lightIntensity > 750) return "Too Bright";
    return "Optimal";
  }
  
  // Classroom Health Index (0-100)
  int get healthIndex {
    int score = 100;
    
    // AQI impact (max -40)
    if (aqi > 150) score -= 40;
    else if (aqi > 100) score -= 20;
    else if (aqi > 50) score -= 10;
    
    // Noise impact (max -30)
    if (noiseLevel > 70) score -= 30;
    else if (noiseLevel > 60) score -= 15;
    
    // Temperature impact (max -20)
    if (temperature < 18 || temperature > 32) score -= 20;
    else if (temperature < 22 || temperature > 28) score -= 10;
    
    // Light impact (max -10)
    if (lightIntensity < 300 || lightIntensity > 750) score -= 10;
    
    return score.clamp(0, 100);
  }
  
  String get healthIndexStatus {
    if (healthIndex >= 80) return "Excellent";
    if (healthIndex >= 60) return "Good";
    if (healthIndex >= 40) return "Fair";
    return "Poor";
  }
}
