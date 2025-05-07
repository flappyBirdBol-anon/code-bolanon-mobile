import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/analytics_service.dart';
import 'package:code_bolanon/services/image_service.dart';
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
  final _imageService = locator<ImageService>();

  double? revenue;

  // User data for the trainer
  UserModel? get currentUser => _userService.currentUser;
  List<String> trainerStacks = ['Flutter', 'Dart', 'Firebase', 'Node.js'];

  // Available metrics for export
  final List<String> availableMetrics = [
    'enrollment',
    'performance',
    'revenue',
  ];
  final Map<String, String> metricLabels = {
    'enrollment': 'Enrollment Data',
    'performance': 'Course Performance',
    'revenue': 'Revenue Metrics',
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

  bool isLoadingData = true;

  TrainerAnalyticsViewModel() {
    initialize();
  }

  Future<void> initialize() async {
    setBusy(true);
    isLoadingData = true;

    await _loadUserData();
    await _loadAnalyticsData();

    isLoadingData = false;
    setBusy(false);
  }

  Future<void> _loadUserData() async {
    // Fetch user data
    if (currentUser == null) {
      await _userService.fetchUserProfile();
    }

    // Default date range (last 12 months)
    endDate = DateTime.now();
    startDate = DateTime(endDate!.year - 1, endDate!.month, endDate!.day);

    _loadTrainerTechStacks();
  }

  Future<void> _loadAnalyticsData() async {
    // Fetch analytics within date range
    enrollmentData = await _analyticsService.getEnrollmentData(
      startDate: startDate,
      endDate: endDate,
    );

    coursePerformanceData = await _analyticsService.getCoursePerformanceData(
      startDate: startDate,
      endDate: endDate,
    );

    revenueMetrics = await _analyticsService.getRevenueMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    monthlyRevenueData = (revenueMetrics['monthlyData'] as List)
        .map((e) => {
              'month': e['month'],
              'revenue': e['revenue'],
              'trend': e['revenue'],
            })
        .toList();

    revenueByCoursesData = await _analyticsService.getRevenueByCourse(
      startDate: startDate,
      endDate: endDate,
    );

    learnerDemographics = _analyticsService.getLearnerDemographics();
    courseEngagementData = _analyticsService.getCourseEngagementData();

    // Generate colors for charts
    enrollmentChartColors =
        _analyticsService.generateChartColors(enrollmentData.length);
    coursePerformanceColors =
        _analyticsService.generateChartColors(coursePerformanceData.length);
    demographicsColors = _analyticsService
        .generateChartColors(learnerDemographics['ageGroups']?.length ?? 0);

    revenue = await _analyticsService.totalRevenue();
    notifyListeners();
  }

  // Load tech stacks for the current trainer
  void _loadTrainerTechStacks() {
    // Load tech stacks assigned to the trainer from their profile
    if (currentUser != null &&
        currentUser!.stacks != null &&
        currentUser!.stacks!.isNotEmpty) {
      trainerStacks = currentUser!.stacks!
          .where((s) => s.stack != null)
          .map((s) => s.stack!.tags)
          .toList();
    } else {
      trainerStacks = [];
    }
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

  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    if (start != null && end != null) {
      startDate = start;
      endDate = end;

      isLoadingData = true;
      setBusy(true);

      // Re-fetch analytics within new date range
      await _loadAnalyticsData();

      isLoadingData = false;
      setBusy(false);
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

  Widget getProfileImageWidget({
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (currentUser!.profileImage!.isEmpty) {
      return errorWidget ??
          const Icon(Icons.person, size: 35, color: Colors.white70);
    }

    // For local files (from cache/camera)
    if (currentUser!.profileImage!.startsWith('/data/')) {
      return Image.asset(
        currentUser!.profileImage!,
        width: 60,
        height: 60,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Icon(Icons.person, size: 35, color: Colors.white70),
      );
    }

    final imageUrl =
        _imageService.getCourseThumbnailFromPath(currentUser!.profileImage!);

    // For network images
    return _imageService.loadImage(
      imageUrl: imageUrl,
      courseId: '',
      width: 60,
      height: 60,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
