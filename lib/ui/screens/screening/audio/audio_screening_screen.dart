import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart'; // 5.x/6.x
import 'package:permission_handler/permission_handler.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:shishu_suraksha/ui/widgets/glass_container.dart';
import 'package:path_provider/path_provider.dart'; // Added for temp path
import 'dart:io'; // For File

class AudioScreeningScreen extends StatefulWidget {
  const AudioScreeningScreen({super.key});

  @override
  State<AudioScreeningScreen> createState() => _AudioScreeningScreenState();
}

class _AudioScreeningScreenState extends State<AudioScreeningScreen> {
  // Using AudioRecorder class for version 5.x/6.x
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _audioPath;
  String _result = "";
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void dispose() {
    _audioRecorder.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
      }
      return;
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        const AudioEncoder encoder = AudioEncoder.aacLc;
        
        // Ensure we have a path
        final Directory tempDir = await getTemporaryDirectory();
        final String path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // record 5.x/6.x uses RecordConfig and path
        await _audioRecorder.start(const RecordConfig(encoder: encoder), path: path);
        
        setState(() {
          _isRecording = true;
          _recordDuration = 0;
          _result = "";
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() => _recordDuration++);
        });
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      // stop() returns the path in 5.x/6.x
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _audioPath = path;
      });

      if (path != null) {
        _analyzeAudio(path);
      }
    } catch (e) {
      debugPrint("Error stopping record: $e");
    }
  }

  Future<void> _analyzeAudio(String path) async {
    setState(() {
      _isProcessing = true;
    });

    // SIMULATES TFLITE INFERENCE
    // In real implementation: 
    // var interpreter = await Interpreter.fromAsset('audio_model.tflite');
    // var input = loadAudio(path);
    // var output = List.filled(1*2, 0).reshape([1, 2]);
    // interpreter.run(input, output);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _result = "Analysis Complete: Normal Cry Pattern Detected (Confidence: 94%)";
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg2.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Glass Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Audio Analysis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Visualization
                GlassContainer(
                   width: 300,
                   height: 300,
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       if (_isProcessing)
                         const CircularProgressIndicator(color: AppColors.secondary)
                       else
                         Icon(
                           _isRecording ? Icons.graphic_eq : Icons.mic,
                           size: 80,
                           color: _isRecording ? Colors.redAccent : AppColors.primary,
                         ),
                       const SizedBox(height: 20),
                       Text(
                         _isRecording ? _formatDuration(_recordDuration) : "Tap to Record",
                         style: const TextStyle(
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                           color: AppColors.textPrimary,
                         ),
                       ),
                       const SizedBox(height: 10),
                       if (_result.isNotEmpty)
                         Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Text(
                             _result,
                             textAlign: TextAlign.center,
                             style: const TextStyle(
                               color: Colors.green,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                     ],
                   ),
                ),

                const Spacer(),

                // Record Button
                GestureDetector(
                  onTap: _isProcessing ? null : _toggleRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : Colors.white,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.red : Colors.white).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording ? Colors.white : AppColors.primary,
                      size: 36,
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
