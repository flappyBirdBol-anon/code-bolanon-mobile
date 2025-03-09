import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../app/app.locator.dart';
import '../../../../services/auth_service.dart';

// Import the SnackbarType enum

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
        // Show success message before navigating
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.success,
          message: 'Login successful! Welcome back.',
          duration: const Duration(seconds: 2),
        );

        // Wait a moment to show the success message before navigating
        await Future.delayed(const Duration(milliseconds: 500));
        await _navigationService.clearStackAndShow(Routes.mainBodyView);
      } else {
        // Show error message with custom error snackbar
        print('Login failed. Please check your credentials.');
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.error,
          message: 'Login failed. Please check your email and password.',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Handle any errors with custom error snackbar
      print('An error occurred during login: $e');
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: 'Login error: ${e.toString().split('\n')[0]}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> loginWithEmail() async {
    _navigationService.replaceWith(Routes.homeView);
    _navigationService.clearStackAndShow(Routes.homeView);
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // await _authService.signInWithGoogle();
      // Show success message for Google login
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.success,
        message: 'Google login successful!',
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      _navigationService.replaceWith('/home');
    } catch (e) {
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: 'Google login failed: ${e.toString().split('\n')[0]}',
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
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.info,
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
