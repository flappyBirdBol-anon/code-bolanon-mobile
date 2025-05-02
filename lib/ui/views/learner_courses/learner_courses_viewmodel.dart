import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/services/completed_lesson_service.dart';
import 'package:code_bolanon/services/course_service.dart'; // Import CourseService
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/ui/common/base/course_base_view_model.dart';
import 'package:flutter/material.dart';

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
      ['All', 'Free', 'Premium', 'In Progress', 'Completed'];

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

  Future<void> fetchCourses() async {
    if (isBusy) return; // Prevent multiple fetches

    try {
      await loadCourses();

      // Always refresh ratings after loading courses
      await _refreshCourseRatings();
    } catch (e) {
      print('Error fetching courses: $e');
      setError(e);
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

    final typeFilters = activeFilters.intersection({'Free', 'Premium'}.toSet());
    if (typeFilters.isNotEmpty) {
      for (var type in typeFilters) {
        if ((type == 'Free' && course.price <= 0) ||
            (type == 'Premium' && course.price > 0)) {
          return true;
        }
      }
    }

    final progressFilters =
        activeFilters.intersection({'In Progress', 'Completed'}.toSet());
    if (progressFilters.isNotEmpty) {
      for (var progress in progressFilters) {
        final courseProgress = computeProgress(course);
        if ((progress == 'In Progress' &&
                courseProgress > 0 &&
                courseProgress < 1) ||
            (progress == 'Completed' && courseProgress >= 1)) {
          return true;
        }
      }
    }

    // No filters matched
    return false;
  }

  // Calculate progress for a course (returns a value between 0.0 and 1.0)
  double computeProgress(CourseModel course) {
    // Use the progress field if available from registration
    if (course.registration?.progress != null) {
      // Convert percentage (0-100) to decimal (0.0-1.0)
      return course.registration!.progress!.percentage / 100.0;
    }

    // Use completedLessonsList if available (preferred)
    if (course.registration?.completedLessonsList != null &&
        course.registration!.completedLessonsList!.isNotEmpty &&
        course.lessons > 0) {
      // Count completed lessons
      final completedCount = course.registration!.completedLessonsList!.length;

      // Calculate progress with more precision
      return completedCount / course.lessons;
    }

    // Fall back if no completion data or zero lessons
    return 0.0;
  }

  // Method to display course image similar to course details view
  Widget getCourseImageWidget(
    CourseModel course, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // Handle local assets differently
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

    // Use ImageService for remote images
    final imageUrl = imageService.getCourseThumbnailFromPath(course.thumbnail);

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

  // Override getCourseTags to ensure we correctly extract tags
  @override
  List<String> getCourseTags(CourseModel course) {
    if (course.stacks.isNotEmpty) {
      return course.stacks;
    }
    return const [];
  }

  // Navigate to course details
  @override
  void navigateToCourseDetails(CourseModel course) {
    navigationService.navigateToCourseDetailsView(
      course: course,
    );
  }

  // Navigate to courses
  void navigateToCourses() {
    navigationService.navigateToAvailableCoursesView();
  }

  // Navigate to wishlist
  void navigateToWishlist() {
    navigationService.navigateToLearnerWishlistsView();
  }

  // Method to handle completion data changes
  void _onCompletionDataChanged() {
    print('CompletedLessonService notified change - refreshing progress');
    if (_allCourses.isEmpty) return; // No courses to update

    // Just notify listeners to rebuild the UI with updated progress
    notifyListeners();
  }

  // Method to handle registration data changes
  void _onRegistrationDataChanged() {
    print('RegistrationService notified change - reloading courses');
    // If we're already loading, don't trigger another load
    if (_isLoading) return;

    // Fully reload courses when registrations change
    loadCourses();
  }

  // Refresh from course details
  Future<void> refreshFromCourseDetails() async {
    print('Refreshing from course details');
    try {
      // Refresh course progress by syncing for each course
      await _completedLessonService.resetAndRefreshAllCompletionData();

      // Then refresh courses to get updated data
      await fetchCourses();
    } catch (e) {
      print('Error refreshing from course details: $e');
    }
  }

  // Manually refresh course ratings
  Future<void> _refreshCourseRatings() async {
    if (_allCourses.isEmpty) return;

    try {
      // For now, skip the problematic course refresh and just update the UI
      print('Skipping individual course refresh due to type errors');

      // Just notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      print('Error refreshing course ratings: $e');
    }
  }

  // Helper to update a course with fresh data while preserving registration info
  // This method was causing type errors, so we're not using it for now
  Future<void> _updateCourseWithFreshData(CourseModel course, int index) async {
    // Method disabled due to type errors with CourseService.getCourseById
    // When fixed, this method can be re-enabled
    print('Course update method disabled due to type errors');
  }

  @override
  void dispose() {
    // Unregister from the widget binding
    WidgetsBinding.instance.removeObserver(this);

    // Remove listeners from services
    _completedLessonService.removeListener(_onCompletionDataChanged);
    registrationService.removeListener(_onRegistrationDataChanged);

    super.dispose();
  }
}
