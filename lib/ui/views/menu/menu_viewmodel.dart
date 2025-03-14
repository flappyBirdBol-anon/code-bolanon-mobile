import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/services/theme_service.dart';

class MenuViewModel extends AppBaseViewModel {
  final _themeService = locator<ThemeService>();
  bool get isDarkMode => _themeService.isDarkTheme;

  String get userName => userService.currentUser?.fullName ?? 'User';
  String get userRole => userService.currentUser?.role ?? 'Guest';
  String get userImage => userService.currentUser?.profileImage ?? '';
  String get userEmail => userService.currentUser?.email ?? '';

  MenuViewModel() {
    userService.addListener(_onUserChanged);
    _themeService.addListener(_onThemeChanged);
  }

  void _onUserChanged() {
    notifyListeners();
  }

  void _onThemeChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    userService.removeListener(_onUserChanged);
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> toggleDarkMode(bool value) async {
    await _themeService.toggleTheme();
  }

  Future<void> profile() async {
    await navigationService.navigateToProfileView();
  }

  Future<void> navigateToAnalytics() async {
    await navigationService.navigateToTrainerAnalyticsView();
  }

  Future<void> logout() async {
    if (isBusy) return;

    setBusy(true);
    try {
      await authService.logout();
      await navigationService.clearStackAndShow(Routes.authView);
    } finally {
      setBusy(false);
    }
  }
}
