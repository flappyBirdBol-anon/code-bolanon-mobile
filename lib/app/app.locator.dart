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

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../services/image_service.dart';
import '../services/theme_service.dart';
import 'package:dio/dio.dart';

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
  locator.registerLazySingleton(() => AuthService(locator<ApiService>()));
  locator.registerLazySingleton(() => ThemeService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => CourseService(
        locator<ApiService>(),
        locator<ImageService>(),
      ));
  locator.registerLazySingleton(() => ImageService(
        baseUrl: 'http://143.198.197.240/api',
        apiService: locator<ApiService>(),
        enableCache: true,
        cacheDuration: const Duration(hours: 12),
        dioo: locator<ApiService>().dio,
        // Access the Dio instance from ApiService
      ));
}
