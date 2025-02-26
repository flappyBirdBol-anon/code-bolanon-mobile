import 'package:code_bolanon/app/app.router.dart';
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
  final organizationController = TextEditingController();
  final specializationController = TextEditingController();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  bool isPasswordFieldFocused = false;
  bool isConfirmPasswordFieldFocused = false;

  // Tech stack selection properties
  final List<String> availableTechStacks = [
    'Flutter',
    'React',
    'Laravel',
    'Node.js',
    'Python',
    'Vue.js',
    'Angular',
    'Django',
    'Ruby on Rails',
    'Swift',
    'Kotlin',
    'Java',
    'Go',
    'PHP',
    'AWS',
    'Azure',
    'Firebase',
    'MongoDB',
    'PostgreSQL',
    'MySQL'
  ];

  final Set<String> _selectedTechStacks = {};
  List<String> get selectedTechStacks => _selectedTechStacks.toList();

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isConfirmPasswordVisible = false;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  bool _termsAccepted = false;
  bool get termsAccepted => _termsAccepted;

  String _selectedRole = 'learner';
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

  // Toggle tech stack selection
  void toggleTechStack(String stack) {
    if (_selectedTechStacks.contains(stack)) {
      _selectedTechStacks.remove(stack);
    } else {
      _selectedTechStacks.add(stack);
    }
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
    if (!_validateInputs()) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('Attempting signup with email: ${emailController.text}');
      final success = await _authService.register(
        firstNameController.text,
        lastNameController.text,
        emailController.text,
        passwordController.text,
        selectedRole,
        [specializationController.text],
        organizationController.text,
        selectedTechStacks
            as String?, // Add selected tech stacks to registration
      );
      if (success) {
        await _navigationService.clearStackAndShow(Routes.mainBodyView);
      } else {
        // Show error message (consider using a dialog service)
        print('Sign up failed. Please check your credentials.');
        _snackbarService.showSnackbar(
          message: 'Sign up failed. Please check your credentials.',
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
      //  await _authService.signInWithGoogle();
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

    if (_selectedTechStacks.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please select at least one tech stack',
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

  void updatePasswordFocus(bool hasFocus) {
    isPasswordFieldFocused = hasFocus;
    notifyListeners();
  }

  void updateConfirmPasswordFocus(bool hasFocus) {
    isConfirmPasswordFieldFocused = hasFocus;
    notifyListeners();
  }

  bool get isAnyPasswordFieldFocused =>
      isPasswordFieldFocused || isConfirmPasswordFieldFocused;

  void notifyPasswordInput() {
    notifyListeners();
  }

  @override
  void dispose() {
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    organizationController.dispose();
    specializationController.dispose();
    super.dispose();
  }
}
