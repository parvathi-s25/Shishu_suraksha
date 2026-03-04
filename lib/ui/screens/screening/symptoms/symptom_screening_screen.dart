import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SymptomScreeningScreen extends StatefulWidget {
  const SymptomScreeningScreen({super.key});

  @override
  State<SymptomScreeningScreen> createState() => _SymptomScreeningScreenState();
}

class _SymptomScreeningScreenState extends State<SymptomScreeningScreen> {
  CameraController? _controller;
  bool _isBusy = false;
  String _result = "Tap capture to analyze";
  
  // MobileNet V2 typically expects 224x224
  static const int _inputSize = 224;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    // Use back camera
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  // No local model: we'll send the captured image to a backend for analysis.

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized || _isBusy) return;
    setState(() => _isBusy = true);

    setState(() => _isBusy = true);

    try {
      final imageFile = await _controller!.takePicture();
      final result = await SymptomApi.analyzeImage(imageFile.path);
      setState(() => _result = result);
    } catch (e) {
      debugPrint("Error analyzing: $e");
      setState(() => _result = "Error: $e");
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptoms Check"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            CameraPreview(_controller!)
          else
            const Center(child: CircularProgressIndicator()),
            
          // Result Overlay
          Positioned(
            bottom: 150,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text("Analysis Result:", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: _isBusy ? null : _captureAndAnalyze,
                backgroundColor: _isBusy ? Colors.grey : Colors.teal,
                child: _isBusy
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.camera_alt, size: 40, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SymptomApi {
  // Update this to your backend address. Use 10.0.2.2 for Android emulator.
  static const String _endpoint = 'http://10.0.2.2:5000/symptoms';

  static Future<String> analyzeImage(String imagePath) async {
    final uri = Uri.parse(_endpoint);
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      try {
        final j = jsonDecode(body);
        return j['result']?.toString() ?? body;
      } catch (_) {
        return body;
      }
    }

    throw Exception('Server error: ${streamed.statusCode} $body');
  }
}
