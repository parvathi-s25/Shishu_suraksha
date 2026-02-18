import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:shishu_suraksha/modules/vision/widgets/vision_camera_view.dart';
import '../services/strabismus_service.dart';
import '../models/vision_result_model.dart';
import 'package:camera/camera.dart';

class StrabismusTestScreen extends StatefulWidget {
  const StrabismusTestScreen({super.key});

  @override
  State<StrabismusTestScreen> createState() => _StrabismusTestScreenState();
}

class _StrabismusTestScreenState extends State<StrabismusTestScreen> {
  final StrabismusService _service = StrabismusService();
  bool _isAnalyzing = false;
  StrabismusResult? _currentResult;
  List<StrabismusResult> _resultsBuffer = [];
  bool _testComplete = false;

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  void _processImage(InputImage inputImage) async {
    if (_isAnalyzing || _testComplete) return;
    _isAnalyzing = true;

    final result = await _service.analyzeImage(inputImage);
    if (mounted && result != null) {
      setState(() {
        _currentResult = result;
        
        if (result.isHeadPositionCorrect) {
            _resultsBuffer.add(result);
            if (_resultsBuffer.length > 20) {
               _finalizeTest();
            }
        }
      });
    }

    _isAnalyzing = false;
  }
  void _finalizeTest() {
    _testComplete = true;
    double avgLeft = _resultsBuffer.map((e) => e.leftEyeDeviation).reduce((a, b) => a + b) / _resultsBuffer.length;
    double avgRight = _resultsBuffer.map((e) => e.rightEyeDeviation).reduce((a, b) => a + b) / _resultsBuffer.length;
    
    // Heuristic Diagnosis
    String diagnosis = "Normal Alignment";
    Color color = Colors.green;
    
    if (avgLeft > 8 || avgRight > 8 || (avgLeft - avgRight).abs() > 5) {
       diagnosis = "Potential Strabismus Detected";
       color = Colors.orange;
    }
    
    _showResultDialog(diagnosis, color, avgLeft, avgRight);
  }

  void _showResultDialog(String title, Color color, double valL, double valR) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text("Left Eye Deviation: ${valL.toStringAsFixed(1)}°"),
             Text("Right Eye Deviation: ${valR.toStringAsFixed(1)}°"),
             const SizedBox(height: 10),
             const Text("Consult an ophthalmologist if values are consistently high (>8°)."),
          ],
        ),
        actions: [
          TextButton(
             onPressed: () {
                final result = StrabismusResult(
                   leftEyeDeviation: valL,
                   rightEyeDeviation: valR,
                   isAbnormal: (valL > 8 || valR > 8),
                   headTilt: 0, // Simplified
                   headTurnRatio: 1,
                   isHeadPositionCorrect: true,
                );
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context, result); // Return result
             },
             child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strabismus Check')),
      body: Stack(
        children: [
          VisionCameraView(
            title: 'Eye Alignment',
            initialDirection: CameraLensDirection.front,
            onImage: _processImage,
          ),
          
          // Head Position Warning
          if (_currentResult != null && !_currentResult!.isHeadPositionCorrect)
             Positioned.fill(
                child: Center(
                   child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                         color: Colors.red.withOpacity(0.8),
                         borderRadius: BorderRadius.circular(16)
                      ),
                      child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                            const Icon(Icons.rotate_right, color: Colors.white, size: 60),
                            const SizedBox(height: 16),
                            const Text(
                               "Straighten Head!",
                               style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                            ),
                            Text(
                               (_currentResult!.headTilt.abs() > 8) ? "Reduce Tilt" : "Look Straight Ahead",
                               style: const TextStyle(color: Colors.white, fontSize: 16)
                            )
                         ],
                      ),
                   ),
                ),
             ),
             
          // Progress & Result
          if (_currentResult != null && _currentResult!.isHeadPositionCorrect)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.white.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Scanning...', style: TextStyle(fontWeight: FontWeight.bold)),
                      LinearProgressIndicator(value: _resultsBuffer.length / 20.0),
                      Text("L: ${_currentResult!.leftEyeDeviation.toStringAsFixed(1)}°  R: ${_currentResult!.rightEyeDeviation.toStringAsFixed(1)}°"),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
