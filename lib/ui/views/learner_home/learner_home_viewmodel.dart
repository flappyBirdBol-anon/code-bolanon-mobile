import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/models/course_model.dart' as api_model;
import 'package:code_bolanon/models/tech_stack_model.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:code_bolanon/ui/views/learner_courses/learner_courses_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class LearnerHomeViewModel extends AppBaseViewModel {
  final bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  // User Info
  String get userFullName => userService.currentUser?.fullName ?? 'User';
  String get userEmail => userService.currentUser?.email ?? '';
  String get userImage => userService.currentUser?.profileImage ?? '';

  // Progress Tracking
  int completedCourses = 0;
  int inProgressCourses = 0;
  int totalEnrolledCourses = 0;
  double get completedCoursesPercentage =>
      totalEnrolledCourses > 0 ? completedCourses / totalEnrolledCourses : 0.0;
  double get inProgressCoursesPercentage =>
      totalEnrolledCourses > 0 ? inProgressCourses / totalEnrolledCourses : 0.0;

  bool isLoading = true;

  // Services
  final _courseService = locator<CourseService>();
  final _imageService = locator<ImageService>();
  final _navigationService = locator<NavigationService>();
  final _appointmentService = locator<AppointmentService>();
  final _registrationService = locator<RegistrationService>();
  @override
  final ImageService imageService = locator<ImageService>();

  // Add a LearnerCoursesViewModel for real course data
  late final LearnerCoursesViewModel _coursesViewModel;

  // Tech Stack
  List<TechStackModel> get userTopics => userService.userTechStacks;
  List<String> get techStack => userTopics.map((e) => e.tags).toList();

  // Course lists
  final List<CourseModel> _popularCourses = [];
  List<CourseModel> _recommendedCourses = [];
  List<CourseModel> _topRatedCourses = [];

  // Real courses instead of mock data
  List<api_model.CourseModel> _registeredCourses = [];
  List<api_model.CourseModel> get registeredCourses => _registeredCourses;

  List<CourseModel> get popularCourses => _popularCourses;
  List<CourseModel> get recommendedCourses => _recommendedCourses;
  List<CourseModel> get topRatedCourses => _topRatedCourses;

  final List<CourseModel> _inProgressCourses = [];
  List<CourseModel> get inProgressCoursesList => _inProgressCourses;

  // Real appointments instead of mock data
  final List<AppointmentModel> _upcomingSessions = [];
  List<AppointmentModel> get upcomingSessions => _upcomingSessions;

  LearnerHomeViewModel() {
    userService.addListener(_onUserChanged);
    _coursesViewModel = LearnerCoursesViewModel(
      registrationService: _registrationService,
      courseService: _courseService,
      imageService: imageService,
    );
    init();
  }

  void _onUserChanged() {
    notifyListeners();
  }

  Future<void> init() async {
    setBusy(true);
    try {
      await refreshData();
    } catch (e) {
      debugPrint('Error initializing learner home: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> refreshData() async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch courses from CourseService and convert to our local CourseModel
      final apiCourses = await _courseService.getCourses();

      // Get real registered courses using the LearnerCoursesViewModel
      await _coursesViewModel.loadCourses();
      _registeredCourses = _coursesViewModel.courses;

      // Update progress stats based on actual registered courses
      totalEnrolledCourses = _registeredCourses.length;

      // Count completed and in-progress courses
      completedCourses = 0;
      inProgressCourses = 0;

      for (var course in _registeredCourses) {
        // Check registration for completion status
        final registration = course.registration;
        if (registration != null && registration.progress != null) {
          final progressPercentage = registration.progress!.percentage;

          if (progressPercentage >= 100) {
            completedCourses++;
          } else if (progressPercentage > 0) {
            inProgressCourses++;
          }
        }
      }

      // IMPORTANT: Check if apiCourses is empty to avoid "No element" errors
      if (apiCourses.isEmpty) {
        _popularCourses.clear();
        _topRatedCourses.clear();
        _recommendedCourses.clear();
      } else {
        // Popular courses: Sort by learners enrolled (highest to lowest), take top 5
        final popularCoursesSorted = List<api_model.CourseModel>.from(
            apiCourses)
          ..sort((a, b) => (b.studentsEnrolled).compareTo(a.studentsEnrolled));
        final popularCoursesTop5 = popularCoursesSorted.take(5).toList();
        _popularCourses.clear();
        _popularCourses.addAll(_convertToCourseModels(popularCoursesTop5));

        // Top rated courses: Sort by ratings (highest to lowest), take top 5
        final topRatedSorted = List<api_model.CourseModel>.from(apiCourses)
          ..sort((a, b) => b.rating.compareTo(a.rating));
        final topRatedTop5 = topRatedSorted.take(5).toList();
        _topRatedCourses = _convertToCourseModels(topRatedTop5);

        // Recommended courses: Filter by matching user's tech stacks
        final userStacks = userTopics.map((stack) => stack.tags).toList();
        final recommendedCoursesList = apiCourses.where((course) {
          // If course has stacks that match any of the user's stacks, include it
          return course.stacks.any((stack) => userStacks.contains(stack));
        }).toList();

        // If no matching courses or user has no tech stacks, fallback to some popular courses
        if (recommendedCoursesList.isEmpty) {
          _recommendedCourses = _convertToCourseModels(
              popularCoursesTop5.skip(1).take(4).toList());
        } else {
          _recommendedCourses =
              _convertToCourseModels(recommendedCoursesList.take(4).toList());
        }
      }

      // Load real appointments from the service
      await _loadRealAppointments();
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper to convert API models to our local CourseModel
  List<CourseModel> _convertToCourseModels(
      List<api_model.CourseModel> apiCourses) {
    return apiCourses.map((apiCourse) {
      // Use a default image path for assets that starts with 'assets/'
      final imageUrl = apiCourse.thumbnail.isNotEmpty
          ? apiCourse.thumbnail
          : PngImages.image1;

      return CourseModel(
        id: apiCourse.id, // Include the ID from the API model
        title: apiCourse.title,
        imageUrl: imageUrl,
        price: apiCourse.price ?? 99.99,
        rating: apiCourse.rating.toDouble() ?? 4.5,
        reviews: apiCourse.reviews ?? 100,
        tags: apiCourse.stacks,
        totalLessons: apiCourse.lessonCount ?? apiCourse.lessons ?? 12,
        enrolledStudents: apiCourse.studentsEnrolled,
        instructorName: apiCourse.author ?? "Instructor",
        description: apiCourse.description,
      );
    }).toList();
  }

  // Method to get real appointment data
  Future<void> _loadRealAppointments() async {
    try {
      _upcomingSessions.clear();
      debugPrint('============= APPOINTMENTS DEBUG START =============');

      // Get appointments from the service
      final appointments = await _appointmentService.getUserAppointments();
      debugPrint('SERVICE: Loaded ${appointments.length} appointments');

      if (appointments.isNotEmpty) {
        // Only exclude completed and cancelled appointments
        final upcomingAppointments = appointments
            .where((appointment) =>
                appointment.status.toLowerCase() != 'completed' &&
                appointment.status.toLowerCase() != 'cancelled')
            .toList();

        debugPrint(
            'Filtered to ${upcomingAppointments.length} valid appointments');

        // Sort by date (closest first)
        upcomingAppointments.sort((a, b) => a.startAt.compareTo(b.startAt));

        _upcomingSessions.addAll(upcomingAppointments);

        // Force a UI refresh
        notifyListeners();

        debugPrint('Added ${_upcomingSessions.length} appointments to UI');
      } else {
        debugPrint('NO APPOINTMENTS FROM SERVICE - Creating test appointments');
        // In debug mode, always create test appointments if none were returned
        if (isDebugMode()) {
          _createTestAppointments();
        }
      }

      debugPrint('============= APPOINTMENTS DEBUG END =============');
    } catch (e) {
      debugPrint('ERROR LOADING APPOINTMENTS: $e');
      // In case of error, create test appointments for UI testing
      if (isDebugMode()) {
        _createTestAppointments();
      }
    }
  }

  // Helper to detect if we're in debug mode
  bool isDebugMode() {
    bool debugMode = false;
    assert(() {
      debugMode = true;
      return true;
    }());
    return debugMode;
  }

  // For testing only - creates fake appointments
  void _createTestAppointments() {
    debugPrint('Creating test appointments for debug mode');

    // Clear existing appointments
    _upcomingSessions.clear();

    // Create a trainer
    final testTrainer = UserModel(
      id: 999,
      firstName: "Test",
      lastName: "Trainer",
      email: "test@example.com",
      profileImage: "", // No image
      role: "trainer", // Adding required role field
    );

    // Create two test appointments
    final now = DateTime.now();

    // Appointment today
    _upcomingSessions.add(AppointmentModel(
      id: 1001,
      trainerId: 999,
      trainer: testTrainer,
      learnerId: 1,
      status: 'booked',
      startAt: now.add(const Duration(hours: 2)),
      endAt: now.add(const Duration(hours: 3)),
      price: 100.0,
      gmeetLink: 'https://meet.google.com/test',
      contextDetails: 'Test session', // Adding required contextDetails field
    ));

    // Appointment tomorrow
    _upcomingSessions.add(AppointmentModel(
      id: 1002,
      trainerId: 999,
      trainer: testTrainer,
      learnerId: 1,
      status: 'booked',
      startAt: now.add(const Duration(days: 1, hours: 2)),
      endAt: now.add(const Duration(days: 1, hours: 3)),
      price: 100.0,
      gmeetLink: 'https://meet.google.com/test2',
      contextDetails:
          'Follow-up session', // Adding required contextDetails field
    ));

    // Notify listeners to update UI
    notifyListeners();
  }

  // Use the LearnerCoursesViewModel's computeProgress method for real progress
  double computeProgress(api_model.CourseModel course) {
    return _coursesViewModel.computeProgress(course);
  }

  // Get course tags from the LearnerCoursesViewModel
  List<String> getCourseTags(api_model.CourseModel course) {
    return _coursesViewModel.getCourseTags(course);
  }

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Widget getProfileImageWidget({
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // Simplified version
    if (userImage.isEmpty) {
      return errorWidget ??
          const Icon(Icons.person, size: 35, color: Colors.white70);
    }

    final imageUrl = _imageService.getCourseThumbnailFromPath(userImage);
    return _imageService.loadImage(
      imageUrl: imageUrl,
      courseId: '',
      width: 60,
      height: 60,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget ??
          const Icon(Icons.person, size: 35, color: Colors.white70),
    );
  }

  void openSession(String sessionId) {
    // Convert to integer ID if possible
    int? appointmentId;
    try {
      appointmentId = int.parse(sessionId);
    } catch (e) {
      debugPrint('Error parsing appointment ID: $e');
    }

    if (appointmentId != null) {
      debugPrint('Opening appointment details: $appointmentId');
      navigationService.navigateToAppointmentDetailsView(
          appointmentId: sessionId);
    } else {
      snackbarService.showSnackbar(
        message: 'Could not open appointment details',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // New method that accepts a course directly
  void openCourseObject(api_model.CourseModel course) {
    debugPrint('Opening course directly: ${course.id}, ${course.title}');
    navigationService.navigateToCourseDetailsView(course: course);
  }

  // Find a course by either ID or title
  api_model.CourseModel findCourseByIdOrTitle(String idOrTitle) {
    debugPrint('Searching for course: $idOrTitle');

    // Check if any courses are loaded
    if (_registeredCourses.isEmpty &&
        _popularCourses.isEmpty &&
        _recommendedCourses.isEmpty &&
        _topRatedCourses.isEmpty) {
      debugPrint('No courses loaded yet, returning default course');
      return api_model.CourseModel(
        id: idOrTitle, // Use as ID by default
        title: 'Loading...',
        price: 0,
        description: '',
        thumbnail: '',
      );
    }

    // First try to find in registered courses by ID
    for (var course in _registeredCourses) {
      if (course.id == idOrTitle) {
        debugPrint('Found course by ID in registered courses');
        return course;
      }
    }

    // Then try to find in registered courses by title
    for (var course in _registeredCourses) {
      if (course.title.toLowerCase() == idOrTitle.toLowerCase()) {
        debugPrint('Found course by title in registered courses');
        return course;
      }
    }

    // Check in other course lists (convert local models to API models)
    var allLocalCourses = [
      ..._popularCourses,
      ..._recommendedCourses,
      ..._topRatedCourses
    ];

    for (var localCourse in allLocalCourses) {
      if (localCourse.id == idOrTitle ||
          localCourse.title.toLowerCase() == idOrTitle.toLowerCase()) {
        // Found a match in local courses, create a basic API model
        debugPrint('Found matching local course, creating API model');
        return api_model.CourseModel(
          id: localCourse.id,
          title: localCourse.title,
          price: localCourse.price.toDouble(),
          description: localCourse.description,
          thumbnail: localCourse.imageUrl,
          stacks: localCourse.tags,
          studentsEnrolled: localCourse.enrolledStudents,
          rating: localCourse.rating,
          reviews: localCourse.reviews,
          author: localCourse.instructorName,
          lessons: localCourse.totalLessons,
        );
      }
    }

    // If all else fails, create a course object with the ID/title
    debugPrint('Creating new course with id/title: $idOrTitle');
    return api_model.CourseModel(
      id: idOrTitle,
      title: idOrTitle,
      price: 0,
      description: '',
      thumbnail: '',
    );
  }

  void openCourse(String idOrTitle) {
    try {
      final course = findCourseByIdOrTitle(idOrTitle);
      debugPrint('Opening course: ${course.id}, ${course.title}');
      navigationService.navigateToCourseDetailsView(course: course);
    } catch (e) {
      debugPrint('Error in openCourse: $e');
      // Create a basic course with the identifier
      final defaultCourse = api_model.CourseModel(
        id: idOrTitle,
        title: idOrTitle,
        price: 0,
        description: '',
        thumbnail: '',
      );
      navigationService.navigateToCourseDetailsView(course: defaultCourse);
    }
  }

  void openProfile() {
    navigationService.navigateTo(Routes.profileView);
  }

  void showNotifications() {
    // Show notifications
  }

  void viewAllCourses() {
    // Navigate to available courses view
    navigationService.navigateTo(Routes.availableCoursesView);
  }

  void viewRegisteredCourses() {
    // Navigate to available courses view
    navigationService.navigateTo(Routes.learnerCoursesView);
  }

  // Navigation methods for appointments
  void navigateToLearnerBookedAppointments() {
    navigationService.navigateTo(Routes.learnerScheduleView);
  }

  @override
  void dispose() {
    userService.removeListener(_onUserChanged);
    super.dispose();
  }

  // Get course image using LearnerCoursesViewModel
  Widget getCourseImageWidget({
    required api_model.CourseModel course,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // Debug the image path
    debugPrint('Loading course image: ${course.thumbnail}');

    // Handle empty thumbnails
    if (course.thumbnail.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: errorWidget ??
            Icon(Icons.image_not_supported, color: Colors.grey[600]),
      );
    }

    // Handle asset images
    if (course.thumbnail.startsWith('assets/')) {
      return Image.asset(
        course.thumbnail,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading asset image: $error');
          return errorWidget ??
              Icon(Icons.image_not_supported, color: Colors.grey[600]);
        },
      );
    }

    // Handle network or other images using ImageService
    final imageUrl = imageService.getCourseThumbnailFromPath(course.thumbnail);
    debugPrint('Processed image URL: $imageUrl');

    return imageService.loadImage(
      imageUrl: imageUrl,
      courseId: course.id,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
      errorWidget: errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
          ),
    );
  }
}

// Keep CourseModel class for backward compatibility with other parts of the app
class CourseModel {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviews;
  final List<String> tags;
  final double progress;
  final String registrationDate;
  final int totalLessons;
  final int enrolledStudents;
  final String lastAccessDate;
  final bool isCompleted;
  final String instructorName;
  final String activityType; // 'completed', 'in_progress', 'started'
  final String difficulty;
  final String duration;
  final String description;

  CourseModel({
    this.id = '',
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviews,
    this.tags = const [],
    this.progress = 0.0,
    this.registrationDate = '',
    this.totalLessons = 0,
    this.enrolledStudents = 0,
    this.lastAccessDate = '',
    this.isCompleted = false,
    this.instructorName = '',
    this.activityType = 'in_progress',
    this.difficulty = 'Intermediate',
    this.duration = '6 weeks',
    this.description = '',
  });
}
