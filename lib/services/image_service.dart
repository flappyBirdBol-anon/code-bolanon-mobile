// lib/services/image_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageService {
  final String baseUrl;
  final Dio dio;
  final ApiService apiService;

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
    this.baseUrl = 'http://143.198.197.240/api',
    ApiService? apiService,
    Dio? dioo,
    this.enableCache = true,
    this.cacheDuration = const Duration(hours: 12),
  })  : apiService = apiService ?? locator<ApiService>(),
        dio = dioo ?? locator<ApiService>().dio;

  /// Constructs the full image URL from a relative path
  String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;

    // Ensure path has no leading slash
    final cleanPath =
        imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$baseUrl/$cleanPath';
  }

  /// Gets the course thumbnail URL from a path
  String getCourseThumbnailFromPath(String thumbnailPath) {
    if (thumbnailPath.isEmpty) return '';
    if (thumbnailPath.startsWith('http') || thumbnailPath.startsWith('https')) {
      return thumbnailPath;
    }
    if (thumbnailPath.startsWith('assets/')) {
      return thumbnailPath;
    }

    // Clean and construct the path
    final cleanPath = thumbnailPath.startsWith('/')
        ? thumbnailPath.substring(1)
        : thumbnailPath;

    // If path already contains 'storage', don't add it again
    if (cleanPath.contains('storage/')) {
      return '$baseUrl/$cleanPath';
    }
    return '$baseUrl/$cleanPath';
  }

  /// Gets the course thumbnail URL by course ID
  String getCourseThumbnailUrl(String courseId) {
    return '$baseUrl/course-thumbnail/$courseId';
  }

  /// Prefetches and caches images for a list of courses
  Future<void> prefetchCourseImages(List<CourseModel> courses) async {
    if (!enableCache || courses.isEmpty) return;

    try {
      _isBatchCaching = true;

      // Create a list of futures for parallel processing
      final futures = <Future>[];

      for (final course in courses) {
        if (course.thumbnail.isNotEmpty) {
          final imageUrl = getCourseThumbnailFromPath(course.thumbnail);
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
      final response = await apiService.dio.get(
        imageUrl,
        options: Options(
          headers: apiService.dio.options.headers,
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
  Future<void> handleCourseCacheUpdate(CourseModel course) async {
    if (course.thumbnail.isEmpty) return;

    final imageUrl = getCourseThumbnailFromPath(course.thumbnail);

    // Force refresh the cache for this course
    await _cacheManager.removeFile(imageUrl);
    _memoryCache.remove('course_${course.id}_image');

    await prefetchImage(imageUrl, courseId: course.id);
  }

  /// Gets cached image bytes for a course
  Future<Uint8List?> getCourseImageBytes(CourseModel course) async {
    if (course.thumbnail.isEmpty) return null;

    final imageUrl = getCourseThumbnailFromPath(course.thumbnail);
    final cacheKey = 'course_${course.id}_image';

    // Check memcache first
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey];
    }

    try {
      // Try to get from disk cache
      final fileInfo = await _cacheManager.getFileFromCache(imageUrl);
      if (fileInfo != null) {
        final bytes = await fileInfo.file.readAsBytes();

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
      final response = await apiService.dio.get(
        imageUrl,
        options: Options(
          headers: apiService.dio.options.headers,
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
                  child: const CircularProgressIndicator(),
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
  }

  Widget getImage({
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
  }) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
      );
    }

    // Use consistent cache key format
    final cacheKey = 'img_${url.hashCode}';

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      cacheKey: cacheKey,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      placeholder: (context, url) =>
          placeholder ??
          Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
              ),
            ),
          ),
      errorWidget: (context, url, error) {
        print('Error loading image $url: $error');
        return placeholder ?? Icon(Icons.error, color: Colors.grey[400]);
      },
    );
  }

  /// Gets course image from cache or network, prioritizing cache
  Future<File?> getCourseThumbnailFile(CourseModel course) async {
    if (course.thumbnail.isEmpty) return null;
    if (course.thumbnail.startsWith('assets/')) return null;

    final imageUrl = getCourseThumbnailFromPath(course.thumbnail);
    final cacheKey = 'course_${course.id}_thumb';

    try {
      // Try to get from disk cache first
      final fileInfo = await _cacheManager.getFileFromCache(imageUrl);
      if (fileInfo != null) {
        final age = DateTime.now().difference(fileInfo.file.lastModifiedSync());
        if (age < cacheDuration) {
          return fileInfo.file;
        }
      }

      // If not in cache or expired, download and cache
      final response = await apiService.dio.get(
        imageUrl,
        options: Options(
          headers: apiService.dio.options.headers,
          responseType: ResponseType.bytes,
        ),
      );

      final file = await _cacheManager.putFile(
        imageUrl,
        response.data,
        key: cacheKey,
        maxAge: cacheDuration,
      );

      return file;
    } catch (e) {
      print('Error getting course thumbnail file: $e');
      return null;
    }
  }

  /// Widget to display course thumbnail from cache
  Widget getCourseImage({
    required CourseModel course,
    BoxFit? fit,
    Widget? placeholder,
    double? width,
    double? height,
  }) {
    if (course.thumbnail.startsWith('assets/')) {
      return Image.asset(
        course.thumbnail,
        fit: fit ?? BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ?? _buildPlaceholder(width: width, height: height),
      );
    }

    return FutureBuilder<File?>(
      future: getCourseThumbnailFile(course),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? _buildPlaceholder(width: width, height: height);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          print('Error loading course image: ${snapshot.error}');
          return placeholder ?? _buildPlaceholder(width: width, height: height);
        }

        return Image.file(
          snapshot.data!,
          fit: fit ?? BoxFit.cover,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) {
            print('Error displaying course image: $error');
            return placeholder ??
                _buildPlaceholder(width: width, height: height);
          },
        );
      },
    );
  }

  Widget _buildPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 32,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
