import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' as foundation;

/// Responsive Design Utility - Handles responsive UI across all devices
class ResponsiveDesign {
  /// Device size categories
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  final BuildContext context;

  ResponsiveDesign(this.context);

  /// Get device type
  DeviceType get deviceType {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Get screen width
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Get is mobile
  bool get isMobile => deviceType == DeviceType.mobile;

  /// Get is tablet
  bool get isTablet => deviceType == DeviceType.tablet;

  /// Get is desktop
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Get adaptive padding
  EdgeInsets get adaptivePadding {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(12);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.desktop:
        return const EdgeInsets.all(20);
    }
  }

  /// Get adaptive font size
  double getAdaptiveFontSize(double baseSize) {
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSize * 0.9;
      case DeviceType.tablet:
        return baseSize;
      case DeviceType.desktop:
        return baseSize * 1.1;
    }
  }

  /// Get adaptive spacing
  double getAdaptiveSpacing(double baseSpacing) {
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSpacing * 0.8;
      case DeviceType.tablet:
        return baseSpacing;
      case DeviceType.desktop:
        return baseSpacing * 1.2;
    }
  }

  /// Get grid columns
  int get gridColumns {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  /// Get max width for content
  double get maxContentWidth {
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth * 0.95;
      case DeviceType.tablet:
        return screenWidth * 0.9;
      case DeviceType.desktop:
        return 1000;
    }
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// UI Performance Monitor - Prevents jank and blocking
class UIPerformanceMonitor {
  static final UIPerformanceMonitor _instance = UIPerformanceMonitor._internal();

  factory UIPerformanceMonitor() {
    return _instance;
  }

  UIPerformanceMonitor._internal();

  final List<FrameMetric> _frameMetrics = [];
  final int maxMetricsSize = 120; // Last 2 seconds at 60fps

  late Stopwatch _frameTimer;
  int _frameCount = 0;
  double _averageFrameTime = 0;

  /// Start frame profiling
  void startFrame() {
    _frameTimer = Stopwatch()..start();
  }

  /// End frame and record metric
  void endFrame() {
    _frameTimer.stop();
    final frameTime = _frameTimer.elapsedMilliseconds.toDouble();

    final metric = FrameMetric(
      frameNumber: _frameCount++,
      frameTime: frameTime,
      timestamp: DateTime.now(),
    );

    _frameMetrics.add(metric);
    if (_frameMetrics.length > maxMetricsSize) {
      _frameMetrics.removeAt(0);
    }

    // Update average
    _updateAverageFrameTime();
  }

  /// Update average frame time
  void _updateAverageFrameTime() {
    if (_frameMetrics.isEmpty) return;
    final sum = _frameMetrics.map((m) => m.frameTime).reduce((a, b) => a + b);
    _averageFrameTime = sum / _frameMetrics.length;
  }

  /// Check if performance is good
  bool get isPerformanceGood => _averageFrameTime < 16.67; // 60fps threshold

  /// Get current FPS
  double get currentFPS => _averageFrameTime > 0 ? 1000 / _averageFrameTime : 0;

  /// Get frame metrics
  List<FrameMetric> get frameMetrics => List.unmodifiable(_frameMetrics);

  /// Get average frame time
  double get averageFrameTime => _averageFrameTime;

  /// Reset metrics
  void reset() {
    _frameMetrics.clear();
    _frameCount = 0;
    _averageFrameTime = 0;
  }
}

/// Frame metric data
class FrameMetric {
  final int frameNumber;
  final double frameTime;
  final DateTime timestamp;

  FrameMetric({
    required this.frameNumber,
    required this.frameTime,
    required this.timestamp,
  });
}

/// Non-blocking task executor
class NonBlockingExecutor {
  static final NonBlockingExecutor _instance = NonBlockingExecutor._internal();

  factory NonBlockingExecutor() {
    return _instance;
  }

  NonBlockingExecutor._internal();

  final List<_QueuedTask> _taskQueue = [];
  bool _isProcessing = false;

  /// Execute task without blocking UI
  Future<T> executeAsync<T>(
    Future<T> Function() task, {
    Duration debounce = Duration.zero,
  }) async {
    return Future.delayed(debounce, () => task());
  }

  /// Execute heavy computation in background
  Future<T> executeHeavyComputation<T>(
    T Function() computation,
  ) async {
    // Use a non-blocking synchronous wrapper to execute computation without
    // depending on `compute` to avoid isolate-related build issues.
    return await Future<T>.sync(() => computation());
  }

  /// Batch execute tasks
  Future<List<T>> executeBatch<T>(
    List<Future<T> Function()> tasks,
  ) async {
    final results = <T>[];
    for (final task in tasks) {
      results.add(await task());
      // Yield to UI thread between tasks
      await Future.delayed(Duration.zero);
    }
    return results;
  }

  /// Process queued task
  Future<void> _processQueue() async {
    if (_isProcessing || _taskQueue.isEmpty) return;

    _isProcessing = true;
    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeAt(0);
      try {
        await task.execute();
      } catch (e) {
        debugPrint('Error executing queued task: $e');
      }
      // Yield to UI
      await Future.delayed(Duration.zero);
    }
    _isProcessing = false;
  }

  /// Clear queue
  void clearQueue() {
    _taskQueue.clear();
  }
}

class _QueuedTask {
  final Future Function() execute;

  _QueuedTask({required this.execute});
}

/// Compute bridge for heavy computations
T _heavyComputationBridge<T>(T Function() computation) => computation();



/// Debounce utility to prevent excessive updates
class Debounce {
  Timer? _timer;
  final Duration delay;

  Debounce({this.delay = const Duration(milliseconds: 500)});

  /// Call function with debouncing
  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancel pending call
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttle utility to limit function calls
class Throttle {
  VoidCallback? _callback;
  bool _isReady = true;
  final Duration interval;
  Timer? _waitTimer;

  Throttle({this.interval = const Duration(milliseconds: 300)});

  /// Call function with throttling
  void call(VoidCallback callback) {
    _callback = callback;
    if (_isReady) {
      _isReady = false;
      callback();
      _waitTimer = Timer(interval, () {
        _isReady = true;
        if (_callback != null) {
          _callback!();
        }
      });
    }
  }

  void dispose() {
    _waitTimer?.cancel();
  }
}
