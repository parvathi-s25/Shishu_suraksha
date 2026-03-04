import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Lightweight TFLite service to load interpreters and run inference.
/// Only included on native (FFI-capable) platforms.
class TFLiteService {
  TFLiteService._private();
  static final TFLiteService instance = TFLiteService._private();

  Interpreter? _interpreter;
  List<int>? _inputShape;
  List<int>? _outputShape;

  bool get isLoaded => _interpreter != null;

  Future<void> loadModel(String assetName, {int? threads}) async {
    try {
      final opts = InterpreterOptions();
      if (threads != null) opts.threads = threads;
      _interpreter = await Interpreter.fromAsset(assetName, options: opts);
      _inputShape = _interpreter!.getInputTensor(0).shape;
      _outputShape = _interpreter!.getOutputTensor(0).shape;
      debugPrint('TFLite model loaded: $assetName');
    } catch (e) {
      debugPrint('Failed to load model $assetName: $e');
      rethrow;
    }
  }

  dynamic run(List<dynamic> input) {
    if (_interpreter == null) throw StateError('Interpreter not loaded');
    final outputSize = _outputShape?.reduce((a, b) => a * b) ?? 1;
    final output = List.filled(outputSize, 0.0);
    _interpreter!.run(input, output);
    return output;
  }

  Future<dynamic> runInBackground(List<dynamic> input) async {
    if (_interpreter == null) throw StateError('Interpreter not loaded');
    final prepared = await compute(_noopPrepare, input);
    return run(prepared as List<dynamic>);
  }

  static List<dynamic> _noopPrepare(List<dynamic> input) => input;

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
