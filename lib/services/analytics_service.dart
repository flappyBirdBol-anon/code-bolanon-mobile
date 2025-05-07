import 'dart:math';
import 'dart:io';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/transactions_model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:syncfusion_officechart/officechart.dart'; // Add this package to open the file
import 'package:code_bolanon/services/transactions_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/services/completed_lesson_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/models/registration_model.dart';

class AnalyticsService {
  final _transactionService = locator<TransactionsService>();
  final _registrationService = locator<RegistrationService>();
  final _completedLessonService = locator<CompletedLessonService>();
  final _lessonsService = locator<LessonsService>();
  final _courseService = locator<CourseService>();

  Transactions? transactions;
  // Get total revenue from transactions with 2 decimal places
  Future<double> totalRevenue() async {
    List<Transactions> transactions =
        await _transactionService.getTransactions();
    double total = 0.0;
    for (var transaction in transactions) {
      if (transaction.status == 'completed') {
        total += double.parse(transaction.amount);
        print('total value: $total');
      }
    }
    return double.parse(total.toStringAsFixed(2));
  }

  // Real data for learner enrollments
  Future<List<Map<String, dynamic>>> getEnrollmentData(
      {DateTime? startDate, DateTime? endDate}) async {
    final allRegs = await _registrationService.getUserRegistrations();
    final regs = allRegs.where((reg) {
      if (startDate != null && reg.createdAt.isBefore(startDate)) return false;
      if (endDate != null && reg.createdAt.isAfter(endDate)) return false;
      return true;
    }).toList();
    final now = DateTime.now();
    List<Map<String, dynamic>> result = [];
    for (int i = 11; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('MMM').format(dt);
      final count = regs
          .where((reg) =>
              reg.createdAt.year == dt.year && reg.createdAt.month == dt.month)
          .length;
      result.add({'month': key, 'count': count});
    }
    return result;
  }

  // Real data for course performance
  Future<List<Map<String, dynamic>>> getCoursePerformanceData(
      {DateTime? startDate, DateTime? endDate}) async {
    final allRegs = await _registrationService.getUserRegistrations();
    final regs = allRegs.where((reg) {
      if (startDate != null && reg.createdAt.isBefore(startDate)) return false;
      if (endDate != null && reg.createdAt.isAfter(endDate)) return false;
      return true;
    }).toList();
    final Map<String, List<RegistrationModel>> byCourse = {};
    for (var reg in regs) {
      final name = reg.course?.title ?? 'Unknown';
      byCourse.putIfAbsent(name, () => []).add(reg);
    }
    List<Map<String, dynamic>> data = [];
    for (var entry in byCourse.entries) {
      final courseName = entry.key;
      final regsList = entry.value;
      final totalRegs = regsList.length;
      final ratingSum = regsList.fold<double>(
          0.0, (sum, r) => sum + (r.rating?.toDouble() ?? 0.0));
      final avgRating = totalRegs > 0 ? ratingSum / totalRegs : 0.0;
      final courseId = regsList.first.course?.id ?? '';
      final lessons = await _lessonsService.getLessons(courseId: courseId);
      final totalLessons = lessons.length;
      double completionSum = 0.0;
      for (var reg in regsList) {
        await _completedLessonService.fetchCompletedLessons(
            registrationId: reg.id);
        final completedCount = _completedLessonService.completedLessons.length;
        completionSum +=
            totalLessons > 0 ? (completedCount / totalLessons * 100) : 0.0;
      }
      final avgCompletion = totalRegs > 0 ? completionSum / totalRegs : 0.0;
      data.add({
        'courseName': courseName,
        'rating': double.parse(avgRating.toStringAsFixed(1)),
        'completionRate': double.parse(avgCompletion.toStringAsFixed(1)),
        'learners': totalRegs
      });
    }
    return data;
  }

