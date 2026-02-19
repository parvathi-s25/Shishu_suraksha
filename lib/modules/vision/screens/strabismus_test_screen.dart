import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:camera/camera.dart';
import 'package:shishu_suraksha/services/camera_service.dart';
import 'package:shishu_suraksha/modules/vision/widgets/eye_alignment_painter.dart';
import '../services/strabismus_service.dart';
import '../models/vision_result_model.dart';

enum _ScanPhase { positioning, scanning, results }

class StrabismusTestScreen extends StatefulWidget {
  const StrabismusTestScreen({super.key});

  @override
  State<StrabismusTestScreen> createState() => _StrabismusTestScreenState();
}

class _StrabismusTestScreenState extends State<StrabismusTestScreen>
    with TickerProviderStateMixin {
  final StrabismusService _service = StrabismusService();

  // --- State ---
  _ScanPhase _phase = _ScanPhase.positioning;
  bool _isAnalyzing = false;
  bool _faceDetected = false;

  // Real-time iris data
  double _leftRatio = 0.5;
  double _rightRatio = 0.5;
  double _leftDeviation = 0.0;
  double _rightDeviation = 0.0;
  bool _isHeadCorrect = false;
  double _headTilt = 0.0;

  // Scan buffer
  final List<StrabismusAnalysis> _resultsBuffer = [];
  static const int _requiredSamples = 20;

  // Final result
  StrabismusResult? _finalResult;

  // --- Animations ---
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scanProgressController;
  late AnimationController _scoreRevealController;
  late Animation<double> _scoreRevealAnimation;
  late AnimationController _eyeFadeController;
  late Animation<double> _eyeFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for positioning guide ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Scan progress (drives the painter ring)
    _scanProgressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    // Score reveal after scanning completes
    _scoreRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scoreRevealAnimation = CurvedAnimation(
      parent: _scoreRevealController,
      curve: Curves.elasticOut,
    );

    // Eye painter fade-in when scanning starts
    _eyeFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _eyeFadeAnimation = CurvedAnimation(
      parent: _eyeFadeController,
      curve: Curves.easeIn,
    );

    // Initialize camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCamera();
    });
  }

  Future<void> _initCamera() async {
    try {
      debugPrint('StrabismusTestScreen: Stopping existing streams...');
      await CameraService.instance.stopImageStream();
      
      debugPrint('StrabismusTestScreen: Initializing camera...');
      try {
        await CameraService.instance.initCamera(
          direction: CameraLensDirection.front,
          preset: ResolutionPreset.high,
          imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
        );
      } catch (e) {
        debugPrint('StrabismusTestScreen: Failed with specific ImageFormatGroup, falling back: $e');
        await CameraService.instance.initCamera(
          direction: CameraLensDirection.front,
          preset: ResolutionPreset.high,
        );
      }
      
      final controller = CameraService.instance.controller;
      if (controller != null) {
        debugPrint('StrabismusTestScreen: Camera initialized. Sensor: ${controller.description.sensorOrientation}, Lens: ${controller.description.lensDirection}');
      }

      if (mounted) {
        debugPrint('StrabismusTestScreen: Starting image stream...');
        await CameraService.instance.startImageStream(_onCameraImage);
      }
    } catch (e) {
      debugPrint('StrabismusTestScreen: Camera initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting camera: $e')),
        );
      }
    }
  }

  void _onCameraImage(CameraImage image) {
    if (_isAnalyzing || _phase == _ScanPhase.results) return;
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    _processImage(inputImage);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final controller = CameraService.instance.controller;
    if (controller == null) return null;

    final sensorOrientation = controller.description.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (controller.description.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      debugPrint('StrabismusTestScreen: Calculated rotation: $rotationCompensation ($rotation)');
    }
    if (rotation == null) {
      debugPrint('StrabismusTestScreen: Could not determine rotation');
      return null;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    debugPrint('StrabismusTestScreen: Frame format: ${image.format.raw} ($format)');
    
    // Be a bit more relaxed with format check on Android (some report yuv420 incorrectly)
    if (format == null && Platform.isIOS) {
      debugPrint('StrabismusTestScreen: Skipping frame due to null format on iOS');
      return null;
    }

    if (image.planes.isEmpty) return null;

    final writeBuffer = WriteBuffer();
    for (final plane in image.planes) {
      writeBuffer.putUint8List(plane.bytes);
    }
    final bytes = writeBuffer.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format ?? InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  static final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void dispose() {
    CameraService.instance.stopImageStream();
    _pulseController.dispose();
    _scanProgressController.dispose();
    _scoreRevealController.dispose();
    _eyeFadeController.dispose();
    _service.close();
    super.dispose();
  }

  // --- Image processing ---
  void _processImage(InputImage inputImage) async {
    if (_isAnalyzing || _phase == _ScanPhase.results) return;
    _isAnalyzing = true;

    try {
      debugPrint('Processing frame...');
      final analysis = await _service.analyzeImageWithRatios(inputImage).timeout(
        const Duration(seconds: 2),
      );
      if (!mounted) return;

      if (analysis == null) {
        if (_faceDetected) setState(() => _faceDetected = false);
        return;
      }

      if (!_faceDetected) {
        debugPrint('Face detected!');
      }

      setState(() {
        _faceDetected = true;
        _leftRatio = analysis.leftRatio;
        _rightRatio = analysis.rightRatio;
        _leftDeviation = analysis.result.leftEyeDeviation;
        _rightDeviation = analysis.result.rightEyeDeviation;
        _isHeadCorrect = analysis.result.isHeadPositionCorrect;
        _headTilt = analysis.result.headTilt;
      });

      if (_phase == _ScanPhase.scanning) {
        _resultsBuffer.add(analysis);
        _scanProgressController.value =
            (_resultsBuffer.length / _requiredSamples).clamp(0.0, 1.0);

        if (_resultsBuffer.length >= _requiredSamples) {
          _finalizeTest();
        }
      }
    } catch (e) {
      debugPrint('Eye alignment processing error: $e');
    } finally {
      _isAnalyzing = false;
    }
  }

  void _startScanning() {
    setState(() => _phase = _ScanPhase.scanning);
    _eyeFadeController.forward();
    // Progress is driven by sample count in _processImage, not a timed animation
  }

  void _finalizeTest() {
    double avgLeft = _resultsBuffer
            .map((e) => e.result.leftEyeDeviation)
            .reduce((a, b) => a + b) /
        _resultsBuffer.length;
    double avgRight = _resultsBuffer
            .map((e) => e.result.rightEyeDeviation)
            .reduce((a, b) => a + b) /
        _resultsBuffer.length;

    bool isAbnormal =
        avgLeft > 8 || avgRight > 8 || (avgLeft - avgRight).abs() > 5;

    setState(() {
      _phase = _ScanPhase.results;
      _finalResult = StrabismusResult(
        leftEyeDeviation: avgLeft,
        rightEyeDeviation: avgRight,
        isAbnormal: isAbnormal,
        headTilt: 0,
        headTurnRatio: 1,
        isHeadPositionCorrect: true,
      );
    });

    _scanProgressController.stop();
    _scoreRevealController.forward();
  }

  // --- Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Eye Alignment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          // Camera layer
          if (_phase != _ScanPhase.results)
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: CameraService.instance.isInitializedNotifier,
                builder: (context, initialized, child) {
                  if (initialized && CameraService.instance.controller != null) {
                    return CameraPreview(CameraService.instance.controller!);
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _initCamera,
                          child: const Text('Loading camera... Tap to retry'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Phase-specific overlays
          if (_phase == _ScanPhase.positioning) _buildPositioningOverlay(),
          if (_phase == _ScanPhase.scanning) _buildScanningOverlay(),
          if (_phase == _ScanPhase.results) _buildResultsScreen(),
        ],
      ),
    );
  }

  // ========================
  // PHASE 1: Positioning
  // ========================
  Widget _buildPositioningOverlay() {
    return Positioned.fill(
      child: SafeArea(
        child: Container(
          color: Colors.white.withOpacity(0.4),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Instruction card
              _buildGlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _faceDetected ? Icons.face : Icons.face_retouching_off,
                      color: _faceDetected ? Colors.greenAccent : Colors.redAccent,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _faceDetected
                          ? 'Face Detected — Center your face'
                          : 'Position face in front of camera',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isHeadCorrect
                          ? 'Head position: ✓ Good'
                          : 'Head tilt: ${_headTilt.toStringAsFixed(1)}° — Look straight ahead',
                      style: TextStyle(
                        color: _isHeadCorrect ? Colors.greenAccent : Colors.amber,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Animated guide ring
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 200 * _pulseAnimation.value,
                        height: 250 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: _faceDetected && _isHeadCorrect
                                ? Colors.green.withOpacity(0.7)
                                : Colors.teal.withOpacity(0.4),
                            width: 3,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Start button
              Padding(
                padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
                child: ValueListenableBuilder<bool>(
                  valueListenable: CameraService.instance.isInitializedNotifier,
                  builder: (context, initialized, _) {
                    final bool canStart = initialized;
                    return ElevatedButton.icon(
                      onPressed: canStart ? _startScanning : null,
                      icon: const Icon(Icons.play_arrow_rounded, size: 26),
                      label: Text(
                        _faceDetected ? 'START SCAN' : 'START ANYWAY',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _faceDetected ? Colors.green : (_isHeadCorrect ? Colors.teal : Colors.orange),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================
  // PHASE 2: Scanning
  // ========================
  Widget _buildScanningOverlay() {
    return Positioned.fill(
      child: SafeArea(
        child: Container(
          color: Colors.white.withOpacity(0.5),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Live status bar
              _buildGlassCard(
                child: Row(
                  children: [
                    _buildStatusDot(_isHeadCorrect),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isHeadCorrect ? 'Scanning eyes...' : 'Straighten head!',
                            style: TextStyle(
                              color: _isHeadCorrect ? Colors.black87 : Colors.orange,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedBuilder(
                            animation: _scanProgressController,
                            builder: (context, _) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _scanProgressController.value,
                                  backgroundColor: Colors.black.withOpacity(0.05),
                                  valueColor: AlwaysStoppedAnimation(
                                    _isHeadCorrect ? Colors.teal : Colors.orange,
                                  ),
                                  minHeight: 6,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_resultsBuffer.length}/$_requiredSamples samples',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Real-time eye simulation — takes remaining space
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedBuilder(
                      animation: Listenable.merge([
                        _eyeFadeAnimation,
                        _scanProgressController,
                      ]),
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: EyeAlignmentPainter(
                            leftRatio: _leftRatio,
                            rightRatio: _rightRatio,
                            leftDeviation: _leftDeviation,
                            rightDeviation: _rightDeviation,
                            isHeadCorrect: _isHeadCorrect,
                            scanProgress: _scanProgressController.value,
                            animationValue: _eyeFadeAnimation.value,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Head tilt warning (only when not correct)
              if (!_isHeadCorrect)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _headTilt.abs() > 8
                                ? 'Reduce head tilt (${_headTilt.toStringAsFixed(1)}°)'
                                : 'Look straight ahead',
                            style: const TextStyle(color: Colors.black87, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Live deviation gauges
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    _buildDeviationGauge('Left Eye', _leftDeviation, Colors.cyanAccent),
                    const SizedBox(width: 12),
                    _buildDeviationGauge('Right Eye', _rightDeviation, Colors.purpleAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================
  // PHASE 3: Results
  // ========================
  Widget _buildResultsScreen() {
    if (_finalResult == null) return const SizedBox();

    final isNormal = !_finalResult!.isAbnormal;
    final statusColor = isNormal ? Colors.greenAccent : Colors.orangeAccent;
    final statusLabel = isNormal ? 'Normal Alignment' : 'Potential Strabismus';
    final statusIcon = isNormal ? Icons.check_circle_rounded : Icons.warning_rounded;

    // Score: 0 (worst) to 100 (best)
    final score = max(
      0.0,
      100 -
          ((_finalResult!.leftEyeDeviation + _finalResult!.rightEyeDeviation) / 2)
              .clamp(0, 50),
    );

    return Container(
      color: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _scoreRevealAnimation,
          builder: (context, _) {
            return Opacity(
              opacity: _scoreRevealAnimation.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.8 + 0.2 * _scoreRevealAnimation.value.clamp(0.0, 1.0),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Score ring
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: CircularProgressIndicator(
                                value: score / 100,
                                strokeWidth: 10,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation(statusColor),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  score.toStringAsFixed(0),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Score',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.4),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: statusColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: statusColor, size: 22),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Detail cards
                      _buildResultDetailCard(
                        'Left Eye Deviation',
                        '${_finalResult!.leftEyeDeviation.toStringAsFixed(1)}%',
                        _finalResult!.leftEyeDeviation > 8
                            ? Colors.orangeAccent
                            : Colors.greenAccent,
                        Icons.visibility,
                      ),
                      const SizedBox(height: 12),
                      _buildResultDetailCard(
                        'Right Eye Deviation',
                        '${_finalResult!.rightEyeDeviation.toStringAsFixed(1)}%',
                        _finalResult!.rightEyeDeviation > 8
                            ? Colors.orangeAccent
                            : Colors.greenAccent,
                        Icons.visibility,
                      ),
                      const SizedBox(height: 12),
                      _buildResultDetailCard(
                        'Asymmetry',
                        '${(_finalResult!.leftEyeDeviation - _finalResult!.rightEyeDeviation).abs().toStringAsFixed(1)}%',
                        (_finalResult!.leftEyeDeviation -
                                        _finalResult!.rightEyeDeviation)
                                    .abs() >
                                5
                            ? Colors.orangeAccent
                            : Colors.greenAccent,
                        Icons.compare_arrows,
                      ),

                      const SizedBox(height: 16),

                      // Recommendation
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.white.withOpacity(0.5), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isNormal
                                    ? 'Eye alignment appears normal. Regular screening recommended.'
                                    : 'Consult an ophthalmologist if values are consistently high (>8%).',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Finish button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, _finalResult),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statusColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Finish Test',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ========================
  // Shared widgets
  // ========================

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatusDot(bool isOk) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOk ? Colors.green : Colors.orange,
        boxShadow: [
          BoxShadow(
            color: (isOk ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviationGauge(String label, double value, Color color) {
    final norm = (value / 30.0).clamp(0.0, 1.0);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 11),
            ),
            const SizedBox(height: 6),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: norm,
                backgroundColor: Colors.black.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(
                  Color.lerp(Colors.green, Colors.red, norm)!,
                ),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDetailCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
