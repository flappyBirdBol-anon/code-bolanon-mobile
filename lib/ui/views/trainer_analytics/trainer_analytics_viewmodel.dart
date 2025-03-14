import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/analytics_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:open_file/open_file.dart';

class TrainerAnalyticsViewModel extends BaseViewModel {
  final _analyticsService = locator<AnalyticsService>();
  final _userService = locator<UserService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();

  // User data for the trainer
  UserModel? get currentUser => _userService.currentUser;
  List<String> trainerStacks = ['Flutter', 'Dart', 'Firebase', 'Node.js'];

  // Available metrics for export
  final List<String> availableMetrics = [
    'enrollment',
    'performance',
    'revenue',
    'demographics',
    'engagement'
  ];
  final Map<String, String> metricLabels = {
    'enrollment': 'Enrollment Data',
    'performance': 'Course Performance',
    'revenue': 'Revenue Metrics',
    'demographics': 'Demographics',
    'engagement': 'Engagement Metrics'
  };
  Set<String> selectedMetrics = {};

  // Data holders for analytics
  List<Map<String, dynamic>> enrollmentData = [];
  int get maxEnrollmentCount => enrollmentData.isEmpty
      ? 100
      : enrollmentData
          .map((e) => e['count'] as int)
          .reduce((max, value) => max > value ? max : value);

  List<Map<String, dynamic>> coursePerformanceData = [];
  Map<String, dynamic> revenueMetrics = {};
  Map<String, dynamic> learnerDemographics = {};
  List<Map<String, dynamic>> courseEngagementData = [];

  // Revenue chart data
  List<Map<String, dynamic>> monthlyRevenueData = [];
  List<Map<String, dynamic>> revenueByCoursesData = [];

  // Chart colors
  List<Color> enrollmentChartColors = [];
  List<Color> coursePerformanceColors = [];
  List<Color> demographicsColors = [];

  // Selected tab
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  // Selected report format
  String _selectedReportFormat = 'Excel';
  String get selectedReportFormat => _selectedReportFormat;
  List<String> reportFormats = ['Excel', 'Word'];

  // Date range for filtering
  DateTime? startDate;
  DateTime? endDate;

  TrainerAnalyticsViewModel() {
    initialize();
  }

  Future<void> initialize() async {
    setBusy(true);

    // Fetch user data if not already available
    if (currentUser == null) {
      await _userService.fetchUserProfile();
    }
    _generateRevenueChartData();
    // Get tech stacks for the current trainer (in a real app, would be from the backend)
    _loadTrainerTechStacks();

    // Fetch all analytics data
    enrollmentData = _analyticsService.getEnrollmentData();
    coursePerformanceData = _analyticsService.getCoursePerformanceData();
    revenueMetrics = _analyticsService.getRevenueMetrics();
    learnerDemographics = _analyticsService.getLearnerDemographics();
    courseEngagementData = _analyticsService.getCourseEngagementData();

    // Generate colors for charts
    enrollmentChartColors =
        _analyticsService.generateChartColors(enrollmentData.length);
    coursePerformanceColors =
        _analyticsService.generateChartColors(coursePerformanceData.length);
    demographicsColors = _analyticsService
        .generateChartColors(learnerDemographics['ageGroups'].length);

    // Set default date range (last 12 months)
    endDate = DateTime.now();
    startDate = DateTime(endDate!.year - 1, endDate!.month, endDate!.day);

    setBusy(false);
  }

  // Load tech stacks for the current trainer
  void _loadTrainerTechStacks() {
    // In a real app, these would come from the user profile or a separate endpoint
    // For now, we're hardcoding some example tech stacks
    if (currentUser != null) {
      switch (currentUser!.specialization) {
        case 'Mobile Development':
          trainerStacks = ['Flutter', 'React Native', 'iOS', 'Android'];
          break;
        case 'Web Development':
          trainerStacks = ['React', 'Angular', 'Vue.js', 'Node.js'];
          break;
        case 'Backend Development':
          trainerStacks = ['PHP', 'Node.js', 'Python', 'Java'];
          break;
        case 'Data Science':
          trainerStacks = ['Python', 'R', 'Tableau', 'SQL'];
          break;
        default:
          trainerStacks = ['Flutter', 'Dart', 'Firebase', 'Git'];
      }
    }
  }

  // Generate data for revenue charts
  void _generateRevenueChartData() {
    // Monthly revenue data for the line chart
    monthlyRevenueData = [
      {'month': 'Jan', 'revenue': 2500, 'trend': 2500},
      {'month': 'Feb', 'revenue': 3200, 'trend': 3000},
      {'month': 'Mar', 'revenue': 3100, 'trend': 3300},
      {'month': 'Apr', 'revenue': 4100, 'trend': 3600},
      {'month': 'May', 'revenue': 3800, 'trend': 3900},
      {'month': 'Jun', 'revenue': 5200, 'trend': 4200},
    ];

    // Revenue by course for pie chart
    revenueByCoursesData = [
      {'courseName': 'Flutter Masterclass', 'revenue': 5200},
      {'courseName': 'React Native Basics', 'revenue': 3100},
      {'courseName': 'Advanced Dart', 'revenue': 2400},
      {'courseName': 'Firebase Integration', 'revenue': 1800},
      {'courseName': 'UI/UX Design', 'revenue': 1500},
    ];
  }

  Future<void> generateReport() async {
    if (_selectedReportFormat != 'Excel') {
      _snackbarService.showSnackbar(
        message: 'Only Excel export is currently supported',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Show metric selection dialog
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.metricSelection,
      title: 'Select Metrics to Export',
      description: 'Choose which metrics you want to include in the report:',
      mainButtonTitle: 'Export',
      secondaryButtonTitle: 'Cancel',
      data: {
        'metrics': availableMetrics,
        'labels': metricLabels,
        'selected': selectedMetrics,
      },
    );

    if (response?.confirmed != true || response?.data == null) return;

    final exportMetrics = (response!.data as Set<String>).toList();
    if (exportMetrics.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please select at least one metric to export',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setBusy(true);
    try {
      final filePath =
          await _analyticsService.exportToExcel(selectedMetrics: exportMetrics);

      // Show success message
      _snackbarService.showSnackbar(
        message: 'Report generated successfully',
        duration: const Duration(seconds: 2),
      );

      // Open the file
      await OpenFile.open(filePath);
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Error generating report: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  void changeTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setReportFormat(String format) {
    _selectedReportFormat = format;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      startDate = start;
      endDate = end;
      notifyListeners();
    }
  }

  // Helper for revenue summary
  Map<String, dynamic> getRevenueSummary() {
    return {
      'totalRevenue': revenueMetrics['totalRevenue'],
      'monthlyGrowth': revenueMetrics['monthlyGrowth'],
      'averageCourseValue': revenueMetrics['averageCourseValue'],
    };
  }

  // Helper to get data for specific metric
  List<Map<String, dynamic>> getChartDataForMetric(String metricType) {
    switch (metricType) {
      case 'enrollment':
        return enrollmentData;
      case 'revenue':
        return monthlyRevenueData;
      default:
        return [];
    }
  }
}
