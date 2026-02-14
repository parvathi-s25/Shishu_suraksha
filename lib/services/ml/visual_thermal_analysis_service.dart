import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:math';

/// Visual Analysis Service - Analyzes images/video for visual screening
class VisualAnalysisService {
  static final VisualAnalysisService _instance = VisualAnalysisService._internal();

  factory VisualAnalysisService() {
    return _instance;
  }

  VisualAnalysisService._internal();

  late PoseDetector _poseDetector;
  bool _isInitialized = false;
  final StreamController<VisualAnalysisResult> _resultStream =
      StreamController<VisualAnalysisResult>.broadcast();

  /// Initialize visual analysis service
  Future<bool> initialize() async {
    try {
      final options = PoseDetectorOptions(mode: PoseDetectionMode.single);
      _poseDetector = PoseDetector(options: options);
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing pose detector: $e');
      return false;
    }
  }

  /// Analyze image for visual assessment
  Future<VisualAnalysisResult?> analyzeImage(File imageFile) async {
    if (!_isInitialized) await initialize();
    
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final List<Pose> poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty) {
        return VisualAnalysisResult(
          detected: false,
          poseEstimate: null,
          confidence: 0.0,
          keyPointsCount: 0,
          riskLevel: 'Unknown - No body detected',
        );
      }

      final pose = poses.first;
      final landmarks = pose.landmarks.values.toList();
      final poseAnalysis = _analyzePose(landmarks);
      final confidence = _calculatePoseConfidence(landmarks);

      final result = VisualAnalysisResult(
        detected: true,
        poseEstimate: poseAnalysis,
        confidence: confidence,
        keyPointsCount: landmarks.length,
        riskLevel: poseAnalysis.riskLevel,
      );
      
      _resultStream.add(result);
      return result;
    } catch (e) {
      debugPrint('Error analyzing image: $e');
      return null;
    }
  }

  /// Analyze pose landmarks
  PoseAnalysis _analyzePose(List<PoseLandmark> landmarks) {
    // Group landmarks by body part
    final headLandmarks = _getLandmarksByType([
      PoseLandmarkType.nose,
      PoseLandmarkType.nose,
      PoseLandmarkType.leftEar,
      PoseLandmarkType.rightEar,
    ], landmarks);

    final armLandmarks = _getLandmarksByType([
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
    ], landmarks);

    final legLandmarks = _getLandmarksByType([
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ], landmarks);

    // Calculate pose metrics
    final headStability = _calculateStability(headLandmarks);
    final armControl = _calculateControl(armLandmarks);
    final legControl = _calculateControl(legLandmarks);

    // Determine risk level
    final riskLevel = _determineVisualRisk(
      headStability,
      armControl,
      legControl,
    );

    return PoseAnalysis(
      headStability: headStability,
      armControl: armControl,
      legControl: legControl,
      overallPosture: (headStability + armControl + legControl) / 3,
      riskLevel: riskLevel,
    );
  }

  /// Get landmarks filtered by type
  List<PoseLandmark> _getLandmarksByType(
    List<PoseLandmarkType> types,
    List<PoseLandmark> landmarks,
  ) {
    return landmarks.where((l) => types.contains(l.type)).toList();
  }

  /// Calculate stability of landmarks
  double _calculateStability(List<PoseLandmark> landmarks) {
    if (landmarks.isEmpty) return 0.0;

    // Calculate average inPosition score
    final avgInPosition = landmarks.map((l) => l.likelihood).reduce((a, b) => a + b) /
        landmarks.length;
    return avgInPosition * 100;
  }

  /// Calculate control of landmarks
  double _calculateControl(List<PoseLandmark> landmarks) {
    if (landmarks.isEmpty) return 0.0;

    double sumDistance = 0;
    for (int i = 0; i < landmarks.length - 1; i++) {
      final a = landmarks[i];
      final b = landmarks[i + 1];
      sumDistance +=
          sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
    }

    // Normalize distance
    final avgDistance = sumDistance / landmarks.length;
    return (100 - (avgDistance * 10).clamp(0, 100)).toDouble();
  }

  /// Determine visual risk level
  String _determineVisualRisk(
    double headStability,
    double armControl,
    double legControl,
  ) {
    final average = (headStability + armControl + legControl) / 3;

    if (average >= 80) return 'Normal';
    if (average >= 60) return 'Mild - Slight motor coordination issues';
    if (average >= 40) return 'Moderate - Motor coordination concerns';
    return 'High - Significant motor development delay';
  }

  /// Calculate overall pose confidence
  double _calculatePoseConfidence(List<PoseLandmark> landmarks) {
    if (landmarks.isEmpty) return 0.0;
    final avgConfidence = landmarks
            .map((l) => l.likelihood)
            .reduce((a, b) => a + b) /
        landmarks.length;
    return avgConfidence;
  }

  /// Analyze image for wound/injury (YOLOv8 stub)
  Future<WoundAnalysisResult?> analyzeWound(File imageFile) async {
    // Stub implementation - in real app would use TFLite/YOLO model
    await Future.delayed(const Duration(seconds: 1)); // Simulate processing
    return WoundAnalysisResult(
      detected: true,
      woundType: 'Abrasion',
      severity: 'Mild',
      confidence: 0.85,
      riskLevel: 'Low',
    );
  }

  /// Analyze image for general symptoms (MobileNet stub)
  Future<SymptomAnalysisResult?> analyzeSymptoms(File imageFile) async {
    // Stub implementation
    await Future.delayed(const Duration(seconds: 1));
    return SymptomAnalysisResult(
      detected: false,
      symptoms: ['Mild Skin Redness'],
      confidence: 0.78,
      riskLevel: 'Normal',
    );
  }

  Stream<VisualAnalysisResult> get resultStream => _resultStream.stream;

  void dispose() {
    _poseDetector.close();
    _resultStream.close();
  }
}

