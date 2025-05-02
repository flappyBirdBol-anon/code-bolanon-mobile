import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/completed_lesson_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:stacked/stacked.dart';

class CompletedLessonService with ListenableServiceMixin {
  final _apiService = locator<ApiService>();
  final _registrationService = locator<RegistrationService>();

  final ReactiveValue<List<CompletedLessonModel>> _completedLessons =
      ReactiveValue<List<CompletedLessonModel>>([]);
  List<CompletedLessonModel> get completedLessons => _completedLessons.value;

  CompletedLessonService() {
    listenToReactiveValues([_completedLessons]);
  }

  Future<void> fetchCompletedLessons({String? lessonId}) async {
    try {
      final response =
          await _apiService.get('/completed_lessons', queryParameters: {
        if (lessonId != null) 'lesson_id': lessonId,
      });

      if (response.data == null) {
        _completedLessons.value = [];
        notifyListeners();
        return;
      }

      final data = response.data;
      if (data is List) {
        _completedLessons.value =
            data.map((item) => CompletedLessonModel.fromJson(item)).toList();
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        _completedLessons.value = (data['data'] as List)
            .map((item) => CompletedLessonModel.fromJson(item))
            .toList();
      } else {
        _completedLessons.value = [];
      }

      notifyListeners();
    } catch (e) {
      _completedLessons.value = [];
      notifyListeners();
      rethrow;
    }
  }

  Future<String?> getRegistrationIdForLesson(int lessonId) async {
    try {
      // First get the course ID for this lesson
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
          return reg.id;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLessonCompleted(int lessonId) async {
    try {
      final registrationId = await getRegistrationIdForLesson(lessonId);
      if (registrationId == null) {
        return false;
      }

      final response =
          await _apiService.get('/completed_lessons', queryParameters: {
        'lesson_id': lessonId.toString(),
        'registration_id': registrationId,
      });

      if (response.data == null) return false;

      final data = response.data;
      List<dynamic> lessons = [];

      if (data is List) {
        lessons = data;
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        lessons = data['data'] as List;
      }

      // If any completed lesson records exist, the lesson is completed
      return lessons.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markLessonAsCompleted(int lessonId) async {
    try {
      final registrationId = await getRegistrationIdForLesson(lessonId);
      if (registrationId == null) {
        return false;
      }

      final response = await _apiService.post('/completed_lessons', data: {
        'lesson_id': lessonId.toString(),
        'registration_id': registrationId,
        'is_completed': true,
      });

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markLessonAsIncomplete(int lessonId) async {
    try {
      final registrationId = await getRegistrationIdForLesson(lessonId);
      if (registrationId == null) {
        print("No registration found for lesson $lessonId");
        return false;
      }

      // Find existing completion record
      final response =
          await _apiService.get('/completed_lessons', queryParameters: {
        'lesson_id': lessonId.toString(),
        'registration_id': registrationId,
      });

      if (response.data == null) {
        print("No completion data found for lesson $lessonId");
        return true; // Already incomplete
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

      if (lessons.isEmpty) {
        print("No completion records found for lesson $lessonId");
        return true; // Already incomplete
      }

      print("Found ${lessons.length} completion records for lesson $lessonId");

      // Delete the completion record
      final recordId = lessons.first['id'].toString();
      print("Deleting completion record $recordId for lesson $lessonId");

      final deleteResponse =
          await _apiService.delete('/completed_lessons/$recordId');

      final success =
          deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204;

      print(
          "Delete response status: ${deleteResponse.statusCode}, success: $success");
      return success;
    } catch (e) {
      print("Error marking lesson $lessonId as incomplete: $e");
      return false;
    }
  }

  Future<bool> toggleLessonCompletion(int lessonId) async {
    try {
      // First check current status
      final isCompleted = await isLessonCompleted(lessonId);
      print(
          "Current lesson completion status: $isCompleted, toggling to ${!isCompleted}");

      // Toggle based on current status
      if (isCompleted) {
        return await markLessonAsIncomplete(lessonId);
      } else {
        return await markLessonAsCompleted(lessonId);
      }
    } catch (e) {
      print("Error in toggleLessonCompletion: $e");
      return false;
    }
  }
}
