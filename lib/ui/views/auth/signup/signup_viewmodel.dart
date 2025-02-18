import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../../app/app.locator.dart';
import '../../../../services/auth_service.dart';

class SignupViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final certificationController = TextEditingController();
  final specializationController = TextEditingController();

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isConfirmPasswordVisible = false;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  bool _termsAccepted = false;
  bool get termsAccepted => _termsAccepted;

  String _selectedRole = 'trainee';
  String get selectedRole => _selectedRole;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setTermsAccepted(bool value) {
    _termsAccepted = value;
    notifyListeners();
  }

  bool get isPasswordValid =>
      passwordController.text.length >= 8 &&
      passwordController.text.contains(RegExp(r'[0-9]')) &&
      passwordController.text.contains(RegExp(r'[A-Z]')) &&
      passwordController.text.contains(RegExp(r'[a-z]')) &&
      passwordController.text == confirmPasswordController.text &&
      !passwordController.text.contains(' ') &&
      passwordController.text.isNotEmpty;

  bool get isConfirmPasswordValid =>
      confirmPasswordController.text == passwordController.text;

  Future<void> signupWithEmail() async {
    if (!_validateInputs()) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUpWithEmail(
        name:
            '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        email: emailController.text.trim(),
        password: passwordController.text,
        role: _selectedRole,
        metadata: _selectedRole == 'trainer'
            ? {
                'certification': certificationController.text,
                'specialization': specializationController.text,
              }
            : null,
      );
      _navigationService.replaceWith('/home');
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Signup failed: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signupWithGoogle() async {
    if (!_termsAccepted) {
      _snackbarService.showSnackbar(
        message: 'Please accept the terms and conditions',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      _navigationService.replaceWith('/home');
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Google signup failed: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateInputs() {
    if (!_termsAccepted) {
      _snackbarService.showSnackbar(
        message: 'Please accept the terms and conditions',
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please fill in all required fields',
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (!isPasswordValid) {
      _snackbarService.showSnackbar(
        message: 'Password does not meet requirements',
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (!isConfirmPasswordValid) {
      _snackbarService.showSnackbar(
        message: 'Passwords do not match',
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    return true;
  }

  void notifyPasswordInput() {
    notifyListeners();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    certificationController.dispose();
    specializationController.dispose();
    super.dispose();
  }
}
