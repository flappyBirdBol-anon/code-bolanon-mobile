import 'dart:async';
import 'package:flutter/foundation.dart';

/// A utility class for performance optimizations
class PerformanceUtils {
  /// Executes a heavy computation in a separate isolate
  ///
  /// [computation] - The function to run in the isolate
  /// [message] - The input data for the computation
  static Future<R> computeAsync<Q, R>(
      ComputeCallback<Q, R> computation, Q message) async {
    return compute(computation, message);
  }

  /// Batches multiple compute operations for better performance
  ///
  /// [computations] - List of functions to run
  /// [messages] - List of input data for each function
  /// [maxConcurrent] - Maximum number of concurrent isolates
  static Future<List<dynamic>> batchCompute<Q, R>({
    required List<ComputeCallback<Q, R>> computations,
    required List<Q> messages,
    int maxConcurrent = 4,
  }) async {
    assert(computations.length == messages.length,
        'Number of computations must match number of messages');

    final results = <dynamic>[];

    // Process in batches to avoid too many concurrent isolates
    for (var i = 0; i < computations.length; i += maxConcurrent) {
      final end = i + maxConcurrent < computations.length
          ? i + maxConcurrent
          : computations.length;

      final batch = <Future<dynamic>>[];

      for (var j = i; j < end; j++) {
        batch.add(compute(computations[j], messages[j]));
      }

      results.addAll(await Future.wait(batch));
    }

    return results;
  }

  /// Debounces a function call to prevent rapid repeated executions
  ///
  /// [callback] - Function to debounce
  /// [duration] - Duration to wait before executing
  static Function() debounce(Function() callback, Duration duration) {
    Timer? timer;

    return () {
      if (timer != null) {
        timer!.cancel();
      }

      timer = Timer(duration, callback);
    };
  }

  /// Throttles a function call to limit execution frequency
  ///
  /// [callback] - Function to throttle
  /// [duration] - Duration between allowed executions
  static Function() throttle(Function() callback, Duration duration) {
    DateTime? lastCall;

    return () {
      final now = DateTime.now();

      if (lastCall == null || now.difference(lastCall!) > duration) {
        lastCall = now;
        callback();
      }
    };
  }

  /// Runs tasks in the background with proper scheduling
  static Future<void> runInBackground(List<Future Function()> tasks) async {
    // Run critical tasks immediately
    if (tasks.isEmpty) return;

    if (tasks.length == 1) {
      unawaited(tasks[0]());
      return;
    }

    // Run first task immediately
    unawaited(tasks[0]());

    // Schedule remaining tasks with slight delays
    for (var i = 1; i < tasks.length; i++) {
      final delay = Duration(milliseconds: 50 * i);
      unawaited(Future.delayed(delay, tasks[i]));
    }
  }

  /// Pre-warms critical components during idle time
  static void prewarmComponents(List<Future Function()> initializers) {
    // Only prewarm in release mode to avoid development overhead
    if (kReleaseMode) {
      Future.microtask(() async {
        for (final init in initializers) {
          await init();
          // Small delay between initializations to avoid UI jank
          await Future.delayed(const Duration(milliseconds: 50));
        }
      });
    }
  }
}

/// Extension on futures for fire-and-forget operations
extension FutureExtensions<T> on Future<T> {
  void fireAndForget() {
    unawaited(this.catchError((error) {
      debugPrint('Unhandled error in fire-and-forget operation: $error');
      return null as T;
    }));
  }
}

/// Provides a delayed initialization mechanism for resources
///
/// Use this to lazy-load resources only when needed
class LazyResource<T> {
  final Future<T> Function() _initializer;
  T? _resource;
  Completer<T>? _completer;

  LazyResource(this._initializer);

  Future<T> get resource async {
    if (_resource != null) {
      return _resource!;
    }

    if (_completer == null) {
      _completer = Completer<T>();

      try {
        _resource = await _initializer();
        _completer!.complete(_resource);
      } catch (e) {
        _completer!.completeError(e);
        _completer = null;
        rethrow;
      }
    }

    return _completer!.future;
  }

  bool get isInitialized => _resource != null;

  void reset() {
    if (_completer?.isCompleted == false) {
      _completer!.completeError(Exception('Resource initialization cancelled'));
    }
    _completer = null;
    _resource = null;
  }
}
