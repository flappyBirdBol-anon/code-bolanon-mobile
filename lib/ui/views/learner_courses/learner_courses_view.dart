import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/course_list_progress.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/filterable_list_view.dart';
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
        showSearchButton: true,
        showNotificationButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            onPressed: viewModel.navigateToWishlist,
          ),
        ],
        onSearchTap: (query) => viewModel.onSearchChanged(query),
      ),
      body: SafeArea(
        child: FilterableListView(
          viewModel: viewModel,
          itemCount: viewModel.courses.length,
          itemBuilder: (context, index) {
            final course = viewModel.courses[index];
            return CourseListProgress(
              title: course.title,
              description: course.description,
              thumbnail: course.thumbnail,
              thumbnailUrl: course.thumbnail,
              progress: viewModel.computeProgress(course),
              rating: course.rating,
              reviews: course.reviews,
              onTap: () => viewModel.navigateToCourseDetails(course),
              imageService: viewModel.imageService,
              tags: viewModel.getCourseTags(course.id),
            );
          },
        ),
      ),
    );
  }

  @override
  LearnerCoursesViewModel viewModelBuilder(context) => LearnerCoursesViewModel(
        courseService: locator<CourseService>(),
        imageService: locator<ImageService>(),
      );
}
