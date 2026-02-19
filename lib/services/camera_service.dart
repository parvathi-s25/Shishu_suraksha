import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

typedef FrameCallback = void Function(CameraImage image);

class CameraService {
  CameraService._private();
  static final CameraService instance = CameraService._private();

  CameraController? _controller;
  CameraDescription? _cameraDescription;
  final ValueNotifier<bool> isInitializedNotifier = ValueNotifier<bool>(false);

  CameraController? get controller => _controller;
  bool get isInitialized => _controller != null && _controller!.value.isInitialized;

  Future<void> initCamera({
    ResolutionPreset preset = ResolutionPreset.medium,
    CameraLensDirection direction = CameraLensDirection.front,
    ImageFormatGroup? imageFormatGroup,
  }) async {
    isInitializedNotifier.value = false;
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    try {
      final cameras = await availableCameras();
      _cameraDescription = cameras.firstWhere((c) => c.lensDirection == direction, orElse: () => cameras.first);
      _controller = CameraController(
        _cameraDescription!,
        preset,
        enableAudio: false,
        imageFormatGroup: imageFormatGroup,
      );
      await _controller!.initialize();
      debugPrint('Camera initialized: ${_cameraDescription!.name}');
    } finally {
      isInitializedNotifier.value = true;
    }
  }

  FrameCallback? _currentCallback;

  Future<void> startImageStream(FrameCallback onFrame) async {
    _currentCallback = onFrame;
    
    if (_controller == null) throw StateError('Camera not initialized');
    if (!_controller!.value.isStreamingImages) {
      debugPrint('CameraService: Starting hardware image stream');
      await _controller!.startImageStream((CameraImage image) {
        if (_currentCallback != null) {
          try {
            _currentCallback!(image);
          } catch (e) {
            debugPrint('Error in frame callback: $e');
          }
        }
      });
    } else {
      debugPrint('CameraService: Hardware stream already active, switched callback.');
    }
  }

  Future<void> stopImageStream() async {
    _currentCallback = null;
    if (_controller != null && _controller!.value.isStreamingImages) {
      debugPrint('CameraService: Stopping hardware image stream');
      await _controller!.stopImageStream();
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null) return;
    await _controller!.setFlashMode(mode);
  }

  Future<void> dispose() async {
    isInitializedNotifier.value = false;
    await _controller?.dispose();
    _controller = null;
  }
}
