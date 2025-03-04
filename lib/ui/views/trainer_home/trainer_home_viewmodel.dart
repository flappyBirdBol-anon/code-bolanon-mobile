import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:flutter/material.dart';

class TrainerHomeViewModel extends AppBaseViewModel {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  String get userName => userService.loggedInUser?.fullName ?? 'User';
  String get userRole => userService.loggedInUser?.role ?? 'Guest';
  String get userImage => userService.loggedInUser?.profileImage ?? '';
  String get userEmail => userService.loggedInUser?.email ?? '';
  bool isLoading = true;
  String profileImageUrl = 'assets/images/1.jpg';
  int activeStudents = 150;
  int totalCourses = 12;
  double totalRevenue = 15000;

  TrainerHomeViewModel() {
    _init();
    print(userName);
  }

  List<RecentActivity> recentActivities = [
    RecentActivity(
      id: '1',
      title: 'New student enrolled in UX Design',
      timestamp: '2 hours ago',
      icon: Icons.person_add,
    ),
    RecentActivity(
      id: '2',
      title: 'Course review received',
      timestamp: '5 hours ago',
      icon: Icons.star,
    ),
    RecentActivity(
      id: '3',
      title: 'New message from student',
      timestamp: '1 day ago',
      icon: Icons.message,
    ),
  ];

  List<String> topics = [
    'JavaScript',
    'Python',
    'React',
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
      lessons: 12,
    ),
    CourseModel(
      id: '2',
      title: 'Web Development Bootcamp...',
      imageUrl: 'assets/images/2.jpg',
      price: 2000,
      rating: 4.1,
      reviews: 3432,
      lessons: 18,
    ),
    CourseModel(
      id: '3',
      title: 'Python for Data Science...',
      imageUrl: 'assets/images/3.jpg',
      price: 1200,
      rating: 4.3,
      reviews: 1100,
      lessons: 10,
    ),
  ];

  // Header actions
  void showNotifications() {
    debugPrint('Showing notifications');
    // Implement notification logic or navigation
  }

  void searchContent() {
    debugPrint('Opening search');
    // Implement search functionality
  }

  // Quick actions
  void createNewCourse() {
    debugPrint('Creating new course');
    // Navigate to course creation screen
  }

  void reviewContent() {
    debugPrint('Opening reviews');
    // Navigate to reviews screen
  }

  void openAnalytics() {
    debugPrint('Opening analytics dashboard');
    // Navigate to analytics screen
  }

  void openSchedule() {
    debugPrint('Opening schedule');
    // Navigate to schedule screen
  }

  // Course related actions
  void openCourse(String id) {
    debugPrint('Opening course with ID: $id');
    // Navigate to specific course
  }

  void viewAllCourses() {
    debugPrint('Viewing all courses');
    // Navigate to courses list
  }

  // Stats related actions
  void showMonthlyStats() {
    debugPrint('Showing monthly statistics');
    // This will be invoked by the UI to show the picker
    // The actual implementation of the picker is in the View
  }

  // Update selected date and fetch associated stats
  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    fetchStatsForMonth(date.year, date.month);
    notifyListeners();
  }

  // Fetch stats for the specified month
  Future<void> fetchStatsForMonth(int year, int month) async {
    setLoading(true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, you would fetch actual data for the selected month
    // For now, let's vary the stats based on the month for demonstration
    final monthSeed = month * 10;
    activeStudents = 120 + monthSeed;
    totalCourses = 8 + (month % 5);
    totalRevenue = 12000 + (month * 500) + (year - 2023) * 2000;

    setLoading(false);
  }

  // Stack related actions
  void addToStack() {
    debugPrint('Adding new technology to stack');
    // Show dialog to add new technology
  }

  // Challenge related actions
  void viewAllChallenges() {
    debugPrint('Viewing all code challenges');
    // Navigate to challenges list
  }

  void openChallenge(String title) {
    debugPrint('Opening challenge: $title');
    // Navigate to specific challenge
  }

  // Session related actions
  void startSession() {
    debugPrint('Starting JavaScript Workshop session');
    // Navigate to video session screen
  }

  void openReviewSession() {
    debugPrint('Opening code review session');
    // Navigate to code review session
  }

  // Activity related actions
  void openActivity(String id) {
    debugPrint('Opening activity with ID: $id');
    // Navigate to specific activity
  }

  // Theme toggle
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Data management
  Future<void> refreshData() async {
    setLoading(true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Refresh data
    activeStudents = 165; // Updated values after refresh
    totalCourses = 14;
    totalRevenue = 16500;

    setLoading(false);
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _init() {
    // Initialize with current month
    _selectedDate = DateTime.now();

    Future.delayed(const Duration(seconds: 3), () {
      setLoading(false);
    });
  }
}

class RecentActivity {
  final String id;
  final String title;
  final String timestamp;
  final IconData icon;

  RecentActivity({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.icon,
  });
}
