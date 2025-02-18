import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfileViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();

  Future<void> logout() async {
    setBusy(true);
    try {
      _authService.logout();
      await _navigationService.clearStackAndShow(Routes.authView);
    } catch (e) {
      print('error during logging out');
    } finally {
      setBusy(false);
    }
  }
}
