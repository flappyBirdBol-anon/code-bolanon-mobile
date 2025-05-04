import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/completed_lesson_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CompletedLessonService with ListenableServiceMixin {
  final _apiService = locator<ApiService>();
  final _registrationService = locator<RegistrationService>();
  final _snackbarService = locator<SnackbarService>();

  final ReactiveValue<List<CompletedLessonModel>> _completedLessons =
      ReactiveValue<List<CompletedLessonModel>>([]);
  List<CompletedLessonModel> get completedLessons => _completedLessons.value;

  // Cache to store lesson completions to minimize API calls
  final Map<String, bool> _lessonCompletionCache = {};

  // Registration cache to minimize API calls for finding registrations
  final Map<int, String> _lessonToRegistrationCache = {};

  // Debug flag to enable verbose logging - set to false in production
  final bool _enableDebugLogs = true;

  CompletedLessonService() {
    listenToReactiveValues([_completedLessons]);
  }

  void _log(String message) {
    if (_enableDebugLogs) {
      debugPrint("CompletedLessonService: $message");
    }
  }

  Future<void> fetchCompletedLessons(
      {String? lessonId, String? registrationId, String? courseId}) async {
    try {
      _log(
          "Fetching completed lessons - lessonId: $lessonId, registrationId: $registrationId, courseId: $courseId");

      final queryParams = <String, dynamic>{};
      if (lessonId != null) queryParams['lesson_id'] = lessonId;
      if (registrationId != null)
        queryParams['registration_id'] = registrationId;
      if (courseId != null) queryParams['course_id'] = courseId;

      _log(
          "Sending API request to /completed_lessons with params: $queryParams");
      final response = await _apiService.get('/completed_lessons',
          queryParameters: queryParams);
      _log("API Response status: ${response.statusCode}");

      if (response.data == null) {
        _log("Response data is null, clearing completed lessons");
        _completedLessons.value = [];
        notifyListeners();
        return;
      }

      _log("Raw response data type: ${response.data.runtimeType}");
      final data = response.data;
      List<CompletedLessonModel> parsedLessons = [];

      if (data is List) {
        _log("Response is a List with ${data.length} items");
        parsedLessons = data.map((item) {
          _log("Processing list item: $item");
          return CompletedLessonModel.fromJson(item);
        }).toList();
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        _log(
            "Response is a Map with 'data' key containing ${data['data'].length} items");
        parsedLessons = (data['data'] as List).map((item) {
          _log("Processing data item: $item");
          return CompletedLessonModel.fromJson(item);
        }).toList();
      } else {
        _log("Response format not recognized: ${data.runtimeType}");
        // Try to extract any lessons from the data
        if (data is Map) {
          _log("Attempting to parse as single lesson record");
          try {
            final mapData = Map<String, dynamic>.from(data);
            parsedLessons = [CompletedLessonModel.fromJson(mapData)];
            _log("Successfully parsed as single record");
          } catch (e) {
            _log("Failed to parse as single record: $e");
            parsedLessons = [];
          }
        } else {
          parsedLessons = [];
        }
      }

      // CRITICAL FIX: Filter by registration ID if specified
      if (registrationId != null) {
        _log("Filtering lessons by registration ID: $registrationId");
        final originalCount = parsedLessons.length;
        parsedLessons = parsedLessons
            .where((lesson) => lesson.registrationId == registrationId)
            .toList();
        _log(
            "After filtering: ${parsedLessons.length} of $originalCount lessons match registration ID");
      }

      _log("Successfully parsed ${parsedLessons.length} completed lessons");
      _completedLessons.value = parsedLessons;

      // Log all parsed lessons for debugging
      if (parsedLessons.isNotEmpty) {
        _log(
            "Parsed lesson IDs: ${parsedLessons.map((l) => l.lessonId).join(', ')}");
      }

      // Update the cache with the fetched data
      _log("Updating cache with ${parsedLessons.length} completed lessons");

      // IMPORTANT: If we're filtering by lessonId, only clear cache for that lesson
      if (lessonId != null && registrationId != null) {
        // Only update cache for this specific lesson
        final cacheKey = "${lessonId}_$registrationId";
        // Check if we have a completion record for this lesson
        final hasCompletionRecord = parsedLessons
            .any((lesson) => lesson.lessonId.toString() == lessonId);
        _lessonCompletionCache[cacheKey] = hasCompletionRecord;
        _log(
            "Updated cache for lesson $lessonId: completed=$hasCompletionRecord");
      } else {
        // If not filtering, clear all cache and rebuild
        _lessonCompletionCache.clear();

        // When populating cache from general fetch, be very explicit about which lessons are completed
        for (var lesson in parsedLessons) {
          String cacheKey = "${lesson.lessonId}_${lesson.registrationId}";
          _lessonCompletionCache[cacheKey] =
              true; // Always true if record exists
          _log("Cached lesson ${lesson.lessonId} as completed");
        }
      }

      notifyListeners();
    } catch (e) {
      _log("Error fetching completed lessons: $e");
      _completedLessons.value = [];
      notifyListeners();
      rethrow;
    }
  }

  // Get a cached registration ID for a lesson if available, otherwise fetch it
  Future<String?> getRegistrationIdForLesson(int lessonId) async {
    // Check cache first
    if (_lessonToRegistrationCache.containsKey(lessonId)) {
      return _lessonToRegistrationCache[lessonId];
    }

    try {
      _log("Getting registration ID for lesson $lessonId");

      // Get the course ID for this lesson
      final lessonResponse = await _apiService.get('/lessons/$lessonId');

      if (lessonResponse.statusCode != 200 || lessonResponse.data == null) {
        return null;
      }

      // Extract course ID from lesson data
      String? courseId;
      if (lessonResponse.data is Map && lessonResponse.data['data'] != null) {
        courseId = lessonResponse.data['data']['course_id'].toString();
      } else if (lessonResponse.data is Map) {
        courseId = lessonResponse.data['course_id']?.toString();
      }

      if (courseId == null) {
        return null;
      }

      // Find registration for this course
      final registrations = await _registrationService.getUserRegistrations();

      for (var reg in registrations) {
        if (reg.courseId.toString() == courseId) {
          // Cache the result for future use
          _lessonToRegistrationCache[lessonId] = reg.id;
          return reg.id;
        }
      }

      return null;
    } catch (e) {
      _log("Error getting registration ID: $e");
      return null;
    }
  }

  String _getCacheKey(int lessonId, String registrationId) {
    return "${lessonId}_$registrationId";
  }

  // Optimized isLessonCompleted with better caching
  Future<bool> isLessonCompleted(int lessonId) async {
    try {
      _log("Checking if lesson $lessonId is completed");

      final registrationId = await getRegistrationIdForLesson(lessonId);
      if (registrationId == null) {
        _log("No registration found for lesson $lessonId");
        return false;
      }

      // Create a unique key for this specific lesson+registration combination
      final cacheKey = _getCacheKey(lessonId, registrationId);

      // Check cache first for performance
      if (_lessonCompletionCache.containsKey(cacheKey)) {
        final isCompleted = _lessonCompletionCache[cacheKey] ?? false;
        _log("Cache hit for lesson $lessonId: completed=$isCompleted");
        return isCompleted;
      }

      // Before making an API call, check if there's a record in our completedLessons list
      final matchingCompletions = _completedLessons.value
          .where((completion) =>
              completion.lessonId.toString() == lessonId.toString())
          .toList();

      if (matchingCompletions.isNotEmpty) {
        _log(
            "Found ${matchingCompletions.length} completion records in local list for lesson $lessonId");
        _lessonCompletionCache[cacheKey] = true;
        return true;
      }

      // Not in cache or local list, fetch from API for this specific lesson
      _log("No cache or local data, fetching from API for lesson $lessonId");
      final response =
          await _apiService.get('/completed_lessons', queryParameters: {
        'lesson_id': lessonId.toString(),
        'registration_id': registrationId,
      });

      _log("API response for lesson $lessonId: status=${response.statusCode}");

      if (response.data == null) {
        _log("No data returned for lesson $lessonId");
        _lessonCompletionCache[cacheKey] = false;
        return false;
      }

      final data = response.data;
      List<dynamic> completedLessons = [];

      if (data is List) {
        completedLessons = data;
        _log("Received data as List with ${completedLessons.length} items");
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        completedLessons = data['data'] as List;
        _log(
            "Received data as Map with ${completedLessons.length} items in 'data' key");
      }

      // Filter to only include records matching this specific lesson ID
      List<dynamic> matchingLessons = completedLessons.where((record) {
        return record != null &&
            record['lesson_id'] != null &&
            record['lesson_id'].toString() == lessonId.toString();
      }).toList();

      _log(
          "After filtering, found ${matchingLessons.length} records for lesson $lessonId");

      // A lesson is completed ONLY if there's at least one record for THIS lesson
      final isCompleted = matchingLessons.isNotEmpty;

      // Update cache with result
      _lessonCompletionCache[cacheKey] = isCompleted;
      _log("Setting cache for lesson $lessonId: completed=$isCompleted");

      return isCompleted;
    } catch (e) {
      _log("Error checking completion status: $e");
      return false;
    }
  }

  Future<bool> markLessonAsCompleted(int lessonId) async {
    try {
      _log("Marking lesson $lessonId as completed");

      final registrationId = await getRegistrationIdForLesson(lessonId);
      if (registrationId == null) {
        _log("No registration found for lesson $lessonId");
        return false;
      }

      // Check if already completed
      if (await isLessonCompleted(lessonId)) {
        _log("Lesson $lessonId is already marked as completed");
        return true;
      }

      _log(
          "Creating completion record for lesson $lessonId, registration $registrationId");

      final response = await _apiService.post('/completed_lessons', data: {
        'lesson_id': lessonId.toString(),
        'registration_id': registrationId,
        'is_completed': true,
      });

      final success = response.statusCode == 201 || response.statusCode == 200;

      if (success) {
        _log("Successfully marked lesson $lessonId as completed");

        // Update cache for THIS specific lesson only
        final cacheKey = _getCacheKey(lessonId, registrationId);
        _lessonCompletionCache[cacheKey] = true;

        // Refresh the lesson service to update the completion status
        await _syncWithLessonService(lessonId, true);

        // Refresh the completed lessons list - use specific parameters to avoid refreshing all lessons
        await fetchCompletedLessons(
          lessonId: lessonId.toString(),
          registrationId: registrationId,
        );
      } else {
        _log(
            "Failed to mark lesson $lessonId as completed: status code ${response.statusCode}");
      }

      return success;
    } catch (e) {
      _log("Error marking lesson $lessonId as completed: $e");
      return false;
    }
  }

  Future<bool> markLessonAsIncomplete(int lessonId) async {
    try {
      _log("Marking lesson $lessonId as incomplete");

      final registrationId = await getRegistrationIdForLesson(lessonId);
      if (registrationId == null) {
        _log("No registration found for lesson $lessonId");
        return false;
      }

      // If already incomplete, don't do anything
      if (!await isLessonCompleted(lessonId)) {
        _log("Lesson $lessonId is already marked as incomplete");
        return true;
      }

      _log(
          "Finding completion record for lesson $lessonId, registration $registrationId");

      // Find existing completion record
      final response =
          await _apiService.get('/completed_lessons', queryParameters: {
        'lesson_id': lessonId.toString(),
        'registration_id': registrationId,
      });

      if (response.data == null) {
        _log("No completion data found for lesson $lessonId");
        // Already incomplete so update cache
        final cacheKey = _getCacheKey(lessonId, registrationId);
        _lessonCompletionCache[cacheKey] = false;
        return true;
      }

      final data = response.data;
      List<dynamic> lessons = [];

      if (data is List) {
        lessons = data;
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        lessons = data['data'] as List;
      }

      _log("Found ${lessons.length} completion records in response");

      // CRITICAL FIX: Filter to find only records for THIS specific lesson
      List<dynamic> matchingLessons = lessons.where((record) {
        return record != null &&
            record['lesson_id'] != null &&
            record['lesson_id'].toString() == lessonId.toString();
      }).toList();

      _log(
          "After filtering, found ${matchingLessons.length} records actually for lesson $lessonId");

      if (matchingLessons.isEmpty) {
        _log("No completion records found specifically for lesson $lessonId");
        // Already incomplete so update cache
        final cacheKey = _getCacheKey(lessonId, registrationId);
        _lessonCompletionCache[cacheKey] = false;
        return true;
      }

      // Delete the completion record for THIS specific lesson
      final recordId = matchingLessons.first['id'].toString();
      _log("Deleting completion record $recordId for lesson $lessonId");

      final deleteResponse =
          await _apiService.delete('/completed_lessons/$recordId');

      final success =
          deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204;

      if (success) {
        _log("Successfully marked lesson $lessonId as incomplete");

        // Update cache for THIS specific lesson only
        final cacheKey = _getCacheKey(lessonId, registrationId);
        _lessonCompletionCache[cacheKey] = false;

        // Update the LessonService
        await _syncWithLessonService(lessonId, false);

        // Refresh the completed lessons list - use specific parameters to avoid refreshing all lessons
        await fetchCompletedLessons(
          lessonId: lessonId.toString(),
          registrationId: registrationId,
        );
      } else {
        _log(
            "Failed to mark lesson $lessonId as incomplete: status code ${deleteResponse.statusCode}");
      }

      return success;
    } catch (e) {
      _log("Error marking lesson $lessonId as incomplete: $e");
      return false;
    }
  }

  // Keep the toggleLessonCompletion method which is crucial for user interaction
  Future<bool> toggleLessonCompletion(int lessonId) async {
    try {
      // First check current status
      final isCompleted = await isLessonCompleted(lessonId);
      _log("Toggling lesson $lessonId from $isCompleted to ${!isCompleted}");

      // Toggle based on current status
      bool success;
      if (isCompleted) {
        success = await markLessonAsIncomplete(lessonId);
        if (success) {
          _snackbarService.showCustomSnackBar(
            message: 'Lesson marked as incomplete',
            duration: const Duration(seconds: 2),
            variant: SnackbarType.success,
          );
        }
      } else {
        success = await markLessonAsCompleted(lessonId);
        if (success) {
          _snackbarService.showCustomSnackBar(
            message: 'Lesson marked as completed',
            duration: const Duration(seconds: 2),
            variant: SnackbarType.success,
          );
        }
      }

      // Updated course progress
      if (success) {
        await _syncWithLessonService(lessonId, !isCompleted);
      }

      // Notify listeners to update UI
      notifyListeners();

      return success;
    } catch (e) {
      _log("Toggle error: $e");
      _snackbarService.showCustomSnackBar(
        message: 'Failed to update lesson',
        duration: const Duration(seconds: 3),
        variant: SnackbarType.error,
      );
      return false;
    }
  }

  // Simplified method to sync with LessonService
  Future<void> _syncWithLessonService(int lessonId, bool isCompleted) async {
    try {
      // Get LessonService from locator
      final lessonService = locator<LessonsService>();

      // Update the lesson's completion status
      lessonService.updateLessonCompletionStatus(lessonId, isCompleted);
    } catch (e) {
      _log("Error updating LessonService: $e");
    }
  }

  // Clear the cache when needed
  void clearCache() {
    _lessonCompletionCache.clear();
    _lessonToRegistrationCache.clear();
    _completedLessons.value = [];
    notifyListeners();
  }

  // Public method to sync lesson completion status with course progress
  Future<void> syncLessonCompletionWithCourseProgress(
      int lessonId, bool isCompleted) async {
    try {
      _log("Syncing lesson $lessonId completion status with course progress");
      await _syncWithLessonService(lessonId, isCompleted);
    } catch (e) {
      _log("Error syncing with course progress: $e");
    }
  }

  // Simplified refresh method
  Future<void> refreshAllCompletionData() async {
    try {
      // Only clear the completion cache, not the registration cache
      _lessonCompletionCache.clear();

      // Get all user registrations
      final registrations = await _registrationService.getUserRegistrations();

      for (var registration in registrations) {
        final response = await _apiService.get('/completed_lessons',
            queryParameters: {'registration_id': registration.id});

        if (response.data != null) {
          List<dynamic> completions = [];

          if (response.data is List) {
            completions = response.data;
          } else if (response.data is Map &&
              response.data.containsKey('data') &&
              response.data['data'] is List) {
            completions = response.data['data'] as List;
          }

          // Build the cache with the fetched data
          for (var record in completions) {
            if (record != null && record['lesson_id'] != null) {
              final lessonId = int.parse(record['lesson_id'].toString());
              final cacheKey = _getCacheKey(lessonId, registration.id);
              _lessonCompletionCache[cacheKey] = true;

              // Also cache the lesson to registration mapping
              _lessonToRegistrationCache[lessonId] = registration.id;
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      _log("Error refreshing completion data: $e");
    }
  }

  // Reset and refresh all completion data
  Future<void> resetAndRefreshAllCompletionData({String? courseId}) async {
    try {
      _log(
          "Resetting and refreshing all completion data${courseId != null ? " for course ID: $courseId" : ""}");

      // Clear the cache completely
      _lessonCompletionCache.clear();
      _lessonToRegistrationCache.clear();

      // Don't notify here - wait until the end
      // Clear but don't notify
      _completedLessons.value = [];

      // Then refresh from the API
      _log("Refreshing all completion data from API");

      // Get all user registrations
      final registrations = await _registrationService.getUserRegistrations();

      // Filter registrations by course ID if provided
      final targetRegistrations = courseId != null
          ? registrations
              .where((reg) => reg.courseId.toString() == courseId)
              .toList()
          : registrations;

      _log(
          "Found ${targetRegistrations.length} relevant registrations${courseId != null ? " for course ID: $courseId" : ""}");

      // For each registration, fetch completed lessons
      for (var registration in targetRegistrations) {
        _log(
            "Fetching completed lessons for registration ID: ${registration.id}, course ID: ${registration.courseId}");

        // Include courseId in query if specified
        final queryParams = <String, dynamic>{
          'registration_id': registration.id
        };
        if (courseId != null) {
          queryParams['course_id'] = courseId;
        }

        final response = await _apiService.get('/completed_lessons',
            queryParameters: queryParams);

        _log(
            "API response status for registration ${registration.id}: ${response.statusCode}");

        if (response.data != null) {
          List<dynamic> completions = [];

          if (response.data is List) {
            completions = response.data;
            _log(
                "Received completion data as List with ${completions.length} items");
          } else if (response.data is Map &&
              response.data.containsKey('data') &&
              response.data['data'] is List) {
            completions = response.data['data'] as List;
            _log(
                "Received completion data as Map with ${completions.length} items in 'data' key");
          }

          _log(
              "Processing ${completions.length} completion records for registration ${registration.id}");

          // Build the cache and completedLessons list with the fetched data
          for (var record in completions) {
            if (record != null && record['lesson_id'] != null) {
              final lessonId = int.parse(record['lesson_id'].toString());
              final cacheKey = _getCacheKey(lessonId, registration.id);
              _lessonCompletionCache[cacheKey] = true;

              // Also cache the lesson to registration mapping
              _lessonToRegistrationCache[lessonId] = registration.id;

              // Add to the completed lessons list
              _completedLessons.value.add(CompletedLessonModel(
                id: record['id'] ?? 0,
                lessonId: lessonId,
                registrationId: registration.id,
                isCompleted: true,
                createdAt: record['created_at'],
                updatedAt: record['updated_at'],
              ));
              _log(
                  "Added completed lesson ID $lessonId to completedLessons list");
            }
          }
        } else {
          _log(
              "No completion data returned for registration ${registration.id}");
        }
      }

      _log(
          "Completed refreshing all data. Found ${_completedLessons.value.length} completed lessons.");

      // Print a summary of the completed lessons
      if (_completedLessons.value.isNotEmpty) {
        final completedLessonIds = _completedLessons.value
            .map((cl) => cl.lessonId.toString())
            .toList();
        _log("Completed lesson IDs: $completedLessonIds");
      }

      // Only notify once at the end
      notifyListeners();
    } catch (e) {
      _log("Error resetting and refreshing completion data: $e");
    }
  }

  // Force check lesson completion status (bypasses cache)
  Future<bool> forceCheckLessonCompletion(int lessonId) async {
    try {
      _log("Force checking completion status for lesson $lessonId");

      final registrationId = await getRegistrationIdForLesson(lessonId);
      if (registrationId == null) {
        return false;
      }

      // Skip cache check and fetch directly from API
      final response =
          await _apiService.get('/completed_lessons', queryParameters: {
        'lesson_id': lessonId.toString(),
        'registration_id': registrationId,
      });

      if (response.data == null) {
        // Update cache with result
        final cacheKey = _getCacheKey(lessonId, registrationId);
        _lessonCompletionCache[cacheKey] = false;
        return false;
      }

      final data = response.data;
      List<dynamic> completedLessons = [];

      if (data is List) {
        completedLessons = data;
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        completedLessons = data['data'] as List;
      }

      // Filter to only include records matching this specific lesson ID
      List<dynamic> matchingLessons = completedLessons.where((record) {
        return record != null &&
            record['lesson_id'] != null &&
            record['lesson_id'].toString() == lessonId.toString();
      }).toList();

      // A lesson is completed ONLY if there's at least one record for THIS lesson
      final isCompleted = matchingLessons.isNotEmpty;

      // Update cache with result
      final cacheKey = _getCacheKey(lessonId, registrationId);
      _lessonCompletionCache[cacheKey] = isCompleted;

      return isCompleted;
    } catch (e) {
      _log("Error force checking completion status: $e");
      return false;
    }
  }
}
