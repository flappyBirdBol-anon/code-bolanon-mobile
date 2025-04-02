import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'learner_book_appointment_viewmodel.dart';

class LearnerBookAppointmentView
    extends StackedView<LearnerBookAppointmentViewModel> {
  const LearnerBookAppointmentView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerBookAppointmentViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Book an Appointment',
        showNotificationButton: false,
        showSearchButton: false,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(
          child: Text('Book an appointment page'),
        ),
      ),
    );
  }

  @override
  LearnerBookAppointmentViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LearnerBookAppointmentViewModel();
}
