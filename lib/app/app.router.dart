// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:code_bolanon/models/course_model.dart' as _i18;
import 'package:code_bolanon/models/lessons_model.dart' as _i19;
import 'package:code_bolanon/ui/views/add_lesson/add_lesson_view.dart' as _i12;
import 'package:code_bolanon/ui/views/auth/auth_view.dart' as _i5;
import 'package:code_bolanon/ui/views/available_courses/available_courses_view.dart'
    as _i13;
import 'package:code_bolanon/ui/views/course_details/course_details_view.dart'
    as _i11;
import 'package:code_bolanon/ui/views/home/home_view.dart' as _i2;
import 'package:code_bolanon/ui/views/learner_courses/learner_courses_view.dart'
    as _i16;
import 'package:code_bolanon/ui/views/learner_home/learner_home_view.dart'
    as _i9;
import 'package:code_bolanon/ui/views/lesson_details/lesson_details_view.dart'
    as _i14;
import 'package:code_bolanon/ui/views/lessons_full/lessons_full_view.dart'
    as _i15;
import 'package:code_bolanon/ui/views/main_body/main_body_view.dart' as _i6;
import 'package:code_bolanon/ui/views/menu/menu_view.dart' as _i8;
import 'package:code_bolanon/ui/views/onboarding/onboarding_view.dart' as _i4;
import 'package:code_bolanon/ui/views/profile/profile_view.dart' as _i7;
import 'package:code_bolanon/ui/views/startup/startup_view.dart' as _i3;
import 'package:code_bolanon/ui/views/trainer_courses/trainer_courses_view.dart'
    as _i10;
