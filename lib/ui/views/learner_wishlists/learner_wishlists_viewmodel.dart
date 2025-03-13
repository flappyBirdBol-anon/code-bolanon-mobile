import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/wishlist_model.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/wishlist_service.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class LearnerWishlistsViewModel extends BaseViewModel {
  final CourseService _courseService;
  final WishlistService _wishlistService; // Add WishlistService
  final ImageService _imageService;

  List<CourseModel> _wishlistedCourses = [];
  List<CourseModel> get wishlistedCourses => _wishlistedCourses;

  // Sample data
  final List<CourseModel> _sampleData = [
    CourseModel(
      id: "1",
      title: "Sample Course 1",
      price: 0,
      description: "Free course description",
      thumbnail: PngImages.image1,
      lessons: 10,
      wishlist: WishlistModel(
        id: '1',
        courseId: 1,
        userId: 1,
      ),
    ),
    CourseModel(
      id: "2",
      title: "Premium Course 1",
      price: 29.99,
      description: "Premium course description",
      thumbnail: PngImages.image2,
      lessons: 15,
      wishlist: WishlistModel(
        id: '2',
        courseId: 2,
        userId: 1,
      ),
    ),
  ];

  LearnerWishlistsViewModel({
    required CourseService courseService,
    required WishlistService wishlistService,
    required ImageService imageService,
  })  : _courseService = courseService,
        _wishlistService = wishlistService,
        _imageService = imageService;

  Future<void> init() async {
    await refreshCourses();
  }

  Future<void> refreshCourses() async {
    setBusy(true);
    try {
      final wishlists = await _wishlistService.getUserWishlist();
      _wishlistedCourses = await _wishlistService.getWishlistCourses(wishlists);
    } catch (e) {
      debugPrint('Error refreshing wishlists: $e');
      // Fallback to sample data when API fails
      _wishlistedCourses = _sampleData;
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<void> removeFromWishlist(CourseModel course) async {
    try {
      if (course.wishlist == null) return;

      final success =
          await _wishlistService.removeFromWishlist(course.wishlist!.id);
      if (success) {
        _wishlistedCourses.removeWhere((c) => c.id == course.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      setError(e);
    }
  }

  Widget getCourseImageWidget({
    required CourseModel course,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    try {
      // Handle local assets
      if (course.thumbnail.startsWith('assets/')) {
        return Image.asset(
          course.thumbnail,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _buildDefaultErrorWidget(width, height);
          },
        );
      }

      // Handle remote images
      if (course.thumbnail.isNotEmpty) {
        final imageUrl =
            _imageService.getCourseThumbnailFromPath(course.thumbnail);
        return _imageService.loadImage(
          imageUrl: imageUrl,
          courseId: course.id,
          width: width,
          height: height,
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
        );
      }

      return errorWidget ?? _buildDefaultErrorWidget(width, height);
    } catch (e) {
      debugPrint('Error loading course image: $e');
      return errorWidget ?? _buildDefaultErrorWidget(width, height);
    }
  }

  Widget _buildDefaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
    );
  }
}
