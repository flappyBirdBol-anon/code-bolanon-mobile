import 'package:code_bolanon/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../app/app.locator.dart';
import '../models/wishlist_model.dart';
import '../services/api_service.dart';

class WishlistService with ReactiveServiceMixin {
  final ApiService _apiService;

  WishlistService({ApiService? apiService})
      : _apiService = apiService ?? locator<ApiService>();

  List<WishlistModel>? _wishlists;
  List<WishlistModel>? get wishlists => _wishlists;

  Future<List<WishlistModel>> getUserWishlist() async {
    try {
      final response = await _apiService.get('/wishlists');

      if (response.statusCode == 200) {
        final List<dynamic> wishlistsJson = response.data['data'];
        _wishlists =
            wishlistsJson.map((json) => WishlistModel.fromJson(json)).toList();
        notifyListeners();
        return _wishlists!;
      } else {
        throw Exception(
            'Failed to load wishlists: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Error loading wishlists: $e');
      return [];
    }
  }

  Future<bool> addToWishlist(String courseId) async {
    try {
      final response = await _apiService.post('/wishlists', data: {
        'course_id': courseId,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newWishlist = WishlistModel.fromJson(response.data['data']);
        _wishlists ??= [];
        _wishlists!.add(newWishlist);
        notifyListeners();
        return true;
      } else {
        throw Exception(
            'Failed to add to wishlist: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      return false;
    }
  }

  Future<bool> removeFromWishlist(String courseId) async {
    try {
      final response = await _apiService.delete('/wishlists/$courseId');

      if (response.statusCode == 200) {
        _wishlists?.removeWhere((item) => item.courseId == courseId);
        notifyListeners();
        return true;
      } else {
        throw Exception(
            'Failed to remove from wishlist: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      return false;
    }
  }

  bool isInWishlist(String courseId) {
    return _wishlists?.any((item) => item.courseId == courseId) ?? false;
  }

  Future<List<CourseModel>> getWishlistCourses(
      List<WishlistModel> wishlists) async {
    try {
      List<CourseModel> courses = [];
      List<Future<CourseModel>> futures = [];

      // Create futures for parallel execution
      for (var wishlist in wishlists) {
        futures.add(_fetchWishlistedCourse(wishlist));
      }

      // Wait for all futures to complete
      final results = await Future.wait(futures);
      courses.addAll(results);

      return courses;
    } catch (e) {
      throw Exception('Failed to get wishlisted courses: ${e.toString()}');
    }
  }

  Future<CourseModel> _fetchWishlistedCourse(WishlistModel wishlist) async {
    final response = await _apiService.get('/courses/${wishlist.courseId}');
    if (response.statusCode == 200) {
      final courseJson = response.data['data'];
      courseJson['wishlist'] = wishlist.toJson();
      return CourseModel.fromJson(courseJson);
    }
    throw Exception('Failed to fetch wishlisted course: ${wishlist.courseId}');
  }
}
