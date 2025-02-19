import 'package:code_bolanon/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class TrainerHomeViewModel extends BaseViewModel {
  bool isLoading = true;
  String profileImageUrl = 'assets/images/1.jpg';
  int activeStudents = 150;
  int totalCourses = 12;
  double totalRevenue = 15000;

  TrainerHomeViewModel() {
    _init();
  }

  List<RecentActivity> recentActivities = [
    RecentActivity(
      title: 'New student enrolled in UX Design',
      timestamp: '2 hours ago',
      icon: Icons.person_add,
    ),
    RecentActivity(
      title: 'Course review received',
      timestamp: '5 hours ago',
      icon: Icons.star,
    ),
    RecentActivity(
      title: 'New message from student',
      timestamp: '1 day ago',
      icon: Icons.message,
    ),
  ];

  List<String> topics = [
    'Development',
    'Design',
    'Tech',
    'Marketing',
    'Business',
    'Sports',
    'IT Software',
  ];

  List<CourseModel> featureCourses = [
    CourseModel(
      id: '1',
      title: 'User Experience Design Crash...',
      imageUrl: 'assets/images/1.jpg',
      price: 1500,
      rating: 4.9,
      reviews: 1724,
    ),
    CourseModel(
      id: '2',
      title: 'lorem lore lorem lorem lor...',
      imageUrl: 'assets/images/2.jpg',
      price: 2000,
      rating: 4.1,
      reviews: 3432,
    ),
    CourseModel(
      id: '2',
      title: 'Ipsum ipsum ipsum ips...',
      imageUrl: 'assets/images/3.jpg',
      price: 1200,
      rating: 4.3,
      reviews: 1100,
    ),
    // Add more courses here
  ];

  String userName = 'John Nicolas';
  Future<void> refreshData() async {
    setLoading(true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setLoading(false);
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _init() {
    Future.delayed(const Duration(seconds: 3), () {
      setLoading(false);
    });
  }
}

class RecentActivity {
  final String title;
  final String timestamp;
  final IconData icon;

  RecentActivity({
    required this.title,
    required this.timestamp,
    required this.icon,
  });
}
