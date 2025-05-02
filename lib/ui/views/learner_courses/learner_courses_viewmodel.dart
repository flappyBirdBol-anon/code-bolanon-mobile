import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/completed_lesson_service.dart';
import 'package:code_bolanon/services/course_service.dart'; // Import CourseService
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/ui/common/base/course_base_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class LearnerCoursesViewModel extends CourseBaseViewModel
    with WidgetsBindingObserver {
  @override
  AppointmentService get appointmentService => locator<AppointmentService>();
  final RegistrationService registrationService; // Keep RegistrationService
  final CourseService courseService; // Add CourseService
  final CompletedLessonService _completedLessonService =
      locator<CompletedLessonService>(); // Add CompletedLessonService

  // Track if this view has ever been initialized (to avoid duplicate initializations)
  bool _hasBeenInitialized = false;
  // Track when the view was last refreshed to avoid too frequent refreshes
  DateTime? _lastRefreshTime;

  // Add course list properties
  List<CourseModel> _allCourses = [];
  List<CourseModel> _filteredCourses = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  List<CourseModel> get courses => _filteredCourses;

  @override
  List<String> get availableFilters =>
      ['All', 'Free', 'Premium', 'In Progress', 'Completed', ...allTags];

  Set<String> _activeFilters = {'All'};
  @override
  Set<String> get activeFilters => _activeFilters;

  @override
  void toggleFilter(String filter) {
    if (filter == 'All') {
      _activeFilters = {'All'};
    } else {
      _activeFilters.remove('All');
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
    }
    applyFilters();
  }

  @override
  void clearFilters() {
    _activeFilters = {'All'};
    applyFilters();
  }

  String _searchQuery = '';
  @override
  String get searchQuery => _searchQuery;

  @override
  void onSearchChanged(String query) {
    _searchQuery = query.toLowerCase().trim();
    if (_searchQuery.isEmpty) {
      // Reset to show all courses when search is cleared
      _filteredCourses = _allCourses;
    } else {
      _filteredCourses = _allCourses.where((course) {
        return course.title.toLowerCase().contains(_searchQuery) ||
            course.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  // Method to handle search reset
  void resetSearch() {
    _searchQuery = '';
    _filteredCourses = _allCourses;
    notifyListeners();
  }

  LearnerCoursesViewModel({
    required this.registrationService,
    required this.courseService,
    required ImageService imageService,
  }) : super(courseService, imageService: imageService) {
    // Register the lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Add listeners to services to react to changes
    _completedLessonService.addListener(_onCompletionDataChanged);
    registrationService.addListener(_onRegistrationDataChanged);

    // Start initialization
    _init();
  }

  void _init() {
    print('LearnerCoursesViewModel - init started');

    // Only refresh if it's been more than 5 seconds since last refresh
    // This prevents excessive refreshes when rapidly navigating
    final now = DateTime.now();
    if (_lastRefreshTime == null ||
        now.difference(_lastRefreshTime!).inSeconds > 5) {
      print('Refreshing courses data');
      _searchQuery = ''; // Reset search query
      _activeFilters = {'All'}; // Reset filters
      loadCourses();
      _lastRefreshTime = now;
    } else {
      print('Skipping refresh - last refresh was too recent');
    }

    _hasBeenInitialized = true;
  }

  @override
  Future<List<CourseModel>> loadCourses(
      {int page = 1, int pageSize = 10}) async {
    print('loadCourses started - page: $page, pageSize: $pageSize');
    if (_isLoading) return _filteredCourses; // Prevent multiple loads

    _isLoading = true;
    setBusy(true);
    notifyListeners();

    try {
      print('Fetching user registrations...');
      final registrations = await registrationService.getUserRegistrations();
      print('Loaded registrations count: ${registrations.length}');

      // Even if no registrations, update courses with empty list to show empty state
      if (registrations.isEmpty) {
        print('No registrations found, showing empty state');
        updateCourses([]);
        return [];
      }

      print('Fetching registered courses...');
      final loadedCourses =
          await registrationService.getRegisteredCourses(registrations);
      print('Loaded courses count: ${loadedCourses.length}');

      if (loadedCourses.isNotEmpty) {
        print('First course title: ${loadedCourses[0].title}');
      }

      // Update courses using the base class method
      updateCourses(loadedCourses);
      return loadedCourses;
    } catch (e, stackTrace) {
      print('Error in loadCourses: $e');
      print('StackTrace: $stackTrace');
      setError(true);
      snackbarService.showSnackbar(message: 'Failed to load courses: $e');
      updateCourses([]);
      return [];
    } finally {
      _isLoading = false;
      setBusy(false); // Always ensure busy state is cleared
      notifyListeners();
    }
  }

  Future<void> initialise() async {
    setBusy(true);
    try {
      await fetchCourses();
      debugPrint('Courses initialized successfully');
    } catch (e) {
      setError(e);
      debugPrint('Error initializing courses: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchCourses() async {
    if (isBusy) return; // Prevent multiple fetches

    try {
      await loadCourses();
    } catch (e) {
      print('Error fetching courses: $e');
      setError(e);
    }
  }

  // Add method to update courses
  @override
  void updateCourses(List<CourseModel> newCourses) {
    print('Updating courses with ${newCourses.length} items');
    _allCourses = newCourses;
    _filteredCourses = newCourses;
    _isLoading = false;
    setBusy(false); // Ensure busy state is cleared after update
    notifyListeners();
  }

  @override
  void applyFilters() {
    if (_allCourses.isEmpty) {
      _filteredCourses = [];
      notifyListeners();
      return;
    }

    _filteredCourses =
        _allCourses.where((course) => filterCourse(course)).toList();
    notifyListeners();
  }

  // Handle navigation results, particularly from the lesson details view
  void handleNavigationResult(dynamic result) {
    if (result is Map &&
        result.containsKey('refreshCourses') &&
        result['refreshCourses'] == true) {
      print('Received refresh signal from navigation - refreshing courses');
      // Use the more comprehensive refresh method
      refreshFromCourseDetails();
    }
  }

  @override
  bool filterCourse(CourseModel course) {
    if (activeFilters.contains('All')) return true;

    // Handle tag filters
    final tagFilters = activeFilters.intersection(allTags.toSet());
    if (tagFilters.isNotEmpty) {
      for (var tag in tagFilters) {
        if (courseHasTag(course.id, tag)) {
          return true;
        }
      }
    }

    // Handle price filters
    if (activeFilters.contains('Free') && course.price == 0) return true;
    if (activeFilters.contains('Premium') && course.price > 0) return true;

    // Handle progress filters
    if (activeFilters.contains('In Progress')) {
      final progress = computeProgress(course);
      return progress > 0 && progress < 1;
    }
    if (activeFilters.contains('Completed')) {
      return computeProgress(course) >= 1;
    }

    return false;
  }

  @override
  AuthService get authService => locator<AuthService>();

  @override
  NavigationService get navigationService => locator<NavigationService>();

  @override
  SnackbarService get snackbarService => locator<SnackbarService>();

  @override
  UserService get userService => locator<UserService>();

  double computeProgress(CourseModel course) {
    // Use the progress field if available
    if (course.registration?.progress != null) {
      return course.registration!.progress!.percentage / 100.0;
    }

    // Use completedLessonsList if available (preferred)
    if (course.registration?.completedLessonsList != null &&
        course.registration!.completedLessonsList!.isNotEmpty &&
        course.lessons > 0) {
      // Count completed lessons - no need to filter since all items in the list represent completed lessons
      final completedCount = course.registration!.completedLessonsList!.length;

      // Calculate progress with more precision
      final progress = completedCount / course.lessons;

      // Log for debugging
      print(
          "Course ${course.id} (${course.title}) progress: $completedCount/${course.lessons} = ${(progress * 100).toStringAsFixed(1)}%");

      return progress;
    }

    // Fall back to the old calculation method if needed
    if (course.registration?.completedLessons == null || course.lessons == 0) {
      print(
          "Course ${course.id} (${course.title}) progress: 0% (no completed lessons data or zero total lessons)");
      return 0.0;
    }

    final progress = course.registration!.completedLessons!.isCompleted
        ? 1.0
        : (course.registration!.completedLessons!.lessonId / course.lessons);

    print(
        "Course ${course.id} (${course.title}) progress: ${(progress * 100).toStringAsFixed(1)}% (using fallback method)");

    return progress;
  }

  void navigateToWishlist() {
    navigationService.navigateToLearnerWishlistsView();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed - refreshing courses');
      // Use fetchCourses which is a lighter refresh than _init
      fetchCourses();
    }
  }

  // This method should be called from the Course Details view
  // when a lesson is completed to update the UI immediately
  void refreshFromCourseDetails() {
    print('Refreshing courses after returning from Course Details');

    // Set last refresh time to allow immediate refresh
    _lastRefreshTime = DateTime.now().subtract(const Duration(seconds: 10));

    // First clear caches and reload data from services
    refreshAllData();
  }

  // Perform a complete data refresh
  Future<void> refreshAllData() async {
    try {
      setBusy(true);

      // Reset filters and search to show all courses
      _searchQuery = '';
      _activeFilters = {'All'};

      // Force service to reload registration data
      await registrationService.loadRegisteredCourses();

      // Load courses with updated progress
      await loadCourses();

      print("Courses refreshed with updated progress");
    } catch (e) {
      print("Error refreshing all data: $e");
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    // Clean up listeners when view model is disposed
    _completedLessonService.removeListener(_onCompletionDataChanged);
    registrationService.removeListener(_onRegistrationDataChanged);

    // Unregister the lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handler for when completion data changes in the CompletedLessonService
  void _onCompletionDataChanged() {
    print('Lesson completion data changed - refreshing courses UI');

    // Only refresh if not already busy and enough time has passed since last refresh
    final now = DateTime.now();
    if (!isBusy &&
        (_lastRefreshTime == null ||
            now.difference(_lastRefreshTime!).inSeconds > 2)) {
      _lastRefreshTime = now;
      fetchCourses();
    } else {
      print('Skipping refresh due to recent update or busy state');
    }
  }

  // Handler for when registration data changes
  void _onRegistrationDataChanged() {
    print('Registration data changed - refreshing courses UI');

    // Only refresh if not already busy and enough time has passed since last refresh
    final now = DateTime.now();
    if (!isBusy &&
        (_lastRefreshTime == null ||
            now.difference(_lastRefreshTime!).inSeconds > 2)) {
      _lastRefreshTime = now;
      fetchCourses();
    } else {
      print('Skipping refresh due to recent update or busy state');
    }
  }
}
