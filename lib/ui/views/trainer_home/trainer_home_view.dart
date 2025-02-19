import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'trainer_home_viewmodel.dart';

class TrainerHomeView extends StackedView<TrainerHomeViewModel> {
  final String? role;
  const TrainerHomeView({Key? key, this.role}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    TrainerHomeViewModel viewModel,
    Widget? child,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        color: const Color.fromARGB(255, 106, 105, 105),
        child: Text(
          role!,
          style: const TextStyle(
              color: Color.fromARGB(255, 179, 3, 3),
              fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  @override
  TrainerHomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      TrainerHomeViewModel();
}
