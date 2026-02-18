import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

typedef FrameCallback = void Function(CameraImage image);

class CameraService {
  CameraService._private();
  static final CameraService instance = CameraService._private();

  CameraController? _controller;
  CameraDescription? _cameraDescription;

  bool get isInitialized => _controller != null && _controller!.value.isInitialized;

  Future<void> initCamera({ResolutionPreset preset = ResolutionPreset.medium, CameraLensDirection direction = CameraLensDirection.front}) async {
    final cameras = await availableCameras();
    _cameraDescription = cameras.firstWhere((c) => c.lensDirection == direction, orElse: () => cameras.first);
    _controller = CameraController(_cameraDescription!, preset, enableAudio: false);
    await _controller!.initialize();
    debugPrint('Camera initialized: ${_cameraDescription!.name}');
  }

  Future<void> startImageStream(FrameCallback onFrame) async {
    if (_controller == null) throw StateError('Camera not initialized');
    if (!_controller!.value.isStreamingImages) {
      await _controller!.startImageStream((CameraImage image) {
        // Do lightweight work on UI thread and delegate heavy tasks to isolates as needed.
        try {
          onFrame(image);
        } catch (e) {
          debugPrint('Error in frame callback: $e');
        }
      });
    }
  }

  Future<void> stopImageStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
