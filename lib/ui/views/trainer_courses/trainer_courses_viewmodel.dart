import 'dart:async';

import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';

import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/ui/common/base/course_base_view_model.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:code_bolanon/ui/views/trainer_courses/add_course.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:code_bolanon/ui/common/widgets/course_dialog.dart';
import 'package:stacked_services/stacked_services.dart';

class TrainerCoursesViewModel extends CourseBaseViewModel {
  final CourseService courseService;
  XFile? _selectedImage;

  // Added controllers and variables for scroll behavior
  final ScrollController scrollController = ScrollController();
  bool _showStats = true;
  bool get showStats => _showStats;

  // Timer for throttling scroll updates
  Timer? _scrollThrottleTimer;
  double _lastScrollPosition = 0;

  // Timer for auto-hiding header
  Timer? _headerHideTimer;
  bool _showHeader = true;
  bool get showHeader => _showHeader;

  @override
  List<String> get availableFilters => ['All', 'Active', 'Inactive'];

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

  TrainerCoursesViewModel({
    required CourseService courseService,
    required ImageService imageService,
  })  : courseService = courseService,
        super(courseService, imageService: imageService);

  @override
  Future<void> init() async {
    await super.init();
    // Start timer to hide header after 3 seconds
    _startHeaderHideTimer();

    // Setup scroll listener with throttling
    scrollController.addListener(_throttledScrollListener);
  }

  void _startHeaderHideTimer() {
    _headerHideTimer?.cancel();
    _headerHideTimer = Timer(const Duration(seconds: 3), () {
      _showHeader = false;
      notifyListeners();
    });
  }

  // Throttled scroll listener to prevent excessive UI updates
  void _throttledScrollListener() {
    final currentPosition = scrollController.offset;

    // Only update if we've scrolled more than 15 pixels since last update
    // This reduces the number of UI updates while scrolling
    if ((_lastScrollPosition - currentPosition).abs() < 15) {
      return;
    }

    _lastScrollPosition = currentPosition;

    // Cancel any pending timer
    _scrollThrottleTimer?.cancel();

    // Set a throttle timer to limit UI updates
    _scrollThrottleTimer = Timer(const Duration(milliseconds: 100), () {
      updateStatsVisibility(currentPosition);
    });
  }

  // Update stats visibility based on scroll position
  void updateStatsVisibility(double scrollPosition) {
    final shouldShow = scrollPosition < 200;
    if (shouldShow != _showStats) {
      _showStats = shouldShow;
      notifyListeners();
    }
  }

  // New stat method for Total Learners Enrolled
  int getTotalLearnersEnrolled() {
    // Sum all enrolled learners across all courses
    return courses.fold<int>(
        0, (previousValue, course) => previousValue + (10));
    //  (previousValue, course) => previousValue + (course.enrolledCount ?? 0));
  }

  // New stat method for Lessons Created
  int getTotalLessonsCreated() {
    // Sum all lessons across all courses
    return courses.fold<int>(
        0, (previousValue, course) => previousValue + (11));
    //  (previousValue, course) => previousValue + (course.lessonsCount ?? 0));
  }

  @override
  void dispose() {
    _headerHideTimer?.cancel();
    _scrollThrottleTimer?.cancel();
    scrollController.removeListener(_throttledScrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Future<List<CourseModel>> loadCourses(
      {int page = 1, int pageSize = 10}) async {
    return await courseService.getCourses(
      page: page,
      pageSize: pageSize,
      filters: activeFilters.toList(),
    );
  }

  @override
  bool filterCourse(CourseModel course) {
    if (activeFilters.isEmpty || activeFilters.contains('All')) return true;
    if (activeFilters.contains('Active') && course.isActive) return true;
    if (activeFilters.contains('Inactive') && !course.isActive) return true;
    return false;
  }

  void navigateToAddCourse(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseCreationView(
          onSave: (title, description, price, image) async {
            _selectedImage = image;
            await _addCourse(title, description, price);
            return true; // Indicate success
          },
        ),
      ),
    );

    if (result == true) {
      await refreshItems();
    }
  }

  Future<void> _addCourse(
      String title, String description, double price) async {
    try {
      await courseService.addCourse(
        title: title,
        description: description,
        price: price,
        image: _selectedImage,
      );
      _showSuccessMessage('Course added successfully');
      await refreshItems();
    } catch (e) {
      _showErrorMessage('Failed to add course: ${e.toString()}');
    }
  }

  void navigateToEditCourse(BuildContext context, CourseModel course) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseCreationView(
          isEditing: true,
          initialCourseName: course.title,
          initialDescription: course.description,
          initialPrice: course.price,
          onSave: (title, description, price, image) async {
            _selectedImage = image;
            await _updateCourse(course.id, title, description, price);
            return true; // Indicate success
          },
        ),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      await refreshItems();
    }
  }

  Future<void> _updateCourse(
    String courseId,
    String title,
    String description,
    double price,
  ) async {
    try {
      await courseService.updateCourse(
        courseId: courseId,
        title: title,
        description: description,
        price: price.toInt(),
        image: _selectedImage,
      );
      _showSuccessMessage('Course updated successfully');
      await refreshItems();
    } catch (e) {
      _showErrorMessage('Failed to update course: ${e.toString()}');
    }
  }

  Future<void> toggleCourseStatus(CourseModel course) async {
    try {
      await courseService.updateCourseStatus(
        courseId: course.id,
        isActive: !course.isActive,
      );
      _showSuccessMessage(
        'Course ${course.isActive ? 'inactive' : 'activate'} successfully',
      );
      await refreshItems();
    } catch (e) {
      _showErrorMessage('Failed to update course status: ${e.toString()}');
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

  @override
  AuthService get authService => locator<AuthService>();

  @override
  NavigationService get navigationService => locator<NavigationService>();

  @override
  SnackbarService get snackbarService => locator<SnackbarService>();

  @override
  UserService get userService => locator<UserService>();
}