  // Real data for revenue metrics
  Future<Map<String, dynamic>> getRevenueMetrics(
      {DateTime? startDate, DateTime? endDate}) async {
    final allTxns = await _transactionService.getTransactions();
    final txns = allTxns.where((t) {
      final dt = t.createdAt ?? DateTime.now();
      if (startDate != null && dt.isBefore(startDate)) return false;
      if (endDate != null && dt.isAfter(endDate)) return false;
      return true;
    }).toList();
    final completed = txns.where((t) => t.status == 'completed').toList();
    final totalRevenue =
        completed.fold<double>(0.0, (sum, t) => sum + double.parse(t.amount));
    final Map<String, double> monthlySums = {};
    for (var t in completed) {
      final dt = t.createdAt ?? DateTime.now();
      final key = DateFormat('MMM yyyy').format(dt);
      monthlySums[key] = (monthlySums[key] ?? 0) + double.parse(t.amount);
    }
    final entries = monthlySums.entries.toList()
      ..sort((a, b) => DateFormat('MMM yyyy')
          .parse(a.key)
          .compareTo(DateFormat('MMM yyyy').parse(b.key)));
    final monthlyData = entries
        .map((e) => {
              'month': e.key,
              'revenue': double.parse(e.value.toStringAsFixed(2))
            })
        .toList();
    double monthlyGrowth = 0.0;
    if (monthlyData.length >= 2) {
      final last = monthlyData.last['revenue'] as double;
      final prev = monthlyData[monthlyData.length - 2]['revenue'] as double;
      if (prev != 0) monthlyGrowth = (last - prev) / prev * 100;
    }
    final avgValue =
        completed.isNotEmpty ? totalRevenue / completed.length : 0.0;
    return {
      'totalRevenue': double.parse(totalRevenue.toStringAsFixed(2)),
      'monthlyGrowth': double.parse(monthlyGrowth.toStringAsFixed(2)),
      'averageCourseValue': double.parse(avgValue.toStringAsFixed(2)),
      'monthlyData': monthlyData
    };
  }

