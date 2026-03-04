import 'dart:ui';

/// Compute symmetry metric between left and right eye centroids.
/// Returns normalized absolute difference divided by interocular distance.
double computeEyeSymmetry(Offset leftCentroid, Offset rightCentroid) {
  final interocular = (rightCentroid - leftCentroid).distance;
  if (interocular <= 1e-6) return 1.0; // maximal asymmetry when distance is invalid
  final dx = (leftCentroid.dx - rightCentroid.dx).abs();
  final value = dx / interocular;
  // Clamp to sensible range [0,1]
  return value.isFinite ? value.clamp(0.0, 1.0) : 1.0;
}

/// Compute face box height ratio to image height.
double computeFaceRatio(double faceBoxHeight, double imageHeight) {
  if (imageHeight <= 0) return 0.0;
  return faceBoxHeight / imageHeight;
}
