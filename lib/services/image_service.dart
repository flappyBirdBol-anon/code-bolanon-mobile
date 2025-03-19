import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Isolate-friendly data structure for image processing
class _ImageProcessingData {
  final String imageUrl;
  final String? courseId;
  final Uint8List? imageData;

  _ImageProcessingData({
    required this.imageUrl,
    this.courseId,
    this.imageData,
  });
}

// Isolate function for image processing
Future<Uint8List?> _processImageInIsolate(_ImageProcessingData data) async {
  // This runs in a separate isolate
  if (data.imageData != null) {
    // Here you could add image optimization if needed
    // For example: resize, compress, etc.
    return data.imageData;
  }
  return null;
}

class ImageService {
  final String baseUrl;
  final Dio dio;
  final ApiService apiService;

  // Memory cache for faster access to frequently used images
  // Using LRU (Least Recently Used) pattern with size limit
  final Map<String, Uint8List> _memoryCache = {};
  final int _memoryCacheSize = 50; // Maximum number of images to keep in memory
  final List<String> _cacheKeyOrder = []; // Track LRU order

  // Disk cache manager with custom settings for better performance
  late final DefaultCacheManager _cacheManager;

  // Cache configuration
  final bool enableCache;
  final Duration cacheDuration;

  // Event tracking for prefetching
  bool _isBatchCaching = false;

  // Lazy initialization flag
  bool _isInitialized = false;

  ImageService({
    this.baseUrl = 'http://codebolanon.commesr.io/api',
    ApiService? apiService,
    Dio? dioo,
    this.enableCache = true,
    this.cacheDuration = const Duration(hours: 12),
  })  : apiService = apiService ?? locator<ApiService>(),
        dio = dioo ?? locator<ApiService>().dio {
    // Lazy initialization of cache manager
    _initializeCacheManager();
  }

