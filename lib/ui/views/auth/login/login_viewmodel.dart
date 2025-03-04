import 'package:code_bolanon/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../app/app.locator.dart';
import '../../../../services/auth_service.dart';

class LoginViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<void> login() async {
    setBusy(true);
    if (!_validateInputs()) {
      setBusy(false);
      return;
    }
    try {
      print('Attempting login with email: ${emailController.text}');
      final success = await _authService.login(
          emailController.text, passwordController.text);
      if (success) {
        await _navigationService.clearStackAndShow(Routes.mainBodyView);
      } else {
        // Show error message (consider using a dialog service)
        print('Login failed. Please check your credentials.');
        _snackbarService.showSnackbar(
          message: 'Login failed. Please check your credentials.',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Handle any errors (consider using a dialog service)
      print('An error occurred during login: $e');
      _snackbarService.showSnackbar(
        message: 'An error occurred during login: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> loginWithEmail() async {
    // if (!_validateInputs()) return;

    // _isLoading = true;
    // notifyListeners();

    // try {
    //   await _authService.signInWithEmail(
    //     email: emailController.text.trim(),
    //     password: passwordController.text,
    //   );
    //   _navigationService.replaceWith('/home');
    // } catch (e) {
    //   _snackbarService.showSnackbar(
    //     message: 'Login failed: ${e.toString()}',
    //     duration: const Duration(seconds: 3),
    //   );
    // } finally {
    //   _isLoading = false;
    //   notifyListeners();
    // }
    _navigationService.replaceWith(Routes.homeView);
    _navigationService.clearStackAndShow(Routes.homeView);
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // await _authService.signInWithGoogle();
      _navigationService.replaceWith('/home');
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Google login failed: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToForgotPassword() {
    _navigationService.navigateTo('/forgot-password');
  }

  bool _validateInputs() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please fill in all fields',
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
