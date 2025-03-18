import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ChangePasswordViewModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final _snackbarService = locator<SnackbarService>();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;

  bool get isOldPasswordVisible => _isOldPasswordVisible;
  bool get isNewPasswordVisible => _isNewPasswordVisible;
  bool get isConfirmNewPasswordVisible => _isConfirmNewPasswordVisible;

  bool get hasMinLength => newPasswordController.text.length >= 8;
  bool get hasNumber => newPasswordController.text.contains(RegExp(r'[0-9]'));
  bool get hasUpperCase =>
      newPasswordController.text.contains(RegExp(r'[A-Z]'));
  bool get hasLowerCase =>
      newPasswordController.text.contains(RegExp(r'[a-z]'));
  bool get isMatch =>
      newPasswordController.text == confirmNewPasswordController.text &&
      newPasswordController.text.isNotEmpty;

  void toggleOldPasswordVisibility() {
    _isOldPasswordVisible = !_isOldPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmNewPasswordVisibility() {
    _isConfirmNewPasswordVisible = !_isConfirmNewPasswordVisible;
    notifyListeners();
  }

  void notifyPasswordInput() {
    notifyListeners();
  }

  bool _validateInputs() {
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmNewPasswordController.text.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please fill in all required fields',
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (!hasMinLength || !hasNumber || !hasUpperCase || !hasLowerCase) {
      _snackbarService.showSnackbar(
        message: 'Password does not meet requirements',
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (!isMatch) {
      _snackbarService.showSnackbar(
        message: 'Passwords do not match',
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    return true;
  }

  Future<void> changePassword() async {
    if (!_validateInputs()) return;

    setBusy(true);

    try {
      final response = await _userService.updatePassword(
        oldPasswordController.text,
        newPasswordController.text,
        confirmNewPasswordController.text,
      );

      if (response['success']) {
        _snackbarService.showSnackbar(
          message: response['message'] ?? 'Password updated successfully',
          duration: const Duration(seconds: 3),
        );
        // Clear controllers and navigate back
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
      } else {
        _snackbarService.showSnackbar(
          message: response['message'] ?? 'Failed to update password',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'An error occurred while updating password',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }
}
