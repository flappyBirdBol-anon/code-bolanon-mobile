import 'package:code_bolanon/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:code_bolanon/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:code_bolanon/ui/views/home/home_view.dart';
import 'package:code_bolanon/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:code_bolanon/ui/views/onboarding/onboarding_view.dart';
import 'package:code_bolanon/ui/views/auth/auth_view.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/theme_service.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/ui/views/main_body/main_body_view.dart';
import 'package:code_bolanon/ui/views/profile/profile_view.dart';
import 'package:code_bolanon/ui/views/menu/menu_view.dart';
import 'package:code_bolanon/ui/views/learner_home/learner_home_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: OnboardingView),
    MaterialRoute(page: AuthView),
    MaterialRoute(page: MainBodyView),
    MaterialRoute(page: ProfileView),
    MaterialRoute(page: MenuView),
    MaterialRoute(page: LearnerHomeView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: AuthService),
    LazySingleton(classType: ThemeService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: ApiService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
