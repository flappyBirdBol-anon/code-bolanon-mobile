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

  // Error states for each field
  String? oldPasswordError;
  String? newPasswordError;
  String? confirmNewPasswordError;

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
    // Clear errors when user types
    clearErrors();
    notifyListeners();
  }

  @override
  void clearErrors() {
    oldPasswordError = null;
    newPasswordError = null;
    confirmNewPasswordError = null;
    notifyListeners();
  }

  bool _validateInputs() {
    clearErrors();
    bool isValid = true;

    // Validate current password
    if (oldPasswordController.text.isEmpty) {
      oldPasswordError = 'Please enter your current password';
      isValid = false;
    } else if (oldPasswordController.text.length < 8) {
      oldPasswordError = 'Current password must be at least 8 characters';
      isValid = false;
    }

    // Validate new password
    if (newPasswordController.text.isEmpty) {
      newPasswordError = 'Please enter a new password';
      isValid = false;
    } else {
      if (oldPasswordController.text == newPasswordController.text) {
        newPasswordError =
            'New password must be different from current password';
        isValid = false;
      }
      if (!hasMinLength) {
        newPasswordError = 'Password must be at least 8 characters';
        isValid = false;
      } else if (!hasNumber) {
        newPasswordError = 'Password must contain at least one number';
        isValid = false;
      } else if (!hasUpperCase) {
        newPasswordError =
            'Password must contain at least one uppercase letter';
        isValid = false;
      } else if (!hasLowerCase) {
        newPasswordError =
            'Password must contain at least one lowercase letter';
        isValid = false;
      }
    }

    // Validate confirm password
    if (confirmNewPasswordController.text.isEmpty) {
      confirmNewPasswordError = 'Please confirm your new password';
      isValid = false;
    } else if (!isMatch) {
      confirmNewPasswordError = 'Passwords do not match';
      isValid = false;
    }

    if (!isValid) {
      _snackbarService.showSnackbar(
        message: 'Please fix the validation errors',
        duration: const Duration(seconds: 2),
      );
    }

    return isValid;
  }

  Future<Map<String, dynamic>> changePassword() async {
    if (!_validateInputs()) {
      return {'success': false, 'message': 'Please fix the validation errors'};
    }

    setBusy(true);

    try {
      final response = await _userService.updatePassword(
        oldPasswordController.text,
        newPasswordController.text,
        confirmNewPasswordController.text,
      );

      if (response['success']) {
        // Show success message
        _snackbarService.showSnackbar(
          message: response['message'] ?? 'Password updated successfully',
          duration: const Duration(seconds: 3),
        );

        // Clear controllers and return success
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
        return response;
      } else {
        // Handle server-side validation errors
        if (response['errors'] != null) {
          final errors = response['errors'] as Map<String, dynamic>;
          errors.forEach((field, error) {
            switch (field) {
              case 'current_password':
                oldPasswordError = error.toString();
                break;
              case 'new_password':
                newPasswordError = error.toString();
                break;
              case 'new_password_confirmation':
                confirmNewPasswordError = error.toString();
                break;
            }
          });
          notifyListeners();
        } else {
          _snackbarService.showSnackbar(
            message: response['message'] ?? 'Failed to update password',
            duration: const Duration(seconds: 3),
          );
        }
        return response;
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'An error occurred while updating password',
        duration: const Duration(seconds: 3),
      );
      return {'success': false, 'message': e.toString()};
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
