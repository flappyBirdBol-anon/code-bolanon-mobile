import 'dart:io';
import 'dart:typed_data';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/ui/common/widgets/file_viewer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:open_file/open_file.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

class FileService {
  final String baseUrl;
  final Dio dio;
  final ApiService apiService;
  final Map<String, Uint8List> _memoryCache = {};
  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  final bool enableCache;
  final Duration cacheDuration;
  final Map<String, String> _urlToFilePathMap =
      {}; // Track file paths with extensions

  FileService({
    this.baseUrl = 'http://codebolanon.commesr.io/api',
    ApiService? apiService,
    Dio? dioo,
    this.enableCache = true,
    this.cacheDuration = const Duration(days: 7),
  })  : apiService = apiService ?? locator<ApiService>(),
        dio = dioo ?? locator<ApiService>().dio;

  String getFileUrl(String fileName) {
    if (fileName.isEmpty) return '';
    if (fileName.startsWith('http')) return fileName;

    final cleanName =
        fileName.startsWith('/') ? fileName.substring(1) : fileName;
    return '$baseUrl/lessons/files/$cleanName';
  }

  String getLessonFileUrl(Lesson lesson) {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) return '';

    if (lesson.fileUrl != null && lesson.fileUrl!.isNotEmpty) {
      print("lesson.fileUrl: ${lesson.fileUrl}");
      return lesson.fileUrl!;
    }
    print("lesson.fileUrl: ${lesson.fileName}");
    return getFileUrl(lesson.fileName!);
  }

  String _getFileExtension(String fileName) {
    return path.extension(fileName).toLowerCase();
  }

  // Helper method to create a file with the correct extension
  Future<File> _createFileWithExtension(
      Uint8List bytes, String fileName) async {
    final extension = _getFileExtension(fileName);
    final cacheDir = await getTemporaryDirectory();
    final uuid = Uuid().v4();
    final filePath = '${cacheDir.path}/$uuid$extension';

    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> prefetchLessonFiles(List<Lesson> lessons) async {
    if (!enableCache || lessons.isEmpty) return;

    try {
      final futures = <Future>[];

      for (final lesson in lessons) {
        if (lesson.fileName != null && lesson.fileName!.isNotEmpty) {
          final fileUrl = getLessonFileUrl(lesson);
          futures.add(prefetchFile(fileUrl,
              lessonId: lesson.id.toString(), fileName: lesson.fileName));
        }
      }

      await Future.wait(futures);
    } catch (e) {
      print('Error prefetching lesson files: $e');
    }
  }

  Future<void> prefetchFile(String fileUrl,
      {String? lessonId, String? fileName}) async {
    if (fileUrl.isEmpty || !enableCache) return;

    try {
      final cacheKey = lessonId != null && fileName != null
          ? 'lesson_${lessonId}_file_$fileName'
          : fileUrl;

      if (_memoryCache.containsKey(cacheKey)) return;

      // Check if we already have this file cached with the correct extension
      if (_urlToFilePathMap.containsKey(fileUrl)) {
        final cachedFilePath = _urlToFilePathMap[fileUrl];
        final cachedFile = File(cachedFilePath!);
        if (await cachedFile.exists()) {
          final age =
              DateTime.now().difference(await cachedFile.lastModified());
          if (age < cacheDuration) {
            if (await cachedFile.length() < 5 * 1024 * 1024) {
              final bytes = await cachedFile.readAsBytes();
              _memoryCache[cacheKey] = bytes;
            }
            return;
          }
        }
      }

      final response = await apiService.dio.get(
        fileUrl,
        options: Options(
          headers: apiService.dio.options.headers,
          responseType: ResponseType.bytes,
        ),
      );

      // Create a file with the correct extension
      if (fileName != null) {
        final file = await _createFileWithExtension(response.data, fileName);
        _urlToFilePathMap[fileUrl] = file.path;

        // Also store in the cache manager for compatibility
        await _cacheManager.putFile(
          fileUrl,
          response.data,
          maxAge: cacheDuration,
        );

        if (response.data.length < 5 * 1024 * 1024) {
          _memoryCache[cacheKey] = response.data;
        }
      } else {
        // Fallback to regular cache manager if no filename is provided
        await _cacheManager.putFile(
          fileUrl,
          response.data,
          maxAge: cacheDuration,
        );

        if (response.data.length < 5 * 1024 * 1024) {
          _memoryCache[cacheKey] = response.data;
        }
      }

      print('File cached successfully: $fileUrl');
    } catch (e) {
      print('Error prefetching file: $e');
    }
  }

  Future<void> handleLessonFileCacheUpdate(Lesson lesson) async {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) return;

    final fileUrl = getLessonFileUrl(lesson);

    await _cacheManager.removeFile(fileUrl);
    _memoryCache.remove('lesson_${lesson.id}_file_${lesson.fileName}');

    // Remove from our custom file path map
    if (_urlToFilePathMap.containsKey(fileUrl)) {
      final filePath = _urlToFilePathMap[fileUrl];
      final file = File(filePath!);
      if (await file.exists()) {
        await file.delete();
      }
      _urlToFilePathMap.remove(fileUrl);
    }

    await prefetchFile(fileUrl,
        lessonId: lesson.id.toString(), fileName: lesson.fileName);
  }

  Future<Uint8List?> getFileBytes(String fileUrl,
      {String? lessonId, String? fileName}) async {
    if (fileUrl.isEmpty) return null;

    final cacheKey = lessonId != null && fileName != null
        ? 'lesson_${lessonId}_file_$fileName'
        : fileUrl;

    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey];
    }

    try {
      // First check our custom cache with preserved extensions
      if (_urlToFilePathMap.containsKey(fileUrl)) {
        final filePath = _urlToFilePathMap[fileUrl];
        final file = File(filePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (bytes.length < 5 * 1024 * 1024) {
            _memoryCache[cacheKey] = bytes;
          }
          return bytes;
        }
      }

      // Fallback to regular cache manager
      final fileInfo = await _cacheManager.getFileFromCache(fileUrl);
      if (fileInfo != null) {
        final bytes = await fileInfo.file.readAsBytes();
        if (bytes.length < 5 * 1024 * 1024) {
          _memoryCache[cacheKey] = bytes;
        }
        return bytes;
      }

      await prefetchFile(fileUrl, lessonId: lessonId, fileName: fileName);

      if (_memoryCache.containsKey(cacheKey)) {
        return _memoryCache[cacheKey];
      }

      // Check our custom cache again after prefetching
      if (_urlToFilePathMap.containsKey(fileUrl)) {
        final filePath = _urlToFilePathMap[fileUrl];
        final file = File(filePath!);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }

      // Fallback to regular cache manager
      final newFileInfo = await _cacheManager.getFileFromCache(fileUrl);
      if (newFileInfo != null) {
        return await newFileInfo.file.readAsBytes();
      }

      return null;
    } catch (e) {
      print('Error getting file bytes: $e');
      return null;
    }
  }

  Future<File?> getCachedFile(String fileUrl, {String? fileName}) async {
    if (fileUrl.isEmpty) return null;

    try {
      // First check our custom cache with preserved extensions
      if (_urlToFilePathMap.containsKey(fileUrl)) {
        final filePath = _urlToFilePathMap[fileUrl];
        final file = File(filePath!);
        if (await file.exists()) {
          return file;
        }
      }

      // Fallback to regular cache manager
      final fileInfo = await _cacheManager.getFileFromCache(fileUrl);
      if (fileInfo != null) {
        return fileInfo.file;
      }

      final response = await apiService.dio.get(
        fileUrl,
        options: Options(
          headers: apiService.dio.options.headers,
          responseType: ResponseType.bytes,
        ),
      );

      // If we have a fileName, create a file with the correct extension
      if (fileName != null) {
        final file = await _createFileWithExtension(response.data, fileName);
        _urlToFilePathMap[fileUrl] = file.path;

        // Also store in the cache manager for compatibility
        await _cacheManager.putFile(
          fileUrl,
          response.data,
          maxAge: cacheDuration,
        );

        return file;
      } else {
        // Fallback to regular cache manager if no filename is provided
        final file = await _cacheManager.putFile(
          fileUrl,
          response.data,
          maxAge: cacheDuration,
        );

        return file;
      }
    } catch (e) {
      print('Error getting cached file: $e');
      return null;
    }
  }

  Future<OpenResult> openFile(String fileUrl, {String? fileName}) async {
    try {
      final file = await getCachedFile(fileUrl, fileName: fileName);
      if (file == null) {
        return OpenResult(
          type: ResultType.error,
          message: 'File not found',
        );
      }

      return await OpenFile.open(file.path);
    } catch (e) {
      print('Error opening file: $e');
      return OpenResult(
        type: ResultType.error,
        message: 'Error opening file: $e',
      );
    }
  }

  Future<OpenResult> openLessonFile(Lesson lesson) async {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      return OpenResult(
        type: ResultType.error,
        message: 'No file available for this lesson',
      );
    }

    final fileUrl = getLessonFileUrl(lesson);
    return await openFile(fileUrl, fileName: lesson.fileName);
  }

  String getFileType(String fileName) {
    if (fileName.isEmpty) return 'unknown';

    final extension = path.extension(fileName).toLowerCase();
    final mimeType = lookupMimeType(fileName);

    if (extension == '.pdf') return 'pdf';
    if (extension == '.doc' || extension == '.docx') return 'document';
    if (extension == '.xls' || extension == '.xlsx') return 'spreadsheet';
    if (extension == '.ppt' || extension == '.pptx') return 'presentation';
    if (extension == '.txt') return 'text';

    if (mimeType?.startsWith('image/') ?? false) return 'image';
    if (mimeType?.startsWith('video/') ?? false) return 'video';
    if (mimeType?.startsWith('audio/') ?? false) return 'audio';

    return 'other';
  }

  Widget renderFile({
    required Lesson lesson,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      return _buildErrorWidget(width, height, errorWidget);
    }

    final fileUrl = getLessonFileUrl(lesson);
    final fileType = lesson.fileType != null
        ? lesson.fileType!
        : getFileType(lesson.fileName!);

    return FileViewer(
      fileUrl: fileUrl,
      fileType: fileType,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  Widget _buildErrorWidget(
      double? width, double? height, Widget? customWidget) {
    return customWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey[600], size: 48),
              SizedBox(height: 8),
              Text(
                'File not available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
  }

  Future<File?> downloadFile(Lesson lesson) async {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      return null;
    }

    final fileUrl = getLessonFileUrl(lesson);
    final fileName = lesson.fileName!;

    try {
      final cachedFile = await getCachedFile(fileUrl, fileName: fileName);
      if (cachedFile == null) {
        throw Exception('Failed to get cached file');
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access external storage');
      }

      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final destinationPath = '${downloadsDir.path}/$fileName';
      final destinationFile = File(destinationPath);

      await cachedFile.copy(destinationPath);

      print('File downloaded to: $destinationPath');
      return destinationFile;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  Future<bool> isFileCached(Lesson lesson) async {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      return false;
    }

    final fileUrl = getLessonFileUrl(lesson);

    // Check our custom cache first
    if (_urlToFilePathMap.containsKey(fileUrl)) {
      final filePath = _urlToFilePathMap[fileUrl];
      final file = File(filePath!);
      if (await file.exists()) {
        return true;
      }
    }

    // Fallback to regular cache manager
    final fileInfo = await _cacheManager.getFileFromCache(fileUrl);
    return fileInfo != null;
  }

  Future<String> getFileSize(Lesson lesson, {bool cached = true}) async {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      return 'No file';
    }

    final fileUrl = getLessonFileUrl(lesson);

    try {
      File? file;

      if (cached) {
        file = await getCachedFile(fileUrl, fileName: lesson.fileName);
      }

      if (file == null && !cached) {
        final response = await apiService.dio.get(
          fileUrl,
          options: Options(
            headers: apiService.dio.options.headers,
          ),
        );

        final contentLength = response.headers.value('content-length');
        if (contentLength != null) {
          final bytes = int.parse(contentLength);
          return _formatBytes(bytes);
        }

        return 'Unknown size';
      } else if (file != null) {
        final bytes = await file.length();
        return _formatBytes(bytes);
      }

      return 'Unknown size';
    } catch (e) {
      print('Error getting file size: $e');
      return 'Unknown size';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Stream<List<int>> streamFile(Lesson lesson) async* {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      yield [];
      return;
    }

    final fileUrl = getLessonFileUrl(lesson);

    try {
      // Check our custom cache first
      if (_urlToFilePathMap.containsKey(fileUrl)) {
        final filePath = _urlToFilePathMap[fileUrl];
        final file = File(filePath!);
        if (await file.exists()) {
          yield* file.openRead();
          return;
        }
      }

      // Fallback to regular cache manager
      final fileInfo = await _cacheManager.getFileFromCache(fileUrl);
      if (fileInfo != null) {
        yield* fileInfo.file.openRead();
        return;
      }

      final response = await apiService.dio.get(
        fileUrl,
        options: Options(
          headers: apiService.dio.options.headers,
          responseType: ResponseType.bytes,
        ),
      );

      yield* response.data.bytes;

      // Cache the file with the correct extension if possible
      if (lesson.fileName != null) {
        final bytes = Uint8List.fromList(
            response.data.bytes.expand((chunk) => chunk).toList());
        final file = await _createFileWithExtension(bytes, lesson.fileName!);
        _urlToFilePathMap[fileUrl] = file.path;
      }

      // Also cache in the regular cache manager for compatibility
      response.data.bytes.toList().then((chunks) {
        final bytes = chunks.expand((chunk) => chunk).toList();
        _cacheManager.putFile(
          fileUrl,
          Uint8List.fromList(bytes),
          maxAge: cacheDuration,
        );
      });
    } catch (e) {
      print('Error streaming file: $e');
      yield [];
    }
  }

  Widget getFileTypeIcon(Lesson lesson, {double size = 24, Color? color}) {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      return Icon(
        Icons.insert_drive_file,
        size: size,
        color: color ?? Colors.grey,
      );
    }

    return Icon(
      lesson.getFileIcon(),
      size: size,
      color: color,
    );
  }

  Widget buildFileListItem(
    BuildContext context,
    Lesson lesson, {
    VoidCallback? onTap,
    VoidCallback? onDownload,
  }) {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      return SizedBox.shrink();
    }

    return FutureBuilder<String>(
      future: getFileSize(lesson),
      builder: (context, snapshot) {
        final fileSize = snapshot.data ?? 'Unknown size';

        return ListTile(
          leading: getFileTypeIcon(lesson, size: 36),
          title: Text(
            lesson.fileName ?? 'Unnamed file',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(fileSize),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onDownload != null)
                IconButton(
                  icon: Icon(Icons.download),
                  onPressed: onDownload,
                  tooltip: 'Download',
                ),
              IconButton(
                icon: Icon(Icons.open_in_new),
                onPressed: onTap ?? () => openLessonFile(lesson),
                tooltip: 'Open',
              ),
            ],
          ),
          onTap: onTap ?? () => openLessonFile(lesson),
        );
      },
    );
  }

  Future<void> clearCache() async {
    _memoryCache.clear();

    // Clear our custom cache with preserved extensions
    for (final filePath in _urlToFilePathMap.values) {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _urlToFilePathMap.clear();

    // Also clear the regular cache manager
    await _cacheManager.emptyCache();
  }

  Future<void> clearLessonCache(String lessonId) async {
    // Clear from memory cache
    _memoryCache.removeWhere(
        (key, value) => key.startsWith('lesson_${lessonId}_file_'));

    // Find and clear files from our custom cache
    final keysToRemove = <String>[];
    for (final entry in _urlToFilePathMap.entries) {
      final url = entry.key;
      final filePath = entry.value;

      // Check if this URL is related to the lesson
      if (_memoryCache.keys.any((key) =>
          key.startsWith('lesson_${lessonId}_file_') && key.contains(url))) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
        keysToRemove.add(url);
      }
    }

    // Remove the keys
    for (final key in keysToRemove) {
      _urlToFilePathMap.remove(key);
    }
  }

  Future<bool> isFileDownloadable(Lesson lesson) async {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      return false;
    }

    final fileUrl = getLessonFileUrl(lesson);

    try {
      final response = await apiService.dio.get(
        fileUrl,
        options: Options(
          headers: apiService.dio.options.headers,
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error checking file downloadability: $e');
      return false;
    }
  }

  Future<List<File>> getCachedFilesForLesson(String lessonId) async {
    try {
      final cachedFiles = <File>[];

      final matchingKeys = _memoryCache.keys
          .where((key) => key.startsWith('lesson_${lessonId}_file_'))
          .toList();

      for (final key in matchingKeys) {
        final parts = key.split('_file_');
        if (parts.length > 1) {
          final fileName = parts[1];
          final fileUrl = getFileUrl(fileName);

          // Check our custom cache first
          if (_urlToFilePathMap.containsKey(fileUrl)) {
            final filePath = _urlToFilePathMap[fileUrl];
            final file = File(filePath!);
            if (await file.exists()) {
              cachedFiles.add(file);
              continue;
            }
          }

          // Fallback to regular cache manager
          final fileInfo = await _cacheManager.getFileFromCache(fileUrl);
          if (fileInfo != null) {
            cachedFiles.add(fileInfo.file);
          }
        }
      }

      return cachedFiles;
    } catch (e) {
      print('Error getting cached files for lesson: $e');
      return [];
    }
  }

  Future<void> prefetchFilesForCourse(List<Lesson> courseLessons) async {
    await prefetchLessonFiles(courseLessons);
  }

  bool hasFile(Lesson lesson) {
    return lesson.fileName != null && lesson.fileName!.isNotEmpty;
  }
}
