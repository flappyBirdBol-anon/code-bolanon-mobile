// course_service.dart
import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class CourseService {
  final ApiService _apiService;
  final ImageService _imageService;

  CourseService(this._apiService, this._imageService);

  Future<List<Course>> getCourses() async {
    final response = await _apiService.get('/courses');

    if (response.statusCode == 200) {
      final List<dynamic> coursesJson = response.data['data'];
      final courses = coursesJson.map((json) => Course.fromJson(json)).toList();

      // Prefetch and cache all course images in the background
      _imageService.prefetchCourseImages(courses);

      return courses;
    } else {
      throw Exception('Failed to load courses: ${response.data['message']}');
    }
  }

  Future<Course> getCourseById(String courseId) async {
    final response = await _apiService.get('/courses/$courseId');

    if (response.statusCode == 200) {
      final course = Course.fromJson(response.data['data']);

      // Prefetch and cache this course's image
      if (course.thumbnail != null && course.thumbnail!.isNotEmpty) {
        final imageUrl =
            _imageService.getCourseThumbnailFromPath(course.thumbnail!);
        _imageService.prefetchImage(imageUrl, courseId: course.id);
      }

      return course;
    } else {
      throw Exception('Failed to load course: ${response.data['message']}');
    }
  }

  Future<Course> addCourse({
    required String title,
    required String description,
    required int price,
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
        final course = Course.fromJson(response.data['data']);

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

  Future<Course> updateCourse({
    required String courseId,
    String? title,
    String? description,
    int? price,
    XFile? image,
  }) async {
    try {
      // Prepare update data
      final Map<String, dynamic> updateData = {};
      if (courseId != null) updateData['id'] = courseId;
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
        final course = Course.fromJson(response.data['data']);

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
