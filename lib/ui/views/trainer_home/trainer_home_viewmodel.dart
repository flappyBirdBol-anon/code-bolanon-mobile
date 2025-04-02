import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/tech_stack_model.dart';
import 'package:code_bolanon/models/transaction_model.dart';
import 'package:code_bolanon/models/transactions_model.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/transactions_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class TrainerHomeViewModel extends AppBaseViewModel {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  String get userName => userService.currentUser?.fullName ?? 'User';
  String get userRole => userService.currentUser?.role ?? 'Guest';
  String get userImage => userService.currentUser?.profileImage ?? '';
  String get userEmail => userService.currentUser?.email ?? '';
  int get userCourseCount => userService.courseCount;

  List<TechStackModel> get userTopics => userService.userTechStacks;
  bool isLoading = true;
  String profileImageUrl = 'assets/images/1.jpg';
  int activeLearners = 0;
  int totalCourses = 0;
  double totalRevenue = 0.0;
  final _courseService = locator<CourseService>();
  final _imageService = locator<ImageService>();
  final _navigationService = locator<NavigationService>();
  final _transactionService = locator<TransactionsService>();

  final List<AppointmentModel> _upcomingAppointments = [];
  List<AppointmentModel> get upcomingAppointments => _upcomingAppointments;

  List<String> getCourseTags(CourseModel course) =>
      course.stacks.map((e) => e).toList();

  TrainerHomeViewModel() {
    userService.addListener(_onUserChanged);
    init();
    _init();
  }
  void _onUserChanged() {
    notifyListeners();
  }

  List<RecentActivity> recentActivities = [
    // RecentActivity(
    //   id: '1',
    //   title: 'New learner enrolled in UX Design',
    //   timestamp: '2 hours ago',
    //   icon: Icons.person_add,
    // ),
    // RecentActivity(
    //   id: '2',
    //   title: 'Course review received',
    //   timestamp: '5 hours ago',
    //   icon: Icons.star,
    // ),
    // RecentActivity(
    //   id: '3',
    //   title: 'New message from learner',
    //   timestamp: '1 day ago',
    //   icon: Icons.message,
    // ),
  ];

  List<String> topics = [];

  List<CourseModel> _courses = [];
  List<CourseModel> get courseList => _courses;

  List<Transactions> _transactions = [];
  List<Transactions> get transactions => _transactions;

  Future<void> init() async {
    print('User Image: $userImage');
    setBusy(true);
    try {
      // Fetch courses from API using CourseService
      _courses = await _courseService.getCourses();
      topics = userTopics.map((e) => e.tags).toList();
      totalCourses = userCourseCount;

      // Fetch transactions from API using TransactionsService
      _transactions = await _transactionService.getTransactions();

      //get total revenue limited to 2 decimal places
      totalRevenue = _transactions.fold(
          0.0,
          (previousValue, transaction) =>
              previousValue + double.parse(transaction.amount));
      totalRevenue = double.parse(totalRevenue.toStringAsFixed(3));

      notifyListeners();
    } catch (e) {
      _showErrorMessage('Failed to load courses: ${e.toString()}');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  int getTotalLearnersEnrolled() {
    // Sum all enrolled learners across all courses
    return courseList.fold<int>(
        0, (previousValue, course) => previousValue + course.studentsEnrolled);
    //  (previousValue, course) => previousValue + (course.enrolledCount ?? 0));
  }

  // Get a widget to display a course image
  Widget getCourseImageWidget({
    required CourseModel course,
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

  void navigateToCourseDetails(CourseModel course) {
    navigationService.navigateToCourseDetailsView(
      course: course,
    );
  }

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
    _navigationService.navigateTo(Routes.trainerCoursesView);
  }

  void openSettings() {
    // debugPrint('Opening settings');
    _navigationService.navigateTo(Routes.settingsView);
  }

  void openAnalytics() {
    // debugPrint('Opening analytics dashboard');
    // Navigate to analytics screen
    _navigationService.navigateToTrainerAnalyticsView();
  }

  void openAppointment() {
    _navigationService.navigateToTrainerAppointmentHomeView();
    // Navigate to schedule screen
  }

  // Course related actions
  void openCourse(String id) {
    debugPrint('Opening course with ID: $id');
    // Navigate to specific course
  }

  void viewAllCourses() {
    _navigationService.navigateToTrainerCoursesView();
    // Navigate to courses list
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

    final monthSeed = month * 10;
    activeLearners = 120 + monthSeed;
    totalCourses = 8 + (month % 5);
    totalRevenue = 12000 + (month * 500) + (year - 2023) * 2000;

    setLoading(false);
  }

  // Stack related actions
  void addToStack() {
    _navigationService.navigateToProfileView();
    // Show dialog to add new technology
  }

  void openReviewSession() {
    debugPrint('Opening code review session');
    // Navigate to code review session
  }

  void openSession(String sessionId) {
    // Implementation for opening a session
    print('Opening session: $sessionId');
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
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> refreshData() async {
    isLoading = true; // Changed from setLoading(true)
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    try {
      //_upcomingAppointments = AppointmentModel.getMockAppointments();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    } finally {
      isLoading = false; // Changed from setLoading(false)
      notifyListeners();
    }
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

  void _init() async {
    isLoading = true; // Changed from setLoading(true)
    await Future.delayed(const Duration(seconds: 2));
    await refreshData();
    notifyListeners();
  }

  Widget getProfileImageWidget({
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    Widget imageWidget;
    if (userImage.isEmpty) {
      imageWidget = errorWidget ??
          const Icon(Icons.person, size: 35, color: Colors.white70);
    } else if (userImage.startsWith('/data/')) {
      imageWidget = Image.asset(
        userImage,
        width: 60,
        height: 60,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Icon(Icons.person, size: 35, color: Colors.white70),
      );
    } else {
      final imageUrl = _imageService.getCourseThumbnailFromPath(userImage);
      imageWidget = _imageService.loadImage(
        imageUrl: imageUrl,
        courseId: '',
        width: 60,
        height: 60,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }

    return GestureDetector(
      onTap: () => _navigationService.navigateToProfileView(),
      child: imageWidget,
    );
  }

  // Empty state flags
  bool get hasNoCourses => courseList.isEmpty && !isLoading;
  bool get hasNoSessions => upcomingAppointments.isEmpty && !isLoading;
  bool get hasNoActivities => recentActivities.isEmpty && !isLoading;
  bool get hasNoProgress => activeLearners == 0 && !isLoading;
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
