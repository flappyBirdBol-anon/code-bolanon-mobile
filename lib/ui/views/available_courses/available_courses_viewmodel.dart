import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';

import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/ui/common/base/course_base_view_model.dart';
import 'package:stacked_services/stacked_services.dart';

class AvailableCoursesViewModel extends CourseBaseViewModel {
  final CourseService courseService;

  @override
  List<String> get availableFilters => [
        'All',
        'Free',
        'Premium',
        ...allTags,
        'Most Popular',
        'Highest Rated',
      ];

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

  AvailableCoursesViewModel({
    required CourseService courseService,
    required ImageService imageService,
  })  : courseService = courseService,
        super(courseService, imageService: imageService);

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
    if (activeFilters.contains('All')) return true;

    // Handle tag filters first
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

    // Handle rating and popularity filters
    if (activeFilters.contains('Most Popular') && course.reviews > 100)
      return true;
    if (activeFilters.contains('Highest Rated') && course.rating >= 4.5)
      return true;

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

  void navigateToMyCourses() {
    navigationService.navigateToLearnerCoursesView();
  }
}
