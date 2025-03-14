// lib/views/course_details/course_details_viewmodel.dart
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/services/wishlist_service.dart';
import 'package:code_bolanon/ui/views/lessons_full/lessons_full_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CourseDetailsViewModel extends ReactiveViewModel {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;
  final _userService = locator<UserService>();
  final _imageService = locator<ImageService>();
  final _lessonsService = locator<LessonsService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _wishlistService = locator<WishlistService>();
  final _registrationService = locator<RegistrationService>();

  final TextEditingController reviewController = TextEditingController();
  final TextEditingController reportReasonController = TextEditingController();
  double userRating = 0;

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [_lessonsService, _wishlistService];

  // Filter lessons for this course
  List<Lesson> get courseLessons =>
      _lessonsService.lessons!.where((l) => l.courseId == course!.id).toList();

  String get profilePictureUrl => _userService.currentUser?.profileImage ?? '';
  String get userName => _userService.currentUser?.fullName ?? 'User';
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  @override
  notifyListeners();
  // Reference to the course
  CourseModel? _course;
  CourseModel? get course => _course;

  // Lessons for the course
  List<Lesson> _lessons = [];
  List<Lesson> get lessons => _lessons;

//for toggle lessons
  bool _showAllLessons = false;
  bool get showAllLessons => _showAllLessons;
  // Initialize with a course
  Future<void> initialize(CourseModel? course) async {
    _course = course;
    setBusy(true);

    if (_course != null && isLearner) {
      // Load registrations first
      await _registrationService.loadRegisteredCourses();
      _isRegistered = _registrationService.isRegistered(_course!.id);

      // Only check wishlist if not registered
      if (!_isRegistered) {
        await _wishlistService.getUserWishlist();
        _isInWishlist = _wishlistService.isInWishlist(_course!.id);
      }
    }

    // Prefetch the course image to ensure it's cached
    final imageUrl =
        _imageService.getCourseThumbnailFromPath(_course!.thumbnail);
    await _imageService.prefetchImage(imageUrl, courseId: _course!.id);

    // Load lessons
    await _loadLessons();

    _isLoading = false;
    setBusy(false);
    notifyListeners();
  }

  // Load lessons from the service
  Future<void> _loadLessons() async {
    try {
      _lessons = await _lessonsService.getLessons(courseId: course!.id);
      notifyListeners();
    } catch (e) {
      // Handle error
      await _dialogService.showDialog(
        title: 'Error Loading Lessons',
        description: 'Could not load lessons. Please try again later.',
      );
    }
  }

  // Refresh lessons
  Future<void> refreshLessons() async {
    setBusy(true);
    await _loadLessons();
    setBusy(false);
  }

  // Get a widget to display the course image
  Widget getCourseImageWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (_course == null) {
      return errorWidget ?? _buildDefaultErrorWidget(width, height);
    }

    // Handle local assets differently
    if (_course!.thumbnail.startsWith('assets/')) {
      return Image.asset(
        _course!.thumbnail,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultErrorWidget(width, height);
        },
      );
    }

    // Use ImageService for remote images
    final imageUrl =
        _imageService.getCourseThumbnailFromPath(_course!.thumbnail);

    return _imageService.loadImage(
      imageUrl: imageUrl,
      courseId: _course!.id,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? _buildDefaultPlaceholder(width, height),
      errorWidget: errorWidget ?? _buildDefaultErrorWidget(width, height),
    );
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

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void navigateToAddLesson(CourseModel course) {
    _navigationService.navigateToAddLessonView(course: course);
  }

  void navigateToLessonsFullView() {
    _navigationService.navigateToView(
      LessonsFullView(
          courseId: _course?.id != null
              ? int.tryParse(_course!.id.toString()) ?? 0
              : 0),
    );
  }

  void navigateToLessonDetails(Lesson lesson) {
    // Remove the isLearner check to allow trainers to navigate
    if (isLearner && !isRegistered) {
      _dialogService.showDialog(
        title: 'Access Restricted',
        description:
            'Please enroll in this course first to access the learning materials.',
        buttonTitle: 'OK',
      );
      return;
    }

    _navigationService.navigateToLessonDetailsView(lesson: lesson);
  }

  void toggleShowAllLessons() {
    _showAllLessons = !_showAllLessons;
    notifyListeners();
  }

  // Delete a lesson
  Future<void> deleteLesson(Lesson lesson) async {
    final dialogResponse = await _dialogService.showConfirmationDialog(
      title: 'Delete Lesson',
      description: 'Are you sure you want to delete "${lesson.label}"?',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (dialogResponse?.confirmed ?? false) {
      setBusy(true);
      try {
        final success = await _lessonsService.deleteLesson(lesson.id);
        if (success) {
          await refreshLessons();
          await _dialogService.showDialog(
            title: 'Success',
            description: 'Lesson deleted successfully',
          );
        }
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to delete lesson: $e',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  // Get total duration of all lessons
  String get totalDuration {
    if (_lessons.isEmpty) return '0 min';

    int totalMinutes = 0;
    for (var lesson in _lessons) {
      // Extract minutes from duration string (e.g., "12 min" -> 12)
      final durationStr = lesson.duration;
      final regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(durationStr);
      if (match != null) {
        totalMinutes += int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }

    if (totalMinutes < 60) {
      return '$totalMinutes min';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '$hours h ${minutes > 0 ? '$minutes min' : ''}';
    }
  }

  bool _isInWishlist = false;
  bool get isInWishlist => _isInWishlist;

  Future<Map<String, dynamic>?> toggleWishlist() async {
    if (_course == null) return null;

    setBusy(true);
    try {
      final result = await _wishlistService.toggleWishlist(_course!.id);
      if (result['success']) {
        _isInWishlist = !_isInWishlist;
        notifyListeners();
      }
      setBusy(false);
      return result;
    } catch (e) {
      setBusy(false);
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update wishlist: ${e.toString()}',
      );
      return null;
    }
  }

  Future<void> showRegistrationDialog() async {
    final response = await _dialogService.showConfirmationDialog(
      title: 'Register for Course',
      description: 'Are you sure you want to register for "${course!.title}"?',
      confirmationTitle: 'Register',
      cancelTitle: 'Cancel',
    );

    if (response?.confirmed == true) {
      try {
        setBusy(true);
        final registration =
            await _registrationService.createRegistration(course!.id);

        await _dialogService.showDialog(
          title: 'Success',
          description: 'You have successfully registered for the course!',
        );

        // Reload the page after successful registration
        await initialize(course);
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to register for course: ${e.toString()}',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  void setRating(double rating) {
    userRating = rating;
    notifyListeners();
  }

  Future<void> submitReview() async {
    if (reviewController.text.isEmpty || userRating == 0) {
      // Show error message
      return;
    }
    // TODO: Implement review submission logic
    reviewController.clear();
    userRating = 0;
    notifyListeners();
  }

  Future<void> submitReport() async {
    if (reportReasonController.text.isEmpty) {
      // Show error message
      return;
    }
    // TODO: Implement report submission logic
    reportReasonController.clear();
    notifyListeners();
  }

  bool _isReviewSectionExpanded = false;
  bool get isReviewSectionExpanded => _isReviewSectionExpanded;

  void toggleReviewSection() {
    _isReviewSectionExpanded = !_isReviewSectionExpanded;
    notifyListeners();
  }

  @override
  void dispose() {
    reviewController.dispose();
    reportReasonController.dispose();
    super.dispose();
  }

  bool get isLearner => _userService.currentUser?.role == 'learner';
  bool _isRegistered = false;
  bool get isRegistered => _isRegistered;

  // Add this getter to control review section visibility
  bool get canWriteReview => isLearner && isRegistered;

  // Add this getter to control visibility of wishlist button
  bool get showWishlistButton => isLearner && !isRegistered;

  // Update the showEnrollButton getter to check if user is learner
  bool get showEnrollButton => isLearner;

  // Update the button text based on registration status
  String get enrollButtonText {
    if (!isLearner) return '';
    return isRegistered ? 'Enrolled' : 'Enroll';
  }

  // Get button icon based on registration status
  IconData get enrollButtonIcon {
    if (!isLearner) return Icons.error;
    return isRegistered ? Icons.check_circle : Icons.shopping_cart_rounded;
  }

  // Update getter to allow trainers full access
  bool get canAccessLessons => !isLearner || isRegistered;
}
