import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'learner_home_viewmodel.dart';

class LearnerHomeView extends StackedView<LearnerHomeViewModel> {
  const LearnerHomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerHomeViewModel viewModel,
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
  LearnerHomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LearnerHomeViewModel();
}
