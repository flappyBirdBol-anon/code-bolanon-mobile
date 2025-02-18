import 'package:code_bolanon/app/app.bottomsheets.dart';
import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/db/supabase.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();

  final AuthService authService = locator<AuthService>();
  String initialRoute = Routes.onboardingView;

  try {
    final isLoggedIn = await authService.isLoggedIn();
    if (isLoggedIn) {
      initialRoute = Routes.mainBodyView;
    }
  } catch (e) {
    // Handle any errors that occur during the check
    print('An error occurred during startup: $e');
    // You might want to navigate to an error screen or show a dialog
  }

  runApp(MainApp(initialRoute: initialRoute));
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      initialRoute: initialRoute,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}
