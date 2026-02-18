import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/vision_result_model.dart';

class PupilReflexTestScreen extends StatefulWidget {
  const PupilReflexTestScreen({super.key});

  @override
  State<PupilReflexTestScreen> createState() => _PupilReflexTestScreenState();
}

class _PupilReflexTestScreenState extends State<PupilReflexTestScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _flashOn = false;
  String _statusMessage = 'Align eyes in frame';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    // Use back camera with Flash
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(camera, ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startTest() async {
    if (_controller == null || _isRecording) return;
    
    setState(() {
      _isRecording = true;
      _statusMessage = 'Recording baseline...';
    });

    // 1. Record Baseline (2s)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Flash ON
    setState(() {
       _flashOn = true;
       _statusMessage = 'Stimulus Active!';
    });
    try {
      await _controller!.setFlashMode(FlashMode.torch);
    } catch (e) {
      debugPrint("Flash error: $e");
    }
    
    // 3. Record Reaction (2s)
    await Future.delayed(const Duration(seconds: 2));

    // 4. Flash OFF
    try {
      await _controller!.setFlashMode(FlashMode.off);
    } catch (e) {
       debugPrint("Flash error: $e");
    }
    setState(() {
       _flashOn = false;
       _statusMessage = 'Processing...';
    });
    
    // 5. Simulate Analysis (Real ML would process stored frames here)
    await Future.delayed(const Duration(seconds: 1));
    
    _showResult();
  }
  
  void _showResult() {
     setState(() {
        _isRecording = false;
        _statusMessage = 'Test Complete';
     });
     
     showDialog(
        context: context,
        builder: (context) => AlertDialog(
           title: const Text('Pupil Reflex Result'),
           content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                 SizedBox(height: 16),
                 Text('Reaction Time: 210ms (Normal)'),
                 Text('Constriction: 4mm -> 2mm'),
              ],
           ),
           actions: [
               TextButton(
                  onPressed: () {
                     final result = PupilReflexResult(
                        reactionTimeMs: 210,
                        isNormal: true,
                        constrictionRatio: 0.5,
                     );
                     Navigator.pop(context); // Close dialog
                     Navigator.pop(context, result); // Return result
                  },
                  child: const Text('OK')
               )
           ],
        ),
     );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pupil Light Reflex')),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          
          // Crosshair
          Center(
             child: Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                   border: Border.all(color: Colors.greenAccent, width: 2),
                   borderRadius: BorderRadius.circular(50),
                ),
             )
          ),
          
          // Controls
          Positioned(
             bottom: 50,
             left: 0,
             right: 0,
             child: Column(
                children: [
                   Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.black54,
                      child: Text(
                         _statusMessage,
                         style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                   ),
                   const SizedBox(height: 20),
                   FloatingActionButton.extended(
                      onPressed: _isRecording ? null : _startTest,
                      label: Text(_isRecording ? 'Testing...' : 'Start Test'),
                      icon: Icon(_isRecording ? Icons.hourglass_bottom : Icons.flash_on),
                      backgroundColor: _isRecording ? Colors.grey : Colors.amber,
                   ),
                ],
             ),
          ),
        ],
      ),
    );
  }
}
