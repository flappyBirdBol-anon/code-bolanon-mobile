// lib/viewmodels/trainer_courses_viewmodel.dart
import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/helpers/dialog_helper.dart';
import 'package:code_bolanon/ui/common/widgets/course_dialog.dart';
import 'package:code_bolanon/ui/views/course_details/course_details_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class TrainerCoursesViewModel extends BaseViewModel {
  final _imagePicker = ImagePicker();
  final _navigationService = NavigationService();

  // Add service dependencies
  final CourseService _courseService;
  final ImageService _imageService;

  List<Course> _courses = [];
  String _selectedFilter = 'All';
  XFile? _selectedImage;
  final bool _isBusy = false;

  List<Course> get courses => _filterCourses();
  String get selectedFilter => _selectedFilter;
  @override
  bool get isBusy => _isBusy;
  ImageService get imageService => _imageService; // Expose image service for UI

  // Constructor with dependency injection
  TrainerCoursesViewModel({
    required CourseService courseService,
    required ImageService imageService,
  })  : _courseService = courseService,
        _imageService = imageService;

  Future<void> init() async {
    setBusy(true);
    try {
      // Fetch courses from API using CourseService
      _courses = await _courseService.getCourses();

      // The CourseService already triggers image prefetching in the background
      // through the ImageService.prefetchCourseImages method
    } catch (e) {
      _showErrorMessage('Failed to load courses: ${e.toString()}');

      // Fallback to sample data if API fails
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
    } finally {
      setBusy(false);
    }
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

  // Get a widget to display a course image
  Widget getCourseImageWidget({
    required Course course,
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

    // If it's a remote image, use the ImageService
    if (course.thumbnail.isNotEmpty) {
      final imageUrl =
          _imageService.getCourseThumbnailFromPath(course.thumbnail);

      return _imageService.loadImage(
        imageUrl: imageUrl,
        courseId: course.id,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }

    // If no image path, return error widget
    return errorWidget ?? _buildDefaultErrorWidget(width, height);
  }

  Widget _buildDefaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
    );
  }

  // Enhanced course creation with proper busy state management and image caching
  Future<void> addNewCourse({
    required String title,
    required String description,
    required double price,
    XFile? image,
  }) async {
    try {
      setBusy(true);

      // Use CourseService to add the course
      final newCourse = await _courseService.addCourse(
        title: title,
        description: description,
        price: price.toInt(),
        image: image,
      );

      // Add to local list
      _courses.add(newCourse);

      // Clear selected image
      _selectedImage = null;

      // Show success message
      _showSuccessMessage('Course created successfully');
    } catch (e) {
      _showErrorMessage('Failed to create course: ${e.toString()}');

      // Fallback to local creation if API fails
      if (_courses.isNotEmpty) {
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
      }
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

      // Use CourseService to update the course
      final updatedCourse = await _courseService.updateCourse(
        courseId: courseId,
        title: title,
        description: description,
        price: price?.toInt(),
        image: newImage,
      );

      // Update local list
      final courseIndex =
          _courses.indexWhere((course) => course.id == courseId);
      if (courseIndex != -1) {
        _courses[courseIndex] = updatedCourse;
      }

      // Clear selected image
      _selectedImage = null;

      _showSuccessMessage('Course updated successfully');
    } catch (e) {
      _showErrorMessage('Failed to update course: ${e.toString()}');

      // Fallback to local update if API fails
      final courseIndex =
          _courses.indexWhere((course) => course.id == courseId);
      if (courseIndex != -1) {
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
      }
    } finally {
      setBusy(false);
    }
  }

  Future<void> toggleCourseStatus(String courseId) async {
    try {
      final courseIndex =
          _courses.indexWhere((course) => course.id == courseId);
      if (courseIndex == -1) return;

      setBusy(true);

      // In a real app, you would call an API here
      // await _courseService.toggleCourseStatus(courseId);

      // For now, just update locally
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
      _showSuccessMessage('Course $statusText successfully');
    } catch (e) {
      _showErrorMessage('Failed to update course status: ${e.toString()}');
    } finally {
      setBusy(false);
      notifyListeners();
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
