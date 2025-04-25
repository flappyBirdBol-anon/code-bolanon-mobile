import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/course_service.dart'; // Import CourseService
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/ui/common/base/course_base_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class LearnerCoursesViewModel extends CourseBaseViewModel {
  @override
  AppointmentService get appointmentService => locator<AppointmentService>();
  final RegistrationService registrationService; // Keep RegistrationService
  final CourseService courseService; // Add CourseService

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
    _init();
  }

  void _init() {
    print('LearnerCoursesViewModel - init started');
    _searchQuery = ''; // Reset search query
    _activeFilters = {'All'}; // Reset filters
    loadCourses();
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
      final registrations = await registrationService.getUserRegistrations();
      print('Loaded registrations count: ${registrations.length}');

      if (registrations.isEmpty) {
        print('No registrations found');
        updateCourses([]);
        return [];
      }

      final loadedCourses =
          await registrationService.getRegisteredCourses(registrations);
      print('Loaded courses count: ${loadedCourses.length}');

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
    if (course.registration?.completedLessons == null || course.lessons == 0) {
      return 0.0;
    }
    return course.registration!.completedLessons!.isCompleted
        ? 1.0
        : (course.registration!.completedLessons!.lessonId / course.lessons);
  }

  void navigateToWishlist() {
    navigationService.navigateToLearnerWishlistsView();
  }
}
