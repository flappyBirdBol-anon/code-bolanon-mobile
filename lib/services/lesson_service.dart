import 'dart:io';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:stacked/stacked.dart';

class LessonsService with ReactiveServiceMixin {
  final ApiService apiService;

  // Cache for lessons
  List<Lesson>? _cachedLessons;
  DateTime? _lastCacheTime;
  String? _cachedCourseId;

  // Cache expiration duration (5 minutes)
  final Duration _cacheExpiration = const Duration(minutes: 5);

  // Fix: Use ReactiveValue with List<Lesson>? type for lessons list
  final ReactiveValue<List<Lesson>?> _lessons =
      ReactiveValue<List<Lesson>?>([]);
  List<Lesson>? get lessons => _lessons.value;

  // Fix: Add a separate reactive value for current lesson if needed
  final ReactiveValue<Lesson?> _currentLesson = ReactiveValue<Lesson?>(null);
  Lesson? get currentLesson => _currentLesson.value;

  LessonsService({ApiService? apiService})
      : apiService = apiService ?? locator<ApiService>() {
    // Fix: Move listenToReactiveValues to constructor and listen to both reactive values
    listenToReactiveValues([_lessons, _currentLesson]);
  }

  Future<List<Lesson>> getLessons({
    String? courseId,
    bool forceRefresh = false,
    String? filterBy,
  }) async {
    // Return cached data if available and not expired
    // Only use cache if the requested courseId matches the cached courseId
    if (!forceRefresh &&
        _cachedLessons != null &&
        _lastCacheTime != null &&
        _cachedCourseId == courseId &&
        DateTime.now().difference(_lastCacheTime!) < _cacheExpiration) {
      return _cachedLessons!;
    }

    try {
      // Construct the endpoint with the courseId if provided
      final endpoint =
          courseId != null ? '/lessons/?course_id=$courseId' : '/lessons';
      final response = await apiService.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];

        // Convert JSON to Lesson objects and ensure fileType is set
        _cachedLessons = data.map((json) {
          final lesson = Lesson.fromJson(json);

          // If fileType is null or empty but we have a fileName, determine the type
          if ((lesson.fileType == null || lesson.fileType!.isEmpty) &&
              lesson.fileName != null &&
              lesson.fileName!.isNotEmpty) {
            // Create a temporary file path from the fileName to determine MIME type
            final tempFilePath = path.join('temp', lesson.fileName!);
            lesson.fileType = getMimeType(tempFilePath);
          }

          return lesson;
        }).toList();

        _cachedCourseId = courseId; // Store the courseId for cache validation
        _lessons.value = _cachedLessons; // Update the reactive value
        _lastCacheTime = DateTime.now();
        return _cachedLessons!;
      } else {
        throw Exception('Failed to load lessons: ${response.data['message']}');
      }
    } catch (e) {
      // If we have cached data for the same course, return it even if expired when there's an error
      if (_cachedLessons != null && _cachedCourseId == courseId) {
        return _cachedLessons!;
      }
      throw Exception('Failed to load lessons: $e');
    }
  }

// Get a single lesson by ID (with cache check)
  Future<Lesson?> getLesson(int id, {bool forceRefresh = false}) async {
    // Try to find the lesson in the cache first
    if (!forceRefresh && _cachedLessons != null) {
      final cachedLesson = _cachedLessons!.firstWhere(
        (lesson) => lesson.id == id,
        orElse: () => Lesson(
          id: -1,
          label: '',
          courseId: 1,
          description: '',
          duration: '',
          fileUrl: '',
          fileName: '',
          fileType: '',
        ),
      );

      if (cachedLesson.id != -1) {
        // Ensure fileType is set before returning
        if ((cachedLesson.fileType == null || cachedLesson.fileType!.isEmpty) &&
            cachedLesson.fileName != null &&
            cachedLesson.fileName!.isNotEmpty) {
          final tempFilePath = path.join('temp', cachedLesson.fileName!);
          cachedLesson.fileType = getMimeType(tempFilePath);
        }

        _currentLesson.value = cachedLesson; // Update current lesson
        return cachedLesson;
      }
    }

    // If not in cache or force refresh, get all lessons (which updates cache)
    await getLessons(forceRefresh: forceRefresh);

    // Now try to find the lesson in the updated cache
    if (_cachedLessons != null) {
      try {
        final lesson = _cachedLessons!.firstWhere((lesson) => lesson.id == id);

        // Double-check fileType is set (should be handled in getLessons, but just to be safe)
        if ((lesson.fileType == null || lesson.fileType!.isEmpty) &&
            lesson.fileName != null &&
            lesson.fileName!.isNotEmpty) {
          final tempFilePath = path.join('temp', lesson.fileName!);
          lesson.fileType = getMimeType(tempFilePath);
        }

        _currentLesson.value = lesson; // Update current lesson
        return lesson;
      } catch (e) {
        _currentLesson.value = null;
        return null;
      }
    }

    _currentLesson.value = null;
    return null;
  }

