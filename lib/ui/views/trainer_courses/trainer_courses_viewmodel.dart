// lib/viewmodels/trainer_courses_viewmodel.dart
import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/ui/common/widgets/course_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';

class TrainerCoursesViewModel extends BaseViewModel {
  final _imagePicker = ImagePicker();

  List<Course> _courses = [];
  String _selectedFilter = 'All';
  XFile? _selectedImage;

  List<Course> get courses => _filterCourses();
  String get selectedFilter => _selectedFilter;

  void init() {
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
    notifyListeners();
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

  Future<void> addNewCourse({
    required String title,
    required String description,
    required double price,
    XFile? image,
  }) async {
    final newCourse = Course(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      thumbnail:
          image?.path ?? 'assets/images/default.jpg', // Add a default image
      isActive: true,
      studentsEnrolled: 0,
      rating: 0,
      price: price.toInt(),
    );

    _courses.add(newCourse);
    notifyListeners();
  }

  Future<void> editCourse(
    String courseId, {
    String? title,
    String? description,
    double? price,
    XFile? newImage,
  }) async {
    final courseIndex = _courses.indexWhere((course) => course.id == courseId);
    if (courseIndex == -1) return;

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
    notifyListeners();
  }

  void toggleCourseStatus(String courseId) {
    final courseIndex = _courses.indexWhere((course) => course.id == courseId);
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
    notifyListeners();
  }

  void showAddCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CourseDialog(
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
}
