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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: const Text('Learner Course List'),
          ),
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