  // Fetch revenue aggregated by course
  Future<List<Map<String, dynamic>>> getRevenueByCourse(
      {DateTime? startDate, DateTime? endDate}) async {
    final allTxns = await _transactionService.getTransactions();
    final txns = allTxns.where((t) {
      final dt = t.createdAt ?? DateTime.now();
      if (startDate != null && dt.isBefore(startDate)) return false;
      if (endDate != null && dt.isAfter(endDate)) return false;
      return true;
    }).toList();
    final completed = txns.where((t) => t.status == 'completed');
    final Map<String, double> courseRevenue = {};
    for (final txn in completed) {
      final courseId = txn.courseId;
      if (courseId != null) {
        final course = await _courseService.getCourseById(courseId);
        final amount = double.parse(txn.amount);
        courseRevenue.update(
          course.title,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      }
    }
    return courseRevenue.entries
        .map((e) => {
              'courseName': e.key,
              'revenue': double.parse(e.value.toStringAsFixed(2)),
            })
        .toList();
  }

  // Mock data for learner demographics
  Map<String, dynamic> getLearnerDemographics() {
    return {
      'ageGroups': [
        {'group': '18-24', 'percentage': 35},
        {'group': '25-34', 'percentage': 42},
        {'group': '35-44', 'percentage': 15},
        {'group': '45+', 'percentage': 8},
      ],
      'gender': [
        {'type': 'Male', 'percentage': 58},
        {'type': 'Female', 'percentage': 40},
        {'type': 'Other', 'percentage': 2},
      ],
      'backgrounds': [
        {'type': 'Computer Science', 'percentage': 45},
        {'type': 'Self-taught', 'percentage': 30},
        {'type': 'Bootcamp', 'percentage': 15},
        {'type': 'Other', 'percentage': 10},
      ]
    };
  }

  // Mock data for course engagement
  List<Map<String, dynamic>> getCourseEngagementData() {
    return [
      {'metric': 'Average Session Time', 'value': '45 mins'},
      {'metric': 'Assignments Completion Rate', 'value': '78%'},
      {'metric': 'Forum Participation', 'value': '62%'},
      {'metric': 'Q&A Response Rate', 'value': '91%'},
      {'metric': 'Video Completion Rate', 'value': '84%'},
    ];
  }

  // Generate random colors for charts
  List<Color> generateChartColors(int count) {
    Random random = Random();
    List<Color> colors = [];

    for (int i = 0; i < count; i++) {
      colors.add(
        Color.fromRGBO(
          random.nextInt(200) + 55,
          random.nextInt(200) + 55,
          random.nextInt(200) + 55,
          1.0,
        ),
      );
    }
    return colors;
  }

  Future<String> exportToExcel({List<String>? selectedMetrics}) async {
    final Workbook workbook = Workbook();
    final metrics = selectedMetrics ??
        ['enrollment', 'performance', 'revenue', 'demographics', 'engagement'];

    // Create all sheets first
    if (metrics.contains('enrollment')) {
      await _addEnrollmentSheet(workbook);
    }

    if (metrics.contains('performance')) {
      await _addPerformanceSheet(workbook);
    }

    if (metrics.contains('revenue')) {
      await _addRevenueSheet(workbook);
    }

    if (metrics.contains('demographics')) {
      _addDemographicsSheet(workbook);
    }

    if (metrics.contains('engagement')) {
      _addEngagementSheet(workbook);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'analytics_report_$dateStr.xlsx';
    final filePath = '${directory.path}/$fileName';

    // Save and close workbook
    final List<int> bytes = workbook.saveAsStream();
    await File(filePath).writeAsBytes(bytes, flush: true);
    workbook.dispose();

    // Optionally open the file to verify charts are present
    // OpenFile.open(filePath);

    return filePath;
  }

  Future<void> _addEnrollmentSheet(Workbook workbook) async {
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Enrollment';

    // Apply bold style to headers
    final Style headerStyle = workbook.styles.add('HeaderStyle');
    headerStyle.bold = true;
    headerStyle.fontSize = 12;
    headerStyle.fontColor = '#2196F3';

    // Headers
    final Range headerRange = sheet.getRangeByName('A1:B1');
    headerRange.cellStyle = headerStyle;
    sheet.getRangeByName('A1').setText('Month');
    sheet.getRangeByName('B1').setText('Enrollments');

    // Data
    final data = await getEnrollmentData();
    for (var i = 0; i < data.length; i++) {
      sheet.getRangeByName('A${i + 2}').setText(data[i]['month']);
      sheet.getRangeByName('B${i + 2}').setNumber(data[i]['count'].toDouble());
    }

    // Auto-fit columns
    sheet.autoFitColumn(1);
    sheet.autoFitColumn(2);

    // Create chart collection
    final ChartCollection charts = ChartCollection(sheet);
    final Chart chart = charts.add();

    // Configure chart with enhanced styling
    chart.chartType = ExcelChartType.line;
    chart.dataRange = sheet.getRangeByName('A1:B${data.length + 1}');
    chart.isSeriesInRows = false;

    // Enhanced chart styling with title formatting
    chart.chartTitle = 'Monthly Enrollment Trends';
    chart.chartTitleArea.bold = true;
    chart.chartTitleArea.size = 12;

    // Axis configuration
    chart.primaryCategoryAxis.title = 'Months';
    chart.primaryValueAxis.title = 'Number of Enrollments';
    chart.primaryCategoryAxis.numberFormat = 'mmm';
    chart.primaryValueAxis.numberFormat = '0';
    chart.primaryValueAxis.hasMajorGridLines = true;

    // Legend configuration
    chart.hasLegend = true;
    chart.legend!.position = ExcelLegendPosition.bottom;

    // Line pattern and color configuration
    chart.plotArea.linePattern = ExcelChartLinePattern.solid;
    chart.plotArea.linePatternColor = '#2196F3';
    chart.linePattern = ExcelChartLinePattern.solid;
    chart.linePatternColor = '#1565C0';

    // Chart position
    chart.topRow = 0;
    chart.bottomRow = 20;
    chart.leftColumn = 3;
    chart.rightColumn = 10;

    // Add chart to worksheet
    sheet.charts = charts;
  }

  Future<void> _addPerformanceSheet(Workbook workbook) async {
    final Worksheet sheet = workbook.worksheets.add();
    sheet.name = 'Performance';

    // Apply styles
    final Style headerStyle = workbook.styles.add('PerfHeaderStyle');
    headerStyle.bold = true;
    headerStyle.fontSize = 12;
    headerStyle.fontColor = '#2196F3';

    // Headers with styling
    final headers = ['Course Name', 'Rating', 'Completion Rate', 'Learners'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data with formatting
    final data = await getCoursePerformanceData();
    for (var i = 0; i < data.length; i++) {
      final row = i + 2;
      sheet.getRangeByIndex(row, 1).setText(data[i]['courseName']);
      sheet.getRangeByIndex(row, 2).setNumber(data[i]['rating'].toDouble());
      sheet
          .getRangeByIndex(row, 3)
          .setNumber(data[i]['completionRate'].toDouble());
      sheet.getRangeByIndex(row, 4).setNumber(data[i]['learners'].toDouble());
    }

    // Auto-fit columns
    for (var i = 1; i <= 4; i++) {
      sheet.autoFitColumn(i);
    }

    // Create charts collection
    final ChartCollection charts = ChartCollection(sheet);

    // Rating chart
    final Chart ratingChart = charts.add();
    ratingChart.chartType = ExcelChartType.column;
    ratingChart.dataRange = sheet.getRangeByName('A1:B${data.length + 1}');
    ratingChart.isSeriesInRows = false;

    ratingChart.chartTitle = 'Course Ratings';
    ratingChart.chartTitleArea.bold = true;
    ratingChart.chartTitleArea.size = 12;

    ratingChart.primaryCategoryAxis.title = 'Courses';
    ratingChart.primaryValueAxis.title = 'Rating';
    ratingChart.primaryValueAxis.numberFormat = '0.0';
    ratingChart.primaryValueAxis.minimumValue = 0;
    ratingChart.primaryValueAxis.maximumValue = 5;

    ratingChart.hasLegend = true;
    ratingChart.legend!.position = ExcelLegendPosition.bottom;

    ratingChart.plotArea.linePattern = ExcelChartLinePattern.solid;
    ratingChart.plotArea.linePatternColor = '#4CAF50';

    ratingChart.topRow = 0;
    ratingChart.bottomRow = 20;
    ratingChart.leftColumn = 5;
    ratingChart.rightColumn = 12;

    // Completion rate chart
    final Chart completionChart = charts.add();
    completionChart.chartType = ExcelChartType.bar;
    // Set data range directly using A and C columns (course names and completion rates)
    completionChart.dataRange = sheet.getRangeByName('A1:C${data.length + 1}');
    completionChart.isSeriesInRows = false;

    completionChart.chartTitle = 'Course Completion Rates';
    completionChart.chartTitleArea.bold = true;
    completionChart.chartTitleArea.size = 12;

    completionChart.primaryCategoryAxis.title = 'Courses';
    completionChart.primaryValueAxis.title = 'Completion Rate (%)';
    completionChart.primaryValueAxis.numberFormat = '0"%"';
    completionChart.primaryValueAxis.minimumValue = 0;
    completionChart.primaryValueAxis.maximumValue = 100;

    completionChart.hasLegend = true;
    completionChart.legend!.position = ExcelLegendPosition.bottom;

    completionChart.plotArea.linePattern = ExcelChartLinePattern.solid;
    completionChart.plotArea.linePatternColor = '#FF9800';

    completionChart.topRow = 21;
    completionChart.bottomRow = 41;
    completionChart.leftColumn = 5;
    completionChart.rightColumn = 12;

    sheet.charts = charts;
  }

  Future<void> _addRevenueSheet(Workbook workbook) async {
    final Worksheet sheet = workbook.worksheets.add();
    sheet.name = 'Revenue';
    final metrics = await getRevenueMetrics();

    // Headers and summary data
    sheet.getRangeByName('A1').setText('Month');
    sheet.getRangeByName('B1').setText('Revenue Amount');

    final monthlyData = metrics['monthlyData'] as List;
    for (var i = 0; i < monthlyData.length; i++) {
      final row = i + 2;
      sheet.getRangeByName('A$row').setText(monthlyData[i]['month']);
      sheet.getRangeByName('B$row').setNumber(monthlyData[i]['revenue']);
    }

    // Create chart collection
    final ChartCollection charts = ChartCollection(sheet);
    final Chart chart = charts.add();

    // Configure chart
    chart.chartType = ExcelChartType.line;
    chart.dataRange = sheet.getRangeByName('A1:B${monthlyData.length + 1}');
    chart.isSeriesInRows = false;

    // Chart title and formatting
    chart.chartTitle = 'Monthly Revenue Trends';
    chart.chartTitleArea.bold = true;
    chart.chartTitleArea.size = 12;

    // Axis configuration
    chart.primaryCategoryAxis.title = 'Months';
    chart.primaryValueAxis.title = 'Revenue';
    chart.primaryCategoryAxis.numberFormat = 'mmm';
    chart.primaryValueAxis.numberFormat = '\$#,##0.00';

    // Legend configuration
    chart.hasLegend = true;
    chart.legend!.position = ExcelLegendPosition.bottom;

    // Line styling
    chart.plotArea.linePattern = ExcelChartLinePattern.solid;
    chart.plotArea.linePatternColor = '#4CAF50';
    chart.linePattern = ExcelChartLinePattern.solid;
    chart.linePatternColor = '#1B5E20';

    // Chart position
    chart.topRow = 0;
    chart.bottomRow = 20;
    chart.leftColumn = 3;
    chart.rightColumn = 10;

    sheet.charts = charts;
  }

  void _addDemographicsSheet(Workbook workbook) {
    final Worksheet sheet = workbook.worksheets.add();
    sheet.name = 'Demographics';
    final demographics = getLearnerDemographics();

    // Apply styles
    final Style headerStyle = workbook.styles.add('DemoHeaderStyle');
    headerStyle.bold = true;
    headerStyle.fontSize = 12;
    headerStyle.fontColor = '#2196F3';

    final Style dataStyle = workbook.styles.add('DemoDataStyle');
    dataStyle.fontSize = 11;

    // Age Groups section
    sheet.getRangeByName('A1').setText('Age Distribution');
    sheet.getRangeByName('A1').cellStyle = headerStyle;
    sheet.getRangeByName('A2').setText('Age Group');
    sheet.getRangeByName('B2').setText('Percentage');

    final ageGroups = demographics['ageGroups'] as List;
    for (var i = 0; i < ageGroups.length; i++) {
      final row = i + 3;
      sheet.getRangeByName('A$row').setText(ageGroups[i]['group']);
      sheet
          .getRangeByName('B$row')
          .setNumber(ageGroups[i]['percentage'].toDouble());
      sheet.getRangeByName('B$row').numberFormat = '0"%"';
      sheet.getRangeByName('A$row:B$row').cellStyle = dataStyle;
    }

    // Gender Distribution section
    sheet.getRangeByName('D1').setText('Gender Distribution');
    sheet.getRangeByName('D1').cellStyle = headerStyle;
    sheet.getRangeByName('D2').setText('Gender');
    sheet.getRangeByName('E2').setText('Percentage');

    final genderData = demographics['gender'] as List;
    for (var i = 0; i < genderData.length; i++) {
      final row = i + 3;
      sheet.getRangeByName('D$row').setText(genderData[i]['type']);
      sheet
          .getRangeByName('E$row')
          .setNumber(genderData[i]['percentage'].toDouble());
      sheet.getRangeByName('E$row').numberFormat = '0"%"';
      sheet.getRangeByName('D$row:E$row').cellStyle = dataStyle;
    }

    // Educational Background section
    sheet.getRangeByName('G1').setText('Educational Background');
    sheet.getRangeByName('G1').cellStyle = headerStyle;
    sheet.getRangeByName('G2').setText('Background');
    sheet.getRangeByName('H2').setText('Percentage');

    final backgrounds = demographics['backgrounds'] as List;
    for (var i = 0; i < backgrounds.length; i++) {
      final row = i + 3;
      sheet.getRangeByName('G$row').setText(backgrounds[i]['type']);
      sheet
          .getRangeByName('H$row')
          .setNumber(backgrounds[i]['percentage'].toDouble());
      sheet.getRangeByName('H$row').numberFormat = '0"%"';
      sheet.getRangeByName('G$row:H$row').cellStyle = dataStyle;
    }

    // Auto-fit columns before creating charts
    for (var i = 1; i <= 8; i++) {
      sheet.autoFitColumn(i);
    }

    // Create charts collection
    final ChartCollection charts = ChartCollection(sheet);

    // Age Distribution Pie Chart - Fixed data range
    final Chart ageChart = charts.add();
    ageChart.chartType = ExcelChartType.pie;
    // Important: Set the correct data range including headers for proper labeling
    final int ageLastRow = 2 + ageGroups.length;
    ageChart.dataRange = sheet.getRangeByName('A2:B$ageLastRow');
    ageChart.isSeriesInRows = false;
    ageChart.hasLegend = true;
    ageChart.legend!.position = ExcelLegendPosition.right;
    ageChart.legend!.textArea.bold = true;
    ageChart.hasTitle = true;
    ageChart.chartTitle = 'Age Distribution';
    ageChart.chartTitleArea.bold = true;
    // Position with enough space
    ageChart.topRow = 2;
    ageChart.bottomRow = 15;
    ageChart.leftColumn = 10;
    ageChart.rightColumn = 16;

    // Gender Distribution Doughnut Chart - Fixed
    final Chart genderChart = charts.add();
    genderChart.chartType = ExcelChartType.doughnut;
    // Set the correct data range including headers
    final int genderLastRow = 2 + genderData.length;
    genderChart.dataRange = sheet.getRangeByName('D2:E$genderLastRow');
    genderChart.isSeriesInRows = false;
    genderChart.hasLegend = true;
    genderChart.legend!.position = ExcelLegendPosition.right;
    genderChart.legend!.textArea.bold = true;
    genderChart.hasTitle = true;
    genderChart.chartTitle = 'Gender Distribution';
    genderChart.chartTitleArea.bold = true;
    // Position with enough space
    genderChart.topRow = 16;
    genderChart.bottomRow = 29;
    genderChart.leftColumn = 10;
    genderChart.rightColumn = 16;

    // Background Distribution Bar Chart
    final Chart backgroundChart = charts.add();
    backgroundChart.chartType = ExcelChartType.bar;
    final int bgLastRow = 2 + backgrounds.length;
    backgroundChart.dataRange = sheet.getRangeByName('G2:H$bgLastRow');
    backgroundChart.isSeriesInRows = false;
    backgroundChart.hasLegend = true;
    backgroundChart.legend!.position = ExcelLegendPosition.bottom;
    backgroundChart.hasTitle = true;
    backgroundChart.chartTitle = 'Educational Background';
    backgroundChart.chartTitleArea.bold = true;
    backgroundChart.primaryValueAxis.title = 'Percentage';
    backgroundChart.primaryValueAxis.numberFormat = '0"%"';
    backgroundChart.topRow = 30;
    backgroundChart.bottomRow = 43;
    backgroundChart.leftColumn = 10;
    backgroundChart.rightColumn = 16;

    // Add charts to worksheet
    sheet.charts = charts;
  }

  void _addEngagementSheet(Workbook workbook) {
    final Worksheet sheet = workbook.worksheets.add();
    sheet.name = 'Engagement';

    // Apply styles
    final Style headerStyle = workbook.styles.add('EngHeaderStyle');
    headerStyle.bold = true;
    headerStyle.fontSize = 12;
    headerStyle.fontColor = '#2196F3';

    final Style dataStyle = workbook.styles.add('EngDataStyle');
    dataStyle.fontSize = 11;

    // Headers with styling
    sheet.getRangeByName('A1:B1').cellStyle = headerStyle;
    sheet.getRangeByName('A1').setText('Metric');
    sheet.getRangeByName('B1').setText('Value');

    // Data with formatting
    final data = getCourseEngagementData();
    for (var i = 0; i < data.length; i++) {
      final row = i + 2;
      sheet.getRangeByName('A$row').setText(data[i]['metric']);
      sheet.getRangeByName('A$row').cellStyle = dataStyle;

      final valueCell = sheet.getRangeByName('B$row');
      final value = data[i]['value'] as String;

      if (value.endsWith('%')) {
        final numericValue = double.parse(value.replaceAll('%', ''));
        valueCell.setNumber(numericValue);
        valueCell.numberFormat = '0"%"';
      } else {
        valueCell.setText(value);
      }
      valueCell.cellStyle = dataStyle;
    }

    // Auto-fit columns
    sheet.autoFitColumn(1);
    sheet.autoFitColumn(2);

    // Create charts collection
    final ChartCollection charts = ChartCollection(sheet);

    // Create bar chart for percentage metrics
    final Chart percentageChart = charts.add();
    percentageChart.chartType = ExcelChartType.bar;

    // Filter rows with percentage values
    List<int> percentageRows = [];
    for (var i = 0; i < data.length; i++) {
      if (data[i]['value'].toString().endsWith('%')) {
        percentageRows.add(i + 2);
      }
    }

    if (percentageRows.isNotEmpty) {
      // Create range for percentage metrics
      final range = sheet.getRangeByName('A1:B${data.length + 1}');
      percentageChart.dataRange = range;

      // Configure chart
      percentageChart.hasLegend = true;
      percentageChart.legend!.position = ExcelLegendPosition.bottom;
      percentageChart.hasTitle = true;
      percentageChart.chartTitle = 'Engagement Metrics';

      // Enhanced styling
      percentageChart.primaryCategoryAxis.title = 'Metrics';
      percentageChart.primaryValueAxis.title = 'Percentage';
      percentageChart.primaryValueAxis.minimumValue = 0;
      percentageChart.primaryValueAxis.maximumValue = 100;
      percentageChart.primaryValueAxis.hasMajorGridLines = true;

      // Position the chart
      percentageChart.topRow = 1;
      percentageChart.bottomRow = 15;
      percentageChart.leftColumn = 4;
      percentageChart.rightColumn = 10;
    }

    // Create doughnut chart for session time
    final Chart timeChart = charts.add();
    timeChart.chartType = ExcelChartType.doughnut;

    // Find the session time metric
    int sessionTimeRow = 0;
    for (var i = 0; i < data.length; i++) {
      if (data[i]['metric'].toString().contains('Session Time')) {
        sessionTimeRow = i + 2;
        break;
      }
    }

    timeChart.dataRange =
        sheet.getRangeByName('A$sessionTimeRow:B$sessionTimeRow');
    timeChart.hasLegend = true;
    timeChart.legend!.position = ExcelLegendPosition.right;
    timeChart.hasTitle = true;
    timeChart.chartTitle = 'Average Session Duration';

    // Position the time chart
    timeChart.topRow = 16;
    timeChart.bottomRow = 30;
    timeChart.leftColumn = 4;
    timeChart.rightColumn = 10;

    // Add charts to worksheet
    sheet.charts = charts;
  }
}
