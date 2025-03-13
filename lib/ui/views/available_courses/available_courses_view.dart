import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/courses_list_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/filterable_grid_view.dart';
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
      appBar: CustomAppBar(
        title: 'Available Courses',
        showSearchButton: true,
        showNotificationButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.book_rounded),
            onPressed: viewModel.navigateToMyCourses,
          ),
        ],
        onSearchTap: (query) => viewModel.onSearchChanged(query),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FilterableGridView(
          viewModel: viewModel,
          itemCount: viewModel.courses.length,
          itemBuilder: (context, index) {
            final course = viewModel.courses[index];
            return CoursesListItem(
              course: course,
              onTap: () => viewModel.navigateToCourseDetails(course),
              imageService: viewModel.imageService,
              tags: viewModel.getCourseTags(course.id),
              isRegistered: viewModel.isCourseRegistered(course.id),
            );
          },
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          childAspectRatio: 0.75,
        ),
      ),
    );
  }

  @override
  AvailableCoursesViewModel viewModelBuilder(context) =>
      AvailableCoursesViewModel(
        courseService: locator<CourseService>(),
        imageService: locator<ImageService>(),
      );
}
