import 'package:flutter/foundation.dart';

/// Web stub for TFLiteService. TFLite is not supported on web.
class TFLiteService {
  TFLiteService._private();
  static final TFLiteService instance = TFLiteService._private();

  bool get isLoaded => false;

  Future<void> loadModel(String assetName, {int? threads}) async {
    debugPrint('TFLite is not supported on this platform.');
  }

  dynamic run(List<dynamic> input) {
    throw UnsupportedError('TFLite is not supported on web.');
  }

  Future<dynamic> runInBackground(List<dynamic> input) async {
    throw UnsupportedError('TFLite is not supported on web.');
  }

  void dispose() {}
}
