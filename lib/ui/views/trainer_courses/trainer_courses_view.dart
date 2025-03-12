// lib/views/trainer_courses_view.dart
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/courses_list_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/filterable_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'trainer_courses_viewmodel.dart';

class TrainerCoursesView extends StackedView<TrainerCoursesViewModel> {
  const TrainerCoursesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    TrainerCoursesViewModel viewModel,
    Widget? child,
  ) {
    // Calculate screen size adaptable values
    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width < 600
        ? 2
        : size.width < 900
            ? 3
            : 4;
    final aspectRatio = size.width < 600 ? 0.73 : 0.75;
    final padding = size.width < 600 ? 0.1 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Courses',
        showSearchButton: true,
        showNotificationButton: true,
        onSearchTap: (query) => viewModel.onSearchChanged(query),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding.toDouble()),
          child: FilterableGridView(
            viewModel: viewModel,
            itemCount: viewModel.courses.length,
            itemBuilder: (context, index) {
              final course = viewModel.courses[index];
              return CoursesListItem(
                course: course,
                onTap: () => viewModel.navigateToCourseDetails(course),
                imageService: viewModel.imageService,
                showStatus: true,
                showControls: true,
                tags: viewModel.getCourseTags(course.id),
                onEditTap: () =>
                    viewModel.showEditCourseDialog(context, course),
                onToggleTap: () => viewModel.toggleCourseStatus(course),
              );
            },
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            mainAxisSpacing: padding.toDouble(),
            crossAxisSpacing: padding.toDouble(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => viewModel.showAddCourseDialog(context),
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  TrainerCoursesViewModel viewModelBuilder(context) => TrainerCoursesViewModel(
        courseService: locator<CourseService>(),
        imageService: locator<ImageService>(),
      );

  @override
  void onViewModelReady(TrainerCoursesViewModel viewModel) => viewModel.init();
}
