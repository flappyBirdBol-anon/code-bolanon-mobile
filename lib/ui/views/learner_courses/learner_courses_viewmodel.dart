// Fixed LearnerCoursesViewModel with corrected progress calculation

import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/services/completed_lesson_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/ui/common/base/course_base_view_model.dart';
import 'package:flutter/material.dart';

class LearnerCoursesViewModel extends CourseBaseViewModel
    with WidgetsBindingObserver {
  @override
  AppointmentService get appointmentService => locator<AppointmentService>();
  final RegistrationService registrationService;
  final CourseService courseService;
  final CompletedLessonService _completedLessonService =
      locator<CompletedLessonService>();

  // Track initialization state
  bool _initialized = false;

  // Throttle refreshes with a fixed cooldown period
  DateTime? _lastRefreshTime;
  static const refreshCooldownSeconds = 5;

  // Track if a refresh is in progress to prevent duplicates
  bool _refreshInProgress = false;

  // Add course list properties
  List<CourseModel> _allCourses = [];
  List<CourseModel> _filteredCourses = [];

  @override
  List<CourseModel> get courses => _filteredCourses;

  @override
  List<String> get availableFilters =>
      ['All', 'Free', 'Premium', 'In Progress', 'Completed'];

  Set<String> _activeFilters = {'All'};
  @override
  Set<String> get activeFilters => _activeFilters;

  String _searchQuery = '';
  @override
  String get searchQuery => _searchQuery;

  LearnerCoursesViewModel({
    required this.registrationService,
    required this.courseService,
    required ImageService imageService,
  }) : super(courseService, imageService: imageService) {
    // Register the lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Add listeners with debounce protection
    _setupServiceListeners();
  }

  // Set up service listeners with safeguards
  void _setupServiceListeners() {
    _completedLessonService.addListener(() {
      // Only update UI, don't trigger full data reload
      if (!_refreshInProgress && _initialized) {
        debugPrint('Progress data changed - updating UI only');
        notifyListeners();
      }
    });

    registrationService.addListener(() {
      // Only trigger reload if not already refreshing and initialized
      if (!_refreshInProgress && _initialized) {
        debugPrint('Registration data changed - scheduling refresh');
        _scheduleDelayedRefresh();
      }
    });
  }

  // Schedule a delayed refresh with debounce logic
  void _scheduleDelayedRefresh() {
    final now = DateTime.now();
    if (_lastRefreshTime == null ||
        now.difference(_lastRefreshTime!).inSeconds > refreshCooldownSeconds) {
      _lastRefreshTime = now;
      // Use Future.delayed to avoid immediate refresh
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_refreshInProgress) {
          fetchCourses();
        }
      });
    } else {
      debugPrint('Skipping refresh - cooldown period active');
    }
  }

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

  // Main initialization method - called once from onViewModelReady
  Future<void> initialise({bool forceRefresh = false}) async {
    // Skip initialization only if already initialized AND not forcing refresh
    if (_initialized && !forceRefresh && _refreshInProgress) {
      debugPrint('Skipping initialize - already initialized or in progress');
      return;
    }

    debugPrint(
        '⭐ LearnerCoursesViewModel: Initializing and loading courses...');
    _refreshInProgress = true;
    setBusy(true);

    try {
      debugPrint('Initializing courses view model');
      // Always force refresh on first load to ensure data is fresh
      await loadCourses(forceRefresh: true);
      _initialized = true;
      debugPrint('✅ Courses initialized successfully');
    } catch (e) {
      setError(e);
      debugPrint('❌ Error initializing courses: $e');
    } finally {
      _refreshInProgress = false;
      setBusy(false);
    }
  }

  @override
  Future<List<CourseModel>> loadCourses(
      {int page = 1, int pageSize = 10, bool forceRefresh = false}) async {
    // Skip if refresh already in progress and not forcing
    if (_refreshInProgress && !forceRefresh) {
      debugPrint('Skipping loadCourses - refresh already in progress');
      return _filteredCourses;
    }

    debugPrint('⭐ Loading courses with forceRefresh=$forceRefresh');
    _refreshInProgress = true;
    setBusy(true);

    try {
      debugPrint('Fetching user registrations...');
      // Clear existing courses before loading new data
      _allCourses = [];
      _filteredCourses = [];

      final registrations = await registrationService.getUserRegistrations();

      if (registrations.isEmpty) {
        debugPrint('No registrations found');
        updateCourses([]);
        return [];
      }

      final loadedCourses =
          await registrationService.getRegisteredCourses(registrations);
      debugPrint('✅ Loaded ${loadedCourses.length} courses');

      // Ensure progress data is properly processed
      for (var course in loadedCourses) {
        // Log the course data to help debug
        debugPrint('Course ${course.id} - ${course.title}');
        if (course.registration?.progress != null) {
          debugPrint(
              'Progress data: ${course.registration?.progress?.percentage}%');
        }

        // Force recalculation of progress
        final progress = computeProgress(course);
        debugPrint('Calculated progress: $progress');
      }

      // Update courses but avoid multiple notifications
      updateCourses(loadedCourses);
      return loadedCourses;
    } catch (e) {
      debugPrint('❌ Error loading courses: $e');
      setError(e);
      snackbarService.showSnackbar(message: 'Failed to load courses: $e');
      updateCourses([]);
      return [];
    } finally {
      _refreshInProgress = false;
      setBusy(false);
      _lastRefreshTime = DateTime.now();
    }
  }

  // Simplified fetch method - used for manual refreshes
  Future<void> fetchCourses() async {
    // Add forceRefresh parameter to ensure data is refreshed
    await loadCourses(forceRefresh: true);
  }

  // Handle navigation results safely
  void handleNavigationResult(dynamic result) {
    if (result is Map &&
        result.containsKey('refreshCourses') &&
        result['refreshCourses'] == true) {
      debugPrint('Received refresh signal from navigation');
      _scheduleDelayedRefresh();
    }
  }

  @override
  void updateCourses(List<CourseModel> newCourses) {
    debugPrint('Updating courses with ${newCourses.length} items');
    _allCourses = newCourses;
    _filteredCourses = newCourses;
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

    return false;
  }

  // Fixed progress calculation method
  double computeProgress(CourseModel course) {
    // Debug logging
    debugPrint('Computing progress for course ${course.id}');

    // Early return if no registration exists
    if (course.registration == null) {
      debugPrint('No registration found - progress: 0.0');
      return 0.0;
    }

    // First try to use the progress field if available
    if (course.registration?.progress != null) {
      final percentage = course.registration!.progress!.percentage;
      debugPrint(
          'Progress percentage raw value: $percentage (Type: ${percentage.runtimeType})');

      // Additional logging
      debugPrint('Progress object: ${course.registration!.progress?.toJson()}');

      // Ensure percentage is handled as a numeric value
      if (percentage is num || percentage is String) {
        // Convert to double regardless of original type
        double numericPercentage;
        if (percentage is String) {
          numericPercentage = double.tryParse(percentage.toString()) ?? 0.0;
        } else {
          numericPercentage = percentage.toDouble();
        }

        // Make sure percentage is a valid value between 0-100
        if (numericPercentage >= 0 && numericPercentage <= 100) {
          return numericPercentage / 100.0;
        } else {
          debugPrint(
              'Invalid percentage value: $numericPercentage - normalizing');
          // Normalize out-of-range values
          return numericPercentage <= 0 ? 0.0 : 1.0;
        }
      }
    }

    // Try to calculate from completed lessons vs total lessons
    if (course.registration?.completedLessonsList != null ||
        course.registration?.completedLessons != null) {
      // Get completed lessons count - note: completedLessonsList is a List but completedLessons might be a different type
      int completedCount = 0;

      if (course.registration?.completedLessonsList != null) {
        completedCount = course.registration!.completedLessonsList!.length;
      } else if (course.registration?.completedLessons != null) {
        // If this is not a List type, try to get the count another way
        // For example, if it's actually a CompletedLessons class with a count property
        completedCount = course.registration!.progress?.completedCount ?? 0;
      }

      // Get total lessons count - try multiple sources
      int totalLessons = 0;

      if (course.registration?.progress?.totalLessons != null &&
          course.registration!.progress!.totalLessons > 0) {
        totalLessons = course.registration!.progress!.totalLessons;
      } else if (course.registration?.lessons != null &&
          course.registration!.lessons!.isNotEmpty) {
        totalLessons = course.registration!.lessons!.length;
      } else if (course.lessonCount != null && course.lessonCount! > 0) {
        totalLessons = course.lessonCount!;
      } else if (course.lessons > 0) {
        totalLessons = course.lessons;
      }

      debugPrint(
          'Completed lessons: $completedCount, Total lessons: $totalLessons');

      if (totalLessons > 0) {
        final progress = completedCount / totalLessons.toDouble();
        debugPrint('Calculated progress: $progress');
        return progress.clamp(0.0, 1.0); // Ensure the value is between 0 and 1
      }
    }

    // Last resort - try to use the progress object directly
    if (course.registration?.progress != null) {
      final completed = course.registration!.progress!.completedCount;
      final total = course.registration!.progress!.totalLessons;

      debugPrint(
          'Using progress object - Completed: $completed, Total: $total');

      if (total > 0) {
        final progress = completed / total.toDouble();
        debugPrint('Calculated progress: $progress');
        return progress.clamp(0.0, 1.0);
      }
    }

    debugPrint('All calculation methods failed - returning 0.0');
    return 0.0;
  }

  // Get course tags
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

  // Safe refresh method that won't trigger loops
  Future<void> refreshFromCourseDetails() async {
    // Skip if already refreshing
    if (_refreshInProgress) {
      debugPrint(
          'Skipping refreshFromCourseDetails - refresh already in progress');
      return;
    }

    _refreshInProgress = true;

    try {
      debugPrint('Refreshing from course details');
      await _completedLessonService.resetAndRefreshAllCompletionData();
      await loadCourses();
    } catch (e) {
      debugPrint('Error refreshing from course details: $e');
    } finally {
      _refreshInProgress = false;
      _lastRefreshTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    // Clean up observers and listeners
    WidgetsBinding.instance.removeObserver(this);
    _completedLessonService.removeListener(_onCompletionDataChanged);
    registrationService.removeListener(_onRegistrationDataChanged);
    super.dispose();
  }

  // Legacy methods kept for compatibility
  void _onCompletionDataChanged() {
    // Empty implementation - main listener is now set up differently
  }

  void _onRegistrationDataChanged() {
    // Empty implementation - main listener is now set up differently
  }
}
