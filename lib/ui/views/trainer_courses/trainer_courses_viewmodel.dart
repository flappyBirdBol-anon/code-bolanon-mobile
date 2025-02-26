// lib/viewmodels/trainer_courses_viewmodel.dart
import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/ui/common/helpers/dialog_helper.dart';
import 'package:code_bolanon/ui/common/widgets/course_dialog.dart';

import 'package:code_bolanon/ui/views/course_details/course_details_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart'; // For navigation service

class TrainerCoursesViewModel extends BaseViewModel {
  final _imagePicker = ImagePicker();
  final _navigationService =
      NavigationService(); // Add this if using stacked navigation

  List<Course> _courses = [];
  String _selectedFilter = 'All';
  XFile? _selectedImage;
  bool _isBusy = false;

  List<Course> get courses => _filterCourses();
  String get selectedFilter => _selectedFilter;
  bool get isBusy => _isBusy;

  void init() {
    setBusy(true);
    // Simulate fetching courses from API
    _courses = [
      Course(
        id: '1',
        title: 'Web Development Fundamentals',
        description:
            'Learn the basics of web development with HTML, CSS, and JavaScript',
        thumbnail: 'assets/images/1.jpg',
        isActive: true,
        studentsEnrolled: 45,
        price: 10,
        rating: 4.5,
      ),
      Course(
        id: '2',
        title: 'Flutter Development Fundamentals',
        description:
            'Learn flutter development with Dart, and build beautiful apps',
        thumbnail: 'assets/images/2.jpg',
        isActive: true,
        studentsEnrolled: 56,
        price: 20,
        rating: 4.8,
      ),
      Course(
        id: '3',
        title: 'Python Development Fundamentals',
        description:
            'Learn python development with Django, and build beautiful apps',
        thumbnail: 'assets/images/3.jpg',
        isActive: true,
        studentsEnrolled: 45,
        price: 60,
        rating: 4.2,
      ),
    ];
    setBusy(false);
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<Course> _filterCourses() {
    if (_selectedFilter == 'All') return _courses;
    if (_selectedFilter == 'Active') {
      return _courses.where((course) => course.isActive).toList();
    }
    if (_selectedFilter == 'Inactive') {
      return _courses.where((course) => !course.isActive).toList();
    }
    if (_selectedFilter == 'Archived') {
      return _courses.where((course) => !course.isActive).toList();
    }
    return _courses;
  }

  Future<void> pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      _selectedImage = image;
      notifyListeners();
    }
  }

  // Enhanced course creation with proper busy state management
  Future<void> addNewCourse({
    required String title,
    required String description,
    required double price,
    XFile? image,
  }) async {
    try {
      setBusy(true);

      // Simulate API call to save course with delay
      await Future.delayed(const Duration(milliseconds: 500));

      final newCourse = Course(
        id: DateTime.now().toString(),
        title: title,
        description: description,
        thumbnail: image?.path ?? 'assets/images/default.jpg',
        isActive: true,
        studentsEnrolled: 0,
        rating: 0,
        price: price.toInt(),
      );

      _courses.add(newCourse);

      // Show success message
      _showSuccessMessage('Course created successfully');
    } catch (e) {
      _showErrorMessage('Failed to create course: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }

  Future<void> editCourse(
    String courseId, {
    String? title,
    String? description,
    double? price,
    XFile? newImage,
  }) async {
    try {
      setBusy(true);

      // Simulate API call with delay
      await Future.delayed(const Duration(milliseconds: 500));

      final courseIndex =
          _courses.indexWhere((course) => course.id == courseId);
      if (courseIndex == -1) {
        throw Exception('Course not found');
      }

      final course = _courses[courseIndex];
      _courses[courseIndex] = Course(
        id: course.id,
        title: title ?? course.title,
        description: description ?? course.description,
        thumbnail: newImage?.path ?? course.thumbnail,
        isActive: course.isActive,
        studentsEnrolled: course.studentsEnrolled,
        rating: course.rating,
        price: (price ?? course.price).toInt(),
      );

      _showSuccessMessage('Course updated successfully');
    } catch (e) {
      _showErrorMessage('Failed to update course: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }

  void toggleCourseStatus(String courseId) {
    try {
      final courseIndex =
          _courses.indexWhere((course) => course.id == courseId);
      if (courseIndex == -1) return;

      final course = _courses[courseIndex];
      _courses[courseIndex] = Course(
        id: course.id,
        title: course.title,
        description: course.description,
        thumbnail: course.thumbnail,
        isActive: !course.isActive,
        studentsEnrolled: course.studentsEnrolled,
        rating: course.rating,
        price: course.price,
      );

      final statusText =
          _courses[courseIndex].isActive ? 'activated' : 'deactivated';
      _showSuccessMessage('Course ${statusText} successfully');
      notifyListeners();
    } catch (e) {
      _showErrorMessage('Failed to update course status: ${e.toString()}');
    }
  }

  // Option 1: Enhanced Dialog approach
  void showAddCourseDialog(BuildContext context) {
    showGlassmorphicDialog(
      context: context,
      blurAmount: 8.0,
      dialog: CourseDialog(
        title: 'Add New Course',
        onSave: (title, description, price, image) {
          addNewCourse(
            title: title,
            description: description,
            price: price,
            image: image,
          );
        },
      ),
    );
  }

  // Option 1: Edit course with enhanced dialog
  void showEditCourseDialog(BuildContext context, Course course) {
    showGlassmorphicDialog(
      context: context,
      blurAmount: 8.0,
      dialog: CourseDialog(
        title: 'Edit Course',
        initialCourseName: course.title,
        initialDescription: course.description,
        initialPrice: course.price.toDouble(),
        onSave: (title, description, price, image) {
          editCourse(
            course.id,
            title: title,
            description: description,
            price: price,
            newImage: image,
          );
        },
      ),
    );
  }

  // // Option 2: Full-page approach for adding course
  // void navigateToAddCourseView(BuildContext context) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => CourseCreationView(
  //         onSave: (title, description, price, image) {
  //           addNewCourse(
  //             title: title,
  //             description: description,
  //             price: price,
  //             image: image,
  //           );
  //         },
  //       ),
  //     ),
  //   );

  //   // Alternative using Stacked navigation service:
  //   // _navigationService.navigateToView(
  //   //   CourseCreationView(
  //   //     onSave: (title, description, price, image) {
  //   //       addNewCourse(
  //   //         title: title,
  //   //         description: description,
  //   //         price: price,
  //   //         image: image,
  //   //       );
  //   //     },
  //   //   ),
  //   // );
  // }

  // // Option 2: Full-page approach for editing course
  // void navigateToEditCourseView(BuildContext context, Course course) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => CourseCreationView(
  //         isEditing: true,
  //         initialCourseName: course.title,
  //         initialDescription: course.description,
  //         initialPrice: course.price.toDouble(),
  //         onSave: (title, description, price, image) {
  //           editCourse(
  //             course.id,
  //             title: title,
  //             description: description,
  //             price: price,
  //             newImage: image,
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  void navigateToCourseDetails(BuildContext context, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsView(course: course),
      ),
    );
  }

  // Helper methods for showing feedback to users
  void _showSuccessMessage(String message) {
    // If using snackbar service from stacked:
    // _snackbarService.showSnackbar(message: message, duration: const Duration(seconds: 2));

    // Otherwise, this can be handled at the UI level via a reactive property
    print(message); // For now, just print
  }

  void _showErrorMessage(String message) {
    // If using dialog service from stacked:
    // _dialogService.showDialog(
    //   title: 'Error',
    //   description: message,
    //   buttonTitle: 'OK',
    // );

    print('ERROR: $message'); // For now, just print
  }
}
