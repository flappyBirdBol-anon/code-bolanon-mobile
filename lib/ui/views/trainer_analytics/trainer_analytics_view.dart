import 'package:cached_network_image/cached_network_image.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'trainer_analytics_viewmodel.dart';

class TrainerAnalyticsView extends StackedView<TrainerAnalyticsViewModel> {
  const TrainerAnalyticsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    TrainerAnalyticsViewModel viewModel,
    Widget? child,
  ) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      title: Text(
                        'Analytics & Reports',
                        style: GoogleFonts.figtree(fontWeight: FontWeight.bold),
                      ),
                      pinned: true,
                      floating: true,
                      forceElevated: innerBoxIsScrolled,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: _buildTrainerProfileCard(viewModel),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          tabAlignment: TabAlignment.start,
                          indicatorColor: AppColors.primary,
                          isScrollable: true,
                          labelStyle: GoogleFonts.figtree(),
                          labelColor: AppColors.primary,
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Course Performance'),
                            Tab(text: 'Revenue'),
                            // Tab(text: 'Demographics'),
                          ],
                          onTap: viewModel.changeTab,
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _buildOverviewTab(viewModel, context),
                    _buildCoursePerformanceTab(viewModel, context),
                    _buildRevenueTab(viewModel, context),
                    // _buildDemographicsTab(viewModel, context),
                  ],
                ),
              ),
        floatingActionButton: viewModel.isBusy || viewModel.isLoadingData
            ? null // Hide FAB while loading
            : FloatingActionButton.extended(
                onPressed: viewModel.generateReport,
                label: Row(
                  children: [
                    const Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      viewModel.selectedReportFormat,
                      style: GoogleFonts.figtree(color: Colors.white),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primary,
              ),
      ),
    );
  }

  Widget _buildOverviewTab(
      TrainerAnalyticsViewModel viewModel, BuildContext context) {
    if (viewModel.isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.enrollmentData.isEmpty) {
      return _buildNoDataAvailable();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed trainer profile card from here
          const SizedBox(height: 8),
          _buildDateRangeSelector(viewModel),
          const SizedBox(height: 24),
          _buildEnrollmentTrendsChart(viewModel),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrainerProfileCard(TrainerAnalyticsViewModel viewModel) {
    final user = viewModel.currentUser;
    if (user == null) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.person,
                    size: 30, color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading profile...',
                      style: GoogleFonts.figtree(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              // backgroundImage:
              //     user.profileImage != null && user.profileImage!.isNotEmpty
              //         ? CachedNetworkImageProvider(user.profileImage!)
              //         : null,
              child: ClipOval(
                child: user.profileImage!.isEmpty
                    ? Icon(Icons.person,
                        size: 30, color: Colors.white.withOpacity(0.7))
                    : viewModel.getProfileImageWidget(
                        fit: BoxFit.cover,
                        placeholder: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: GoogleFonts.figtree(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.specialization ?? 'Technology Trainer',
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: viewModel.trainerStacks.map((stack) {
                      return Chip(
                        label: Text(stack),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: GoogleFonts.figtree(
                          color: AppColors.primary,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursePerformanceTab(
      TrainerAnalyticsViewModel viewModel, BuildContext context) {
    if (viewModel.isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.coursePerformanceData.isEmpty) {
      return _buildNoDataAvailable();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.coursePerformanceData.length,
      itemBuilder: (context, index) {
        final course = viewModel.coursePerformanceData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['courseName'],
                  style: GoogleFonts.figtree(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMetricItem(
                      icon: Icons.star,
                      value: course['rating'].toString(),
                      label: 'Rating',
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 24),
                    _buildMetricItem(
                      icon: Icons.people,
                      value: course['learners'].toString(),
                      label: 'Learners',
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: course['completionRate'] / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    course['completionRate'] > 75
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completion Rate: ${course['completionRate']}%',
                  style: GoogleFonts.figtree(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueTab(
      TrainerAnalyticsViewModel viewModel, BuildContext context) {
    if (viewModel.isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    // Fallback if no revenue data available
    if (viewModel.revenue == null ||
        viewModel.monthlyRevenueData.isEmpty ||
        viewModel.revenueByCoursesData.isEmpty) {
      return _buildNoDataAvailable();
    }

    final revenue = viewModel.getRevenueSummary();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildRevenueCard(
                  'Total Revenue',
                  'P${viewModel.revenue}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRevenueCard(
                  'Monthly Growth',
                  '${revenue['monthlyGrowth']}%',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Trends',
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: const CategoryAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        labelRotation: 0,
                      ),
                      primaryYAxis: NumericAxis(
                        numberFormat: NumberFormat.currency(symbol: 'P'),
                        majorGridLines: const MajorGridLines(width: 0.5),
                      ),
                      legend: const Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        ColumnSeries<Map<String, dynamic>, String>(
                          dataSource: viewModel.monthlyRevenueData,
                          xValueMapper: (Map<String, dynamic> data, _) =>
                              data['month'].toString(),
                          yValueMapper: (Map<String, dynamic> data, _) =>
                              data['revenue'] as num,
                          name: 'Monthly Revenue',
                          color: Theme.of(context).primaryColor,
                        ),
                        LineSeries<Map<String, dynamic>, String>(
                          dataSource: viewModel.monthlyRevenueData,
                          xValueMapper: (Map<String, dynamic> data, _) =>
                              data['month'].toString(),
                          yValueMapper: (Map<String, dynamic> data, _) =>
                              data['trend'] as num,
                          name: 'Trend',
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue by Course',
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfCircularChart(
                      legend: const Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap,
                      ),
                      series: <CircularSeries>[
                        PieSeries<Map<String, dynamic>, String>(
                          dataSource: viewModel.revenueByCoursesData,
                          xValueMapper: (Map<String, dynamic> data, _) =>
                              data['courseName'].toString(),
                          yValueMapper: (Map<String, dynamic> data, _) =>
                              data['revenue'] as num,
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                          ),
                          enableTooltip: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsTab(
      TrainerAnalyticsViewModel viewModel, BuildContext context) {
    if (viewModel.isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    final demographics = viewModel.learnerDemographics;
    if (demographics.isEmpty ||
        demographics['ageGroups'] == null ||
        demographics['backgrounds'] == null) {
      return _buildNoDataAvailable();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDemographicSection(
            'Age Distribution',
            demographics['ageGroups'],
            viewModel.demographicsColors,
          ),
          const SizedBox(height: 24),
          _buildDemographicSection(
            'Educational Background',
            demographics['backgrounds'],
            viewModel.demographicsColors,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data is being processed or not yet available',
            style: GoogleFonts.figtree(
              color: Colors.grey[500],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(TrainerAnalyticsViewModel viewModel) {
    return Builder(
      builder: (context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.date_range),
              const SizedBox(width: 16),
              Text(
                'Date Range: ${viewModel.startDate?.toString().substring(0, 10)} - ${viewModel.endDate?.toString().substring(0, 10)}',
                style: GoogleFonts.figtree(fontSize: 16),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showDateRangePicker(context, viewModel),
                child: const Text('Change'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.figtree(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.figtree(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.figtree(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.figtree(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicSection(
    String title,
    List<dynamic> data,
    List<Color> colors,
  ) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No $title data available',
              style: GoogleFonts.figtree(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.figtree(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              data.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data[index]['group'] ??
                              data[index]['type'] ??
                              'Unknown',
                          style: GoogleFonts.figtree(),
                        ),
                        Text(
                          '${data[index]['percentage']}%',
                          style: GoogleFonts.figtree(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: data[index]['percentage'] / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.isNotEmpty
                            ? colors[index % colors.length]
                            : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateRangePicker(
      BuildContext context, TrainerAnalyticsViewModel viewModel) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: viewModel.startDate ??
            DateTime.now().subtract(const Duration(days: 30)),
        end: viewModel.endDate ?? DateTime.now(),
      ),
    );
    if (picked != null) {
      viewModel.setDateRange(picked.start, picked.end);
    }
  }

  Widget _buildEnrollmentTrendsChart(TrainerAnalyticsViewModel viewModel) {
    if (viewModel.enrollmentData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enrollment Trends',
                style: GoogleFonts.figtree(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: Center(
                  child: Text(
                    'No enrollment data available',
                    style: GoogleFonts.figtree(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enrollment Trends',
              style: GoogleFonts.figtree(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: viewModel.maxEnrollmentCount.toDouble(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = viewModel.enrollmentData[groupIndex];
                        return BarTooltipItem(
                          '${item['month']}: ${item['count']} enrollments',
                          GoogleFonts.figtree(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: GoogleFonts.figtree(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 ||
                              value >= viewModel.enrollmentData.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              viewModel.enrollmentData[value.toInt()]['month'],
                              style: GoogleFonts.figtree(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    ),
                  ),
                  barGroups: List.generate(
                    viewModel.enrollmentData.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (viewModel.enrollmentData[index]['count'] as int)
                              .toDouble(),
                          color: viewModel.enrollmentChartColors.isNotEmpty
                              ? viewModel.enrollmentChartColors[index %
                                  viewModel.enrollmentChartColors.length]
                              : Colors.blue,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Monthly Enrollment Growth',
                style: GoogleFonts.figtree(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  TrainerAnalyticsViewModel viewModelBuilder(BuildContext context) =>
      TrainerAnalyticsViewModel();
}

// Helper class to make TabBar compatible with SliverPersistentHeader
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
