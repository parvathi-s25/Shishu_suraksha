import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:shishu_suraksha/core/utils/ml_kit_utils.dart'; // Reuse the utils we fixed earlier

class OCRDataEntryScreen extends StatefulWidget {
  const OCRDataEntryScreen({super.key});

  @override
  State<OCRDataEntryScreen> createState() => _OCRDataEntryScreenState();
}

class _OCRDataEntryScreenState extends State<OCRDataEntryScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessing = false;
  
  // Form Data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.nv21 
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    _nameController.dispose();
    _dobController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _scanImage() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      _extractData(recognizedText);
    } catch (e) {
      debugPrint('Error scanning text: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _extractData(RecognizedText recognizedText) {
    String text = recognizedText.text;
    
    // Simple heuristic for demo purposes
    // Real implementation would use more robust Regex
    
    String? name;
    String? dob;
    String? id;

    // Split lines and try to find keywords
    for (String line in text.split('\n')) {
      line = line.trim();
      if ((line.startsWith('Name:') || line.startsWith('Name')) && name == null) {
        name = line.replaceAll(RegExp(r'Name:?'), '').trim();
      } else if (line.contains('DOB') || line.contains('Date of Birth')) {
        // Try to find date pattern DD/MM/YYYY
        final dobMatch = RegExp(r'\d{2}/\d{2}/\d{4}').firstMatch(line);
        if (dobMatch != null) {
          dob = dobMatch.group(0);
        }
      } else if (RegExp(r'\d{4}\s\d{4}\s\d{4}').hasMatch(line)) {
        // Aadhaar pattern
        id = line.trim();
      } else if (name == null && line.length > 3 && !line.contains(RegExp(r'[0-9]'))) {
        // Possible name line if not found yet (fallback)
        // name = line; // Too risky for false positives without stricter checks
      }
    }

    setState(() {
      if (name != null) _nameController.text = name;
      if (dob != null) _dobController.text = dob;
      if (id != null) _idController.text = id;
      _showForm = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Student ID', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Camera View
          if (_isCameraInitialized)
            SizedBox.expand(
              child: CameraPreview(_controller!),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Overlay Guide
          if (!_showForm)
            Center(
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Align ID Card Here',
                      style: TextStyle(color: Colors.white, fontSize: 16, shadows: [
                        Shadow(blurRadius: 4, color: Colors.black)
                      ]),
                    ),
                  ],
                ),
              ),
            ),

          // Controls
          if (!_showForm)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.large(
                  onPressed: _isProcessing ? null : _scanImage,
                  backgroundColor: AppColors.primary,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
            ),

          // Bottom Sheet Form
          if (_showForm)
            DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Extracted Data',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _showForm = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        _buildTextField('Student Name', _nameController, Icons.person),
                        const SizedBox(height: 16),
                        _buildTextField('Date of Birth', _dobController, Icons.calendar_today),
                        const SizedBox(height: 16),
                        _buildTextField('ID Number', _idController, Icons.badge),
                        
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Save data logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Data Saved Successfully!')),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Save Profile', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => setState(() => _showForm = false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Retake Scan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
