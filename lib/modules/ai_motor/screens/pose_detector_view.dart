
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../ui/widgets/ai/camera_view.dart';
import '../../../../ui/widgets/ai/pose_painter.dart';
import '../../ai_motor/services/motor_assessment_service.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({Key? key}) : super(key: key);

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  final MotorAssessmentService _assessmentService = MotorAssessmentService();
  Map<String, dynamic> _lastAnalysis = {};

  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraView(
          title: 'Motor Assessment',
          customPaint: _customPaint,
          text: _text,
          onImage: (inputImage) {
            processImage(inputImage);
          },
          initialDirection: CameraLensDirection.back,
        ),
        Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: _buildAnalysisCard(),
        )
      ],
    );
  }

  Widget _buildAnalysisCard() {
    if (_lastAnalysis.isEmpty) return const SizedBox();

    Color statusColor = Colors.green;
    if (_lastAnalysis['status'] != 'Normal') statusColor = Colors.orange;
    if (_lastAnalysis['status'] == 'Incomplete') statusColor = Colors.grey;

    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Status: ${_lastAnalysis['status']}",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 18,
                color: statusColor
              ),
            ),
            const SizedBox(height: 8),
            if (_lastAnalysis['issues'] != null && (_lastAnalysis['issues'] as List).isNotEmpty)
              ...(_lastAnalysis['issues'] as List).map((e) => Text(
                "• $e",
                style: const TextStyle(color: Colors.red),
              ))
            else if (_lastAnalysis['status'] == 'Normal')
              const Text("No obvious motor delays detected in this frame.")
          ],
        ),
      ),
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    
    try {
      final poses = await _poseDetector.processImage(inputImage);
      
      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = PosePainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          CameraLensDirection.back, // Assuming back for motor assessment
        );
        _customPaint = CustomPaint(painter: painter);
        
        // Analyze first pose
        if (poses.isNotEmpty) {
           _lastAnalysis = _assessmentService.analyzePose(poses.first);
        } else {
           _lastAnalysis = {};
        }

      } else {
        _text = 'Poses found: ${poses.length}\n\nMode: Static';
        _customPaint = null;
      }
    } catch (e) {
      _text = 'Error: $e';
    }
    
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

