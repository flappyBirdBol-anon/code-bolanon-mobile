import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/course_list_progress.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Courses',
        showSearchButton: false,
        showNotificationButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            onPressed: () => viewModel.navigateToWishlist(),
          ),
        ],
        onSearchTap: () => (),
        onNotificationTap: () => (),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: viewModel.isBusy
                  ? const Center(child: CircularProgressIndicator())
                  : _buildLearnerCourses(viewModel, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnerCourses(
      LearnerCoursesViewModel viewModel, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildFilterChips(viewModel),
        Expanded(
          child: viewModel.filteredCourses.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = viewModel.filteredCourses[index];
                    return CourseListProgress(
                      title: course.title,
                      imageUrl: course.thumbnail,
                      registrationDate: viewModel.formatDate(course.createdAt),
                      progress: viewModel.computeProgress(course),
                      isDark: isDark,
                      onTap: () => (),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(LearnerCoursesViewModel viewModel) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.availableFilters.length,
        itemBuilder: (context, index) {
          final filter = viewModel.availableFilters[index];
          final isSelected = viewModel.selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => viewModel.setFilter(filter),
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.indigo[100],
              checkmarkColor: Colors.indigo,
              labelStyle: TextStyle(
                color: isSelected ? Colors.indigo : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No courses found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  LearnerCoursesViewModel viewModelBuilder(BuildContext context) {
    final imageService = locator<ImageService>();
    final courseService = CourseService();

    return LearnerCoursesViewModel(
      courseService: courseService,
      imageService: imageService,
    )..init(); // Initialize
  }
}
