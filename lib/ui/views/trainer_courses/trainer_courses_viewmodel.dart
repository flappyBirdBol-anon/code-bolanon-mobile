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

  // Remove throttle timer and use frame callback instead
  bool _showHeader = true;
  bool get showHeader => _showHeader;

  // Track scroll direction for better UX
  double _lastScrollPosition = 0;
  bool _isScrollingDown = false;

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
    // Set initial header state to visible
    _showHeader = true;

    // Add optimized scroll listener
    scrollController.addListener(_handleScroll);
  }

  // Optimized scroll handler that runs directly in the scroll callback
  void _handleScroll() {
    final currentPosition = scrollController.offset;

    // Check scroll direction
    _isScrollingDown = currentPosition > _lastScrollPosition;

    // Update header visibility based on scroll position and direction
    if (currentPosition < 10) {
      // Always show header at the top
      if (!_showHeader) {
        _showHeader = true;
        notifyListeners();
      }
    } else if (_isScrollingDown && _showHeader && currentPosition > 50) {
      // Hide header when scrolling down past threshold
      _showHeader = false;
      notifyListeners();
    } else if (!_isScrollingDown && !_showHeader && currentPosition < 300) {
      // Show header when scrolling up (but not when deep in the content)
      _showHeader = true;
      notifyListeners();
    }

    // Update stats visibility with more granular control
    final shouldShowStats = currentPosition < 150;
    if (shouldShowStats != _showStats) {
      _showStats = shouldShowStats;
      notifyListeners();
    }

    _lastScrollPosition = currentPosition;
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
    scrollController.removeListener(_handleScroll);
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
          onSave: (title, description, price, image, learningExpectations,
              requirements, level, duration, techStackIds) async {
            _selectedImage = image;
            await _addCourse(title, description, price, learningExpectations,
                requirements, level, duration, techStackIds);
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
      String title,
      String description,
      double price,
      List<String> learningExpectations,
      List<String> requirements,
      String level,
      String duration,
      List<int> techStackIds) async {
    try {
      await courseService.addCourse(
        title: title,
        description: description,
        price: price,
        image: _selectedImage,
        learningExpectations: learningExpectations,
        requirements: requirements,
        level: level,
        duration: duration,
        techStackIds: techStackIds, // Pass tech stack IDs
      );
      _showSuccessMessage('Course added successfully');
      await refreshItems();
    } catch (e) {
      _showErrorMessage('Failed to add course: ${e.toString()}');
    }
  }

  void navigateToEditCourse(BuildContext context, CourseModel course) async {
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

    if (result == true) {
      await refreshItems();
    }
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