// Create a new lesson
  Future<Lesson> createLesson({
    required String label,
    required String description,
    int? courseId,
    required String duration,
    required String filePath,
    required String fileName,
    String? fileType,
  }) async {
    try {
      // Create a File object from the file path
      final file = File(filePath);

      // Determine file type if not provided
      final actualFileType = fileType ?? getMimeType(filePath);

      // Prepare the fields
      final fields = {
        'label': label,
        'description': description,
        'duration': duration,
        'course_id': courseId.toString(),
        'fileType': actualFileType, // Add file type to the fields
      };

      // Prepare the file
      final files = {
        'file': PlatformFile(
          path: filePath,
          name: fileName,
          size: await file.length(),
          bytes: await file.readAsBytes(),
        )
      };

      // Upload the file and create the lesson
      final response = await apiService.uploadLessonFile(
        '/lessons',
        fields: fields,
        files: files,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['data'] == null) {
          throw Exception('Server returned null data');
        }

        final newLesson = Lesson.fromJson(response.data['data']);

        // Update the cache with the new lesson
        if (_cachedLessons != null) {
          _cachedLessons!.add(newLesson);
          _lessons.value = _cachedLessons; // Update reactive value
        } else {
          // Initialize cache if it doesn't exist
          _cachedLessons = [newLesson];
          _lessons.value = _cachedLessons; // Update reactive value
          _lastCacheTime = DateTime.now();
        }

        _currentLesson.value = newLesson; // Set as current lesson
        return newLesson;
      } else {
        throw Exception('Failed to create lesson: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to create lesson: $e');
    }
  }

  Future<Lesson> updateLesson({
    required int id,
    required String label,
    required String description,
    required String duration,
    String? courseId,
    String? filePath,
    String? fileName,
    String? fileType,
  }) async {
    try {
      Lesson updatedLesson;

      if (filePath != null && fileName != null) {
        // If there's a new file, use uploadFile
        final file = File(filePath);

        // Determine file type if not provided but file path is available
        final actualFileType = fileType ?? getMimeType(filePath);

        final fields = {
          'label': label,
          'description': description,
          'duration': duration,
          'course_id': courseId ?? '',
          'fileType': actualFileType, // Add file type to the fields
          '_method': 'PUT', // Method spoofing for Laravel
        };

        final files = {
          'file': PlatformFile(
            path: filePath,
            name: fileName,
            size: await file.length(),
            bytes: await file.readAsBytes(),
          )
        };

        final response = await apiService.uploadLessonFile(
          '/lessons/$id',
          fields: fields,
          files: files,
          method: 'PUT',
        );

        if (response.statusCode == 200) {
          updatedLesson = Lesson.fromJson(response.data['data']);
        } else {
          throw Exception(
              'Failed to update lesson: ${response.data['message']}');
        }
      } else {
        // If there's no new file, use regular PUT
        final data = {
          'label': label,
          'description': description,
          'duration': duration,
          // Don't update fileType if no new file is provided
        };

        final response = await apiService.put('/lessons/$id', data: data);

        if (response.statusCode == 200) {
          updatedLesson = Lesson.fromJson(response.data['data']);
        } else {
          throw Exception(
              'Failed to update lesson: ${response.data['message']}');
        }
      }

      // Update the lesson in the cache
      if (_cachedLessons != null) {
        final index = _cachedLessons!.indexWhere((lesson) => lesson.id == id);
        if (index != -1) {
          _cachedLessons![index] = updatedLesson;
          _lessons.value = _cachedLessons; // Update reactive value
        }
      }

      // Update current lesson if it's the one being edited
      if (_currentLesson.value?.id == id) {
        _currentLesson.value = updatedLesson;
      }

      return updatedLesson;
    } catch (e) {
      throw Exception('Failed to update lesson: $e');
    }
  }

  // Delete a lesson
  Future<bool> deleteLesson(int id) async {
    try {
      final response = await apiService.dio.delete('/lessons/$id');

      final success = response.statusCode == 200 || response.statusCode == 204;

      // Remove the lesson from the cache if deletion was successful
      if (success && _cachedLessons != null) {
        _cachedLessons!.removeWhere((lesson) => lesson.id == id);
        _lessons.value = _cachedLessons; // Update reactive value

        // Clear current lesson if it's the one being deleted
        if (_currentLesson.value?.id == id) {
          _currentLesson.value = null;
        }
      }

      return success;
    } catch (e) {
      throw Exception('Failed to delete lesson: $e');
    }
  }

  // Clear the cache
  void clearCache() {
    _cachedLessons = null;
    _lastCacheTime = null;
    _lessons.value = null;
    _currentLesson.value = null;
  }

  // Helper method to get MIME type from file extension
  String getMimeType(String filePath) {
    // First try using the mime package
    final mimeType = lookupMimeType(filePath);

    if (mimeType != null) {
      return mimeType;
    }

    // Fallback to extension-based detection
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.pdf':
        return 'application/pdf';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.ppt':
      case '.pptx':
        return 'application/vnd.ms-powerpoint';
      case '.xls':
      case '.xlsx':
        return 'application/vnd.ms-excel';
      case '.txt':
        return 'text/plain';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.mp4':
        return 'video/mp4';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      default:
        return 'application/octet-stream';
    }
  }

  // Helper method to pick a file
  Future<PlatformFile?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }
}
