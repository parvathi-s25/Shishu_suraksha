import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'camera_service.dart';

class VisionProcessor {
  VisionProcessor._private();
  static final VisionProcessor instance = VisionProcessor._private();

  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  Timer? _throttleTimer;
  bool _running = false;

  /// Callbacks to receive computed values
  void Function(bool distanceOk)? onDistance;
  void Function(bool attentionOk)? onAttention;
  void Function(Face face)? onFace;

  Future<void> start() async {
    if (_running) return;
    _running = true;
    await CameraService.instance.initCamera(preset: ResolutionPreset.low, direction: CameraLensDirection.front);
    await CameraService.instance.startImageStream(_processFrame);
  }

  Future<void> stop() async {
    _running = false;
    await CameraService.instance.stopImageStream();
  }

  void _processFrame(CameraImage image) {
    // throttle heavy processing to ~2 Hz
    if (_throttleTimer?.isActive ?? false) return;
    _throttleTimer = Timer(const Duration(milliseconds: 500), () {});

    try {
      final inputImage = _convertCameraImage(image);
      _detector.processImage(inputImage).then((faces) {
        if (faces.isEmpty) {
          onDistance?.call(false);
          onAttention?.call(false);
          return;
        }
        final face = faces.first;
        final box = face.boundingBox;
        // compute face box ratio relative to image
        final imageHeight = inputImage.metadata?.size.height ?? 0.0;
        final faceRatio = (imageHeight > 0) ? (box.height / imageHeight) : 0.0;

        // Heuristic: tune per device. Here we assume ~3m corresponds to faceRatio ~0.22
        final distanceOk = faceRatio >= 0.18 && faceRatio <= 0.30;

        // Attention: use headEulerAngleY / X as a proxy for gaze
        final yaw = face.headEulerAngleY ?? 0.0; // yaw in degrees
        final pitch = face.headEulerAngleX ?? 0.0;
        final attentionOk = yaw.abs() <= 15 && pitch.abs() <= 15;

        onDistance?.call(distanceOk);
        onAttention?.call(attentionOk);
        onFace?.call(face);
      }).catchError((e) {
        debugPrint('Face processing error: $e');
      });
    } catch (e) {
      debugPrint('VisionProcessor convert error: $e');
    }
  }

  InputImage _convertCameraImage(CameraImage image) {
    // Concatenate planes into a single NV21 / YUV byte buffer
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final size = Size(image.width.toDouble(), image.height.toDouble());

    final planeData = image.planes.map((plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    }).toList();

    final rotation = InputImageRotation.rotation90deg; // Adjusted for upright mobile
    final format = InputImageFormatMethods.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    final metadata = InputImageMetadata(
      size: size,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  void dispose() {
    _detector.close();
    _throttleTimer?.cancel();
  }
}
