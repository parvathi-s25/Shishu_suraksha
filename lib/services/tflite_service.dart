import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Lightweight TFLite service to load interpreters and run inference.
/// This is a scaffold: adjust tensor handling to your model shapes.
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

  /// Run inference synchronously on the current interpreter.
  /// `input` should be shaped according to the model expectation.
  /// Returns raw output as List or Typed Data depending on model.
  dynamic run(List<dynamic> input) {
    if (_interpreter == null) throw StateError('Interpreter not loaded');
    final outputSize = _outputShape?.reduce((a, b) => a * b) ?? 1;
    final output = List.filled(outputSize, 0.0);
    _interpreter!.run(input, output);
    return output;
  }

  /// Run inference in background using `compute`.
  Future<dynamic> runInBackground(List<dynamic> input) async {
    if (_interpreter == null) throw StateError('Interpreter not loaded');
    // Note: Interpreter instances are not sendable to isolates. This helper
    // uses a simple approach: run lightweight preprocessing in isolate
    // then call `run` on the main thread. For heavier models, spawn a
    // dedicated isolate that owns its own Interpreter.
    final prepared = await compute(_noopPrepare, input);
    return run(prepared as List<dynamic>);
  }

  static List<dynamic> _noopPrepare(List<dynamic> input) => input;

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
