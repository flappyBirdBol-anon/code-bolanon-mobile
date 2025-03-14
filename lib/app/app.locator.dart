// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_services/src/snackbar/snackbar_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../services/analytics_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../services/file_service.dart';
import '../services/forgot_password_service.dart';
import '../services/image_service.dart';
import '../services/lesson_service.dart';
import '../services/payment_service.dart';
import '../services/registration_service.dart';
import '../services/stripe_service.dart';
import '../services/tag_service.dart';
import '../services/tech_stack_service.dart';
import '../services/theme_service.dart';
import '../services/user_service.dart';
import '../services/wishlist_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => ThemeService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => CourseService());
  locator.registerLazySingleton(() => ImageService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => LessonsService());
  locator.registerLazySingleton(() => FileService());
  locator.registerLazySingleton(() => TagService());
  locator.registerLazySingleton(() => PaymentService());
  locator.registerLazySingleton(() => StripeService());
  locator.registerLazySingleton(() => ForgotPasswordService());
  locator.registerLazySingleton(() => TechStackService());
  locator.registerLazySingleton(() => AnalyticsService());
}
