// lib/ui/common/helpers/dialog_helper.dart
import 'dart:ui';
import 'package:flutter/material.dart';

/// Shows a dialog with a full-screen blurred background
Future<T?> showGlassmorphicDialog<T>({
  required BuildContext context,
  required Widget dialog,
  double blurAmount = 8.0,
  Color barrierColor = Colors.black54,
}) {
  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (_, __, ___) => dialog,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent, // Transparent barrier for our custom blur
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuad,
      );

      return AnimatedBuilder(
        animation: curvedAnimation,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurAmount * curvedAnimation.value,
              sigmaY: blurAmount * curvedAnimation.value,
            ),
            child: Container(
              color: barrierColor.withOpacity(curvedAnimation.value * 0.5),
              child: child,
            ),
          );
        },
        child: child,
      );
    },
  );
}
