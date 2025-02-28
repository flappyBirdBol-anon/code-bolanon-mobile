import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';

class MenuViewModel extends AppBaseViewModel {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String get userName => userService.currentUser?.fullName ?? 'User';
  String get userRole => userService.currentUser?.role ?? 'Guest';
  String get userImage => userService.currentUser?.profileImage ?? '';
  String get userEmail => userService.currentUser?.email ?? '';

  MenuViewModel() {
    userService.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    userService.removeListener(_onUserChanged);
    super.dispose();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  Future<void> profile() async {
    await navigationService.navigateToProfileView();
  }

  Future<void> logout() async {
    setBusy(true);
    try {
      final success = await authService.logout();
      if (success) {
        await navigationService.clearStackAndShow(Routes.authView);
      }
    } catch (e) {
      print('error during logging out: $e');
    } finally {
      setBusy(false);
    }
  }
}
