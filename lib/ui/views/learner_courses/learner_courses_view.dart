import 'package:code_bolanon/ui/common/app_colors.dart';
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
            icon: const Icon(Icons.bookmark_rounded),
            onPressed: () => (),
          ),
        ],
        onSearchTap: () => (),
        onNotificationTap: () => (),
      ),
      body: const SafeArea(
        child: Column(
          children: [],
        ),
      ),
    );
  }

  @override
  LearnerCoursesViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LearnerCoursesViewModel();
}
