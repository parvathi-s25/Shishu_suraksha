import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/pose_analyzer.dart';
import '../../../widgets/ai/pose_painter.dart';

class VisualScreeningScreen extends StatefulWidget {
  const VisualScreeningScreen({super.key});

  @override
  State<VisualScreeningScreen> createState() => _VisualScreeningScreenState();
}

class _VisualScreeningScreenState extends State<VisualScreeningScreen> {
  CameraController? _controller;
  bool _isBusy = false;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  final PoseAnalyzer _poseAnalyzer = PoseAnalyzer();
  CustomPaint? _customPaint;
  List<String> _currentWarnings = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use front camera by default if available
    var camera = cameras.first;
    for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == CameraLensDirection.front) {
            camera = cameras[i];
            break;
        }
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // Required for Android
          : ImageFormatGroup.bgra8888, // Required for iOS
    );

    await _controller!.initialize();
    _controller!.startImageStream(_processCameraImage);
    if (mounted) setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isBusy = false;
      return;
    }

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        
        // Analyze poses
        List<String> newWarnings = [];
        if (poses.isNotEmpty) {
           newWarnings = _poseAnalyzer.analyze(poses.first);
        }

        final painter = PosePainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _controller!.description.lensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
        _currentWarnings = newWarnings;
      } else {
        _customPaint = null;
        _currentWarnings = [];
      }
    } catch (e) {
      debugPrint('Error processing pose: $e');
    }

    _isBusy = false;
    if (mounted) setState(() {});
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;
    
    // Calculate rotation compensation
    var rotation = InputImageRotation.rotation0deg;
    if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation != null) {
        if (camera.lensDirection == CameraLensDirection.front) {
          // front-facing
          rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
        } else {
          // back-facing
          rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
        }
        rotation = _rotationIntToImageRotation(rotationCompensation);
      }
    }

    // Handle format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    
    // Validating format for platform
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.isEmpty) { return null; }

    // Concatenate planes into a single buffer (Android NV21 requires combined planes)
    final writeBuffer = WriteBuffer();
    for (final plane in image.planes) {
      writeBuffer.putUint8List(plane.bytes);
    }
    final bytes = writeBuffer.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  static final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pose Estimation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
         iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (_customPaint != null) _customPaint!,
          
          // Warning Overlay
          if (_currentWarnings.isNotEmpty)
            Positioned(
              top: 100,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _currentWarnings.map((warning) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(204), // 0.8 opacity
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    warning,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                )).toList(),
              ),
            ),

          Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                  child: FloatingActionButton(
                    onPressed: () {
                         // Logic to capture or move on
                         Navigator.pop(context);
                    },
                    backgroundColor: Colors.white, 
                    child: const Icon(Icons.camera_alt, color: Colors.teal),
                  ),
              ),
          )
        ],
      ),
    );
  }
}
