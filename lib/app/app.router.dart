// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:code_bolanon/ui/views/auth/auth_view.dart' as _i5;
import 'package:code_bolanon/ui/views/course_details/course_details_view.dart'
    as _i11;
import 'package:code_bolanon/ui/views/home/home_view.dart' as _i2;
import 'package:code_bolanon/ui/views/learner_courses/learner_courses_view.dart'
    as _i12;
import 'package:code_bolanon/ui/views/learner_home/learner_home_view.dart'
    as _i9;
import 'package:code_bolanon/ui/views/main_body/main_body_view.dart' as _i6;
import 'package:code_bolanon/ui/views/menu/menu_view.dart' as _i8;
import 'package:code_bolanon/ui/views/onboarding/onboarding_view.dart' as _i4;
import 'package:code_bolanon/ui/views/profile/profile_view.dart' as _i7;
import 'package:code_bolanon/ui/views/startup/startup_view.dart' as _i3;
import 'package:code_bolanon/ui/views/trainer_courses/trainer_courses_view.dart'
    as _i10;
import 'package:flutter/material.dart' as _i13;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i14;

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/startup-view';

  static const onboardingView = '/onboarding-view';

  static const authView = '/auth-view';

  static const mainBodyView = '/main-body-view';

  static const profileView = '/profile-view';

  static const menuView = '/menu-view';

  static const learnerHomeView = '/learner-home-view';

  static const trainerCoursesView = '/trainer-courses-view';

  static const courseDetailsView = '/course-details-view';

  static const learnerCoursesView = '/learner-courses-view';

  static const all = <String>{
    homeView,
    startupView,
    onboardingView,
    authView,
    mainBodyView,
    profileView,
    menuView,
    learnerHomeView,
    trainerCoursesView,
    courseDetailsView,
    learnerCoursesView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.homeView,
      page: _i2.HomeView,
    ),
    _i1.RouteDef(
      Routes.startupView,
      page: _i3.StartupView,
    ),
    _i1.RouteDef(
      Routes.onboardingView,
      page: _i4.OnboardingView,
    ),
    _i1.RouteDef(
      Routes.authView,
      page: _i5.AuthView,
    ),
    _i1.RouteDef(
      Routes.mainBodyView,
      page: _i6.MainBodyView,
    ),
    _i1.RouteDef(
      Routes.profileView,
      page: _i7.ProfileView,
    ),
    _i1.RouteDef(
      Routes.menuView,
      page: _i8.MenuView,
    ),
    _i1.RouteDef(
      Routes.learnerHomeView,
      page: _i9.LearnerHomeView,
    ),
    _i1.RouteDef(
      Routes.trainerCoursesView,
      page: _i10.TrainerCoursesView,
    ),
    _i1.RouteDef(
      Routes.courseDetailsView,
      page: _i11.CourseDetailsView,
    ),
    _i1.RouteDef(
      Routes.learnerCoursesView,
      page: _i12.LearnerCoursesView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },
    _i4.OnboardingView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.OnboardingView(),
        settings: data,
      );
    },
    _i5.AuthView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i5.AuthView(),
        settings: data,
      );
    },
    _i6.MainBodyView: (data) {
      final args = data.getArgs<MainBodyViewArguments>(
        orElse: () => const MainBodyViewArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => _i6.MainBodyView(key: args.key, role: args.role),
        settings: data,
      );
    },
    _i7.ProfileView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.ProfileView(),
        settings: data,
      );
    },
    _i8.MenuView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.MenuView(),
        settings: data,
      );
    },
    _i9.LearnerHomeView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.LearnerHomeView(),
        settings: data,
      );
    },
    _i10.TrainerCoursesView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.TrainerCoursesView(),
        settings: data,
      );
    },
    _i11.CourseDetailsView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.CourseDetailsView(),
        settings: data,
      );
    },
    _i12.LearnerCoursesView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.LearnerCoursesView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class MainBodyViewArguments {
  const MainBodyViewArguments({
    this.key,
    this.role,
  });

  final _i13.Key? key;

  final String? role;

  @override
  String toString() {
    return '{"key": "$key", "role": "$role"}';
  }

  @override
  bool operator ==(covariant MainBodyViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.role == role;
  }

  @override
  int get hashCode {
    return key.hashCode ^ role.hashCode;
  }
}

extension NavigatorStateExtension on _i14.NavigationService {
  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToOnboardingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.onboardingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAuthView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.authView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMainBodyView({
    _i13.Key? key,
    String? role,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.mainBodyView,
        arguments: MainBodyViewArguments(key: key, role: role),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.profileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMenuView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.menuView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLearnerHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.learnerHomeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToTrainerCoursesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.trainerCoursesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCourseDetailsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.courseDetailsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLearnerCoursesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.learnerCoursesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithOnboardingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.onboardingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAuthView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.authView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMainBodyView({
    _i13.Key? key,
    String? role,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.mainBodyView,
        arguments: MainBodyViewArguments(key: key, role: role),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.profileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMenuView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.menuView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLearnerHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.learnerHomeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithTrainerCoursesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.trainerCoursesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCourseDetailsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.courseDetailsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLearnerCoursesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.learnerCoursesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
