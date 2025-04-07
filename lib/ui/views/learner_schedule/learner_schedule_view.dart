import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your Scheduled Appointments',
        showSearchButton: true,
        showNotificationButton: false,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: const SafeArea(
        child: CustomScrollView(),
      ),
    );
  }

  @override
  LearnerScheduleViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LearnerScheduleViewModel();
}
