import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
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
        child: Builder(
          builder: (context) {
            // Add detailed debug prints
            debugPrint('View State - isBusy: ${viewModel.isBusy}');
            debugPrint('View State - hasError: ${viewModel.hasError}');
            debugPrint('View State - courses: ${viewModel.courses}');

            if (viewModel.isBusy) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.hasError) {
              return Center(
                child: Text(
                  'Error loading courses: ${viewModel.modelError}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (viewModel.courses.isEmpty) {
              debugPrint(
                  'Courses list is empty. Check if data is being loaded properly.');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No courses found. Try enrolling in a course!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => viewModel.initialise(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: viewModel.courses.length,
                itemBuilder: (context, index) {
                  final course = viewModel.courses[index];
                  debugPrint('Building course at index $index: $course');

                  return CourseListProgress(
                    title: course.title ?? 'Untitled Course',
                    description:
                        course.description ?? 'No description available',
                    thumbnail: course.thumbnail ?? '',
                    thumbnailUrl: course.thumbnail ?? '',
                    progress: viewModel.computeProgress(course),
                    rating: course.rating ?? 0.0,
                    reviews: course.reviews ?? 0,
                    onTap: () => viewModel.navigateToCourseDetails(course),
                    imageService: viewModel.imageService,
                    tags: viewModel.getCourseTags(course),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  LearnerCoursesViewModel viewModelBuilder(context) => LearnerCoursesViewModel(
        registrationService: locator<RegistrationService>(),
        courseService: locator<CourseService>(),
        imageService: locator<ImageService>(),
      );
}
