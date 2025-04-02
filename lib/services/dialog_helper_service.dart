import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart';

class DialogHelperService {
  final DialogService _dialogService = locator<DialogService>();

  Future<DialogResponse?> showFullscreenDialog({
    required Widget child,
    Color? backgroundColor,
    Duration insetAnimationDuration = Duration.zero,
    Curve insetAnimationCurve = Curves.decelerate,
    bool barrierDismissible = true,
  }) {
    return _dialogService.showCustomDialog(
      // variant: DialogType.fullscreen,
      barrierDismissible: barrierDismissible,
      data: {
        'child': child,
        'backgroundColor': backgroundColor,
        'insetAnimationDuration': insetAnimationDuration,
        'insetAnimationCurve': insetAnimationCurve,
      },
    );
  }
}
