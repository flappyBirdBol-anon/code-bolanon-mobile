import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'appointment_details_viewmodel.dart';

class AppointmentDetailsView extends StackedView<AppointmentDetailsViewModel> {
  const AppointmentDetailsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AppointmentDetailsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      ),
    );
  }

  @override
  AppointmentDetailsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AppointmentDetailsViewModel();
}
