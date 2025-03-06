import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/courses_list_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'available_courses_viewmodel.dart';

class AvailableCoursesView extends StackedView<AvailableCoursesViewModel> {
  const AvailableCoursesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AvailableCoursesViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Available Courses',
        showSearchButton: true,
        showNotificationButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context, viewModel),
          ),
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: viewModel.navigateToMyCourses,
          ),
        ],
        onSearchTap: () => (),
        onNotificationTap: () => (),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (viewModel.activeFilters.isNotEmpty)
              _buildActiveFilters(viewModel),
            Expanded(
              child: viewModel.isBusy
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCourseGrid(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters(AvailableCoursesViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: viewModel.activeFilters.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(filter),
                onDeleted: () => viewModel.removeFilter(filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCourseGrid(AvailableCoursesViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async => viewModel.refreshCourses(),
      child: LayoutBuilder(builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 600 ? 3 : 2;
        final double aspectRatio = width > 600 ? 0.9 : 0.9;

        if (viewModel.filteredCourses.isEmpty) {
          return const Center(
            child: Text(
              'No courses found',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: viewModel.filteredCourses.length,
          itemBuilder: (context, index) {
            final course = viewModel.filteredCourses[index];
            return CoursesListItem(
              course: course,
              viewModel: viewModel,
              showControls: false, // Hide controls for learners
              showStatus: false, // Add this to hide status badge
            );
          },
        );
      }),
    );
  }

  void _showFilterOptions(
      BuildContext context, AvailableCoursesViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Courses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: viewModel.availableFilters.map((filter) {
                return FilterChip(
                  label: Text(filter),
                  selected: viewModel.activeFilters.contains(filter),
                  onSelected: (selected) => viewModel.toggleFilter(filter),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  AvailableCoursesViewModel viewModelBuilder(BuildContext context) {
    final imageService = locator<ImageService>();
    final courseService = CourseService();

    return AvailableCoursesViewModel(
      courseService: courseService,
      imageService: imageService,
    )..init(); // Initialize immediately
  }
}
