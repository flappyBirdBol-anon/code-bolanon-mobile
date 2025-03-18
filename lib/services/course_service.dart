import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/tag_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CourseService {
  final ApiService _apiService;
  final ImageService _imageService;
  final TagService _tagService = locator<TagService>();

  CourseService({ApiService? apiService, ImageService? imageService})
      : _apiService = apiService ?? locator<ApiService>(),
        _imageService = imageService ?? locator<ImageService>();

  List<CourseModel>? _courses;
  List<CourseModel>? get courseList => _courses;

  Future<List<CourseModel>> getCourses({
    int page = 1,
    int pageSize = 10,
    List<String>? filters,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'pageSize': pageSize,
      };

      if (filters != null && filters.isNotEmpty) {
        queryParams['filters'] = filters.join(',');
      }

      final response =
          await _apiService.get('/courses', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> coursesJson = response.data['data'];
        final courses = coursesJson.map((json) {
          final course = CourseModel.fromJson(json);
          _tagService.addTagsToCourse(
              course.id, ["Flutter", "Mobile Dev", "Frontend"]);
          return course;
        }).toList();

        _courses = courses;
        _imageService.prefetchCourseImages(courses);
        return courses;
      } else {
        throw Exception('Failed to load courses: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Error loading courses: $e');
      return [];
    }
  }

  Future<CourseModel> getCourseById(String courseId) async {
    final response = await _apiService.get('/courses/$courseId');

    if (response.statusCode == 200) {
      final course = CourseModel.fromJson(response.data['data']);

      // Prefetch and cache this course's image
      if (course.thumbnail.isNotEmpty) {
        final imageUrl =
            _imageService.getCourseThumbnailFromPath(course.thumbnail);
        _imageService.prefetchImage(imageUrl, courseId: course.id);
      }

      return course;
    } else {
      throw Exception('Failed to load course: ${response.data['message']}');
    }
  }

  Future<CourseModel> addCourse({
    required String title,
    required String description,
    required double price,
    XFile? image,
    List<String> learningExpectations = const [],
    List<String> requirements = const [],
    String level = 'Beginner',
    String duration = '4 weeks',
    List<int> techStackIds = const [], // Add tech stack IDs parameter
  }) async {
    try {
      // Prepare data
      final Map<String, dynamic> courseData = {
        'title': title,
        'description': description,
        'price': price.toString(), // Convert to string for form data
        'level': level,
        'duration': duration,
      };

      // Add arrays for learning expectations and requirements
      for (int i = 0; i < learningExpectations.length; i++) {
        courseData['learning_expectations[$i]'] = learningExpectations[i];
      }

      for (int i = 0; i < requirements.length; i++) {
        courseData['requirements[$i]'] = requirements[i];
      }

      // Add tech stack IDs
      for (int i = 0; i < techStackIds.length; i++) {
        courseData['tech_stack_ids[$i]'] = techStackIds[i];
      }

      Response response;

      if (image != null) {
        // Use the dedicated file upload method
        response = await _apiService.uploadFile(
          '/courses',
          fields: courseData,
          files: {'thumbnail': image},
        );
      } else {
        // Regular JSON request if no file
        response = await _apiService.post('/courses', data: courseData);
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final course = CourseModel.fromJson(response.data['data']);

        // Cache the new course image
        await _imageService.handleCourseCacheUpdate(course);

        return course;
      } else {
        throw Exception('Failed to add course: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to add course: ${e.toString()}');
    }
  }

  Future<CourseModel> updateCourseStatus({
    required String courseId,
    required bool isActive,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'is_active': isActive,
        '_method': 'PUT', // For Laravel method spoofing
      };

      final response = await _apiService.post(
        '/courses/$courseId/status',
        data: updateData,
      );

      if (response.statusCode == 200) {
        final course = CourseModel.fromJson(response.data['data']);

        // Update our local course list if it exists
        if (_courses != null) {
          final index = _courses!.indexWhere((c) => c.id == courseId);
          if (index != -1) {
            _courses![index] = course;
          }
        }

        return course;
      } else {
        throw Exception(
            'Failed to update course status: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to update course status: ${e.toString()}');
    }
  }

  Future<CourseModel> updateCourse({
    required String courseId,
    String? title,
    String? description,
    int? price,
    XFile? image,
    List<String>? learningExpectations,
    List<String>? requirements,
    String? level,
    String? duration,
    List<int>? techStackIds, // Add tech stack IDs parameter
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        '_method': 'PUT',
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (price != null) 'price': price.toString(),
        if (learningExpectations != null)
          'learning_expectations': learningExpectations,
        if (requirements != null) 'requirements': requirements,
        if (level != null) 'level': level,
        if (duration != null) 'duration': duration,
        if (techStackIds != null) 'tech_stack_ids': techStackIds,
      };

      var response;
      if (image != null) {
        // Only update image if a new one is provided
        response = await _apiService.uploadFile(
          '/courses/$courseId',
          fields: updateData,
          files: {'thumbnail': image},
        );
      } else {
        // Regular JSON request for update without changing image
        response =
            await _apiService.post('/courses/$courseId', data: updateData);
      }

      if (response.statusCode == 200) {
        final course = CourseModel.fromJson(response.data['data']);
        await _imageService.handleCourseCacheUpdate(course);
        return course;
      } else {
        throw Exception('Failed to update course: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to update course: ${e.toString()}');
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      final response = await _apiService.post(
        '/courses/$courseId',
        data: {'_method': 'DELETE'},
      );

      if (response.statusCode == 200) {
        // Clear the cache for this course
        await _imageService.clearCourseCache(courseId);
        return true;
      } else {
        throw Exception('Failed to delete course: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to delete course: ${e.toString()}');
    }
  }
}
