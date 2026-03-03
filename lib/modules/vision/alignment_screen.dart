import 'dart:ui' show Offset;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../services/module_status_service.dart';
import '../../services/vision_processor.dart';
import '../../services/db_service.dart';

class AlignmentScreen extends StatefulWidget {
  const AlignmentScreen({super.key});

  @override
  State<AlignmentScreen> createState() => _AlignmentScreenState();
}

class _AlignmentScreenState extends State<AlignmentScreen> {
  String _statusText = 'Waiting for face...';

  @override
  void initState() {
    super.initState();
    VisionProcessor.instance.onFace = _onFace;
    VisionProcessor.instance.start();
  }

  void _onFace(Face face) {
    try {
      final leftContour = face.contours[FaceContourType.leftEye]?.points;
      final rightContour = face.contours[FaceContourType.rightEye]?.points;
      if (leftContour == null || rightContour == null) {
        setState(() => _statusText = 'Eye contours not available');
        return;
      }

      Offset centroid(List<dynamic> pts) {
        double sx = 0, sy = 0;
        for (final p in pts) {
          sx += (p.x as num).toDouble();
          sy += (p.y as num).toDouble();
        }
        return Offset(sx / pts.length, sy / pts.length);
      }

      final l = centroid(leftContour);
      final r = centroid(rightContour);

      final interocular = (r - l).distance;
      if (interocular <= 1e-6) {
        setState(() => _statusText = 'Invalid interocular distance');
        return;
      }

      final verticalDiff = (l.dy - r.dy).abs();
      final symmetry = (verticalDiff / interocular).clamp(0.0, 1.0);
      final risk = symmetry > 0.08;

      setState(() => _statusText =
          'Vertical offset: ${verticalDiff.toStringAsFixed(1)} px — '
          'Symmetry: ${symmetry.toStringAsFixed(3)} ${risk ? '(risk)' : '(ok)'}');
    } catch (e) {
      setState(() => _statusText = 'Error computing alignment');
    }
  }

  @override
  void dispose() {
    VisionProcessor.instance.stop();
    VisionProcessor.instance.onFace = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eye Alignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_statusText),
            const SizedBox(height: 20),
            const Expanded(child: Center(child: Icon(Icons.remove_red_eye, size: 72))),
            ElevatedButton(
              onPressed: () {
                final sym = _statusText;
                DBService.instance.insert('vision_alignment', {
                  'assessment_id': 'local',
                  'symmetry': 0.0,
                  'risk_flag': sym.contains('risk') ? 1 : 0,
                  'details': sym,
                  'created_at': DateTime.now().millisecondsSinceEpoch,
                });
                ModuleStatusService.instance.markCompleted('vision_alignment', true);
                ModuleStatusService.instance.markCompleted('vision', true);
                Navigator.of(context).pop();
              },
              child: const Text('Complete Alignment Test'),
            )
          ],
        ),
      ),
    );
  }
}
