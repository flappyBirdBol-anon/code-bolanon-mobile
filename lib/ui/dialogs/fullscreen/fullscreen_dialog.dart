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
    return Scaffold(
      backgroundColor: request.data?['backgroundColor'] ?? Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => completer(DialogResponse(confirmed: true)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              viewModel.isLandscape
                  ? Icons.screen_lock_portrait
                  : Icons.screen_lock_landscape,
              color: Colors.white,
            ),
            onPressed: () {
              if (viewModel.isLandscape) {
                viewModel.setPortrait();
              } else {
                viewModel.setLandscape();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1200, // Maximum width for very large screens
            ),
            child: request.data?['child'] ?? const SizedBox(),
          ),
        ),
      ),
    );
  }

  @override
  FullscreenDialogModel viewModelBuilder(BuildContext context) =>
      FullscreenDialogModel();
}
