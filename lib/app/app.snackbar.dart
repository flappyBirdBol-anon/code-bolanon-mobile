import 'package:code_bolanon/app/app.locator.dart';

import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../ui/common/enums/enums.dart';

void setupSnackbarUi() {
  final service = locator<SnackbarService>();

  try {
    service.registerCustomSnackbarConfig(
      variant: 'info',
      configBuilder: () {
        return SnackbarConfig(messageColor: Colors.white);
      },
    );

    service.registerCustomSnackbarConfig(
      variant: SnackbarType.error,
      configBuilder: () {
        Color backgroundColor = const Color.fromARGB(255, 253, 0, 0);
        Color textColor = Colors.white;
        Widget icon = const Icon(Icons.info_outline, color: Colors.white);

        return SnackbarConfig(
          backgroundColor: backgroundColor,
          textColor: textColor,
          borderRadius: 8,
          dismissDirection: DismissDirection.horizontal,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.all(16),
          icon: icon,
        );
      },
    );
  } catch (e) {
    print(e);
  }

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.info,
    configBuilder: () {
      Color backgroundColor = const Color.fromARGB(255, 20, 0, 245);
      Color textColor = Colors.white;
      Widget icon = const Icon(Icons.error_outline, color: Colors.white);

      return SnackbarConfig(
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: 8,
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.all(16),
        icon: icon,
      );
    },
  );

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.success,
    configBuilder: () {
      Color backgroundColor = Colors.green;
      Color textColor = Colors.white;
      Widget icon = const Icon(Icons.check_circle_outline, color: Colors.white);

      return SnackbarConfig(
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderRadius: 8,
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.all(16),
        icon: icon,
      );
    },
  );
}