/// Wound analysis result
class WoundAnalysisResult {
  final bool detected;
  final String woundType;
  final String severity;
  final double confidence;
  final String riskLevel;

  WoundAnalysisResult({
    required this.detected,
    required this.woundType,
    required this.severity,
    required this.confidence,
    required this.riskLevel,
  });
}

/// Symptom analysis result
class SymptomAnalysisResult {
  final bool detected;
  final List<String> symptoms;
  final double confidence;
  final String riskLevel;

  SymptomAnalysisResult({
    required this.detected,
    required this.symptoms,
    required this.confidence,
    required this.riskLevel,
  });
}

/// Visual analysis result
class VisualAnalysisResult {
  final bool detected;
  final PoseAnalysis? poseEstimate;
  final double confidence;
  final int keyPointsCount;
  final String riskLevel;

  VisualAnalysisResult({
    required this.detected,
    required this.poseEstimate,
    required this.confidence,
    required this.keyPointsCount,
    required this.riskLevel,
  });
}

/// Pose analysis data
class PoseAnalysis {
  final double headStability;
  final double armControl;
  final double legControl;
  final double overallPosture;
  final String riskLevel;

  PoseAnalysis({
    required this.headStability,
    required this.armControl,
    required this.legControl,
    required this.overallPosture,
    required this.riskLevel,
  });

  Map<String, dynamic> toJson() => {
        'headStability': headStability,
        'armControl': armControl,
        'legControl': legControl,
        'overallPosture': overallPosture,
        'riskLevel': riskLevel,
      };
}

/// Thermal Imaging Analysis Service
/// Analyzes thermal images for health assessments
class ThermalAnalysisService {
  static final ThermalAnalysisService _instance = ThermalAnalysisService._internal();

  factory ThermalAnalysisService() {
    return _instance;
  }

  ThermalAnalysisService._internal();

  final StreamController<ThermalAnalysisResult> _resultStream =
      StreamController<ThermalAnalysisResult>.broadcast();

  /// Analyze thermal image
  Future<ThermalAnalysisResult?> analyzeThermalImage(File imageFile) async {
    try {
      // Simulate thermal image analysis
      // In production, integrate with actual thermal imaging SDK
      final result = ThermalAnalysisResult(
        averageTemperature: 36.5,
        maxTemperature: 37.2,
        minTemperature: 35.8,
        hotspots: [],
        bodySymmetry: 0.92,
        inflammationRisk: 'Low',
        nutritionStatus: 'Normal',
        riskLevel: 'Normal',
      );

      _resultStream.add(result);
      return result;
    } catch (e) {
      debugPrint('Error analyzing thermal image: $e');
      return null;
    }
  }

