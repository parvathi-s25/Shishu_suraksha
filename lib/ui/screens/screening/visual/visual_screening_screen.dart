import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shishu_suraksha/core/utils/ml_kit_utils.dart';
import 'package:shishu_suraksha/ui/screens/screening/visual/pose_painter.dart';

class VisualScreeningScreen extends StatefulWidget {
  const VisualScreeningScreen({super.key});

  @override
  State<VisualScreeningScreen> createState() => _VisualScreeningScreenState();
}

class _VisualScreeningScreenState extends State<VisualScreeningScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInit = false;
  int _selectedCameraIndex = 0;
  
  // ML Kit
  final _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _isBusy = false;
  CustomPainter? _customPaint;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) return;

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      _controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.medium, // Lower resolution for faster processing
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid 
            ? ImageFormatGroup.nv21 // Android standard
            : ImageFormatGroup.bgra8888, // iOS standard
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isInit = true;
      });

      _startImageStream();
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  void _startImageStream() {
    _controller?.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final camera = _cameras[_selectedCameraIndex];
      final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;

      final inputImage = MLKitUtils.convertCameraImage(image, camera, rotation);
      if (inputImage == null) return;

      final poses = await _poseDetector.processImage(inputImage);

      if (mounted) {
        setState(() {
          final size = Size(
            image.width.toDouble(),
            image.height.toDouble(),
          );
          _customPaint = PosePainter(poses, size, rotation);
        });
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isBusy = false;
    }
  }

  void _toggleCamera() {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _onCameraSwitched();
  }

  Future<void> _onCameraSwitched() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _customPaint = null;
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit || _controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(_controller!),
          
          // Overlay
          // Fixed: Wrap in CustomPaint
          if (_customPaint != null) CustomPaint(painter: _customPaint),

          // Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'switch',
                  onPressed: _toggleCamera,
                  backgroundColor: Colors.white24,
                  child: const Icon(Icons.cameraswitch, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: 'capture',
                  onPressed: () {
                    // TODO: Capture Logic
                  },
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.camera, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 56), // Placeholder for symmetry
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
