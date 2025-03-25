import 'package:flutter/material.dart';

class FullscreenDialog extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;

  const FullscreenDialog({
    super.key,
    required this.child,
    this.backgroundColor,
    this.insetAnimationDuration = Duration.zero,
    this.insetAnimationCurve = Curves.decelerate,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: backgroundColor,
      insetAnimationDuration: insetAnimationDuration,
      insetAnimationCurve: insetAnimationCurve,
      child: child,
    );
  }
}

Future<T?> showFullscreenDialog<T>({
  required BuildContext context,
  required Widget child,
  Color? backgroundColor,
  Duration insetAnimationDuration = Duration.zero,
  Curve insetAnimationCurve = Curves.decelerate,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return showDialog<T>(
    context: context,
    builder: (BuildContext context) => FullscreenDialog(
      backgroundColor: backgroundColor,
      insetAnimationDuration: insetAnimationDuration,
      insetAnimationCurve: insetAnimationCurve,
      child: child,
    ),
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}
