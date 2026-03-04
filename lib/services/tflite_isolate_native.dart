import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Minimal isolate worker for native platforms only (requires dart:ffi).
class TFLiteIsolate {
  Isolate? _isolate;
  SendPort? _sendPort;

  Future<void> spawn() async {
    final init = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, init.sendPort);
    _sendPort = await init.first as SendPort;
  }

  Future<void> loadModel(String assetPath) async {
    final p = ReceivePort();
    _sendPort?.send({'cmd': 'load', 'model': assetPath, 'reply': p.sendPort});
    final res = await p.first;
    if (res is String && res != 'ok') throw StateError('Model load failed: $res');
  }

  Future<List<double>> run(List<double> input) async {
    final p = ReceivePort();
    _sendPort?.send({'cmd': 'run', 'data': input, 'reply': p.sendPort});
    final res = await p.first;
    if (res is List) return List<double>.from(res.map((e) => (e as num).toDouble()));
    throw StateError('Unexpected response from isolate');
  }

  void kill() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }

  static void _isolateEntry(SendPort mainSend) {
    final port = ReceivePort();
    mainSend.send(port.sendPort);
    Interpreter? interpreter;

    port.listen((message) async {
      try {
        final cmd = message['cmd'] as String;
        if (cmd == 'load') {
          final model = message['model'] as String;
          final reply = message['reply'] as SendPort;
          try {
            interpreter?.close();
            interpreter = await Interpreter.fromAsset(model);
            reply.send('ok');
          } catch (e) {
            reply.send('error:$e');
          }
        } else if (cmd == 'run') {
          final data = message['data'] as List<dynamic>;
          final reply = message['reply'] as SendPort;
          if (interpreter == null) {
            reply.send([]);
            return;
          }
          try {
            final input = [data];
            final outputT = interpreter!.getOutputTensor(0);
            final outShape = outputT.shape.reduce((a, b) => a * b);
            final output = List.filled(outShape, 0.0);
            interpreter!.run(input, output);
            reply.send(output);
          } catch (e) {
            reply.send([]);
          }
        }
      } catch (e) {
        debugPrint('Isolate worker error: $e');
      }
    });
  }
}
