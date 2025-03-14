import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/course_model.dart';
// import 'package:code_bolanon/models/course_param.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/tag_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/ui/common/base/filterable_view_model.dart';
import 'package:code_bolanon/ui/common/widgets/tag_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

abstract class CourseBaseViewModel extends BaseViewModel
    implements AppBaseViewModel, FilterableViewModel {
  final CourseService _courseService;
  final ImageService imageService;
  final TagService _tagService = locator<TagService>();

  List<CourseModel> _courses = [];
  List<CourseModel> get courses => _courses;

  void updateCourses(List<CourseModel> newCourses) {
    _courses = newCourses;
    notifyListeners();
  }

  List<CourseModel> _filteredCourses = [];

  List<String> get allTags => _tagService.getAllTags();

  String _searchQuery = '';
  @override
  String get searchQuery => _searchQuery;
  set searchQuery(String value) => _searchQuery = value;

  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _hasMoreItems = true;
  bool get hasMoreItems => _hasMoreItems;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  final Set<String> _activeFilters = {'All'};
  @override
  Set<String> get activeFilters => _activeFilters;

  CourseBaseViewModel(this._courseService, {required this.imageService});

  Future<void> init() async {
    await refreshItems();
  }

  Future<void> refreshItems() async {
    _currentPage = 1;
    _hasMoreItems = true;
    await runBusyFuture(loadInitialItems());
  }

  Future<void> loadInitialItems() async {
    try {
      final items = await _courseService.getCourses(
        page: 1,
        pageSize: _pageSize,
        filters: activeFilters.toList(),
      );

      _hasMoreItems = items.length >= _pageSize;
      await handleInitialItems(items);
    } catch (e) {
      setError(e);
    }
  }

  Future<void> loadMoreItems() async {
    if (!_hasMoreItems || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final items = await _courseService.getCourses(
        page: _currentPage,
        pageSize: _pageSize,
        filters: activeFilters.toList(),
      );

      _hasMoreItems = items.length >= _pageSize;
      await handleMoreItems(items);
    } catch (e) {
      setError(e);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> showTagSelectionDialog(CourseModel course) async {
    final context = navigationService.navigatorKey?.currentContext;
    if (context == null) return;

    final currentTags = _tagService.getCourseTags(course.id);
    final selectedTags = await showDialog<List<String>>(
      context: context,
      builder: (context) => TagSelectionDialog(
        availableTags: allTags,
        selectedTags: currentTags,
      ),
    );

    if (selectedTags != null) {
      _tagService.addTagsToCourse(course.id, selectedTags);
      notifyListeners();
    }
  }

  // Template method to be implemented by subclasses
  Future<List<CourseModel>> loadCourses({int page = 1, int pageSize = 10});

  void navigateToCourseDetails(CourseModel course) {
    navigationService.navigateToCourseDetailsView(
      course: course,
    );
    // navigationService.navigateToPaymentView(
    //   course: CourseParam(
    //     id: "7",
    //     title: "Firebase ",
    //     description:
    //         "Connect your Flutter app to Firebase for authentication, database, and cloud functions.",
    //     price: 100,
    //     taxRate: 0.06,
    //     discountPercentage: 0.20,
    //   ),
    // );
  }

  // Get tags for a specific course
  List<String> getCourseTags(String courseId) =>
      _tagService.getCourseTags(courseId);

  // Check if course has specific tag
  bool courseHasTag(String courseId, String tag) =>
      _tagService.courseHasTag(courseId, tag);

  @override
  void applyFilters() {
    if (activeFilters.isEmpty) {
      _filteredCourses = _courses;
    } else {
      _filteredCourses =
          _courses.where((course) => filterCourse(course)).toList();
    }

    if (searchQuery.isNotEmpty) {
      _filteredCourses = _filteredCourses
          .where((course) =>
              course.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              course.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              getCourseTags(course.id).any((tag) =>
                  tag.toLowerCase().contains(searchQuery.toLowerCase())))
          .toList();
    }

    notifyListeners();
  }

  @override
  void onSearchChanged(String value) {
    searchQuery = value;
    if (searchQuery.isEmpty) {
      _filteredCourses = _courses;
    } else {
      _filteredCourses = _courses
          .where((course) =>
              course.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              course.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              getCourseTags(course.id).any((tag) =>
                  tag.toLowerCase().contains(searchQuery.toLowerCase())))
          .toList();
    }
    notifyListeners();
  }

  // Template method to be implemented by subclasses
  bool filterCourse(CourseModel course);

  Future<void> handleInitialItems(List<CourseModel> items) async {
    _courses = items;
    applyFilters();
  }

  Future<void> handleMoreItems(List<CourseModel> items) async {
    _courses.addAll(items);
    applyFilters();
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
