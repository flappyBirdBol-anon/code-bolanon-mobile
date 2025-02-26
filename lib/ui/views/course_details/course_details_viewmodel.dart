// lib/views/course_details/course_details_viewmodel.dart
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/services/auth_service.dart';
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
  final _authService = locator<AuthService>();
  String get profilePictureUrl => _authService.currentUser?.profileImage ?? '';
  String get userName => _authService.currentUser?.fullName ?? 'User';
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  final _navigationService = locator<NavigationService>();

  Future<void> initialize() async {
    // Load additional course details if needed
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    _isLoading = false;
    notifyListeners();
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
              decoration: const InputDecoration(
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

    // Or using regular navigation
    // Navigator.push(
    //   _navigationService.navigatorKey.currentContext!,
    //   MaterialPageRoute(builder: (context) => const AddLessonView()),
    // );
  }
}
