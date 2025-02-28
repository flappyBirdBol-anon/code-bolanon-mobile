// lib/views/course_details/course_details_viewmodel.dart
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/ui/views/add_lesson/add_lesson_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class Lesson {
  final String title;
  final String duration;
  final String? description;

  Lesson({required this.title, required this.duration, this.description});
}

class CourseDetailsViewModel extends BaseViewModel {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;
  final _userService = locator<UserService>();
  final _imageService = locator<ImageService>(); // Add ImageService

  String get profilePictureUrl => _userService.currentUser?.profileImage ?? '';
  String get userName => _userService.currentUser?.fullName ?? 'User';
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  final _navigationService = locator<NavigationService>();

  // Reference to the course
  Course? _course;
  Course? get course => _course;

  // Initialize with a course
  Future<void> initialize(Course? course) async {
    _course = course;

    if (_course != null && _course!.thumbnail != null) {
      // Prefetch the course image to ensure it's cached
      final imageUrl =
          _imageService.getCourseThumbnailFromPath(_course!.thumbnail!);
      await _imageService.prefetchImage(imageUrl, courseId: _course!.id);
    }

    // Load additional course details if needed
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    _isLoading = false;
    notifyListeners();
  }

  // Get a widget to display the course image
  Widget getCourseImageWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (_course == null || _course!.thumbnail == null) {
      return errorWidget ?? _buildDefaultErrorWidget(width, height);
    }

    // Handle local assets differently
    if (_course!.thumbnail!.startsWith('assets/')) {
      return Image.asset(
        _course!.thumbnail!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultErrorWidget(width, height);
        },
      );
    }

    // Use ImageService for remote images
    final imageUrl =
        _imageService.getCourseThumbnailFromPath(_course!.thumbnail!);

    return _imageService.loadImage(
      imageUrl: imageUrl,
      courseId: _course!.id,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? _buildDefaultPlaceholder(width, height),
      errorWidget: errorWidget ?? _buildDefaultErrorWidget(width, height),
    );
  }

  Widget _buildDefaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDefaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
    );
  }

  final List<Lesson> _lessons = [
    Lesson(
        title: 'What Is UX Design?',
        duration: '12 min',
        description:
            'Learn the fundamentals of UX Design and its importance in modern applications.'),
    Lesson(
        title: 'Why We Use UX Design?',
        duration: '8 min',
        description:
            'Explore the key reasons why UX Design is crucial for successful products.'),
    Lesson(
        title: 'UX And Our Design?',
        duration: '4:00 min',
        description:
            'Understand how UX principles apply to our specific design challenges.'),
    Lesson(
        title: 'Introduction To Figma',
        duration: '3:00 min',
        description:
            'Get started with Figma, the industry-standard design tool.'),
  ];

  List<Lesson> get lessons => _lessons;

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void addNewLesson(BuildContext context) {
    // Show dialog to add new lesson
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Lesson'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Lesson Title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Duration (in minutes)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add lesson logic here
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void navigateToAddLesson() {
    // Using Stacked Services
    _navigationService.navigateTo(Routes.addLessonView);
  }
}
