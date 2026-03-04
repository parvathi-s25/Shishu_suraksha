class FlutterVision {
  FlutterVision();

  Future<void> loadYoloModel({required String labels, required String modelPath, String? modelVersion, int? numThreads, bool? useGpu}) async {
    // no-op stub for build; returns immediately
    return;
  }

  Future<List<Map<String, dynamic>>> yoloOnFrame({required List<List<int>> bytesList, required int imageHeight, required int imageWidth, double? iouThreshold, double? confThreshold, double? classThreshold}) async {
    // Return empty results so UI behaves safely when model isn't available.
    return <Map<String, dynamic>>[];
  }

  void closeYoloModel() {}
}

// Backwards-compatible export
class FlutterVisionResult {
  // placeholder
}
