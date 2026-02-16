
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Real-time Audio Processing Service
/// Handles audio recording, streaming, and ML preprocessing
class RealtimeAudioService {
  static final RealtimeAudioService _instance = RealtimeAudioService._internal();

  factory RealtimeAudioService() {
    return _instance;
  }

  RealtimeAudioService._internal();

  late stt.SpeechToText _speechToText;
  final StreamController<AudioFrame> _audioFrameStream =
      StreamController<AudioFrame>.broadcast();
  final StreamController<AudioStats> _statsStream =
      StreamController<AudioStats>.broadcast();

  bool _isListening = false;
  bool _isInitialized = false;
  int _frameCount = 0;
  DateTime? _startTime;
  double _peakLevel = 0;
  double _averageLevel = 0;

  // Audio parameters
  final int sampleRate = 16000;
  final int frameSize = 512;
  List<int> _audioBuffer = [];

  /// Initialize audio service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _speechToText = stt.SpeechToText();
      final available = await _speechToText.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
        onStatus: (status) => debugPrint('Speech recognition status: $status'),
      );

      if (!available) {
        debugPrint('Speech to text not available');
        return false;
      }

      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('Microphone permission not granted');
        return false;
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
      return false;
    }
  }

  /// Start listening to audio
  Future<bool> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      _isListening = true;
      _frameCount = 0;
      _startTime = DateTime.now();
      _audioBuffer.clear();
      _peakLevel = 0;
      _averageLevel = 0;

      // Start speech recognition with audio level detection
      await _speechToText.listen(
        onResult: (result) {
          _processAudioResult(result);
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onDevice: true,
      );

      return true;
    } catch (e) {
      debugPrint('Error starting audio listening: $e');
      _isListening = false;
      return false;
    }
  }

  /// Stop listening to audio
  Future<void> stopListening() async {
    try {
      _isListening = false;
      await _speechToText.stop();
      
      // Emit final stats
      if (_startTime != null) {
        _statsStream.add(AudioStats(
          duration: DateTime.now().difference(_startTime!),
          frameCount: _frameCount,
          peakLevel: _peakLevel,
          averageLevel: _averageLevel,
          sampleRate: sampleRate,
        ));
      }
    } catch (e) {
      debugPrint('Error stopping audio listening: $e');
    }
  }

  /// Process audio result from speech recognition
  void _processAudioResult(dynamic result) {
    _frameCount++;

    double confidence = 0.0;
    String recognized = '';
    bool isFinal = false;
    try {
      confidence = (result?.confidence ?? 0.0) as double;
      recognized = (result?.recognizedWords ?? '') as String;
      isFinal = (result?.finalResult ?? false) as bool;
    } catch (_) {}

    // Create audio frame
    final frame = AudioFrame(
      frameNumber: _frameCount,
      timestamp: DateTime.now(),
      sampleRate: sampleRate,
      confidence: confidence,
      recognizedText: recognized,
      isFinal: isFinal,
      audioLevel: 0.5, // This would come from actual audio analysis
    );

    _audioFrameStream.add(frame);

    // Update stats
    _updateAudioStats(frame);
  }

  /// Update audio statistics
  void _updateAudioStats(AudioFrame frame) {
    _peakLevel = frame.audioLevel > _peakLevel ? frame.audioLevel : _peakLevel;

    // Calculate running average
    if (_frameCount == 1) {
      _averageLevel = frame.audioLevel;
    } else {
      _averageLevel = (_averageLevel * (_frameCount - 1) + frame.audioLevel) / _frameCount;
    }
  }

  /// Get audio frame stream
  Stream<AudioFrame> get audioFrameStream => _audioFrameStream.stream;

  /// Get audio statistics stream
  Stream<AudioStats> get statsStream => _statsStream.stream;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get current frame count
  int get frameCount => _frameCount;

  /// Dispose resources
  void dispose() {
    _audioFrameStream.close();
    _statsStream.close();
    _isListening = false;
  }
}

/// Audio frame data
class AudioFrame {
  final int frameNumber;
  final DateTime timestamp;
  final int sampleRate;
  final double confidence;
  final String recognizedText;
  final bool isFinal;
  final double audioLevel;

  AudioFrame({
    required this.frameNumber,
    required this.timestamp,
    required this.sampleRate,
    required this.confidence,
    required this.recognizedText,
    required this.isFinal,
    required this.audioLevel,
  });

  /// Get frame duration based on sample rate
  Duration get frameDuration => Duration(
    milliseconds: ((512 / sampleRate) * 1000).toInt(),
  );
}

/// Audio statistics
class AudioStats {
  final Duration duration;
  final int frameCount;
  final double peakLevel;
  final double averageLevel;
  final int sampleRate;

  AudioStats({
    required this.duration,
    required this.frameCount,
    required this.peakLevel,
    required this.averageLevel,
    required this.sampleRate,
  });

  /// Get frames per second
  double get fps => frameCount / duration.inMilliseconds * 1000;

  /// Get total samples
  int get totalSamples => (duration.inMilliseconds * sampleRate) ~/ 1000;
}

/// Hearing screening analyzer
class HearingScreeningAnalyzer {
  final RealtimeAudioService _audioService = RealtimeAudioService();
  final StreamController<HearingTestResult> _resultStream =
      StreamController<HearingTestResult>.broadcast();

  bool _isRunning = false;
  int _responseCount = 0;
  List<double> _frequencyResponses = [];

  /// Start hearing screening test
  Future<bool> startTest() async {
    try {
      final initialized = await _audioService.initialize();
      if (!initialized) return false;

      _isRunning = true;
      _responseCount = 0;
      _frequencyResponses.clear();

      await _audioService.startListening();
      return true;
    } catch (e) {
      debugPrint('Error starting hearing test: $e');
      return false;
    }
  }

  /// Stop hearing screening test
  Future<HearingTestResult?> stopTest() async {
    try {
      await _audioService.stopListening();
      _isRunning = false;

      if (_responseCount == 0) {
        return HearingTestResult(
          passed: false,
          score: 0,
          riskLevel: 'High - No response detected',
          frequenciesTested: [],
          responseLatency: Duration.zero,
        );
      }

      // Calculate hearing score
      final score = (_responseCount / 5 * 100).clamp(0, 100).toDouble();

      return HearingTestResult(
        passed: score >= 75,
        score: score,
        riskLevel: score >= 75 ? 'Normal' : score >= 50 ? 'Mild' : 'High',
        frequenciesTested: _frequencyResponses.map((e) => e.toInt()).toList(),
        responseLatency: const Duration(seconds: 1),
      );
    } catch (e) {
      debugPrint('Error stopping hearing test: $e');
      return null;
    }
  }

  /// Get result stream
  Stream<HearingTestResult> get resultStream => _resultStream.stream;

  /// Check if test is running
  bool get isRunning => _isRunning;

  void dispose() {
    _resultStream.close();
    _audioService.dispose();
  }
}

/// Hearing test result
class HearingTestResult {
  final bool passed;
  final double score;
  final String riskLevel;
  final List<int>? frequenciesTested;
  final Duration? responseLatency;

  HearingTestResult({
    required this.passed,
    required this.score,
    required this.riskLevel,
    this.frequenciesTested,
    this.responseLatency,
  });
}
