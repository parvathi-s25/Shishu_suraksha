class HealthData {
  final String childId;
  final DateTime timestamp;
  final int heartRate; // bpm: 70-140
  final int spo2; // %: 92-100
  final double temperature; // Celsius: 36-39
  final int stepCount;
  final int stressIndex; // 0-100
  final double sleepHours;
  final String deviceStatus; // "Connected", "Syncing", "Offline"

  HealthData({
    required this.childId,
    required this.timestamp,
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.stepCount,
    required this.stressIndex,
    required this.sleepHours,
    required this.deviceStatus,
  });

  // Factory for initial empty state
  factory HealthData.initial(String childId) {
    return HealthData(
      childId: childId,
      timestamp: DateTime.now(),
      heartRate: 0,
      spo2: 0,
      temperature: 0.0,
      stepCount: 0,
      stressIndex: 0,
      sleepHours: 0.0,
      deviceStatus: 'Offline',
    );
  }

  // Copy with for easy updates
  HealthData copyWith({
    String? childId,
    DateTime? timestamp,
    int? heartRate,
    int? spo2,
    double? temperature,
    int? stepCount,
    int? stressIndex,
    double? sleepHours,
    String? deviceStatus,
  }) {
    return HealthData(
      childId: childId ?? this.childId,
      timestamp: timestamp ?? this.timestamp,
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      temperature: temperature ?? this.temperature,
      stepCount: stepCount ?? this.stepCount,
      stressIndex: stressIndex ?? this.stressIndex,
      sleepHours: sleepHours ?? this.sleepHours,
      deviceStatus: deviceStatus ?? this.deviceStatus,
    );
  }
}