  // Lazy initialization method
  void _initializeCacheManager() {
    if (!_isInitialized) {
      _cacheManager = DefaultCacheManager();
      _isInitialized = true;
    }
  }

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
  /// Uses compute to process in the background
  Future<void> prefetchCourseImages(List<CourseModel> courses) async {
    if (!enableCache || courses.isEmpty) return;

    try {
      _isBatchCaching = true;

      // Prioritize visible courses (e.g., first 5-10)
      final visibleCourses = courses.take(10).toList();
      final remainingCourses = courses.skip(10).toList();

      // Process visible courses immediately
      await _processCourseGroup(visibleCourses);

      // Process remaining courses with a slight delay to not block UI
      if (remainingCourses.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _processCourseGroup(remainingCourses);
        });
      }
    } catch (e) {
      print('Error prefetching course images: $e');
    } finally {
      _isBatchCaching = false;
    }
  }

  // Helper method to process a group of courses
  Future<void> _processCourseGroup(List<CourseModel> courses) async {
    final futures = <Future>[];

    for (final course in courses) {
      if (course.thumbnail.isNotEmpty) {
        final imageUrl = getCourseThumbnailFromPath(course.thumbnail);
        futures.add(prefetchImage(imageUrl, courseId: course.id));
      }
    }

    // Process in chunks to avoid memory pressure
    const chunkSize = 5;
    for (var i = 0; i < futures.length; i += chunkSize) {
      final end =
          (i + chunkSize < futures.length) ? i + chunkSize : futures.length;
      await Future.wait(futures.sublist(i, end));
    }
  }

  /// Prefetches and caches a single image
  /// Uses compute for image processing
  Future<void> prefetchImage(String imageUrl, {String? courseId}) async {
    if (imageUrl.isEmpty || !enableCache) return;

    // Ensure cache manager is initialized
    _initializeCacheManager();

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
          _addToMemoryCache(cacheKey, bytes);
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

      // Process image in background using compute
      final processedData = await compute(
        _processImageInIsolate,
        _ImageProcessingData(
          imageUrl: imageUrl,
          courseId: courseId,
          imageData: response.data,
        ),
      );

      // If processing was successful, cache the result
      if (processedData != null) {
        // Save to disk cache
        await _cacheManager.putFile(
          imageUrl,
          processedData,
          maxAge: cacheDuration,
        );

        // Save to memory cache
        _addToMemoryCache(cacheKey, processedData);
      } else {
        // Fall back to original data if processing failed
        await _cacheManager.putFile(
          imageUrl,
          response.data,
          maxAge: cacheDuration,
        );

        _addToMemoryCache(cacheKey, response.data);
      }
    } catch (e) {
      print('Error prefetching image: $e');
    }
  }

  // Add to memory cache with LRU eviction policy
  void _addToMemoryCache(String key, Uint8List data) {
    // If key already exists, update its position in the LRU order
    if (_memoryCache.containsKey(key)) {
      _cacheKeyOrder.remove(key);
      _cacheKeyOrder.add(key);
      _memoryCache[key] = data;
      return;
    }

    // If cache is full, remove the least recently used item
    if (_cacheKeyOrder.length >= _memoryCacheSize &&
        _cacheKeyOrder.isNotEmpty) {
      final lruKey = _cacheKeyOrder.removeAt(0);
      _memoryCache.remove(lruKey);
    }

    // Add new item to cache
    _cacheKeyOrder.add(key);
    _memoryCache[key] = data;
  }

  // Get image from cache with optimized lookup
  Future<Uint8List?> getCachedImage(String imageUrl, {String? courseId}) async {
    if (imageUrl.isEmpty || !enableCache) return null;

    // Ensure cache manager is initialized
    _initializeCacheManager();

    final cacheKey = courseId != null ? 'course_${courseId}_image' : imageUrl;

    // First check memory cache (fastest)
    if (_memoryCache.containsKey(cacheKey)) {
      // Update LRU order
      _cacheKeyOrder.remove(cacheKey);
      _cacheKeyOrder.add(cacheKey);
      return _memoryCache[cacheKey];
    }

    // Then check disk cache
    try {
      final fileInfo = await _cacheManager.getFileFromCache(imageUrl);
      if (fileInfo != null) {
        final bytes = await fileInfo.file.readAsBytes();
        _addToMemoryCache(cacheKey, bytes);
        return bytes;
      }
    } catch (e) {
      print('Error retrieving cached image: $e');
    }

    return null;
  }

  // Clear memory cache to free up resources
  void clearMemoryCache() {
    _memoryCache.clear();
    _cacheKeyOrder.clear();
  }

  // Clear disk cache
  Future<void> clearDiskCache() async {
    await _cacheManager.emptyCache();
  }

  // Optimized image provider to use with CachedNetworkImage
  ImageProvider getOptimizedImageProvider(String imageUrl, {String? courseId}) {
    final fullUrl =
        imageUrl.startsWith('http') ? imageUrl : getImageUrl(imageUrl);

    return CachedNetworkImageProvider(
      fullUrl,
      cacheManager: _cacheManager,
    );
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
                  child:
                      const CircularProgressIndicator(color: AppColors.primary),
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
                color: AppColors.primary,
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

  /// Gets profile image widget
  Widget getProfileImageWidget({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildPlaceholder(width: width, height: height);
    }

    // For local files
    if (imageUrl.startsWith('/data/') || imageUrl.startsWith('file://')) {
      final filePath = imageUrl.replaceAll('file://', '');
      final file = File(filePath);
      if (!file.existsSync()) {
        return errorWidget ?? _buildPlaceholder(width: width, height: height);
      }
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildPlaceholder(width: width, height: height),
      );
    }

    // For network images
    return CachedNetworkImage(
      imageUrl: getImageUrl(imageUrl),
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ?? _buildPlaceholder(width: width, height: height),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildPlaceholder(width: width, height: height),
    );
  }

  /// Gets the profile picture URL from a path
  String getProfilePictureUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.startsWith('assets/')) return imagePath;
    if (imagePath.startsWith('/data/') || imagePath.startsWith('file://')) {
      return imagePath.replaceAll('file://', '');
    }

    // Clean and construct the path for network images
    final cleanPath =
        imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$baseUrl/$cleanPath';
  }
}
