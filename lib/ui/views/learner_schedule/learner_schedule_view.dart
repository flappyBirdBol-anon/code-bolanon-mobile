import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'learner_schedule_viewmodel.dart';

class LearnerScheduleView extends StackedView<LearnerScheduleViewModel> {
  const LearnerScheduleView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerScheduleViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      ),
    );
  }

  @override
  LearnerScheduleViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LearnerScheduleViewModel();
}
