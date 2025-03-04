// lib/services/image_service.dart
import 'dart:io';
import 'dart:typed_data';
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

//memcache
  final Map<String, Uint8List> _memoryCache = {};

  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  // Optional caching parameters
  final bool enableCache;
  final Duration cacheDuration;

  ImageService({
    required String baseUrl,
    required ApiService apiService,
    required Dio dioo,
    this.enableCache = true,
    this.cacheDuration = const Duration(days: 3),
  })  : _baseUrl = baseUrl,
        _apiService = apiService,
        dio = dioo;

  String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;

    // Ensure path has no leading slash
    final cleanPath =
        imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;

    // If it's a thumbnail path from the API (like "thumbnails/filename.png")
    // we need to append it directly to the base URL
    return '$_baseUrl/$cleanPath';
  }

  String getCourseThumbnailFromPath(String thumbnailPath) {
    // For paths like "thumbnails/1740558233_scaled_Screenshot_20250221-100502_code_bolanon.png"
    return '$_baseUrl/$thumbnailPath';
  }

  /// Get the full URL to a course thumbnail by course ID
  String getCourseThumbnailUrl(String courseId) {
    return '$_baseUrl/images/$courseId';
  }

  /// Get the full URL to an uploaded image by filename
  String getUploadedImageUrl(String filename) {
    return '$_baseUrl/image/$filename';
  }

  /// Download and cache an image (useful for sharing or offline use)
  Future<File?> downloadAndCacheImage(String imageUrl,
      {String? customFileName}) async {
    try {
      // Create a filename from the URL or use provided filename
      final fileName = customFileName ?? path.basename(imageUrl);

      // Get temp directory for caching
      final tempDir = await getTemporaryDirectory();
      final filePath = path.join(tempDir.path, fileName);

      // Check if file exists and not expired
      final file = File(filePath);
      if (enableCache && file.existsSync()) {
        final lastModified = file.lastModifiedSync();
        if (DateTime.now().difference(lastModified) < cacheDuration) {
          // Return cached file if not expired
          return file;
        }
      }

      // Download the file
      final response = await dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to file
      await file.writeAsBytes(response.data);
      return file;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  /// Get image bytes directly (useful for image manipulation or custom rendering)
  Future<Uint8List?> getImageBytes(String imageUrl) async {
    try {
      final response = await dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      print('Error getting image bytes: $e');
      return null;
    }
  }

  /// Load an image with authentication
  Widget loadImage({
    required String imageUrl,
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

    // Use a FutureBuilder to load the image with authentication
    return FutureBuilder<File>(
      future: _getImageWithAuth(imageUrl),
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

  /// Get image file with authentication and caching
  Future<File> _getImageWithAuth(String imageUrl) async {
    // Check if cached version exists and is not expired
    final fileInfo = await _cacheManager.getFileFromCache(imageUrl);

    if (fileInfo != null && enableCache) {
      final age = DateTime.now().difference(fileInfo.file.lastModifiedSync());
      if (age < cacheDuration) {
        return fileInfo.file;
      }
    }

    // Download with authentication
    try {
      final response = await _apiService.dio.get(
        imageUrl,
        options: Options(
          headers: _apiService.dio.options.headers,
          responseType: ResponseType.bytes,
        ),
      );

      // Save to cache
      final file = await _cacheManager.putFile(
        imageUrl,
        response.data,
        maxAge: cacheDuration,
      );

      return file;
    } catch (e) {
      print('Error downloading image: $e');
      throw Exception('Failed to load image: $e');
    }
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

  // Preload and cache an image for smoother UI
  Future<void> preloadImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    try {
      await _getImageWithAuth(imageUrl);
    } catch (e) {
      print('Error preloading image: $e');
    }
  }

  // Clear cached images (call this when low on memory)
  void clearCache() {
    _memoryCache.clear();
  }
}
