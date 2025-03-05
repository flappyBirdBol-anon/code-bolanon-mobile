// lib/views/trainer_courses_view.dart
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
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
      // Calculate responsive grid parameters based on screen size
      final double width = constraints.maxWidth;
      final int crossAxisCount = width > 600 ? 3 : 2;
      final double aspectRatio = width > 600 ? 0.75 : 0.64;

      if (viewModel.courses.isEmpty) {
        return const Center(
          child: Text(
            'No courses found',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 14,
          childAspectRatio: aspectRatio,
        ),
        itemCount: viewModel.courses.length,
        itemBuilder: (context, index) {
          final course = viewModel.courses[index];
          return _CourseCard(
            course: course,
            onEdit: () => viewModel.showEditCourseDialog(context, course),
            onToggleStatus: () => viewModel.toggleCourseStatus(course.id),
            viewModel: viewModel,
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

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final TrainerCoursesViewModel viewModel;

  const _CourseCard({
    required this.course,
    required this.onEdit,
    required this.onToggleStatus,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: () => viewModel.navigateToCourseDetails(context, course),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildCourseImage(),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: course.isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: Text(
                            course.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.studentsEnrolled} Students',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$${course.price}.00',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: onEdit,
                              color: AppColors.primary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const Spacer(),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: course.isActive,
                                onChanged: (_) => onToggleStatus(),
                                activeColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Use the ImageService to load and display the course image
  Widget _buildCourseImage() {
    return viewModel.getCourseImageWidget(
      course: course,
      fit: BoxFit.cover,
      placeholder: Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
