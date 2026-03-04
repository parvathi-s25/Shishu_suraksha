import 'dart:async';
import 'dart:math';

class SpeechModelService {
  final Random _random = Random();

  /// Simulate analyzing an audio file for speech recognition
  Future<Map<String, dynamic>> analyzeAudio(String audioPath) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulated results
    final double confidence = 0.85 + (_random.nextDouble() * 0.14); // 0.85 - 0.99
    final double fluencyScore = 7.0 + (_random.nextDouble() * 3.0); // 7.0 - 10.0
    
    // Select a random sample transcript
    final List<String> samples = [
      "The quick brown fox jumps over the lazy dog.",
      "She sells seashells by the seashore.",
      "How much wood would a woodchuck chuck if a woodchuck could chuck wood?",
      "Peter Piper picked a peck of pickled peppers.",
      "I scream, you scream, we all scream for ice cream."
    ];
    
    final String transcript = samples[_random.nextInt(samples.length)];

    return {
      'transcript': transcript,
      'confidence': confidence,
      'fluency_score': fluencyScore,
      'word_count': transcript.split(' ').length,
      'duration_seconds': 5 + _random.nextInt(10),
    };
  }

  /// Simulate distinct speech features extraction
  Map<String, double> extractFeatures() {
    return {
      'pitch_variance': 0.5 + _random.nextDouble(),
      'speaking_rate': 120 + _random.nextDouble() * 40, // words per minute
      'pause_duration': 0.2 + _random.nextDouble() * 0.5,
    };
  }
}
