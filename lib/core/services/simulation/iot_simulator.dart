import 'dart:async';
import 'dart:math';

class IoTDeviceSimulator {
  final Random _random = Random();
  bool _isConnected = false;
  Timer? _timer;
  final StreamController<Map<String, dynamic>> _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get vitalsStream => _controller.stream;

  bool get isConnected => _isConnected;

  void connect() {
    _isConnected = true;
    _startGeneration();
  }

  void disconnect() {
    _isConnected = false;
    _timer?.cancel();
  }

  void _startGeneration() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isConnected) return;
      
      final Map<String, dynamic> data = {
        'heart_rate': 60 + _random.nextInt(40), // 60-100 bpm
        'spo2': 94 + _random.nextInt(6), // 94-100%
        'body_temp': 36.5 + (_random.nextDouble() * 1.5), // 36.5-38.0 C
        'timestamp': DateTime.now().toIso8601String(),
        'device_id': 'IOT-DEMO-${_random.nextInt(100)}'
      };
      
      _controller.add(data);
    });
  }
}

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
}
