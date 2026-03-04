import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart'; // Or use relevant package export

class CameraUtils {
  static InputImage? inputImageFromCameraImage(
      CameraImage image,
      CameraDescription camera,
      DeviceOrientation orientation,
  ) {
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[orientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
        // For MVP we ignore other formats or handle them gracefully
        // return null; 
    }

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // Compose InputImage (using latest API structure)
    /*
      Since ML Kit API changes often, this is the safest structure for current versions:
      InputImage.fromBytes(bytes: ..., metadata: InputImageMetadata(...))
    */
    
    // We'll stick to a simpler implementation that relies on the caller providing rotation 
    // or just return null if we can't determine it perfectly.
    // For now let's just create a basic metadata object.
    
    // NOTE: This file is a placeholder for the logic.
    // The actual robust implementation requires Context or specialized logic 
    // to determine DeviceOrientation. 
    return null; 
  }

  static final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  
  // Helper just to get rotation int
  static int getRotationCompensation(
      CameraDescription camera, DeviceOrientation orientation) {
    var rotationCompensation = _orientations[orientation];
    if (rotationCompensation == null) return 0;
    if (camera.lensDirection == CameraLensDirection.front) {
      // front-facing
      rotationCompensation = (camera.sensorOrientation + rotationCompensation) % 360;
    } else {
      // back-facing
      rotationCompensation =
          (camera.sensorOrientation - rotationCompensation + 360) % 360;
    }
    return rotationCompensation;
  }
}
