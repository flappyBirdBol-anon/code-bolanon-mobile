import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/services/file_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/theme_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

class SettingsViewModel extends AppBaseViewModel {
  final _fileService = locator<FileService>();
  final _imageService = locator<ImageService>();
  final _lessonsService = locator<LessonsService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final _themeService = locator<ThemeService>();

  bool get isDarkMode => _themeService.isDarkTheme;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _appVersion = '';
  String get appVersion => _appVersion;

  // Notification settings
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  // Auto-download settings
  bool _autoDownloadEnabled = true;
  bool get autoDownloadEnabled => _autoDownloadEnabled;

  // Data usage settings
  String _dataSavingMode = 'Standard';
  String get dataSavingMode => _dataSavingMode;

  // Cache statistics
  String _imageCacheSize = 'Calculating...';
  String _lessonCacheSize = 'Calculating...';
  String _totalCacheSize = 'Calculating...';

  String get imageCacheSize => _imageCacheSize;
  String get lessonCacheSize => _lessonCacheSize;
  String get totalCacheSize => _totalCacheSize;

  SettingsViewModel() {
    _init();
  }

  Future<void> _init() async {
    setBusy(true);

    // Load app version
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      _appVersion = '1.0.0';
    }

    // Calculate cache sizes
    await _calculateCacheSize();

    setBusy(false);
  }

  Future<void> _calculateCacheSize() async {
    try {
      // Reset values to show calculation is in progress
      _imageCacheSize = 'Calculating...';
      _lessonCacheSize = 'Calculating...';
      _totalCacheSize = 'Calculating...';
      notifyListeners();

      // Add a small delay to allow UI to refresh and cache clearing to complete
      await Future.delayed(const Duration(milliseconds: 300));

      // Get app's temporary directory (where cache is usually stored)
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/libCachedImageData');

      // Calculate image cache size
      final int imageCacheSizeBytes = await _calculateImageCacheSize(cacheDir);
      _imageCacheSize = _formatBytes(imageCacheSizeBytes);

      // Calculate lesson/file cache size
      final int lessonCacheSizeBytes = await _calculateFileCacheSize(tempDir);
      _lessonCacheSize = _formatBytes(lessonCacheSizeBytes);

      // Calculate total cache size
      final totalCacheSizeBytes = imageCacheSizeBytes + lessonCacheSizeBytes;
      _totalCacheSize = _formatBytes(totalCacheSizeBytes);

      notifyListeners();
    } catch (e) {
      // Fallback to placeholder values in case of error
      _imageCacheSize = '0 B';
      _lessonCacheSize = '0 B';
      _totalCacheSize = '0 B';
      notifyListeners();

      print('Error calculating cache size: $e');
    }
  }

  Future<int> _calculateImageCacheSize(Directory cacheDir) async {
    int totalSize = 0;

    if (await cacheDir.exists()) {
      final files = await cacheDir.list(recursive: true).toList();
      for (var entity in files) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    }

    return totalSize;
  }

  Future<int> _calculateFileCacheSize(Directory tempDir) async {
    int totalSize = 0;

    // Look for files managed by the DefaultCacheManager
    final fileDir = Directory('${tempDir.path}/libCachedImageData');
    if (await fileDir.exists()) {
      final files = await fileDir.list(recursive: true).toList();
      for (var entity in files) {
        if (entity is File &&
            !(entity.path.contains('libCachedImageData/thumbnails') ||
                entity.path.contains('libCachedImageData/images'))) {
          totalSize += await entity.length();
        }
      }
    }

    // Also look for files handled directly by the FileService
    try {
      final Directory appCacheDir = await getApplicationCacheDirectory();
      if (await appCacheDir.exists()) {
        final files = await appCacheDir.list(recursive: true).toList();
        for (var entity in files) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      print('Error accessing app cache directory: $e');
    }

    return totalSize;
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<void> toggleTheme() async {
    await _themeService.toggleTheme();
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    // In a real app, you would persist this setting
    notifyListeners();
  }

  Future<void> toggleAutoDownload(bool value) async {
    _autoDownloadEnabled = value;
    // In a real app, you would persist this setting
    notifyListeners();
  }

  Future<void> setDataSavingMode(String mode) async {
    _dataSavingMode = mode;
    // In a real app, you would persist this setting
    notifyListeners();
  }

  Future<void> clearAllCache() async {
    final result = await _dialogService.showDialog(
      title: 'Clear All Cache',
      description:
          'This will clear all cached images and lesson files. Continue?',
      barrierDismissible: true,
      buttonTitle: 'Clear',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed == true) {
      _setLoading(true);
      try {
        // Reset cache size values immediately to indicate clearing
        _imageCacheSize = 'Clearing...';
        _lessonCacheSize = 'Clearing...';
        _totalCacheSize = 'Clearing...';
        notifyListeners();

        // Clear all caches
        await _fileService.clearCache();
        await _imageService.clearCache();
        _lessonsService.clearCache();

        // Force garbage collection by setting values to null first
        _imageCacheSize = '0 B';
        _lessonCacheSize = '0 B';
        _totalCacheSize = '0 B';
        notifyListeners();

        // Recalculate cache sizes
        await Future.delayed(const Duration(milliseconds: 500));
        await _calculateCacheSize();

        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.success,
          message: 'Cache cleared successfully',
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.error,
          message: 'Failed to clear cache: ${e.toString()}',
          duration: const Duration(seconds: 3),
        );
      } finally {
        _setLoading(false);
      }
    }
  }

  Future<void> clearImageCache() async {
    final result = await _dialogService.showDialog(
      title: 'Clear Image Cache',
      description: 'This will clear all cached images. Continue?',
      barrierDismissible: true,
      buttonTitle: 'Clear',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed == true) {
      _setLoading(true);
      try {
        // Reset image cache size value immediately
        _imageCacheSize = 'Clearing...';
        _totalCacheSize = 'Recalculating...';
        notifyListeners();

        await _imageService.clearCache();

        // Allow a small delay for cache clearing to complete
        await Future.delayed(const Duration(milliseconds: 500));
        await _calculateCacheSize();

        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.success,
          message: 'Image cache cleared successfully',
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.error,
          message: 'Failed to clear image cache: ${e.toString()}',
          duration: const Duration(seconds: 3),
        );
      } finally {
        _setLoading(false);
      }
    }
  }

  Future<void> clearLessonCache() async {
    final result = await _dialogService.showDialog(
      title: 'Clear Lesson Cache',
      description: 'This will clear all cached lesson files. Continue?',
      barrierDismissible: true,
      buttonTitle: 'Clear',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed == true) {
      _setLoading(true);
      try {
        // Reset lesson cache size value immediately
        _lessonCacheSize = 'Clearing...';
        _totalCacheSize = 'Recalculating...';
        notifyListeners();

        await _fileService.clearCache();
        _lessonsService.clearCache();

        // Allow a small delay for cache clearing to complete
        await Future.delayed(const Duration(milliseconds: 500));
        await _calculateCacheSize();

        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.success,
          message: 'Lesson cache cleared successfully',
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.error,
          message: 'Failed to clear lesson cache: ${e.toString()}',
          duration: const Duration(seconds: 3),
        );
      } finally {
        _setLoading(false);
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
