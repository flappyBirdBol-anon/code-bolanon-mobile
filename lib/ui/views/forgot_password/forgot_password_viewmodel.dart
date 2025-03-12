import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';

import 'package:code_bolanon/services/forgot_password_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final _forgotPasswordService = locator<ForgotPasswordService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool _codeSent = false;
  bool get codeSent => _codeSent;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isConfirmPasswordVisible = false;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  String? _verificationToken;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  bool get isPasswordValid =>
      newPasswordController.text.length >= 8 &&
      RegExp(r'[0-9]').hasMatch(newPasswordController.text) &&
      RegExp(r'[A-Z]').hasMatch(newPasswordController.text) &&
      RegExp(r'[a-z]').hasMatch(newPasswordController.text) &&
      newPasswordController.text.isNotEmpty;

  bool get isConfirmPasswordValid =>
      confirmPasswordController.text == newPasswordController.text &&
      confirmPasswordController.text.isNotEmpty;

  Future<void> requestPasswordReset() async {
    if (emailController.text.isEmpty) {
      _showSnackbar('Please enter your email address', SnackbarType.info);
      return;
    }

    if (!emailController.text.contains('@')) {
      _showSnackbar('Please enter a valid email address', SnackbarType.info);
      return;
    }

    setBusy(true);
    try {
      final success = await _forgotPasswordService.requestPasswordReset(
        emailController.text.trim(),
      );

      if (success) {
        _codeSent = true;
        _currentStep = 1;
        _showSnackbar(
          'Password reset code sent to your email',
          SnackbarType.success,
        );
      }
    } catch (e) {
      _showSnackbar(
        'Failed to send reset code: ${e.toString().split('\n')[0]}',
        SnackbarType.error,
      );
    } finally {
      setBusy(false);
    }
    notifyListeners();
  }

  Future<void> verifyCode() async {
    if (codeController.text.isEmpty) {
      _showSnackbar('Please enter the verification code', SnackbarType.info);
      return;
    }

    setBusy(true);
    try {
      final success = await _forgotPasswordService.verifyResetCode(
        emailController.text.trim(),
        codeController.text.trim(),
      );

      if (success.containsKey('reset_token')) {
        _verificationToken = success['reset_token'];
        _currentStep = 2;
        _showSnackbar(
          'Code verified! You can now reset your password',
          SnackbarType.success,
        );
      } else {
        _showSnackbar('Invalid verification response', SnackbarType.error);
      }
    } catch (e) {
      _showSnackbar('Invalid verification code', SnackbarType.error);
    } finally {
      setBusy(false);
    }
    notifyListeners();
  }

  Future<void> resetPassword() async {
    if (!_validatePasswordInputs()) return;
    if (_verificationToken == null) {
      _showSnackbar('Please verify your code first', SnackbarType.error);
      return;
    }

    setBusy(true);
    try {
      final success = await _forgotPasswordService.resetPassword(
        emailController.text.trim(),
        _verificationToken!,
        newPasswordController.text,
        confirmPasswordController.text,
      );

      if (success) {
        _showSnackbar('Password successfully reset!', SnackbarType.success);
        await Future.delayed(const Duration(seconds: 1));
        _navigationService.clearStackAndShow(Routes.authView);
      }
    } catch (e) {
      _showSnackbar(
        'Failed to reset password: ${e.toString().split('\n')[0]}',
        SnackbarType.error,
      );
    } finally {
      setBusy(false);
    }
  }

  bool _validatePasswordInputs() {
    if (newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnackbar('Please fill in all password fields', SnackbarType.info);
      return false;
    }

    if (!isPasswordValid) {
      _showSnackbar(
        'Password must be at least 8 characters long and contain uppercase, lowercase, and numbers',
        SnackbarType.info,
      );
      return false;
    }

    if (!isConfirmPasswordValid) {
      _showSnackbar('Passwords do not match', SnackbarType.error);
      return false;
    }

    return true;
  }

  void _showSnackbar(String message, String type) {
    _snackbarService.showCustomSnackBar(
      variant: type,
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  void navigateBack() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    } else {
      _navigationService.back();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
