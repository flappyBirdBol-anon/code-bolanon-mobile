import 'package:code_bolanon/app/app.locator.dart';

import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../ui/common/enums/enums.dart';

void setupSnackbarUi() {
  print('setupSnackbarUi() called'); // Add this line
  final service = locator<SnackbarService>();

  try {
    service.registerCustomSnackbarConfig(
      variant: 'info',
      configBuilder: () {
        print('configBuilder for SnackbarType.info is being executed!');

        return SnackbarConfig(messageColor: Colors.white); // Minimal config
      },
    );

    // Using configBuilder approach for all snackbar types
    print('Registering SnackbarType.info with variant: ${SnackbarType.info}');
    service.registerCustomSnackbarConfig(
      variant: SnackbarType.error,
      configBuilder: () {
        // Default values
        print('Registering SnackbarType.info config');
        try {
          Color backgroundColor;
          Color textColor = Colors.white;
          Widget icon;
          backgroundColor = const Color.fromARGB(255, 253, 0, 0);
          icon = const Icon(Icons.info_outline, color: Colors.white);

          return SnackbarConfig(
            backgroundColor: backgroundColor,
            textColor: textColor,
            borderRadius: 8,
            dismissDirection: DismissDirection.horizontal,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.all(16),
            icon: icon,
          );
        } catch (e) {
          print(e);
          rethrow;
        }
      },
    );
  } catch (e) {
    print(e);
  }

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.info,
    configBuilder: () {
      // Default values
      Color backgroundColor;
      Color textColor = Colors.white;
      Widget icon;
      backgroundColor = const Color.fromARGB(255, 20, 0, 245);
      icon = const Icon(Icons.error_outline, color: Colors.white);
      print('Registering SnackbarType.info config');
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
      // Default values
      Color backgroundColor;
      Color textColor = Colors.white;
      Widget icon;
      backgroundColor = Colors.green;
      icon = const Icon(Icons.check_circle_outline, color: Colors.white);
      print('Registering SnackbarType.info config');
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
