import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/models/registration_model.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/completed_lesson_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/services/wishlist_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:code_bolanon/ui/views/add_lesson/add_lesson_view.dart';
import 'package:code_bolanon/ui/views/lessons_full/lessons_full_view.dart';
import 'package:code_bolanon/ui/views/trainer_courses/add_course.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  final snackbarService = locator<SnackbarService>();
  final courseService = locator<CourseService>();
  XFile? _selectedImage;

  final imageService = locator<ImageService>();

  // User data for the trainer
  UserModel? get currentUser => _userService.currentUser;

  // Get current user ID in string format for comparison
  String get currentUserId {
    final id = _userService.currentUser?.id?.toString().trim() ?? '';
    print('Current User ID from UserService: ${_userService.currentUser?.id}');
    print('Current User ID after toString: $id');
    return id;
  }

  // Helper method to compare user IDs
  bool isReviewByCurrentUser(RegistrationModel review) {
    final currentId = currentUserId;
    // Safely handle null userId
    final reviewerId = review.userId.toString().trim() ?? '';

    print('Debug: Review object: ${review.toString()}');
    print('Debug: Current User ID: "$currentId"');
    print('Debug: Reviewer ID: "$reviewerId"');
    print('Debug: Raw review.userId: "${review.userId}"');

    if (currentId.isEmpty || reviewerId.isEmpty) {
      print(
          'Debug: One or both IDs are empty - currentId: $currentId, reviewerId: $reviewerId');
      return false;
    }

    final isMatch = reviewerId == currentId;
    print('Debug: ID comparison result: $isMatch');
    return isMatch;
  }

  final TextEditingController reviewController = TextEditingController();
  final TextEditingController reportReasonController = TextEditingController();
  double userRating = 0;

  // Reviews related properties
  List<RegistrationModel> _reviews = [];
  List<RegistrationModel> get reviews => _reviews;
  String _reviewSortBy = 'latest'; // 'latest', 'highest', 'lowest'
  String get reviewSortBy => _reviewSortBy;

  void setReviewSortBy(String sortBy) {
    _reviewSortBy = sortBy;
    _sortReviews();
    notifyListeners();
  }

  void setRating(double rating) {
    userRating = rating;
    notifyListeners();
  }

  void _sortReviews() {
    switch (_reviewSortBy) {
      case 'highest':
        _reviews.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'lowest':
        _reviews.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
        break;
      case 'latest':
      default:
        _reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  // Calculate average ratings for each star level
  Map<int, double> get ratingDistribution {
    if (_reviews.isEmpty) return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    // Count reviews with ratings
    final reviewsWithRatings = _reviews.where((r) => r.rating != null).toList();
    if (reviewsWithRatings.isEmpty) return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    // Count each rating
    final Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviewsWithRatings) {
      if (review.rating != null && review.rating! >= 1 && review.rating! <= 5) {
        counts[review.rating!] = (counts[review.rating!] ?? 0) + 1;
      }
    }

    // Calculate percentages
    final Map<int, double> percentages = {};
    final total = reviewsWithRatings.length;
    for (var rating in counts.keys) {
      percentages[rating] = total > 0 ? counts[rating]! / total : 0;
    }

    return percentages;
  }

  // Calculate overall average rating
  double get averageRating {
    if (_reviews.isEmpty) return 0;

    final reviewsWithRatings = _reviews.where((r) => r.rating != null).toList();
    if (reviewsWithRatings.isEmpty) return 0;

    final sum =
        reviewsWithRatings.fold(0, (sum, review) => sum + (review.rating ?? 0));
    return sum / reviewsWithRatings.length;
  }

  // Keep the class field
  final _completedLessonService = locator<CompletedLessonService>();

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [_lessonsService, _wishlistService];

  // Listen for completion service changes in initialize
  void _setupCompletionServiceListener() {
    // Add a simple listener to update UI when completion service changes
    _completedLessonService.addListener(() {
      print("CompletedLessonService changed, updating UI");
      notifyListeners();
    });
  }

  // Filter lessons for this course
  List<Lesson> get courseLessons =>
      _lessonsService.lessons!.where((l) => l.courseId == course!.id).toList();

  String get profilePictureUrl => _userService.currentUser?.profileImage ?? '';
  String get userName => _userService.currentUser?.fullName ?? 'User';
  String get userRole => _userService.currentUser?.role ?? 'User';
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Reference to the course
  CourseModel? _course;
  CourseModel? get course => _course;

  // Lessons for the course
  List<Lesson> _lessons = [];
  List<Lesson> get lessons => _lessons;

//for toggle lessons
  bool _showAllLessons = false;
  bool get showAllLessons => _showAllLessons;

  // Add a debug flag to control logging
  static const bool _enableDebugLogs = false;

  // Centralized logging method
  void _log(String message) {
    if (_enableDebugLogs) {
      debugPrint('CourseDetailsViewModel: $message');
    }
  }

  // Initialize with a course
  Future<void> initialize(CourseModel? course) async {
    _course = course;
    setBusy(true);

    try {
      _log('Initializing course details view');

      // Batch operation: Load course data and registrations in parallel
      if (_course != null) {
        final futures = <Future>[];

        // Set up completion service listener
        _setupCompletionServiceListener();

        // Only load registrations if user is a learner
        if (isLearner) {
          _log('Loading registration data');
          futures.add(_registrationService.loadRegisteredCourses().then((_) {
            _isRegistered = _registrationService.isRegistered(_course!.id);

            // Only check wishlist if not registered (optimization)
            if (!_isRegistered) {
              _log('Loading wishlist data');
              return _wishlistService.getUserWishlist().then((_) {
                _isInWishlist = _wishlistService.isInWishlist(_course!.id);
              });
            }
            return null;
          }));
        }

        // Prefetch course image
        final imageUrl =
            _imageService.getCourseThumbnailFromPath(_course!.thumbnail);
        futures
            .add(_imageService.prefetchImage(imageUrl, courseId: _course!.id));

        // Get fresh course data if ID is available
        if (_course!.id.isNotEmpty) {
          futures
              .add(courseService.getCourseById(_course!.id).then((freshCourse) {
            _course = freshCourse;

            // Extract reviews
            if (_course!.registrations.isNotEmpty) {
              _reviews =
                  _course!.registrations.where((reg) => reg.hasReview).toList();
              _sortReviews();
            }
          }).catchError((e) {
            _log('Error refreshing course: $e');
            // Continue with existing data if refresh fails
          }));
        }

        // Wait for all parallel operations to complete
        await Future.wait(futures);

        // Load lessons last (depends on registration data)
        await _loadLessonsEfficiently();
      }
    } catch (e) {
      _log('Error during initialization: $e');
    } finally {
      _isLoading = false;
      setBusy(false);
      notifyListeners();
    }
  }

  // Optimized lesson loading with fewer redundant calls
  Future<void> _loadLessonsEfficiently() async {
    if (course == null) return;

    _log('Loading lessons efficiently');

    try {
      // Load lessons once
      _lessons = await _lessonsService.getLessons(courseId: course!.id);

      // Only verify completion status if the user is registered
      if (_isRegistered) {
        _log('Verifying completion status for registered user');

        // Check if we need to fix completion status (only on first load)
        // This prevents redundant calls during normal navigation
        if (!_hasVerifiedCompletionStatus) {
          await _completedLessonService.refreshAllCompletionData();

          // Update lessons with verified completion status
          for (int i = 0; i < _lessons.length; i++) {
            final lesson = _lessons[i];
            final isCompleted =
                await _completedLessonService.isLessonCompleted(lesson.id);

            if (lesson.isCompleted != isCompleted) {
              _lessons[i] = lesson.copyWith(isCompleted: isCompleted);
            }
          }

          _hasVerifiedCompletionStatus = true;
        }
      }
    } catch (e) {
      _log('Error loading lessons: $e');
      await _dialogService.showDialog(
        title: 'Error Loading Lessons',
        description: 'Could not load lessons. Please try again later.',
        buttonTitleColor: AppColors.primary,
      );
    }
  }

  // Track if we've already verified completion status to avoid redundant checks
  bool _hasVerifiedCompletionStatus = false;

  // Toggle a lesson's completion status
  Future<void> toggleLessonCompletion(int lessonId) async {
    try {
      setBusy(true);

      final success =
          await _completedLessonService.toggleLessonCompletion(lessonId);

      if (success) {
        // Update just the specific lesson (efficient update)
        final lessonIndex =
            _lessons.indexWhere((lesson) => lesson.id == lessonId);
        if (lessonIndex != -1) {
          // Update the lesson in the list
          _lessons[lessonIndex] = _lessons[lessonIndex]
              .copyWith(isCompleted: !_lessons[lessonIndex].isCompleted);

          // Set flag to refresh parent view when navigating back
          _shouldRefreshOnBack = true;

          // Update UI
          notifyListeners();
        }
      }
    } catch (e) {
      snackbarService.showCustomSnackBar(
        message: 'Failed to update lesson status',
        variant: SnackbarType.error,
        duration: const Duration(seconds: 2),
      );
    } finally {
      setBusy(false);
    }
  }

  // Refresh lessons
  Future<void> refreshLessons() async {
    setBusy(true);
    try {
      await _loadLessonsEfficiently();

      // Get course ID
      final courseId = course?.id;
      if (courseId != null) {
        print("Refreshing course data for course ID: $courseId");

        // Fix any lesson completion status issues
        final completedLessonService = locator<CompletedLessonService>();

        // Force registration service to reload and update progress data
        await _registrationService.loadRegisteredCourses();

        // Reload course to get updated progress
        try {
          _course = await courseService.getCourseById(courseId);
          print("Course data refreshed with updated progress");

          // This sends a notification to any reactive listeners
          // that depend on course data being refreshed
          notifyListeners();
        } catch (e) {
          print("Error refreshing course data: $e");
        }
      }
    } catch (e) {
      print("Error refreshing lessons: $e");
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  bool _manualOverrideEnabled = false;
  bool get manualOverrideEnabled => _manualOverrideEnabled;
  final ScrollController scrollController = ScrollController();

  bool _innerBoxIsScrolled = false;
  bool get innerBoxIsScrolled => _innerBoxIsScrolled;

  void setManualOverrideEnabled(bool value) {
    _manualOverrideEnabled = value;
    notifyListeners();
  }

  void setInnerBoxIsScrolled(bool value) {
    _innerBoxIsScrolled = value;
    notifyListeners();
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

  void navigateToAddLesson(CourseModel course, {Lesson? lesson}) {
    if (lesson != null) {
      // Edit mode - pass both course and lesson as separate arguments
      _navigationService.navigateToView(
        AddLessonView(
          course: course,
          lesson: lesson,
        ),
      );
    } else {
      // Add mode - pass only course
      _navigationService.navigateToView(
        AddLessonView(
          course: course,
        ),
      );
    }
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

    // Navigate to lesson details and wait for a result when returning
    _navigationService
        .navigateToLessonDetailsView(lesson: lesson)
        .then((result) {
      // If there's a result indicating we should refresh courses
      if (result is Map &&
          result.containsKey('refreshCourses') &&
          result['refreshCourses'] == true) {
        print(
            'Received refresh signal from lesson details - refreshing course data');

        // Set flag to refresh My Courses view when navigating back
        _shouldRefreshOnBack = true;

        // Refresh course data including lessons and progress
        refreshLessons();
      }
    });
  }

  // Flag to indicate if My Courses view should be refreshed when navigating back
  bool _shouldRefreshOnBack = false;

  // Handle back navigation and pass refresh signal to parent if needed
  void handleBackPress() {
    if (_shouldRefreshOnBack) {
      print("Returning to My Courses with refresh flag");
      _navigationService.back(result: {'refreshCourses': true});
    } else {
      _navigationService.back();
    }
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
    if (course == null) return;

    // Show confirmation dialog first
    final response = await _dialogService.showConfirmationDialog(
      title: 'Register for Course',
      description:
          'Are you sure you want to register for "${course!.title}"?\n\nYou will be directed to the payment page to complete your enrollment.',
      confirmationTitle: 'Continue to Payment',
      cancelTitle: 'Cancel',
    );

    // If dialog was dismissed or Cancel was clicked, just return
    if (response == null || !response.confirmed) {
      return;
    }

    // If confirmed, start the registration process
    try {
      setBusy(true);

      // This will navigate to the payment view and wait for result
      final registrationSuccessful =
          await _registrationService.createRegistration(course!.id);

      // This code will run after returning from the payment flow
      if (registrationSuccessful) {
        // Show success message
        await _dialogService.showDialog(
          title: 'Registration Successful',
          description: 'You have successfully enrolled in this course.',
          buttonTitle: 'OK',
        );

        // Reload the page after successful registration
        await initialize(course);
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to process registration: ${e.toString()}',
        buttonTitle: 'OK',
      );
    } finally {
      setBusy(false);
    }
  }

  // Helper to fully refresh course data after review actions
  Future<void> _refreshCourseAfterReview() async {
    try {
      setBusy(true);

      // Clear the form
      reviewController.clear();
      userRating = 0;

      // First, get fresh course data from the server
      if (course != null) {
        _course = await courseService.getCourseById(course!.id);

        // Extract the reviews from the registrations
        if (_course!.registrations.isNotEmpty) {
          _reviews =
              _course!.registrations.where((reg) => reg.hasReview).toList();
          _sortReviews();
        }

        // Show success message
        snackbarService.showCustomSnackBar(
          message: 'Review action completed successfully',
          variant: SnackbarType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      snackbarService.showCustomSnackBar(
        message: 'Error refreshing course data: $e',
        variant: SnackbarType.error,
        duration: const Duration(seconds: 2),
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> submitReview() async {
    if (reviewController.text.isEmpty || userRating == 0) {
      await _dialogService.showDialog(
        title: 'Invalid Review',
        description: 'Please provide both a rating and review text.',
        buttonTitle: 'OK',
      );
      return;
    }

    try {
      setBusy(true);
      final registration = _registrationService.registrations
          .firstWhere((reg) => reg.courseId == course!.id);

      final success = await _registrationService.submitReviewOrReport(
        registrationId: registration.id,
        rating: userRating,
        feedback: reviewController.text,
        type: 'review',
      );

      if (success) {
        // Refresh course data from server
        await _refreshCourseAfterReview();
      }
    } catch (e) {
      snackbarService.showCustomSnackBar(
        message: 'Failed to submit review: $e',
        variant: SnackbarType.error,
        duration: const Duration(seconds: 2),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateReview(RegistrationModel review) async {
    try {
      setBusy(true);
      final success = await _registrationService.submitReviewOrReport(
        registrationId: review.id,
        rating: userRating,
        feedback: reviewController.text,
        type: 'review',
      );

      if (success) {
        // Refresh course data from server
        await _refreshCourseAfterReview();
      }
    } catch (e) {
      snackbarService.showCustomSnackBar(
        message: 'Failed to update review: $e',
        variant: SnackbarType.error,
        duration: const Duration(seconds: 2),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> submitReport() async {
    if (reportReasonController.text.isEmpty) {
      await _dialogService.showDialog(
        title: 'Invalid Report',
        description: 'Please provide a reason for reporting this course.',
        buttonTitle: 'OK',
      );
      return;
    }

    try {
      setBusy(true);

      // Find current registration for this course
      final registration = _registrationService.registrations
          .firstWhere((reg) => reg.courseId == course!.id);

      // Submit the report using registration service
      final success = await _registrationService.submitReviewOrReport(
        registrationId: registration.id,
        reportedReason: reportReasonController.text,
        type: 'report',
      );

      if (success) {
        await _dialogService.showDialog(
          title: 'Report Submitted',
          description: 'Thank you for your report. We will review it shortly.',
          buttonTitle: 'OK',
        );

        // Clear the form
        reportReasonController.clear();

        // Refresh data
        await initialize(course);
      } else {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to submit your report. Please try again later.',
          buttonTitle: 'OK',
        );
      }
      _navigationService.back();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An error occurred: ${e.toString()}',
        buttonTitle: 'OK',
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
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

  // Add this method to navigate to the edit course page
  void navigateToEditCourse(BuildContext context, CourseModel course) async {
    if (!isCreator) {
      _dialogService.showDialog(
        title: 'Access Denied',
        description: 'Only the course creator can edit this course.',
        buttonTitle: 'OK',
      );
      return;
    }

    // Attempt to get cached image file first
    XFile? cachedImageFile;

    try {
      if (course.thumbnail.isNotEmpty) {
        final imageUrl =
            imageService.getCourseThumbnailFromPath(course.thumbnail);
        final file = await imageService.getCachedImageFile(imageUrl);

        if (file != null) {
          cachedImageFile = XFile(file.path);
        }
      }
    } catch (e) {
      print('Error loading cached image: $e');
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseCreationView(
          isEditing: true,
          initialCourseName: course.title,
          initialDescription: course.description,
          initialPrice: course.price,
          initialLearningExpectations: course.learningExpectations,
          initialRequirements: course.requirements,
          initialStacks: course.stacks,
          initialLevel: course.level,
          initialDuration: course.duration,
          initialTechStackIds:
              course.techStackIds, // Pass existing tech stack IDs
          initialThumbnail: course.thumbnail, // Pass the current thumbnail
          onSave: (title, description, price, image, learningExpectations,
              requirements, level, duration, techStackIds) async {
            // Use the selected image or keep the cached one if no new image is selected
            _selectedImage = image ?? cachedImageFile;
            await _updateCourse(
                course.id,
                title,
                description,
                price,
                learningExpectations,
                requirements,
                level,
                duration,
                techStackIds);
            return true; // Indicate success
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _updateCourse(
    String courseId,
    String title,
    String description,
    double price,
    List<String> learningExpectations,
    List<String> requirements,
    String level,
    String duration,
    List<int> techStackIds, // Add tech stack IDs parameter
  ) async {
    try {
      await courseService.updateCourse(
        courseId: courseId,
        title: title,
        description: description,
        price: price.toInt(),
        image: _selectedImage,
        learningExpectations: learningExpectations,
        requirements: requirements,
        level: level,
        duration: duration,
        techStackIds: techStackIds, // Pass tech stack IDs
      );
      _showSuccessMessage('Course updated successfully');
    } catch (e) {
      _showErrorMessage('Failed to update course: ${e.toString()}');
    }
  }

  void _showErrorMessage(String message) {
    snackbarService.showCustomSnackBar(
      message: message,
      duration: const Duration(seconds: 3),
      variant: SnackbarType.error,
    );
  }

  void _showSuccessMessage(String message) {
    snackbarService.showCustomSnackBar(
      message: message,
      duration: const Duration(seconds: 3),
      variant: SnackbarType.success,
    );
  }

  // Add this getter to check if current user is the creator of the course
  bool get isCreator =>
      _course != null &&
      currentUser != null &&
      _course!.author == currentUser!.fullName;

  // Add this getter to control review section visibility
  bool get canWriteReview {
    if (!isLearner || !isRegistered || course == null) return false;

    // Find user's registration for this course
    try {
      final registration = _registrationService.registrations
          .firstWhere((reg) => reg.courseId == course!.id);

      // Can write review only if feedback and rating are null
      return registration.feedback == null && registration.rating == null;
    } catch (e) {
      // If registration not found, user cannot write review
      return false;
    }
  }

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

  Widget getProfileImageWidget({
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (course?.author_image?.isEmpty ?? true) {
      print('author_image is empty');
      return errorWidget ??
          const Icon(Icons.person, size: 35, color: Colors.white70);
    }

    // For local files (from cache/camera)
    if (course!.author_image!.startsWith('/data/')) {
      return Image.asset(
        currentUser!.profileImage!,
        width: 60,
        height: 60,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Icon(Icons.person, size: 35, color: Colors.white70),
      );
    }

    final imageUrl =
        _imageService.getCourseThumbnailFromPath(course!.author_image!);

    // For network images
    return _imageService.loadImage(
      imageUrl: imageUrl,
      courseId: '',
      width: 60,
      height: 60,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  // Helper to format date for display
  String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).round(); // Rounded weeks
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).round(); // Rounded months
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).round(); // Rounded years
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // Get a widget to display the profile image from registration
  Widget getReviewerImageWidget(
    RegistrationModel registration, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (registration.userProfilePicture == null ||
        registration.userProfilePicture!.isEmpty) {
      return errorWidget ??
          Container(
            width: width ?? 48,
            height: height ?? 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.grey[600],
              size: (width ?? 48) * 0.6,
            ),
          );
    }

    // Use ImageService for remote images
    final imageUrl = _imageService
        .getCourseThumbnailFromPath(registration.userProfilePicture!);

    return _imageService.loadImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? _buildDefaultPlaceholder(width, height),
      errorWidget: errorWidget ?? _buildDefaultErrorWidget(width, height),
    );
  }

  // Helper method to get the appropriate vertical margin for review items
  EdgeInsetsGeometry getReviewItemMargin(int index) {
    // First review should have minimal top margin
    if (index == 0) {
      return const EdgeInsets.only(top: 4, bottom: 12);
    }
    return const EdgeInsets.only(bottom: 12);
  }

  // Show the edit review dialog with proper state management
  void showEditReviewDialog(BuildContext context, RegistrationModel review) {
    // Initialize the rating value
    final initialRating = review.rating?.toDouble() ?? 0;
    setRating(initialRating);
    reviewController.text = review.feedback ?? '';

    // Use a local rating variable in the dialog
    double dialogRating = initialRating;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Your Review',
                    style: GoogleFonts.figtree(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Rate this course',
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              // Update both the local and viewmodel rating
                              dialogRating = index + 1.0;
                              setRating(dialogRating);
                              setState(() {});
                            },
                            child: Icon(
                              index < dialogRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: index < dialogRating
                                  ? Colors.amber
                                  : Colors.grey[400],
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    style: GoogleFonts.figtree(
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                      hintText: 'Share your updated thoughts...',
                      hintStyle: GoogleFonts.figtree(
                        color: Colors.grey[400],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.figtree(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          updateReview(review);
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(
                          Icons.save_outlined,
                          size: 18,
                        ),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Add a helper to handle rating selection in the write review section
  void handleRatingSelection(int index, Function setState) {
    final newRating = index + 1.0;
    setRating(newRating);
    setState();
  }

  // Calculate completion statistics for the course
  Map<String, dynamic> computeCompletionStats() {
    if (_lessons.isEmpty) {
      return {
        'completedCount': 0,
        'totalCount': 0,
        'completionPercentage': 0.0,
      };
    }

    int completedCount = _lessons.where((lesson) => lesson.isCompleted).length;
    double percentage = (completedCount / _lessons.length) * 100;

    return {
      'completedCount': completedCount,
      'totalCount': _lessons.length,
      'completionPercentage': percentage,
    };
  }
}
