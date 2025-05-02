import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/wishlist_model.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/wishlist_service.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LearnerWishlistsViewModel extends BaseViewModel {
  final CourseService _courseService;
  final WishlistService _wishlistService;
  final ImageService imageService;
  final NavigationService _navigationService = locator<NavigationService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();

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
        courseId: '1', // Changed from int to String
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
        courseId: '2', // Changed from int to String
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
        imageService = imageService;

  Future<void> init() async {
    await refreshCourses();
  }

  Future<void> refreshCourses() async {
    setBusy(true);
    try {
      final wishlists = await _wishlistService.getUserWishlist();
      _wishlistedCourses = await _wishlistService.getWishlistCourses(wishlists);

      // Prefetch images for better performance
      if (_wishlistedCourses.isNotEmpty) {
        for (var course in _wishlistedCourses) {
          if (course.thumbnail.isNotEmpty &&
              !course.thumbnail.startsWith('assets/')) {
            final imageUrl =
                imageService.getCourseThumbnailFromPath(course.thumbnail);
            imageService.prefetchImage(imageUrl, courseId: course.id);
          }
        }
      }
    } catch (e) {
      debugPrint('Error refreshing wishlists: $e');
      _wishlistedCourses = _sampleData;
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  // Navigate to course details
  void navigateToCourseDetails(CourseModel course) {
    _navigationService.navigateToCourseDetailsView(
      course: course,
    );
  }

  // Navigate back to courses
  void navigateToMyCourses() {
    _navigationService.back();
  }

  // Navigate to explore courses
  void navigateToExploreCourses() {
    _navigationService.navigateToAvailableCoursesView();
  }

  Future<void> toggleWishlist(CourseModel course) async {
    try {
      final result = await _wishlistService.toggleWishlist(course.id);
      if (result['success']) {
        await refreshCourses();
        _snackbarService.showSnackbar(
          message: result['message'],
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      _snackbarService.showSnackbar(
        message: 'Failed to update wishlist: $e',
        duration: const Duration(seconds: 2),
      );
      setError(e);
    }
  }

  Future<Map<String, dynamic>> removeFromWishlist(CourseModel course) async {
    try {
      setBusy(true);
      await _wishlistService.removeFromWishlist(course.id);
      // Update local list instead of refreshing
      _wishlistedCourses.removeWhere((c) => c.id == course.id);
      notifyListeners();
      return {'success': true, 'message': 'Successfully removed from wishlist'};
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      return {'success': false, 'message': 'Failed to remove from wishlist'};
    } finally {
      setBusy(false);
    }
  }

  // Extract course tags
  List<String> getCourseTags(CourseModel course) {
    if (course.stacks.isNotEmpty) {
      return course.stacks;
    }
    return const [];
  }

  // Method to display course image similar to course details view
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
            imageService.getCourseThumbnailFromPath(course.thumbnail);
        return imageService.loadImage(
          imageUrl: imageUrl,
          courseId: course.id,
          width: width,
          height: height,
          fit: fit,
          placeholder: placeholder ?? _buildDefaultPlaceholder(width, height),
          errorWidget: errorWidget ?? _buildDefaultErrorWidget(width, height),
        );
      }

      return errorWidget ?? _buildDefaultErrorWidget(width, height);
    } catch (e) {
      debugPrint('Error loading course image: $e');
      return errorWidget ?? _buildDefaultErrorWidget(width, height);
    }
  }

  Widget _buildDefaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDefaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
    );
  }

  // Get actual lesson count
  int getActualLessonCount(CourseModel course) {
    // First try to get from lessons_count
    if (course.lessonCount != null) {
      return course.lessonCount!;
    }

    // Fall back to default lessons field
    return course.lessons;
  }
}