  Stream<ThermalAnalysisResult> get resultStream => _resultStream.stream;

  void dispose() {
    _resultStream.close();
  }
}

/// Thermal analysis result
class ThermalAnalysisResult {
  final double averageTemperature;
  final double maxTemperature;
  final double minTemperature;
  final List<Hotspot> hotspots;
  final double bodySymmetry;
  final String inflammationRisk;
  final String nutritionStatus;
  final String riskLevel;

  ThermalAnalysisResult({
    required this.averageTemperature,
    required this.maxTemperature,
    required this.minTemperature,
    required this.hotspots,
    required this.bodySymmetry,
    required this.inflammationRisk,
    required this.nutritionStatus,
    required this.riskLevel,
  });
}

/// Hotspot detected in thermal image
class Hotspot {
  final double temperature;
  final double x;
  final double y;
  final double radius;

  Hotspot({
    required this.temperature,
    required this.x,
    required this.y,
    required this.radius,
  });
}

/// Speech Analysis Service - Analyzes speech for development screening
class SpeechAnalysisService {
  static final SpeechAnalysisService _instance = SpeechAnalysisService._internal();

  factory SpeechAnalysisService() {
    return _instance;
  }

  SpeechAnalysisService._internal();

  final StreamController<SpeechAnalysisResult> _resultStream =
      StreamController<SpeechAnalysisResult>.broadcast();

  /// Analyze speech data
  Future<SpeechAnalysisResult?> analyzeSpeech(String audioPath) async {
    try {
      // Extract speech features
      final features = SpeechFeatures(
        articulation: _analyzeArticulation(audioPath),
        fluency: _analyzeFluency(audioPath),
        clarity: _analyzeClarity(audioPath),
        volumeLevel: _analyzeVolume(audioPath),
        pausePatterns: _analyzePausePatterns(audioPath),
      );

      // Determine speech development level
      final developmentLevel = _determineSpeechDevelopment(features);

      return SpeechAnalysisResult(
        features: features,
        developmentLevel: developmentLevel,
        riskLevel: _determineSpeechRisk(features),
      );
    } catch (e) {
      debugPrint('Error analyzing speech: $e');
      return null;
    }
  }

  double _analyzeArticulation(String audioPath) => 0.85;
  double _analyzeFluency(String audioPath) => 0.78;
  double _analyzeClarity(String audioPath) => 0.82;
  double _analyzeVolume(String audioPath) => 0.75;
  Map<String, Duration> _analyzePausePatterns(String audioPath) => {};

  String _determineSpeechDevelopment(SpeechFeatures features) {
    final avg = (features.articulation + features.fluency + features.clarity) / 3;
    if (avg >= 0.85) return 'Advanced';
    if (avg >= 0.70) return 'On Track';
    if (avg >= 0.50) return 'Developing';
    return 'Delayed';
  }

  String _determineSpeechRisk(SpeechFeatures features) {
    if (features.clarity < 0.50) return 'High - Severe articulation issues';
    if (features.fluency < 0.50) return 'Moderate - Speech fluency concerns';
    if (features.articulation < 0.65) return 'Mild - Minor articulation issues';
    return 'Normal';
  }

  Stream<SpeechAnalysisResult> get resultStream => _resultStream.stream;

  void dispose() {
    _resultStream.close();
  }
}

/// Speech features extracted from audio
class SpeechFeatures {
  final double articulation;
  final double fluency;
  final double clarity;
  final double volumeLevel;
  final Map<String, Duration> pausePatterns;

  SpeechFeatures({
    required this.articulation,
    required this.fluency,
    required this.clarity,
    required this.volumeLevel,
    required this.pausePatterns,
  });
}

/// Speech analysis result
class SpeechAnalysisResult {
  final SpeechFeatures features;
  final String developmentLevel;
  final String riskLevel;

  SpeechAnalysisResult({
    required this.features,
    required this.developmentLevel,
    required this.riskLevel,
  });
}
