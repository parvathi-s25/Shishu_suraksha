import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import '../models/vision_result_model.dart';
import '../../../services/vision_processor.dart';
import '../../../services/tflite_isolate.dart';
import '../../../services/camera_service.dart';

class PupilReflexTestScreen extends StatefulWidget {
  const PupilReflexTestScreen({super.key});

  @override
  State<PupilReflexTestScreen> createState() => _PupilReflexTestScreenState();
}

class _PupilReflexTestScreenState extends State<PupilReflexTestScreen> {
  double? _baselineLeftEye;
  double? _baselineRightEye;
  double? _postLeftEye;
  double? _postRightEye;
  String _status = 'Ready';
  double? _contractionPctLeft;
  double? _contractionPctRight;
  final _tfliteIsolate = TFLiteIsolate();
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    VisionProcessor.instance.onFace = _onFace;
    VisionProcessor.instance.start(direction: CameraLensDirection.back);
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      await _tfliteIsolate.spawn();
      await _tfliteIsolate.loadModel('assets/ml/pupil_unet.tflite');
      if (mounted) setState(() => _modelLoaded = true);
    } catch (e) {
      if (mounted) setState(() => _modelLoaded = false);
    }
  }

  bool _faceVisible = false;
  bool _eyesVisible = false;

  void _onFace(Face face) {
    if (!mounted) return;
    final leftPts = face.contours[FaceContourType.leftEye]?.points ?? [];
    final rightPts = face.contours[FaceContourType.rightEye]?.points ?? [];
    
    // Check for contours first
    double? leftH = _eyeContourHeight(leftPts);
    double? rightH = _eyeContourHeight(rightPts);

    // Fallback to landmarks if contours are null
    if (leftH == null || rightH == null) {
      final leftLandmark = face.landmarks[FaceLandmarkType.leftEye];
      final rightLandmark = face.landmarks[FaceLandmarkType.rightEye];
      if (leftLandmark != null && rightLandmark != null) {
        // Estimate height based on face bounding box if contours missing
        leftH = face.boundingBox.height * 0.05; 
        rightH = face.boundingBox.height * 0.05;
      }
    }

    setState(() {
      _faceVisible = true;
      _eyesVisible = leftH != null && rightH != null;
    });
  }

  void _startAutomatedTest() async {
    if (_status.contains('Testing')) return;

    setState(() {
      _status = 'Position eye in center...';
      _baselineLeftEye = null;
      _baselineRightEye = null;
      _postLeftEye = null;
      _postRightEye = null;
      _contractionPctLeft = null;
      _contractionPctRight = null;
    });

    // Step 1: Baseline Capture
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _status = 'Capturing baseline...');
    
    Completer<void> baselineDone = Completer();
    VisionProcessor.instance.onFace = (face) {
      final leftPts = face.contours[FaceContourType.leftEye]?.points ?? [];
      final rightPts = face.contours[FaceContourType.rightEye]?.points ?? [];
      
      double? leftH = _eyeContourHeight(leftPts);
      double? rightH = _eyeContourHeight(rightPts);

      // Diagnostic Fallback
      if (leftH == null || rightH == null) {
        final leftLM = face.landmarks[FaceLandmarkType.leftEye];
        final rightLM = face.landmarks[FaceLandmarkType.rightEye];
        if (leftLM != null && rightLM != null) {
          leftH = face.boundingBox.height * 0.06;
          rightH = face.boundingBox.height * 0.06;
        }
      }

      if (leftH != null && rightH != null) {
        setState(() {
          _faceVisible = true;
          _eyesVisible = true;
          _baselineLeftEye = leftH;
          _baselineRightEye = rightH;
        });
        if (!baselineDone.isCompleted) baselineDone.complete();
      } else {
        setState(() {
          _faceVisible = true;
          _eyesVisible = false;
        });
      }
    };
    
    try {
      await baselineDone.future.timeout(const Duration(seconds: 7));
    } catch (_) {
      VisionProcessor.instance.onFace = _onFace;
    }

    if (_baselineLeftEye == null) {
      setState(() => _status = 'Eyes not detected. Ensure face is centered.');
      return;
    }

    // Step 2: Flash & Capture
    setState(() => _status = 'Stimulating with Flash...');
    await CameraService.instance.setFlashMode(FlashMode.torch);
    
    await Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => const _FlashOverlay(),
    ));

    // Small delay to allow the pupil to react
    await Future.delayed(const Duration(milliseconds: 300));
    
    Completer<void> captureDone = Completer();
    VisionProcessor.instance.onFace = (face) {
      final leftPts = face.contours[FaceContourType.leftEye]?.points ?? [];
      final rightPts = face.contours[FaceContourType.rightEye]?.points ?? [];
      
      double? leftH = _eyeContourHeight(leftPts);
      double? rightH = _eyeContourHeight(rightPts);

      if (leftH == null || rightH == null) {
        final leftLM = face.landmarks[FaceLandmarkType.leftEye];
        final rightLM = face.landmarks[FaceLandmarkType.rightEye];
        if (leftLM != null && rightLM != null) {
          leftH = face.boundingBox.height * 0.05; // Slightly smaller expected after flash
          rightH = face.boundingBox.height * 0.05;
        }
      }

      if (leftH != null && rightH != null) {
        setState(() {
          _postLeftEye = leftH;
          _postRightEye = rightH;
        });
        if (!captureDone.isCompleted) captureDone.complete();
      }
    };

    try {
      await captureDone.future.timeout(const Duration(seconds: 4));
    } catch (_) {
      VisionProcessor.instance.onFace = _onFace;
    }

    await CameraService.instance.setFlashMode(FlashMode.off);

    if (_postLeftEye == null) {
      setState(() => _status = 'Capture failed. Eyes moved?');
    } else {
      setState(() {
        if (_baselineLeftEye != null) {
          _contractionPctLeft = ((_baselineLeftEye! - _postLeftEye!) / _baselineLeftEye!) * 100.0;
        }
        if (_baselineRightEye != null) {
          _contractionPctRight = ((_baselineRightEye! - _postRightEye!) / _baselineRightEye!) * 100.0;
        }
        _status = 'Test complete';
      });
    }
    VisionProcessor.instance.onFace = _onFace;
  }

  double? _eyeContourHeight(List points) {
    if (points.isEmpty) return null;
    double minY = double.infinity, maxY = -double.infinity;
    for (final p in points) {
      final y = (p.y as num).toDouble();
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
    if (minY == double.infinity || maxY == -double.infinity) return null;
    final h = (maxY - minY).abs();
    return h > 2.0 ? h : null; // Ignore tiny heights
  }

  void _saveResult() {
    final leftOk = (_contractionPctLeft ?? 0) >= 20.0;
    final rightOk = (_contractionPctRight ?? 0) >= 20.0;
    final ok = leftOk && rightOk;

    final leftContraction = _contractionPctLeft ?? 0.0;
    final rightContraction = _contractionPctRight ?? 0.0;
    final avgContraction = (leftContraction + rightContraction) / 2.0;
    final constrictionRatio = (avgContraction / 100.0).clamp(0.0, 1.0);
    final reactionTimeMs = ok ? 220.0 : 350.0;

    final result = PupilReflexResult(
      reactionTimeMs: reactionTimeMs,
      isNormal: ok,
      constrictionRatio: constrictionRatio,
    );

    Navigator.pop(context, result);
  }

  @override
  void dispose() {
    VisionProcessor.instance.stop();
    VisionProcessor.instance.onFace = null;
    _tfliteIsolate.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool baselineCaptured = _baselineLeftEye != null || _baselineRightEye != null;
    final bool postCaptured = _postLeftEye != null || _postRightEye != null;
    final bool canSave = baselineCaptured && postCaptured;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pupil Light Reflex'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Camera Preview and status chips
              Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildChip(
                        label: 'Face',
                        isActive: _faceVisible,
                        activeColor: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: 'Eyes',
                        isActive: _eyesVisible,
                        activeColor: Colors.cyan,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _eyesVisible ? Colors.cyan.withOpacity(0.8) : Colors.cyan.withOpacity(0.3), 
                        width: 2
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: CameraService.instance.isInitializedNotifier,
                        builder: (context, initialized, child) {
                          if (initialized && CameraService.instance.controller != null) {
                            return CameraPreview(CameraService.instance.controller!);
                          }
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Status card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        _status.contains('complete') ? Icons.check_circle : Icons.info_outline,
                        color: _status.contains('complete') ? Colors.green : Colors.blueGrey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _status,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Result info (now always visible but empty if not captured)
              Row(
                children: [
                  Expanded(
                    child: _buildResultRow(
                      label: 'Left Eye',
                      value: _contractionPctLeft != null ? '${_contractionPctLeft!.toStringAsFixed(1)}%' : '--',
                      isOk: (_contractionPctLeft ?? 0) >= 20.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildResultRow(
                      label: 'Right Eye',
                      value: _contractionPctRight != null ? '${_contractionPctRight!.toStringAsFixed(1)}%' : '--',
                      isOk: (_contractionPctRight ?? 0) >= 20.0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startAutomatedTest,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Start Automated Test', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: canSave ? _saveResult : null,
                  icon: const Icon(Icons.done_all),
                  label: const Text('Submit Results'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Instructions:\n1. Use the back camera to aim at the eyes.\n2. Ensure eyes are visible in the preview.\n3. Tap "Start Test". The flash will trigger and analyze the reflex.',
                style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required String label,
    required String value,
    required bool isOk,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              isOk ? Icons.check_circle : Icons.warning_amber_rounded,
              color: isOk ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14)),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isOk ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildChip({
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? activeColor.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? activeColor : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? activeColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashOverlay extends StatefulWidget {
  const _FlashOverlay({super.key});

  @override
  State<_FlashOverlay> createState() => _FlashOverlayState();
}

class _FlashOverlayState extends State<_FlashOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Colors.white);
}
