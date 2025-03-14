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

//  // Initialize with sample course data (for demonstration)
//   void _initializeSampleData() {
//     final sampleCourses = [
//       CourseModel(
//         id: "1",
//         title: "Advanced Flutter Development",
//         description: "Master Flutter app development with real-world projects",
//         price: 99.99,
//         thumbnail: "assets/images/1.jpg",
//         lessons: 24,
//         rating: 4.8,
//         reviews: 128,
//       ),
//       CourseModel(
//         id: "2",
//         title: "Full Stack Web Development",
//         description: "Learn modern web development from frontend to backend",
//         price: 149.99,
//         thumbnail: "assets/images/2.jpg",
//         lessons: 36,
//         rating: 4.9,
//         reviews: 256,
//       ),
//       CourseModel(
//         id: "3",
//         title: "Python Data Science",
//         description: "Master data analysis and machine learning with Python",
//         price: 129.99,
//         thumbnail: "assets/images/3.jpg",
//         lessons: 30,
//         rating: 4.7,
//         reviews: 189,
//       ),
//     ];

//     // Add tags to courses
//     _tagService.addTagsToCourse("1", ["Flutter", "Mobile Dev", "Frontend"]);
//     _tagService.addTagsToCourse("2", ["Frontend", "Backend", "Full Stack", "JavaScript"]);
//     _tagService.addTagsToCourse("3", ["Python", "Data Science", "Machine Learning"]);

//     _courses = sampleCourses;
//   }

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
  }) async {
    try {
      // Prepare data
      final Map<String, dynamic> courseData = {
        'title': title,
        'description': description,
        'price': price.toString(), // Convert to string for form data
      };

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
  }) async {
    try {
      // Prepare update data
      final Map<String, dynamic> updateData = {};
      updateData['id'] = courseId;
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price.toString();

      // Add method spoofing for Laravel
      updateData['_method'] = 'PUT';

      Response response;

      if (image != null) {
        // Use the dedicated file upload method
        print("image null");
        response = await _apiService.uploadFile(
          '/courses/$courseId',
          fields: updateData,
          files: {'thumbnail': image},
        );
      } else {
        // Regular JSON request for update without file
        print("no image, just regular json");
        response =
            await _apiService.post('/courses/$courseId', data: updateData);
      }

      if (response.statusCode == 200) {
        final course = CourseModel.fromJson(response.data['data']);

        // Update the cache for this course
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
