// lib/views/trainer_courses_view.dart
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/courses_list_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/views/trainer_courses/trainer_courses_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class TrainerCoursesView extends StackedView<TrainerCoursesViewModel> {
  const TrainerCoursesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    TrainerCoursesViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Courses',
        showSearchButton: true,
        showNotificationButton: true,
        onSearchTap: () => (),
        onNotificationTap: () => (),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(viewModel),
            Expanded(
              child: viewModel.isBusy
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCourseGrid(viewModel),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => viewModel.showAddCourseDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters(TrainerCoursesViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', viewModel),
            _filterChip('Active', viewModel),
            _filterChip('Inactive', viewModel),
            _filterChip('Archived', viewModel),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, TrainerCoursesViewModel viewModel) {
    final isSelected = viewModel.selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (bool selected) => viewModel.setFilter(label),
        backgroundColor: AppColors.cardBackground,
        selectedColor: AppColors.secondary,
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildCourseGrid(TrainerCoursesViewModel viewModel) {
    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth;
      final int crossAxisCount = width > 600 ? 3 : 2;
      final double aspectRatio =
          width > 600 ? 0.9 : 0.75; // Increased aspect ratio

      if (viewModel.courses.isEmpty) {
        return const Center(
          child: Text(
            'No courses found',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(12), // Reduced padding
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12, // Reduced spacing
          mainAxisSpacing: 12, // Reduced spacing
          childAspectRatio: aspectRatio,
        ),
        itemCount: viewModel.courses.length,
        itemBuilder: (context, index) {
          final course = viewModel.courses[index];
          return CoursesListItem(
            course: course,
            onEdit: () => viewModel.showEditCourseDialog(context, course),
            onToggleStatus: () => viewModel.toggleCourseStatus(course.id),
            viewModel: viewModel,
            showStatus: true,
            showControls: true,
          );
        },
      );
    });
  }

  @override
  TrainerCoursesViewModel viewModelBuilder(BuildContext context) {
    // Create and inject dependencies
    // In a real app, you would use a proper DI framework
    final apiService = locator<ApiService>();
    final imageService = locator<ImageService>();
    final courseService = CourseService(apiService, imageService);

    return TrainerCoursesViewModel(
      courseService: courseService,
      imageService: imageService,
    );
  }

  @override
  void onViewModelReady(TrainerCoursesViewModel viewModel) => viewModel.init();
}
