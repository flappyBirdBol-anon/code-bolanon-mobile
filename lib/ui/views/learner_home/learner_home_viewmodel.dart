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

      // Convert to our local CourseModel for the other sections that still use the old model
      _topRatedCourses = _convertToCourseModels(apiCourses.take(5).toList());
      _recommendedCourses =
          _convertToCourseModels(apiCourses.skip(1).take(4).toList());

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

      // Get appointments from the service
      final appointments = await _appointmentService.getUserAppointments();

      if (appointments.isNotEmpty) {
        // Filter to only show upcoming appointments
        final now = DateTime.now();
        final upcomingAppointments = appointments
            .where((appointment) => appointment.startAt.isAfter(now))
            .toList();

        // Sort by date (closest first)
        upcomingAppointments.sort((a, b) => a.startAt.compareTo(b.startAt));

        _upcomingSessions.addAll(upcomingAppointments);
      } else {
        // If no real appointments, add a few mock ones for UI demonstration
        _createMockAppointments();
      }
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      _createMockAppointments();
    }
  }

  void _createMockAppointments() {
    // Clear any existing appointments
    _upcomingSessions.clear();

    // Add fake appointments with user-related data
    _upcomingSessions.add(
      AppointmentModel(
        id: 1,
        startAt: DateTime.now().add(const Duration(days: 1)),
        endAt: DateTime.now().add(const Duration(days: 1, hours: 1)),
        price: 50.0,
        contextDetails: 'Flutter Application Development',
        status: 'confirmed',
        trainerId: 1,
        trainer: UserModel(
          id: 1,
          firstName: "John",
          lastName: "Doe",
          email: "john.doe@example.com",
          profileImage: "",
          role: "trainer",
        ),
      ),
    );

    _upcomingSessions.add(
      AppointmentModel(
        id: 2,
        startAt: DateTime.now().add(const Duration(days: 3)),
        endAt: DateTime.now().add(const Duration(days: 3, hours: 1)),
        price: 75.0,
        contextDetails: 'Mobile App Architecture Review',
        status: 'confirmed',
        trainerId: 2,
        trainer: UserModel(
          id: 2,
          firstName: "Jane",
          lastName: "Smith",
          email: "jane.smith@example.com",
          profileImage: "",
          role: "trainer",
        ),
      ),
    );

    notifyListeners();
  }

  // Other methods remain the same...

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
    // Just print for now since launchAppointment isn't defined
    debugPrint('Opening session: $sessionId');
  }

  void openCourse(String courseId) {
    // Just print for now as we can't access the correct navigation method
    debugPrint('Opening course: $courseId');
    // Navigate to courses view instead
    navigationService.navigateTo(Routes.availableCoursesView);
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

  // Navigation methods for appointments
  void navigateToLearnerBookedAppointments() {
    navigationService.navigateTo(Routes.learnerAppointmentHomeView);
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
    // Fallback implementation if course image widget can't be directly obtained
    if (course.thumbnail.startsWith('assets/')) {
      return Image.asset(
        course.thumbnail,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Icon(Icons.image_not_supported, color: Colors.grey[600]);
        },
      );
    }

    // Use the ImageService directly instead
    final imageUrl = imageService.getCourseThumbnailFromPath(course.thumbnail);
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
          Icon(Icons.image_not_supported, color: Colors.grey[600]),
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
