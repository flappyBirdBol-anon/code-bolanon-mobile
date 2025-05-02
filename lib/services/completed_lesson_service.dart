import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/completed_lesson_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
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

  // Debug flag to enable verbose logging
  final bool _debug = true;

  CompletedLessonService() {
    listenToReactiveValues([_completedLessons]);
  }

  void _log(String message) {
    if (_debug) {
      print("CompletedLessonService: $message");
    }
  }

  Future<void> fetchCompletedLessons(
      {String? lessonId, String? registrationId}) async {
    try {
      _log(
          "Fetching completed lessons - lessonId: $lessonId, registrationId: $registrationId");

      final queryParams = <String, dynamic>{};
      if (lessonId != null) queryParams['lesson_id'] = lessonId;
      if (registrationId != null)
        queryParams['registration_id'] = registrationId;

      final response = await _apiService.get('/completed_lessons',
          queryParameters: queryParams);

      if (response.data == null) {
        _log("Response data is null, clearing completed lessons");
        _completedLessons.value = [];
        notifyListeners();
        return;
      }

      final data = response.data;
      List<CompletedLessonModel> parsedLessons = [];

      if (data is List) {
        _log("Response is a List with ${data.length} items");
        parsedLessons =
            data.map((item) => CompletedLessonModel.fromJson(item)).toList();
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        _log(
            "Response is a Map with 'data' key containing ${data['data'].length} items");
        parsedLessons = (data['data'] as List)
            .map((item) => CompletedLessonModel.fromJson(item))
            .toList();
      } else {
        _log("Response format not recognized: ${data.runtimeType}");
        parsedLessons = [];
      }

      _completedLessons.value = parsedLessons;

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
          _lessonCompletionCache[cacheKey] = lesson.isCompleted;
          _log(
              "Cached lesson ${lesson.lessonId} as completed=${lesson.isCompleted}");
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

  Future<String?> getRegistrationIdForLesson(int lessonId) async {
    try {
      _log("Getting registration ID for lesson $lessonId");

      // First get the course ID for this lesson
      final lessonResponse = await _apiService.get('/lessons/$lessonId');

      if (lessonResponse.statusCode != 200 || lessonResponse.data == null) {
        _log("Failed to get lesson data for $lessonId");
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
        _log("Could not extract course ID from lesson data");
        return null;
      }

      _log("Found course ID $courseId for lesson $lessonId");

      // Find registration for this course
      final registrations = await _registrationService.getUserRegistrations();
      _log("Found ${registrations.length} user registrations");

      for (var reg in registrations) {
        if (reg.courseId.toString() == courseId) {
          _log("Found registration ID ${reg.id} for course $courseId");
          return reg.id;
        }
      }

      _log("No registration found for course $courseId");
      return null;
    } catch (e) {
      _log("Error getting registration ID for lesson $lessonId: $e");
      return null;
    }
  }

  String _getCacheKey(int lessonId, String registrationId) {
    return "${lessonId}_$registrationId";
  }

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
        final cachedResult = _lessonCompletionCache[cacheKey] ?? false;
        _log(
            "Found in cache: lesson $lessonId is ${cachedResult ? 'completed' : 'not completed'}");
        return cachedResult;
      }

      _log(
          "Not in cache, fetching from API for lesson $lessonId and registration $registrationId");

      // IMPORTANT: We need to ensure we're getting data for THIS specific lesson only
      final response =
          await _apiService.get('/completed_lessons', queryParameters: {
        'lesson_id': lessonId.toString(),
        'registration_id': registrationId,
      });

      if (response.data == null) {
        _log("API response data is null");
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

      _log(
          "Found ${completedLessons.length} completion records in response for lesson $lessonId");

      // CRITICAL FIX: Filter the records to only include those matching this specific lesson ID
      List<dynamic> matchingLessons = completedLessons.where((record) {
        // Ensure the record has a lesson_id field and it matches our requested lessonId
        return record != null &&
            record['lesson_id'] != null &&
            record['lesson_id'].toString() == lessonId.toString();
      }).toList();

      _log(
          "After filtering, found ${matchingLessons.length} records actually for lesson $lessonId");

      // A lesson is completed ONLY if there's at least one record specifically for THIS lesson
      final isCompleted = matchingLessons.isNotEmpty;

      // Update cache with result
      _lessonCompletionCache[cacheKey] = isCompleted;
      _log(
          "Lesson $lessonId is ${isCompleted ? 'completed' : 'not completed'}");

      return isCompleted;
    } catch (e) {
      _log("Error checking if lesson $lessonId is completed: $e");
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
        await _updateLessonService(lessonId, true);

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
        await _updateLessonService(lessonId, false);

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

  Future<bool> toggleLessonCompletion(int lessonId) async {
    try {
      // First check current status
      final isCompleted = await isLessonCompleted(lessonId);
      _log(
          "Toggling lesson $lessonId completion from $isCompleted to ${!isCompleted}");

      // Toggle based on current status
      bool success;
      if (isCompleted) {
        success = await markLessonAsIncomplete(lessonId);
        if (success) {
          // Show consistent snackbar
          _snackbarService.showCustomSnackBar(
            message: 'Lesson marked as incomplete',
            duration: const Duration(seconds: 2),
            variant: SnackbarType.success,
          );
        }
      } else {
        success = await markLessonAsCompleted(lessonId);
        if (success) {
          // Show consistent snackbar
          _snackbarService.showCustomSnackBar(
            message: 'Lesson marked as completed',
            duration: const Duration(seconds: 2),
            variant: SnackbarType.success,
          );
        }
      }

      // Force synchronization with course progress after toggling completion
      if (success) {
        await synchronizeWithCourseProgress(lessonId);
      }

      return success;
    } catch (e) {
      _log("Error in toggleLessonCompletion: $e");
      _snackbarService.showCustomSnackBar(
        message: 'Failed to update lesson: $e',
        duration: const Duration(seconds: 3),
        variant: SnackbarType.error,
      );
      return false;
    }
  }

  // Update the LessonService when a lesson's completion status changes
  Future<void> _updateLessonService(int lessonId, bool isCompleted) async {
    try {
      _log(
          "Updating LessonService for lesson $lessonId, isCompleted=$isCompleted");

      // Get LessonService from locator
      final lessonService = locator<LessonsService>();

      // Update the lesson's completion status
      lessonService.updateLessonCompletionStatus(lessonId, isCompleted);

      _log("Successfully updated LessonService for lesson $lessonId");
    } catch (e) {
      _log("Error updating LessonService: $e");
    }
  }

  // Clear the cache when needed (e.g., on logout)
  void clearCache() {
    _lessonCompletionCache.clear();
    _completedLessons.value = [];
    notifyListeners();
    _log("Cache cleared");
  }

  // PUBLIC METHOD: Use this to check if a lesson is completed - bypassing cache
  Future<bool> forceCheckLessonCompletion(int lessonId) async {
    try {
      _log(
          "FORCE CHECKING lesson $lessonId directly from API, bypassing cache");

      final registrationId = await getRegistrationIdForLesson(lessonId);
      if (registrationId == null) {
        _log("No registration found for lesson $lessonId");
        return false;
      }

      // Here's the more reliable approach:
      // 1. Get ALL completed lessons for this registration
      // 2. Filter client-side for the specific lesson ID
      final response =
          await _apiService.get('/completed_lessons', queryParameters: {
        'registration_id': registrationId,
      });

      _log(
          "Force check: Fetched ALL completed lessons for registration $registrationId");

      if (response.data == null) {
        _log("API response data is null");
        // Update the cache
        final cacheKey = _getCacheKey(lessonId, registrationId);
        _lessonCompletionCache[cacheKey] = false;
        return false;
      }

      // Parse the response
      final data = response.data;
      List<dynamic> allCompletedLessons = [];

      if (data is List) {
        allCompletedLessons = data;
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        allCompletedLessons = data['data'] as List;
      }

      _log(
          "FORCE CHECK: Retrieved ${allCompletedLessons.length} total completed lessons");

      // Find the records specifically for this lesson ID
      final List<dynamic> matchingRecords = allCompletedLessons.where((record) {
        // Safe check to ensure the record has a lesson_id field that matches
        return record != null &&
            record['lesson_id'] != null &&
            record['lesson_id'].toString() == lessonId.toString();
      }).toList();

      _log(
          "FORCE CHECK: Found ${matchingRecords.length} records specifically for lesson $lessonId");

      // Show debug data about the matching records
      if (matchingRecords.isNotEmpty) {
        for (var record in matchingRecords) {
          _log(
              "FORCE CHECK: Record ID ${record['id']} - Lesson ID ${record['lesson_id']} - Registration ID ${record['registration_id']}");
        }
      }

      // Is completed only if there are matching records
      final isCompleted = matchingRecords.isNotEmpty;

      // Update the cache with the result
      final cacheKey = _getCacheKey(lessonId, registrationId);
      _lessonCompletionCache[cacheKey] = isCompleted;

      _log(
          "FORCE CHECK RESULT: Lesson $lessonId is ${isCompleted ? 'COMPLETED' : 'NOT COMPLETED'}");

      return isCompleted;
    } catch (e) {
      _log("Error in forceCheckLessonCompletion: $e");
      return false;
    }
  }

  // Refresh all completion data
  Future<void> refreshAllCompletionData() async {
    try {
      _log("Refreshing all completion data");

      // Clear the cache
      _lessonCompletionCache.clear();

      // Fetch fresh data
      await fetchCompletedLessons();

      _log("Completion data refreshed successfully");
    } catch (e) {
      _log("Error refreshing completion data: $e");
    }
  }

  // Reset and refresh all completion data from scratch
  Future<void> resetAndRefreshAllCompletionData() async {
    try {
      _log(
          "FULL RESET: Completely resetting and refreshing all completion data");

      // 1. Clear local caches
      _lessonCompletionCache.clear();
      _completedLessons.value = [];

      // 2. Get all registrations
      final registrations = await _registrationService.getUserRegistrations();
      _log("Found ${registrations.length} user registrations");

      // 3. For each registration, fetch completed lessons and rebuild the cache
      for (var registration in registrations) {
        final registrationId = registration.id;
        _log(
            "Processing registration $registrationId for course ${registration.courseId}");

        try {
          // Fetch ALL completed lessons for this registration
          final response =
              await _apiService.get('/completed_lessons', queryParameters: {
            'registration_id': registrationId,
          });

          if (response.data == null) {
            _log("No completion data for registration $registrationId");
            continue;
          }

          // Parse the response
          final data = response.data;
          List<dynamic> completedLessons = [];

          if (data is List) {
            completedLessons = data;
          } else if (data is Map &&
              data.containsKey('data') &&
              data['data'] is List) {
            completedLessons = data['data'] as List;
          }

          _log(
              "Found ${completedLessons.length} completion records for registration $registrationId");

          // Add each completion record to the cache with proper lesson ID filtering
          for (var record in completedLessons) {
            if (record != null && record['lesson_id'] != null) {
              final lessonId = record['lesson_id'].toString();
              final cacheKey = "${lessonId}_$registrationId";
              _lessonCompletionCache[cacheKey] = true;
              _log(
                  "→ Cached lesson $lessonId as COMPLETED for registration $registrationId");
            }
          }
        } catch (e) {
          _log("Error processing registration $registrationId: $e");
        }
      }

      _log(
          "FULL RESET COMPLETE: Cache has been rebuilt with ${_lessonCompletionCache.length} entries");
      notifyListeners();
    } catch (e) {
      _log("Error during full reset of completion data: $e");
      // If reset fails, ensure cache is at least empty
      _lessonCompletionCache.clear();
      _completedLessons.value = [];
      notifyListeners();
    }
  }

  // Synchronize lesson completion with course progress
  Future<void> synchronizeWithCourseProgress(int lessonId) async {
    try {
      _log("Synchronizing lesson $lessonId completion with course progress");

      // Get the course ID for this lesson
      final lessonResponse = await _apiService.get('/lessons/$lessonId');
      if (lessonResponse.statusCode != 200 || lessonResponse.data == null) {
        _log("Failed to get lesson data for $lessonId");
        return;
      }

      // Extract course ID from lesson data
      String? courseId;
      if (lessonResponse.data is Map && lessonResponse.data['data'] != null) {
        courseId = lessonResponse.data['data']['course_id'].toString();
      } else if (lessonResponse.data is Map) {
        courseId = lessonResponse.data['course_id']?.toString();
      }

      if (courseId == null) {
        _log("Could not extract course ID from lesson data");
        return;
      }

      _log(
          "Found course ID $courseId for lesson $lessonId, refreshing registration data");

      // Force refresh of registration data for this course
      await _registrationService.loadRegisteredCourses();

      // Get LessonService to ensure lesson list is updated
      final lessonService = locator<LessonsService>();

      // Fix any potentially inverted completion statuses
      await lessonService.fixInvertedCompletionStatus(courseId);

      _log("Successfully synchronized course progress for course $courseId");

      // Force notification to listeners that data has changed
      notifyListeners();
    } catch (e) {
      _log("Error synchronizing course progress: $e");
    }
  }
}
