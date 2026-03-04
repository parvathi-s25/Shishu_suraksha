/// Web stub for TFLiteIsolate. Dart Isolates with FFI are not supported on web.
class TFLiteIsolate {
  Future<void> spawn() async {}
  Future<void> loadModel(String assetPath) async {}
  Future<List<double>> run(List<double> input) async => [];
  void kill() {}
}
