// course_service.dart
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/registration_model.dart';
import 'package:code_bolanon/models/wishlist_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CourseService {
  final ApiService _apiService;
  final ImageService _imageService;

  CourseService({ApiService? apiService, ImageService? imageService})
      : _apiService = apiService ?? locator<ApiService>(),
        _imageService = imageService ?? locator<ImageService>();

  List<CourseModel>? _courses;
  List<CourseModel>? get courseList => _courses;

  Future<List<CourseModel>> getCourses() async {
    final response = await _apiService.get('/courses');

    if (response.statusCode == 200) {
      final List<dynamic> coursesJson = response.data['data'];
      final courses =
          coursesJson.map((json) => CourseModel.fromJson(json)).toList();
      _courses = courses;
      // Prefetch and cache all course images in the background
      _imageService.prefetchCourseImages(courses);

      return courses;
    } else {
      throw Exception('Failed to load courses: ${response.data['message']}');
    }
  }

  Future<CourseModel> getCourseById(int courseId) async {
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

  Future<List<RegistrationModel>> getUserRegistrations() async {
    try {
      final response = await _apiService.get('/registrations');

      if (response.statusCode == 200) {
        final List<dynamic> registrationsJson = response.data['data'];
        return registrationsJson
            .map((json) => RegistrationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load registrations: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to get user registrations: ${e.toString()}');
    }
  }

  Future<List<CourseModel>> getRegisteredCourses(
      List<RegistrationModel> registrations) async {
    try {
      List<CourseModel> courses = [];

      // Get course details for each registration
      for (var registration in registrations) {
        final response =
            await _apiService.get('/courses/${registration.courseId}');

        if (response.statusCode == 200) {
          final courseJson = response.data['data'];
          // Add registration data to course model
          courseJson['registration'] = registration.toJson();
          courses.add(CourseModel.fromJson(courseJson));
        }
      }
      return courses;
    } catch (e) {
      throw Exception('Failed to get registered courses: ${e.toString()}');
    }
  }

  Future<List<WishlistModel>> getUserWishlists() async {
    try {
      final response = await _apiService.get('/wishlists');

      if (response.statusCode == 200) {
        final List<dynamic> registrationsJson = response.data['data'];
        return registrationsJson
            .map((json) => WishlistModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load wishlists: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to get user wishlists: ${e.toString()}');
    }
  }

  Future<List<CourseModel>> getWishlistCourses(
      List<WishlistModel> wishlists) async {
    try {
      List<CourseModel> courses = [];

      for (var wishlist in wishlists) {
        final response = await _apiService.get('/courses/${wishlist.courseId}');

        if (response.statusCode == 200) {
          final courseJson = response.data['data'];
          courseJson['wishlist'] = wishlist.toJson();
          courses.add(CourseModel.fromJson(courseJson));
        }
      }
      return courses;
    } catch (e) {
      throw Exception('Failed to get wishlisted courses: ${e.toString()}');
    }
  }

  Future<bool> removeFromWishlist(int wishlistId) async {
    try {
      final response = await _apiService.delete('/wishlists/$wishlistId');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      return false;
    }
  }
}
