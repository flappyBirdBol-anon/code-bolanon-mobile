import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:stacked/stacked.dart';

import 'learner_courses_viewmodel.dart';

class LearnerCoursesView extends StackedView<LearnerCoursesViewModel> {
  const LearnerCoursesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerCoursesViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => viewModel.refreshData(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressIndicators(viewModel),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicators(LearnerCoursesViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCircularProgress(
              title: 'Completed',
              value: viewModel.completedCoursesPercentage,
              color: Colors.green,
              count: viewModel.completedCourses,
              total: viewModel.totalEnrolledCourses,
            ),
            _buildCircularProgress(
              title: 'In Progress',
              value: viewModel.inProgressCoursesPercentage,
              color: Colors.orange,
              count: viewModel.inProgressCourses,
              total: viewModel.totalEnrolledCourses,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularProgress({
    required String title,
    required double value,
    required Color color,
    required int count,
    required int total,
  }) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 45.0,
          lineWidth: 10.0,
          percent: value,
          center: Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          progressColor: color,
          backgroundColor: const Color.fromARGB(255, 193, 190, 190),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1500,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$count of $total courses',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  LearnerCoursesViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LearnerCoursesViewModel();
}
