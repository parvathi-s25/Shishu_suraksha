// Minimal stub implementation to satisfy imports when native plugin is removed.
import 'dart:async';

class TfliteAudio {
  static Future<void> loadModel({required String model, required String label, int? numThreads, bool? isAsset, String? inputType}) async {
    return;
  }

  /// Returns a simulated stream of recognition events. Consumers should handle empty streams.
  static Stream<Map<dynamic, dynamic>> startAudioRecognition({int? sampleRate, int? bufferSize, int? numOfInferences, double? detectionThreshold}) {
    // Provide a periodic empty stream to keep listeners functional.
    return Stream<Map<dynamic,dynamic>>.periodic(Duration(seconds: 1), (_) => <dynamic,dynamic>{'recognitionResult': 'silence', 'confidence': 0.0}).asBroadcastStream();
  }

  static Future<void> stopAudioRecognition() async {
    return;
  }
}
