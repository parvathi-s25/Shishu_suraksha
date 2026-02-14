import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

/// ML Models Manager - Handles loading and caching of ML models
/// Supports async loading to prevent UI blocking
class MLModelsManager {
  static final MLModelsManager _instance = MLModelsManager._internal();

  factory MLModelsManager() {
    return _instance;
  }

  MLModelsManager._internal();

  // Model cache
  final Map<String, dynamic> _modelCache = {};
  final Map<String, bool> _loadingStatus = {};
  final Map<String, StreamController<double>> _loadingProgress = {};

  /// Load model asynchronously without blocking UI
  Future<T?> loadModel<T>(
    String modelName, {
    required Future<T> Function() loader,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Check if already loaded
      if (_modelCache.containsKey(modelName)) {
        return _modelCache[modelName] as T?;
      }

      // Check if already loading
      if (_loadingStatus[modelName] == true) {
        // Wait for existing load to complete
        await Future.delayed(const Duration(milliseconds: 100));
        return _modelCache[modelName] as T?;
      }

      // Mark as loading
      _loadingStatus[modelName] = true;
      _loadingProgress[modelName] ??= StreamController<double>.broadcast();

      // Load with timeout
      final model = await loader().timeout(timeout);

      // Cache it
      _modelCache[modelName] = model;
      _loadingStatus[modelName] = false;
      _loadingProgress[modelName]?.add(100.0);

      return model;
    } catch (e) {
      _loadingStatus[modelName] = false;
      _loadingProgress[modelName]?.addError(e);
      return null;
    }
  }

  /// Get cached model
  T? getCachedModel<T>(String modelName) {
    return _modelCache[modelName] as T?;
  }

  /// Clear model cache
  void clearModel(String modelName) {
    _modelCache.remove(modelName);
    _loadingStatus.remove(modelName);
    _loadingProgress[modelName]?.close();
    _loadingProgress.remove(modelName);
  }

  /// Clear all models
  void clearAll() {
    _modelCache.clear();
    _loadingStatus.clear();
    for (var controller in _loadingProgress.values) {
      controller.close();
    }
    _loadingProgress.clear();
  }

  /// Get loading progress stream
  Stream<double> getLoadingProgress(String modelName) {
    _loadingProgress[modelName] ??= StreamController<double>.broadcast();
    return _loadingProgress[modelName]!.stream;
  }

  /// Check if model is loaded
  bool isModelLoaded(String modelName) {
    return _modelCache.containsKey(modelName);
  }

  /// Check if model is currently loading
  bool isModelLoading(String modelName) {
    return _loadingStatus[modelName] ?? false;
  }
}

/// ML Model Inference Handler - Base class for running inferences
abstract class MLInferenceHandler<Input, Output> {
  Future<Output?> inference(Input input);
  void dispose();
}

/// Real-time processing controller with frame buffering
class RealtimeMLProcessor<T> {
  final StreamController<T> _inputStream = StreamController<T>.broadcast();
  final StreamController<ProcessingResult<T>> _outputStream =
      StreamController<ProcessingResult<T>>.broadcast();

  late StreamSubscription<T> _subscription;
  bool _isProcessing = false;
  int _frameCounter = 0;
  final int _maxFrameRate;
  DateTime _lastProcessTime = DateTime.now();

  RealtimeMLProcessor({
    int maxFrameRate = 30,
  }) : _maxFrameRate = maxFrameRate;

  /// Process data in real-time
  void processStream(
    Stream<T> inputStream, {
    required Future<ProcessingResult<T>> Function(T data) processor,
  }) {
    _subscription = inputStream.listen((data) async {
      // Frame rate limiting
      if (_isProcessing) return;

      final now = DateTime.now();
      final elapsed = now.difference(_lastProcessTime).inMilliseconds;
      final targetInterval = 1000 ~/ _maxFrameRate;

      if (elapsed < targetInterval) {
        return;
      }

      _isProcessing = true;
      _frameCounter++;
      _lastProcessTime = now;

      try {
        final result = await processor(data);
        _outputStream.add(result);
      } catch (e) {
        _outputStream.addError(e);
      } finally {
        _isProcessing = false;
      }
    });
  }

  /// Get output stream
  Stream<ProcessingResult<T>> get outputStream => _outputStream.stream;

  /// Stop processing
  void stop() {
    _subscription.cancel();
    _inputStream.close();
    _outputStream.close();
  }

  int get frameCounter => _frameCounter;
}

/// Processing result wrapper
class ProcessingResult<T> {
  final T input;
  final dynamic result;
  final double confidence;
  final Duration processingTime;
  final bool isError;
  final String? errorMessage;

  ProcessingResult({
    required this.input,
    required this.result,
    this.confidence = 1.0,
    required this.processingTime,
    this.isError = false,
    this.errorMessage,
  });

  factory ProcessingResult.error(
    T input,
    String message,
    Duration time,
  ) {
    return ProcessingResult(
      input: input,
      result: null,
      confidence: 0.0,
      processingTime: time,
      isError: true,
      errorMessage: message,
    );
  }
}

/// Cache strategy for ML inference
class InferenceCache {
  final Map<String, CachedInference> _cache = {};
  final int maxSize;
  final Duration ttl;

  InferenceCache({
    this.maxSize = 100,
    this.ttl = const Duration(seconds: 30),
  });

  /// Get cached inference result
  dynamic getCachedResult(String key) {
    final cached = _cache[key];
    if (cached != null) {
      if (DateTime.now().difference(cached.timestamp).inMilliseconds < ttl.inMilliseconds) {
        return cached.result;
      } else {
        _cache.remove(key);
      }
    }
    return null;
  }

  /// Cache inference result
  void cacheResult(String key, dynamic result) {
    if (_cache.length >= maxSize) {
      // Remove oldest entry
      final oldest = _cache.entries.reduce(
        (a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b,
      );
      _cache.remove(oldest.key);
    }
    _cache[key] = CachedInference(result, DateTime.now());
  }

  void clear() => _cache.clear();
}

class CachedInference {
  final dynamic result;
  final DateTime timestamp;

  CachedInference(this.result, this.timestamp);
}



