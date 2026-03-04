// Frame processor - throttles camera frames and coordinates all detections
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FrameProcessor {
  final PoseDetector poseDetector;
  final FaceDetector faceDetector;
  
  int _frameCount = 0;
  final int _throttleFrames; // Process every N frames (e.g., 5 = ~10 FPS on 30 FPS camera)

  FrameProcessor({
    required this.poseDetector,
    required this.faceDetector,
    int throttleFrames = 3, // ~10 FPS on 30 FPS camera
  }) : _throttleFrames = throttleFrames;

  /// Check if we should process this frame
  bool shouldProcessFrame() {
    _frameCount++;
    return _frameCount % _throttleFrames == 0;
  }

  /// Convert CameraImage to InputImage for ML Kit
  Future<InputImage> convertToInputImage(CameraImage image) async {
    final rotation = InputImageRotation.rotation0deg; // Adjust based on camera orientation

    final format = InputImageFormat.nv21;
    final plane = image.planes.cast<Plane>();

    return InputImage.fromBytes(
      bytes: plane[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane[0].bytesPerRow,
      ),
    );
  }

  /// Process frame for pose detection
  Future<List<Pose>> processPose(InputImage inputImage) async {
    try {
      final poses = await poseDetector.processImage(inputImage);
      return poses;
    } catch (e) {
      print('Pose detection error: $e');
      return [];
    }
  }

  /// Process frame for face detection
  Future<List<Face>> processFace(InputImage inputImage) async {
    try {
      final faces = await faceDetector.processImage(inputImage);
      return faces;
    } catch (e) {
      print('Face detection error: $e');
      return [];
    }
  }

  /// Extract brightness from image bytes
  Future<double> extractBrightness(CameraImage image) async {
    // Convert Y channel to brightness
    final yPlane = image.planes[0];
    int brightness = 0;
    int count = 0;

    for (int i = 0; i < yPlane.bytes.length; i++) {
      brightness += yPlane.bytes[i];
      count++;
    }

    return brightness / count;
  }

  /// Crop eye region from image
  List<int> cropEyeRegion(
    List<int> imageBytes,
    int imageWidth,
    int imageHeight,
    double eyeX,
    double eyeY,
    int regionSize,
  ) {
    final cropped = <int>[];
    final startX = (eyeX - regionSize / 2).round().clamp(0, imageWidth - 1);
    final startY = (eyeY - regionSize / 2).round().clamp(0, imageHeight - 1);
    final endX = (startX + regionSize).clamp(0, imageWidth);
    final endY = (startY + regionSize).clamp(0, imageHeight);

    for (int y = startY; y < endY; y++) {
      for (int x = startX; x < endX; x++) {
        final index = (y * imageWidth) + x;
        if (index < imageBytes.length) {
          cropped.add(imageBytes[index]);
        }
      }
    }
    return cropped;
  }

  void dispose() {
    poseDetector.close();
    faceDetector.close();
  }
}
