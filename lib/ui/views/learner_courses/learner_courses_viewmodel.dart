import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';

import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/ui/common/base/course_base_view_model.dart';
import 'package:stacked_services/stacked_services.dart';

class LearnerCoursesViewModel extends CourseBaseViewModel {
  final CourseService courseService;

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

  LearnerCoursesViewModel({
    required CourseService courseService,
    required ImageService imageService,
  })  : courseService = courseService,
        super(courseService, imageService: imageService);

  @override
  Future<List<CourseModel>> loadCourses(
      {int page = 1, int pageSize = 10}) async {
    final registrations = await courseService.getUserRegistrations();
    return await courseService.getRegisteredCourses(registrations);
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
        : (course.registration!.completedLessons!.lessonId) / course.lessons;
  }

  void navigateToWishlist() {
    navigationService.navigateToLearnerWishlistsView();
  }
}
