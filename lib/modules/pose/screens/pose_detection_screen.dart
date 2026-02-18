import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shishu_suraksha/modules/vision/widgets/vision_camera_view.dart';

import '../services/pose_analysis_service.dart';
import '../../../ui/widgets/ai/pose_painter.dart';

class PoseDetectionScreen extends StatefulWidget {
  const PoseDetectionScreen({super.key});

  @override
  State<PoseDetectionScreen> createState() => _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends State<PoseDetectionScreen> {
  final PoseAnalysisService _service = PoseAnalysisService();
  bool _isProcessing = false;
  CustomPaint? _customPaint;
  String? _text;
  PoseAnalysisResult? _videoResult;
  bool _modeGallery = false; // Toggle between Camera/Gallery mode UI logic if needed
  
  // Gallery Logic
  File? _imageFile;

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  void _processImage(InputImage inputImage) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final result = await _service.analyzeImage(inputImage);
    
    if (mounted && result != null) {
      setState(() {
        _videoResult = result;
        _text = "Score: ${result.postureScore.toStringAsFixed(0)}\n${result.issues.join(', ')}";
        
        // Ensure to pass rotation/size correctly. 
        // VisionCameraView handles the image stream.
        // But for Painting on CameraPreview, we need valid geometric data.
        // The VisionCameraView (reused) might need update to accept a Painter builder or we pass the paint directly.
        // Our reused widget takes `customPaint`.
        
        final painter = PosePainter(
          result.poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          CameraLensDirection.back, // Assuming back camera
          color: result.isGoodPosture ? Colors.green : Colors.red,
        );
        _customPaint = CustomPaint(painter: painter);
      });
    }
    
    _isProcessing = false;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
       setState(() {
          _imageFile = File(pickedFile.path);
          _modeGallery = true;
          _customPaint = null;
          _text = "Analyzing...";
       });
       _analyzeStaticImage(_imageFile!);
    }
  }

  Future<void> _analyzeStaticImage(File file) async {
     final inputImage = InputImage.fromFilePath(file.path);
     final result = await _service.analyzeImage(inputImage);
     
     if (mounted && result != null) {
        // Need image dimensions for painter.
        // Decode image to get size?
        var decodedImage = await decodeImageFromList(file.readAsBytesSync());
        
        setState(() {
           _text = "Score: ${result.postureScore.toStringAsFixed(0)}\n${result.issues.join('\n')}";
           
           final painter = PosePainter(
              result.poses,
              Size(decodedImage.width.toDouble(), decodedImage.height.toDouble()),
              InputImageRotation.rotation0deg, // Static image usually 0
              CameraLensDirection.back,
              color: result.isGoodPosture ? Colors.green : Colors.red,
           );
           _customPaint = CustomPaint(painter: painter);
        });
     }
  }

  @override
  Widget build(BuildContext context) {
    if (_modeGallery && _imageFile != null) {
       return Scaffold(
          appBar: AppBar(
             title: const Text('Pose Analysis (Gallery)'),
             leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _modeGallery = false),
             ),
          ),
          body: Column(
             children: [
                Expanded(
                   child: Container(
                      color: Colors.black,
                      child: Center(
                         child: LayoutBuilder(
                            builder: (ctx, constraints) {
                               return Stack(
                                  children: [
                                     Image.file(_imageFile!, fit: BoxFit.contain),
                                     if (_customPaint != null)
                                        _customPaint!, // This might need scaling to fit the RenderBox of Image
                                  ],
                               );
                            }
                         ),
                      ),
                   ),
                ),
                _buildResultPanel(),
             ],
          ),
       );
    }
  
    return Scaffold(
      body: Stack(
        children: [
          VisionCameraView(
            title: 'Pose Detection',
            onImage: _processImage,
            customPaint: _customPaint,
            initialDirection: CameraLensDirection.back,
            text: _text,
          ),
          Positioned(
             bottom: 20,
             left: 20,
             child: FloatingActionButton(
                heroTag: 'gallery_btn',
                onPressed: _pickImage,
                child: const Icon(Icons.photo_library),
             ),
          ),
          if (_videoResult != null)
             Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton.extended(
                   heroTag: 'save_btn',
                   onPressed: () {
                      Navigator.pop(context, _videoResult);
                   },
                   label: const Text("Save & Next"),
                   icon: const Icon(Icons.check),
                   backgroundColor: Colors.green,
                ),
             ),
          if (_videoResult != null)
             Positioned(
                top: 100,
                right: 20,
                child: Container(
                   padding: const EdgeInsets.all(8),
                   color: Colors.black54,
                   child: Column(
                      children: [
                         Text(
                            "${_videoResult!.postureScore.toStringAsFixed(0)}",
                            style: TextStyle(
                               fontSize: 32, 
                               fontWeight: FontWeight.bold,
                               color: _videoResult!.isGoodPosture ? Colors.green : Colors.red
                            ),
                         ),
                         const Text("Score", style: TextStyle(color: Colors.white)),
                      ],
                   ),
                ),
             )
        ],
      ),
    );
  }
  
  Widget _buildResultPanel() {
     return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Text("Result:", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(_text ?? "No result"),
              if (_videoResult != null)
                 Padding(
                   padding: const EdgeInsets.only(top: 16.0),
                   child: SizedBox(
                     width: double.infinity,
                     child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, _videoResult),
                        icon: const Icon(Icons.check),
                        label: const Text("Save Result"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                     ),
                   ),
                 )
           ],
        ),
     );
  }
}
