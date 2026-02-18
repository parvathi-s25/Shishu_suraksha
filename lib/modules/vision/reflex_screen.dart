import 'package:flutter/material.dart';
import '../../services/module_status_service.dart';
import '../../services/vision_processor.dart';
import '../../services/tflite_isolate.dart';

class ReflexScreen extends StatefulWidget {
  const ReflexScreen({super.key});

  @override
  State<ReflexScreen> createState() => _ReflexScreenState();
}

class _ReflexScreenState extends State<ReflexScreen> {
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
    VisionProcessor.instance.start();
    // try to spawn isolate and load pupil segmentation model (optional)
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      await _tfliteIsolate.spawn();
      await _tfliteIsolate.loadModel('assets/ml/pupil_unet.tflite');
      setState(() => _modelLoaded = true);
    } catch (e) {
      // model not present or failed to load; we'll fall back to contour method
      setState(() => _modelLoaded = false);
    }
  }

  void _onFace(face) {
    // store latest face contours for capture steps
    // no-op here; capture handlers will read contours via VisionProcessor callback
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
    return (maxY - minY).abs();
  }

  void _captureBaseline() {
    // Use latest detection synchronously via a one-shot detector
    VisionProcessor.instance.onFace = (face) async {
      final leftPts = face.getContour(FaceContourType.leftEye)?.points ?? [];
      final rightPts = face.getContour(FaceContourType.rightEye)?.points ?? [];
      double? leftH = _eyeContourHeight(leftPts);
      double? rightH = _eyeContourHeight(rightPts);
      // If TFLite model available, attempt segmentation-run to get pupil area baseline
      if (_modelLoaded) {
        try {
          // Placeholder: prepare input vector from contour or ROI. Here we send a zeroed vector
          final input = List<double>.filled(224 * 224, 0.0);
          final out = await _tfliteIsolate.run(input);
          if (out.isNotEmpty) {
            final maskSum = out.fold<double>(0.0, (p, e) => p + (e as num).toDouble());
            leftH = maskSum; // treat maskSum as proxy area; real code maps ROI -> mask
            rightH = maskSum;
          }
        } catch (_) {
          // ignore and use contour heuristic
        }
      }

      setState(() {
        _baselineLeftEye = leftH;
        _baselineRightEye = rightH;
        _status = 'Baseline captured';
      });
      // restore onFace to default so live updates remain available
      VisionProcessor.instance.onFace = _onFace;
    };
  }

  Future<void> _flashAndCapture() async {
    setState(() => _status = 'Flashing...');
    // show a white fullscreen overlay for 300ms
    await Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => const _FlashOverlay(),
    ));

    // after flash, capture one frame similarly
    VisionProcessor.instance.onFace = (face) async {
      final leftPts = face.getContour(FaceContourType.leftEye)?.points ?? [];
      final rightPts = face.getContour(FaceContourType.rightEye)?.points ?? [];
      double? leftH = _eyeContourHeight(leftPts);
      double? rightH = _eyeContourHeight(rightPts);

      if (_modelLoaded) {
        try {
          final input = List<double>.filled(224 * 224, 0.0);
          final out = await _tfliteIsolate.run(input);
          if (out.isNotEmpty) {
            final maskSum = out.fold<double>(0.0, (p, e) => p + (e as num).toDouble());
            leftH = maskSum;
            rightH = maskSum;
          }
        } catch (_) {
          // fallback to contours
        }
      }

      setState(() {
        _postLeftEye = leftH;
        _postRightEye = rightH;
        if (_baselineLeftEye != null && _postLeftEye != null && _baselineLeftEye! > 0) {
          _contractionPctLeft = ((_baselineLeftEye! - _postLeftEye!) / _baselineLeftEye!) * 100.0;
        }
        if (_baselineRightEye != null && _postRightEye != null && _baselineRightEye! > 0) {
          _contractionPctRight = ((_baselineRightEye! - _postRightEye!) / _baselineRightEye!) * 100.0;
        }
        _status = 'Captured';
      });
      VisionProcessor.instance.onFace = _onFace;
    };
  }

  void _finish() {
    // Basic rule: contraction < 25% flagged as abnormal
    final leftOk = (_contractionPctLeft ?? 0) >= 25.0;
    final rightOk = (_contractionPctRight ?? 0) >= 25.0;
    final ok = leftOk && rightOk;
    DBService.instance.insert('vision_reflex', {
      'assessment_id': 'local',
      'left_contraction': _contractionPctLeft ?? 0.0,
      'right_contraction': _contractionPctRight ?? 0.0,
      'risk_flag': ok ? 0 : 1,
      'details': '{}',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    ModuleStatusService.instance.markCompleted('vision_reflex', true);
    ModuleStatusService.instance.markCompleted('vision', true);
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Reflex Result'), content: Text(ok ? 'Normal' : 'Abnormal'))).then((_) => Navigator.of(context).pop());
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
    return Scaffold(
      appBar: AppBar(title: const Text('Pupil Light Reflex')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text('Status: $_status'),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(onPressed: _captureBaseline, child: const Text('Capture Baseline')),
            ElevatedButton(onPressed: _flashAndCapture, child: const Text('Flash & Capture')),
          ]),
          const SizedBox(height: 12),
          if (_contractionPctLeft != null) Text('Left contraction: ${_contractionPctLeft!.toStringAsFixed(1)}%'),
          if (_contractionPctRight != null) Text('Right contraction: ${_contractionPctRight!.toStringAsFixed(1)}%'),
          const Spacer(),
          ElevatedButton(onPressed: _finish, child: const Text('Save Result'))
        ]),
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
    Future.delayed(const Duration(milliseconds: 300), () => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Colors.white);
}

