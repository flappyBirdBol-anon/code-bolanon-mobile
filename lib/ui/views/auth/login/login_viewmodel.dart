import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
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

  String? emailError;
  String? passwordError;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void validateEmailField(String value) {
    if (emailError != null && value.isNotEmpty) {
      emailError = null;
      notifyListeners();
    }
  }

  void validatePasswordField(String value) {
    if (passwordError != null && value.isNotEmpty) {
      passwordError = null;
      notifyListeners();
    }
  }

  void clearErrors() {
    emailError = null;
    passwordError = null;
    notifyListeners();
  }

  Future<void> login() async {
    clearErrors();
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
        await Future.delayed(const Duration(milliseconds: 1000));
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
      String errorMessage;

      if (e is Exception) {
        var message = e.toString().split('\n')[0]; // Extract first line
        errorMessage = message.replaceAll("Exception", "");
      } else {
        errorMessage = 'An unexpected error occurred.';
      }

      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: 'Login error: $errorMessage',
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
    _navigationService.navigateTo(Routes.forgotPasswordView);
  }

  bool _validateInputs() {
    bool isValid = true;
    if (emailController.text.isEmpty) {
      emailError = 'Please enter your email';
      isValid = false;
    }

    if (passwordController.text.isEmpty) {
      passwordError = 'Please enter your password';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
