import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';

import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/ui/common/base/course_base_view_model.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:code_bolanon/ui/common/widgets/course_dialog.dart';
import 'package:stacked_services/stacked_services.dart';

class TrainerCoursesViewModel extends CourseBaseViewModel {
  final CourseService courseService;
  XFile? _selectedImage;

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
        super(courseService, imageService: imageService) {
    init();
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

  void showAddCourseDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CourseDialog(
        title: 'Add New Course',
        onSave: (title, description, price, image) async {
          _selectedImage = image;
          await _addCourse(title, description, price);
        },
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

  void showEditCourseDialog(BuildContext context, CourseModel course) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CourseDialog(
        title: 'Edit Course',
        initialCourseName: course.title,
        initialDescription: course.description,
        initialPrice: course.price,
        onSave: (title, description, price, image) async {
          _selectedImage = image;
          await _updateCourse(course.id, title, description, price);
        },
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
