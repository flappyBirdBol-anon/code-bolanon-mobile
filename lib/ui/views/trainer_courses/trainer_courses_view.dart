// lib/views/trainer_courses_view.dart
import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/course_dialog.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(viewModel),
            _buildFilters(viewModel),
            Expanded(
              child: _buildCourseGrid(viewModel),
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

  Widget _buildHeader(TrainerCoursesViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Courses',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
                color: AppColors.primary,
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
                color: AppColors.primary,
              ),
            ],
          ),
        ],
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
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 14,
        childAspectRatio: 0.64,
      ),
      itemCount: viewModel.courses.length,
      itemBuilder: (context, index) {
        final course = viewModel.courses[index];
        return _CourseCard(
          course: course,
          onEdit: () => viewModel.editCourse(course.id),
          onToggleStatus: () => viewModel.toggleCourseStatus(course.id),
          viewModel: viewModel,
        );
      },
    );
  }

  @override
  TrainerCoursesViewModel viewModelBuilder(BuildContext context) =>
      TrainerCoursesViewModel();

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
        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      course.thumbnail,
                      height: constraints.maxHeight * 0.4,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
              Expanded(
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
                      Text(
                        course.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
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
                            onPressed: () => _showEditDialog(context),
                            color: AppColors.primary,
                          ),
                          const Spacer(),
                          Switch(
                            value: course.isActive,
                            onChanged: (_) => onToggleStatus(),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CourseDialog(
        title: 'Edit Course',
        initialCourseName: course.title,
        initialDescription: course.description,
        initialPrice: course.price.toDouble(),
        onSave: (title, description, price, image) {
          onEdit();
          viewModel.editCourse(
            course.id,
            title: title,
            description: description,
            price: price,
            newImage: image,
          );
        },
      ),
    );
  }
}
