import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AppBaseViewModel extends BaseViewModel {
  final userService = locator<UserService>();
  final snackbarService = locator<SnackbarService>();
  final authService = locator<AuthService>();
  final navigationService = locator<NavigationService>();
}
