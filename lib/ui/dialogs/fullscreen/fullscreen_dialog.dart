import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'fullscreen_dialog_model.dart';

class FullscreenDialogWrapper extends StackedView<FullscreenDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const FullscreenDialogWrapper({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    FullscreenDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog.fullscreen(
      backgroundColor: request.data?['backgroundColor'],
      insetAnimationDuration:
          request.data?['insetAnimationDuration'] ?? Duration.zero,
      insetAnimationCurve:
          request.data?['insetAnimationCurve'] ?? Curves.decelerate,
      child: request.data?['child'] ?? const SizedBox(),
    );
  }

  @override
  FullscreenDialogModel viewModelBuilder(BuildContext context) =>
      FullscreenDialogModel();
}
