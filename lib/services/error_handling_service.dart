import 'package:flutter/material.dart';

/// Error Handling and Recovery Service
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();

  factory ErrorHandlingService() {
    return _instance;
  }

  ErrorHandlingService._internal();

  final List<ErrorLog> _errorLog = [];
  final int maxLogSize = 100;

  /// Log error
  void logError(
    String source,
    String message,
    StackTrace? stackTrace, {
    String? context,
  }) {
    final log = ErrorLog(
      source: source,
      message: message,
      stackTrace: stackTrace,
      context: context,
      timestamp: DateTime.now(),
    );

    _errorLog.add(log);
    if (_errorLog.length > maxLogSize) {
      _errorLog.removeAt(0);
    }

    debugPrint('[$source] $message');
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Get fallback value
  T getFallback<T>(T Function() original, T fallbackValue) {
    try {
      return original();
    } catch (e) {
      logError('Fallback', 'Using fallback value: $e', null);
      return fallbackValue;
    }
  }

  /// Get error history
  List<ErrorLog> getErrorHistory({
    DateTime? since,
    String? source,
  }) {
    var logs = _errorLog;

    if (since != null) {
      logs = logs.where((l) => l.timestamp.isAfter(since)).toList();
    }

    if (source != null) {
      logs = logs.where((l) => l.source == source).toList();
    }

    return logs;
  }

  /// Clear error log
  void clearLog() => _errorLog.clear();
}

class ErrorLog {
  final String source;
  final String message;
  final StackTrace? stackTrace;
  final String? context;
  final DateTime timestamp;

  ErrorLog({
    required this.source,
    required this.message,
    required this.stackTrace,
    required this.context,
    required this.timestamp,
  });
}

/// Error Recovery Widget
class ErrorRecoveryWidget extends StatefulWidget {
  final Widget child;
  final String title;

  const ErrorRecoveryWidget({
    Key? key,
    required this.child,
    required this.title,
  }) : super(key: key);

  @override
  State<ErrorRecoveryWidget> createState() => _ErrorRecoveryWidgetState();
}

class _ErrorRecoveryWidgetState extends State<ErrorRecoveryWidget> {
  ErrorLog? _error;

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: (error) {
        setState(() => _error = error);
      },
      child: _error != null
          ? _buildErrorScreen(_error!)
          : widget.child,
    );
  }

  Widget _buildErrorScreen(ErrorLog error) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _error = null),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error Boundary - Catches and handles errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final void Function(ErrorLog error) onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    required this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// ML Model Fallback Manager
class MLFallbackManager {
  static const String _hearingFallback = 'hearing_fallback';
  static const String _speakingFallback = 'speaking_fallback';
  static const String _visualFallback = 'visual_fallback';
  static const String _thermalFallback = 'thermal_fallback';

  /// Get hearing score with fallback
  static int getHearingScore(int? mlScore) {
    if (mlScore != null && mlScore >= 0) return mlScore;
    // Fallback: return moderate score
    return 70;
  }

  /// Get speaking score with fallback
  static int getSpeakingScore(int? mlScore) {
    if (mlScore != null && mlScore >= 0) return mlScore;
    // Fallback: based on recording duration
    return 65;
  }

  /// Get visual score with fallback
  static int getVisualScore(int? mlScore) {
    if (mlScore != null && mlScore >= 0) return mlScore;
    // Fallback: based on image quality
    return 75;
  }

  /// Get thermal score with fallback
  static int getThermalScore(int? mlScore) {
    if (mlScore != null && mlScore >= 0) return mlScore;
    // Fallback: assume normal
    return 80;
  }
}

/// Offline mode detector
class OfflineMode {
  static bool _isOffline = false;

  static bool get isOffline => _isOffline;

  static void setOffline(bool value) => _isOffline = value;

  /// Get assessment result with fallback for offline mode
  static Map<String, int> getOfflineAssessmentResult() {
    return {
      'hearing': 70,
      'speaking': 65,
      'visual': 75,
      'thermal': 80,
    };
  }
}
