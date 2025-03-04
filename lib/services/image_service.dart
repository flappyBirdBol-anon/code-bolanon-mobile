// lib/services/image_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageService {
  final String _baseUrl;
  final Dio dio;
  final ApiService _apiService;

  // Memory cache for faster access to frequently used images
  final Map<String, Uint8List> _memoryCache = {};

  // Disk cache manager
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  // Cache configuration
  final bool enableCache;
  final Duration cacheDuration;

  // Event tracking for prefetching
  bool _isBatchCaching = false;

  ImageService({
    required String baseUrl,
    required ApiService apiService,
    required Dio dioo,
    this.enableCache = true,
    this.cacheDuration = const Duration(days: 7),
  })  : _baseUrl = baseUrl,
        _apiService = apiService,
        dio = dioo;

  /// Constructs the full image URL from a relative path
  String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;

    // Ensure path has no leading slash
    final cleanPath =
        imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$_baseUrl/$cleanPath';
  }

  /// Gets the course thumbnail URL from a path
  String getCourseThumbnailFromPath(String thumbnailPath) {
    if (thumbnailPath.isEmpty) return '';
    if (thumbnailPath.startsWith('http')) return thumbnailPath;

    // Ensure path has no leading slash
    final cleanPath = thumbnailPath.startsWith('/')
        ? thumbnailPath.substring(1)
        : thumbnailPath;
    return '$_baseUrl/$cleanPath';
  }

  /// Gets the course thumbnail URL by course ID
  String getCourseThumbnailUrl(String courseId) {
    return '$_baseUrl/course-thumbnail/$courseId';
  }

  /// Prefetches and caches images for a list of courses
  Future<void> prefetchCourseImages(List<Course> courses) async {
    if (!enableCache || courses.isEmpty) return;

    try {
      _isBatchCaching = true;

      // Create a list of futures for parallel processing
      final futures = <Future>[];

      for (final course in courses) {
        if (course.thumbnail != null && course.thumbnail!.isNotEmpty) {
          final imageUrl = getCourseThumbnailFromPath(course.thumbnail!);
          futures.add(prefetchImage(imageUrl, courseId: course.id));
        }
      }

      // Wait for all prefetch operations to complete
      await Future.wait(futures);
    } catch (e) {
      print('Error prefetching course images: $e');
    } finally {
      _isBatchCaching = false;
    }
  }

  /// Prefetches and caches a single image
  Future<void> prefetchImage(String imageUrl, {String? courseId}) async {
    if (imageUrl.isEmpty || !enableCache) return;

    try {
      // Generate a cache key that includes course ID if available
      final cacheKey = courseId != null ? 'course_${courseId}_image' : imageUrl;

      // Check if already in memory cache
      if (_memoryCache.containsKey(cacheKey)) return;

      // Check if already in disk cache and not expired
      final fileInfo = await _cacheManager.getFileFromCache(imageUrl);
      if (fileInfo != null) {
        final age = DateTime.now().difference(fileInfo.file.lastModifiedSync());
        if (age < cacheDuration) {
          // Load into memory cache for faster access
          final bytes = await fileInfo.file.readAsBytes();
          _memoryCache[cacheKey] = bytes;
          return;
        }
      }

      // Fetch the image with authentication
      final response = await _apiService.dio.get(
        imageUrl,
        options: Options(
          headers: _apiService.dio.options.headers,
          responseType: ResponseType.bytes,
        ),
      );

      // Save to disk cache
      final file = await _cacheManager.putFile(
        imageUrl,
        response.data,
        maxAge: cacheDuration,
      );

      // Save to memory cache
      _memoryCache[cacheKey] = response.data;

      print('Image cached successfully: $imageUrl');
    } catch (e) {
      print('Error prefetching image: $e');
    }
  }

  /// Handles caching for a newly created or updated course
  Future<void> handleCourseCacheUpdate(Course course) async {
    if (course.thumbnail == null || course.thumbnail!.isEmpty) return;

    final imageUrl = getCourseThumbnailFromPath(course.thumbnail!);

    // Force refresh the cache for this course
    await _cacheManager.removeFile(imageUrl);
    _memoryCache.remove('course_${course.id}_image');

    // Prefetch the new image
    await prefetchImage(imageUrl, courseId: course.id);
  }

  /// Gets cached image bytes for a course
  Future<Uint8List?> getCourseImageBytes(Course course) async {
    if (course.thumbnail == null || course.thumbnail!.isEmpty) return null;

    final imageUrl = getCourseThumbnailFromPath(course.thumbnail!);
    final cacheKey = 'course_${course.id}_image';

    // Check memory cache first
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey];
    }

    try {
      // Try to get from disk cache
      final fileInfo = await _cacheManager.getFileFromCache(imageUrl);
      if (fileInfo != null) {
        final bytes = await fileInfo.file.readAsBytes();
        // Store in memory cache for faster future access
        _memoryCache[cacheKey] = bytes;
        return bytes;
      }

      // If not in cache, fetch and cache
      await prefetchImage(imageUrl, courseId: course.id);
      return _memoryCache[cacheKey];
    } catch (e) {
      print('Error getting course image bytes: $e');
      return null;
    }
  }

  /// Gets a cached image file
  Future<File?> getCachedImageFile(String imageUrl) async {
    if (imageUrl.isEmpty) return null;

    try {
      final fileInfo = await _cacheManager.getFileFromCache(imageUrl);
      if (fileInfo != null) {
        return fileInfo.file;
      }

      // If not cached, download and cache
      final response = await _apiService.dio.get(
        imageUrl,
        options: Options(
          headers: _apiService.dio.options.headers,
          responseType: ResponseType.bytes,
        ),
      );

      final file = await _cacheManager.putFile(
        imageUrl,
        response.data,
        maxAge: cacheDuration,
      );

      return file;
    } catch (e) {
      print('Error getting cached image file: $e');
      return null;
    }
  }

  /// Widget to display an image with caching
  Widget loadImage({
    required String imageUrl,
    String? courseId,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(width, height, errorWidget);
    }

    // If it's a local asset, just load it directly
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
      );
    }

    // Use a FutureBuilder to load the image with authentication and caching
    return FutureBuilder<File?>(
      future: getCachedImageFile(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ??
              Center(
                child: SizedBox(
                  width: width != null ? width * 0.3 : 30,
                  height: width != null ? width * 0.3 : 30,
                  child: CircularProgressIndicator(),
                ),
              );
        } else if (snapshot.hasError || !snapshot.hasData) {
          print('Error loading image: ${snapshot.error}');
          return _buildErrorWidget(width, height, errorWidget);
        } else {
          return Image.file(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              print('Error displaying image: $error');
              return _buildErrorWidget(width, height, errorWidget);
            },
          );
        }
      },
    );
  }

  Widget _buildErrorWidget(
      double? width, double? height, Widget? customWidget) {
    return customWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[600]),
        );
  }

  /// Clears all cached images
  Future<void> clearCache() async {
    _memoryCache.clear();
    await _cacheManager.emptyCache();
  }

  /// Clears cache for a specific course
  Future<void> clearCourseCache(String courseId) async {
    _memoryCache.remove('course_${courseId}_image');
    // We would need the URL to remove from disk cache
    // This is handled in handleCourseCacheUpdate
  }
}
