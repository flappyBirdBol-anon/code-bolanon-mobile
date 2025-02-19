import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MenuViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String get userName => _authService.currentUser?.fullName ?? 'User';
  String get userRole => _authService.currentUser?.role ?? 'Guest';
  String get userImage => _authService.currentUser?.profileImage ?? '';
  String get userEmail => _authService.currentUser?.email ?? '';

  MenuViewModel() {
    _authService.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(_onUserChanged);
    super.dispose();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  Future<void> profile() async {
    await _navigationService.navigateToProfileView();
  }

  Future<void> logout() async {
    setBusy(true);
    try {
      final success = await _authService.logout();
      if (success) {
        await _navigationService.clearStackAndShow(Routes.authView);
      }
    } catch (e) {
      print('error during logging out: $e');
    } finally {
      setBusy(false);
    }
  }
}
