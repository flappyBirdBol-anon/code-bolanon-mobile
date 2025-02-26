import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class LearnerHomeViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  bool isLoading = true;

  // User Info
  String get userFullName => _authService.currentUser?.fullName ?? 'User';
  String get userEmail => _authService.currentUser?.email ?? '';
  String profileImageUrl = 'assets/images/profile.jpg';

  // Progress Tracking
  int completedCourses = 8;
  int inProgressCourses = 5;
  int totalEnrolledCourses = 15;
  double get completedCoursesPercentage =>
      completedCourses / totalEnrolledCourses;
  double get inProgressCoursesPercentage =>
      inProgressCourses / totalEnrolledCourses;

  // Top Users
  List<UserModel> topUsers = [
    UserModel('John Doe', 'assets/images/profile.jpg', 12),
    UserModel('Jane Smith', 'assets/images/profile.jpg', 10),
    UserModel('Bob Wilson', 'assets/images/profile.jpg', 8),
  ];

  // Tech Stack
  List<TechStackItem> techStack = [
    TechStackItem('Flutter', Colors.blue),
    TechStackItem('React', Colors.cyan),
    TechStackItem('Node.js', Colors.green),
    TechStackItem('Python', Colors.amber),
    TechStackItem('JavaScript', Colors.orange),
  ];

  // Add this after existing tech stack list
  List<CourseModel> getTechStackRecommendations() {
    // Example: Filter courses based on selected tech stack
    final selectedTech =
        techStack.first; // In real app, get actual selected tech
    return [
      CourseModel(
        title: 'Advanced ${selectedTech.name} Patterns',
        imageUrl: 'assets/images/1.jpg',
        price: 129.99,
        rating: 4.9,
        reviews: 1250,
        tags: [selectedTech.name, 'Advanced'],
        totalLessons: 24,
        enrolledStudents: 8420,
        instructorName: 'John Smith',
        difficulty: 'Advanced',
        duration: '8 weeks',
        description:
            'Master advanced patterns and architectures in ${selectedTech.name}',
      ),
      // Add more recommendations based on tech stack
    ];
  }

  // Courses
  List<CourseModel> recommendedCourses = [];
  List<CourseModel> topRatedCourses = [];
  List<CourseModel> recentCourses = [];

  // Add this list for progress carousel
  List<CourseModel> inProgressCoursesList = [
    CourseModel(
      title: 'Flutter Development Masterclass',
      imageUrl: 'assets/images/1.jpg',
      price: 99.99,
      rating: 4.8,
      reviews: 1250,
      progress: 0.7,
      tags: ['Flutter', 'Mobile'],
    ),
    CourseModel(
      title: 'React Native Fundamentals',
      imageUrl: 'assets/images/2.jpg',
      price: 89.99,
      rating: 4.6,
      reviews: 980,
      progress: 0.4,
      tags: ['React Native', 'Mobile'],
    ),
    CourseModel(
      title: 'iOS Development with Swift',
      imageUrl: 'assets/images/3.jpg',
      price: 129.99,
      rating: 4.9,
      reviews: 750,
      progress: 0.3,
      tags: ['iOS', 'Swift'],
    ),
  ];

  // Sessions
  List<SessionModel> upcomingSessions = [];

  LearnerHomeViewModel() {
    _init();
    _loadCourses();
    _loadSessions();
    // Add listener to auth service
    _authService.addListener(() {
      notifyListeners();
    });
  }

  void _init() {
    Future.delayed(const Duration(seconds: 2), () {
      isLoading = false;
      notifyListeners();
    });
  }

  void _loadCourses() {
    recommendedCourses = [
      CourseModel(
        title: 'Flutter Development Masterclass',
        imageUrl: 'assets/images/1.jpg',
        price: 99.99,
        rating: 4.8,
        reviews: 1250,
        tags: ['Flutter', 'Mobile'],
      ),
      // Add more courses...
    ];

    // Update topRatedCourses initialization
    topRatedCourses = [
      CourseModel(
        title: 'Advanced Flutter Architecture',
        imageUrl: 'assets/images/1.jpg',
        price: 149.99,
        rating: 4.9,
        reviews: 2150,
        tags: ['Flutter', 'Architecture'],
        totalLessons: 24,
        enrolledStudents: 15420,
        instructorName: 'John Smith',
      ),
      CourseModel(
        title: 'Firebase & Flutter Integration',
        imageUrl: 'assets/images/2.jpg',
        price: 119.99,
        rating: 4.8,
        reviews: 1820,
        tags: ['Flutter', 'Firebase'],
      ),
      CourseModel(
        title: 'Flutter State Management Pro',
        imageUrl: 'assets/images/3.jpg',
        price: 89.99,
        rating: 4.7,
        reviews: 1560,
        tags: ['Flutter', 'State Management'],
      ),
    ];

    recentCourses = [
      CourseModel(
        title: 'Flutter State Management',
        imageUrl: 'assets/images/2.jpg',
        price: 89.99,
        rating: 4.7,
        reviews: 1250,
        progress: 0.8,
        lastAccessDate: '2 hours ago',
        totalLessons: 18,
        activityType: 'in_progress',
        instructorName: 'Sarah Johnson',
      ),
      CourseModel(
        title: 'Firebase Integration',
        imageUrl: 'assets/images/3.jpg',
        price: 99.99,
        rating: 4.8,
        reviews: 980,
        progress: 1.0,
        lastAccessDate: 'Yesterday',
        totalLessons: 15,
        activityType: 'completed',
        instructorName: 'Mike Wilson',
      ),
      // Add more courses...
    ];
  }

  void _loadSessions() {
    upcomingSessions = [
      SessionModel(
        title: 'Flutter State Management',
        type: 'Live Class',
        date: 'June 15, 2023',
        time: '10:00 AM',
      ),
      // Add more sessions...
    ];
  }

  Future<void> refreshData() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _loadCourses();
    _loadSessions();

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(() {});
    super.dispose();
  }
}

class UserModel {
  final String name;
  final String imageUrl;
  final int coursesCompleted;

  UserModel(this.name, this.imageUrl, this.coursesCompleted);
}

class CourseModel {
  final String title;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviews;
  final List<String> tags;
  final double progress;
  final String registrationDate;
  final int totalLessons;
  final int enrolledStudents;
  final String lastAccessDate;
  final bool isCompleted;
  final String instructorName;
  final String activityType; // 'completed', 'in_progress', 'started'
  final String difficulty;
  final String duration;
  final String description;

  CourseModel({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviews,
    this.tags = const [],
    this.progress = 0.0,
    this.registrationDate = '',
    this.totalLessons = 0,
    this.enrolledStudents = 0,
    this.lastAccessDate = '',
    this.isCompleted = false,
    this.instructorName = '',
    this.activityType = 'in_progress',
    this.difficulty = 'Intermediate',
    this.duration = '6 weeks',
    this.description = '',
  });
}

class SessionModel {
  final String title;
  final String type;
  final String date;
  final String time;

  SessionModel({
    required this.title,
    required this.type,
    required this.date,
    required this.time,
  });
}

class TechStackItem {
  final String name;
  final Color color;

  TechStackItem(this.name, this.color);
}
