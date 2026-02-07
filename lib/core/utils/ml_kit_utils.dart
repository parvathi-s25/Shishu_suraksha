import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';

class MLKitUtils {
  static InputImage? convertCameraImage(CameraImage image, CameraDescription camera, InputImageRotation rotation) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final InputImageFormat inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImageMetadata(
          bytesPerRow: plane.bytesPerRow,
          // Fixed: Handle potential null values for width/height
          size: Size(
            (plane.width ?? 0).toDouble(), 
            (plane.height ?? 0).toDouble()
          ),
          format: inputImageFormat,
          rotation: rotation,
        );
      },
    ).toList();
    
    // We are simplifying here for the sake of the prompt "build the dashboard".
    // In a full prod app we need robust NV21/YUV conversion.
    // However, ML Kit's InputImage.fromBytes is the standard way.

    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageData,
    );
  }

  static InputImageRotation rotationIntToImageRotation(int rotation) {
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
}
