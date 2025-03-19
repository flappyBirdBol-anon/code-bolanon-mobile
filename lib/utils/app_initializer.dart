import 'package:flutter/foundation.dart';

/// Priority levels for module initialization
enum InitPriority {
  critical, // Must be initialized before app starts (blocking)
  high, // Should be initialized as soon as possible after app starts
  medium, // Can be initialized after essential UI is rendered
  low, // Can be initialized during idle time or on-demand
}

/// Module initialization configuration
class InitModule {
  final String name;
  final Future<void> Function() initializer;
  final InitPriority priority;
  final bool initOnDemand;

  InitModule({
    required this.name,
    required this.initializer,
    this.priority = InitPriority.medium,
    this.initOnDemand = false,
  });
}

/// Manages efficient app initialization
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  final List<InitModule> _modules = [];
  final Map<String, bool> _initialized = {};
  final Map<String, DateTime> _initTimes = {};

  bool _isInitializing = false;

  /// Register a module for initialization
  void registerModule(InitModule module) {
    _modules.add(module);
    _initialized[module.name] = false;
  }

  /// Initialize critical modules (blocking)
  Future<void> initializeCriticalModules() async {
    if (_isInitializing) return;
    _isInitializing = true;

    final criticalModules = _modules
        .where((module) =>
            module.priority == InitPriority.critical && !module.initOnDemand)
        .toList();

    for (final module in criticalModules) {
      await _initializeModule(module);
    }
  }

  /// Initialize non-critical modules in the background
  void initializeNonCriticalModules() {
    final highPriorityModules = _modules
        .where((module) =>
            module.priority == InitPriority.high && !module.initOnDemand)
        .toList();

    final mediumPriorityModules = _modules
        .where((module) =>
            module.priority == InitPriority.medium && !module.initOnDemand)
        .toList();

    final lowPriorityModules = _modules
        .where((module) =>
            module.priority == InitPriority.low && !module.initOnDemand)
        .toList();

    // Initialize high priority modules immediately after app starts
    Future.microtask(() async {
      for (final module in highPriorityModules) {
        await _initializeModule(module);
      }
    });

    // Initialize medium priority modules with slight delay
    Future.delayed(const Duration(milliseconds: 300), () async {
      for (final module in mediumPriorityModules) {
        await _initializeModule(module);
        // Add small delay between initializations
        await Future.delayed(const Duration(milliseconds: 50));
      }
    });

    // Initialize low priority modules during idle time
    // or when app is stable (longer delay)
    Future.delayed(const Duration(seconds: 2), () {
      _initializeLowPriorityModules(lowPriorityModules);
    });
  }

  // Helper to initialize low priority modules in chunks
  void _initializeLowPriorityModules(List<InitModule> modules) async {
    const chunkSize = 2;

    for (var i = 0; i < modules.length; i += chunkSize) {
      final end =
          (i + chunkSize < modules.length) ? i + chunkSize : modules.length;
      final chunk = modules.sublist(i, end);

      for (final module in chunk) {
        _initializeModule(module);
      }

      // Wait between chunks to avoid impacting UI
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Initialize a specific module by name (for on-demand modules)
  Future<void> initializeModule(String name) async {
    if (_initialized[name] == true) return;

    final module = _modules.firstWhere(
      (m) => m.name == name,
      orElse: () => throw Exception('Module not found: $name'),
    );

    await _initializeModule(module);
  }

  /// Helper to initialize a single module with timing
  Future<void> _initializeModule(InitModule module) async {
    if (_initialized[module.name] == true) return;

    try {
      final startTime = DateTime.now();

      await module.initializer();

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _initialized[module.name] = true;
      _initTimes[module.name] = endTime;

      if (kDebugMode) {
        print('✅ Initialized ${module.name} in ${duration.inMilliseconds}ms');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize ${module.name}: $e');
      }
    }
  }

  /// Get initialization statistics for debugging
  Map<String, dynamic> getInitStats() {
    final stats = <String, dynamic>{};

    for (final module in _modules) {
      final isInit = _initialized[module.name] ?? false;
      final initTime = _initTimes[module.name];

      stats[module.name] = {
        'initialized': isInit,
        'initTime': initTime?.toIso8601String(),
        'priority': module.priority.toString(),
        'onDemand': module.initOnDemand,
      };
    }

    return stats;
  }
}

/// Example usage in main.dart:
///
/// final initializer = AppInitializer();
///
/// void setupInitializer() {
///   final authService = locator<AuthService>();
///
///   initializer.registerModule(
///     InitModule(
///       name: 'auth',
///       priority: InitPriority.high,
///       initializer: () => authService.initialize(),
///     ),
///   );
///
///   // Register other modules...
/// }
///
/// void main() async {
///   // Initialize Flutter
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Register modules
///   setupInitializer();
///
///   // Initialize critical modules
///   await initializer.initializeCriticalModules();
///
///   // Run app with loading indicator
///   runApp(const AppLoader());
///
///   // Initialize remaining modules in background
///   initializer.initializeNonCriticalModules();
///
///   // Once initial route is determined, replace loader
///   // with actual app
///   // ...
/// }