import 'package:flutter/material.dart' as _i17;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i20;

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

  static const addLessonView = '/add-lesson-view';

  static const availableCoursesView = '/available-courses-view';

  static const lessonDetailsView = '/lesson-details-view';

  static const lessonsFullView = '/lessons-full-view';

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
    addLessonView,
    availableCoursesView,
    lessonDetailsView,
    lessonsFullView,
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
      Routes.addLessonView,
      page: _i12.AddLessonView,
    ),
    _i1.RouteDef(
      Routes.availableCoursesView,
      page: _i13.AvailableCoursesView,
    ),
    _i1.RouteDef(
      Routes.lessonDetailsView,
      page: _i14.LessonDetailsView,
    ),
    _i1.RouteDef(
      Routes.lessonsFullView,
      page: _i15.LessonsFullView,
    ),
    _i1.RouteDef(
      Routes.learnerCoursesView,
      page: _i16.LearnerCoursesView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },
    _i4.OnboardingView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.OnboardingView(),
        settings: data,
      );
    },
    _i5.AuthView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i5.AuthView(),
        settings: data,
      );
    },
    _i6.MainBodyView: (data) {
      final args = data.getArgs<MainBodyViewArguments>(
        orElse: () => const MainBodyViewArguments(),
      );
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => _i6.MainBodyView(key: args.key, role: args.role),
        settings: data,
      );
    },
    _i7.ProfileView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.ProfileView(),
        settings: data,
      );
    },
    _i8.MenuView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.MenuView(),
        settings: data,
      );
    },
    _i9.LearnerHomeView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.LearnerHomeView(),
        settings: data,
      );
    },
    _i10.TrainerCoursesView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.TrainerCoursesView(),
        settings: data,
      );
    },
    _i11.CourseDetailsView: (data) {
      final args = data.getArgs<CourseDetailsViewArguments>(
        orElse: () => const CourseDetailsViewArguments(),
      );
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i11.CourseDetailsView(key: args.key, course: args.course),
        settings: data,
      );
    },
    _i12.AddLessonView: (data) {
      final args = data.getArgs<AddLessonViewArguments>(
        orElse: () => const AddLessonViewArguments(),
      );
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i12.AddLessonView(key: args.key, course: args.course),
        settings: data,
      );
    },
    _i13.AvailableCoursesView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i13.AvailableCoursesView(),
        settings: data,
      );
    },
    _i14.LessonDetailsView: (data) {
      final args = data.getArgs<LessonDetailsViewArguments>(
        orElse: () => const LessonDetailsViewArguments(),
      );
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i14.LessonDetailsView(key: args.key, lesson: args.lesson),
        settings: data,
      );
    },
    _i15.LessonsFullView: (data) {
      final args = data.getArgs<LessonsFullViewArguments>(
        orElse: () => const LessonsFullViewArguments(),
      );
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i15.LessonsFullView(key: args.key, courseId: args.courseId),
        settings: data,
      );
    },
    _i16.LearnerCoursesView: (data) {
      return _i17.MaterialPageRoute<dynamic>(
        builder: (context) => const _i16.LearnerCoursesView(),
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

  final _i17.Key? key;

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

class CourseDetailsViewArguments {
  const CourseDetailsViewArguments({
    this.key,
    this.course,
  });

  final _i17.Key? key;

  final _i18.CourseModel? course;

  @override
  String toString() {
    return '{"key": "$key", "course": "$course"}';
  }

  @override
  bool operator ==(covariant CourseDetailsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.course == course;
  }

  @override
  int get hashCode {
    return key.hashCode ^ course.hashCode;
  }
}

class AddLessonViewArguments {
  const AddLessonViewArguments({
    this.key,
    this.course,
  });

  final _i17.Key? key;

  final _i18.CourseModel? course;

  @override
  String toString() {
    return '{"key": "$key", "course": "$course"}';
  }

  @override
  bool operator ==(covariant AddLessonViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.course == course;
  }

  @override
  int get hashCode {
    return key.hashCode ^ course.hashCode;
  }
}

class LessonDetailsViewArguments {
  const LessonDetailsViewArguments({
    this.key,
    this.lesson,
  });

  final _i17.Key? key;

  final _i19.Lesson? lesson;

  @override
  String toString() {
    return '{"key": "$key", "lesson": "$lesson"}';
  }

  @override
  bool operator ==(covariant LessonDetailsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.lesson == lesson;
  }

  @override
  int get hashCode {
    return key.hashCode ^ lesson.hashCode;
  }
}

class LessonsFullViewArguments {
  const LessonsFullViewArguments({
    this.key,
    this.courseId,
  });

  final _i17.Key? key;

  final int? courseId;

  @override
  String toString() {
    return '{"key": "$key", "courseId": "$courseId"}';
  }

  @override
  bool operator ==(covariant LessonsFullViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.courseId == courseId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ courseId.hashCode;
  }
}

extension NavigatorStateExtension on _i20.NavigationService {
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
    _i17.Key? key,
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

  Future<dynamic> navigateToCourseDetailsView({
    _i17.Key? key,
    _i18.CourseModel? course,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.courseDetailsView,
        arguments: CourseDetailsViewArguments(key: key, course: course),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAddLessonView({
    _i17.Key? key,
    _i18.CourseModel? course,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.addLessonView,
        arguments: AddLessonViewArguments(key: key, course: course),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAvailableCoursesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.availableCoursesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLessonDetailsView({
    _i17.Key? key,
    _i19.Lesson? lesson,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.lessonDetailsView,
        arguments: LessonDetailsViewArguments(key: key, lesson: lesson),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLessonsFullView({
    _i17.Key? key,
    int? courseId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.lessonsFullView,
        arguments: LessonsFullViewArguments(key: key, courseId: courseId),
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
    _i17.Key? key,
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

  Future<dynamic> replaceWithCourseDetailsView({
    _i17.Key? key,
    _i18.CourseModel? course,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.courseDetailsView,
        arguments: CourseDetailsViewArguments(key: key, course: course),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAddLessonView({
    _i17.Key? key,
    _i18.CourseModel? course,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.addLessonView,
        arguments: AddLessonViewArguments(key: key, course: course),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAvailableCoursesView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.availableCoursesView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLessonDetailsView({
    _i17.Key? key,
    _i19.Lesson? lesson,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.lessonDetailsView,
        arguments: LessonDetailsViewArguments(key: key, lesson: lesson),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLessonsFullView({
    _i17.Key? key,
    int? courseId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.lessonsFullView,
        arguments: LessonsFullViewArguments(key: key, courseId: courseId),
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
