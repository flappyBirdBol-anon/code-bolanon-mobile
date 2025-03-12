import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/tech_stack_model.dart';
import 'package:code_bolanon/services/tech_stack_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../app/app.locator.dart';
import '../../../../services/auth_service.dart';

class SignupViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _techStackService = locator<TechStackService>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final organizationController = TextEditingController();
  final specializationController = TextEditingController();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? organizationError;
  String? specializationError;
  String? techStackError;

  bool isPasswordFieldFocused = false;
  bool isConfirmPasswordFieldFocused = false;

  List<TechStackModel> _availableTechStacks = [];
  List<String> get availableTechStacks =>
      _availableTechStacks.map((stack) => stack.tags).toList();

  final Set<String> _selectedTechStacks = {};
  List<String> get selectedTechStacks => _selectedTechStacks.toList();

  void toggleTechStack(String tag) {
    if (_selectedTechStacks.contains(tag)) {
      _selectedTechStacks.remove(tag);
    } else {
      _selectedTechStacks.add(tag);
    }
    validateTechStack();
    notifyListeners();
  }

  bool isStackSelected(String tag) {
    return _selectedTechStacks.contains(tag);
  }

  List<String> getSelectedStackIds() {
    return _selectedTechStacks
        .map((tag) {
          final stack = _availableTechStacks.firstWhere(
            (s) => s.tags == tag,
            orElse: () => TechStackModel(id: -1, tags: ''),
          );
          return stack.id.toString();
        })
        .where((id) => id != '-1')
        .toList();
  }

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

  SignupViewModel() {
    _loadTechStacks();
  }

  void clearErrors() {
    firstNameError = null;
    lastNameError = null;
    emailError = null;
    passwordError = null;
    confirmPasswordError = null;
    organizationError = null;
    specializationError = null;
    techStackError = null;
    notifyListeners();
  }

  Future<void> _loadTechStacks() async {
    setBusy(true);
    try {
      _availableTechStacks = await _techStackService.fetchTechStacks();
      notifyListeners();
    } catch (e) {
      print('Error loading tech stacks: $e');
    } finally {
      setBusy(false);
    }
  }

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
    clearErrors();
    if (!_validateInputs()) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.register(
        firstNameController.text,
        lastNameController.text,
        emailController.text,
        passwordController.text,
        selectedRole,
        getSelectedStackIds(),
        selectedRole == 'trainer' ? specializationController.text : null,
        selectedRole == 'trainer' ? organizationController.text : null,
      );

      if (success) {
        _snackbarService.showCustomSnackBar(
          variant: SnackbarType.success,
          message:
              'Registration successful! Please check your email to verify your account.',
          duration: const Duration(seconds: 4),
        );

        await _navigationService.clearStackAndShow(Routes.authView);
      }
    } catch (e) {
      String errorMessage = 'Registration failed. ';
      if (e.toString().contains('422')) {
        errorMessage += 'Please check your information and try again.';
      } else {
        errorMessage += e.toString().split('\n')[0];
      }
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: errorMessage,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signupWithGoogle() async {
    if (!_termsAccepted) {
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: 'Please accept the terms and conditions',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.success,
        message: 'Google signup successful!',
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      _navigationService.replaceWith('/home');
    } catch (e) {
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: 'Google signup failed: ${e.toString().split('\n')[0]}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateInputs() {
    bool isValid = true;

    if (firstNameController.text.isEmpty) {
      firstNameError = 'Please enter your first name';
      isValid = false;
    }

    if (lastNameController.text.isEmpty) {
      lastNameError = 'Please enter your last name';
      isValid = false;
    }

    if (emailController.text.isEmpty) {
      emailError = 'Please enter your email';
      isValid = false;
    }

    if (passwordController.text.isEmpty) {
      passwordError = 'Please enter your password';
      isValid = false;
    } else if (!isPasswordValid) {
      passwordError = 'Password does not meet requirements';
      isValid = false;
    }

    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError = 'Please confirm your password';
      isValid = false;
    } else if (!isConfirmPasswordValid) {
      confirmPasswordError = 'Passwords do not match';
      isValid = false;
    }

    if (selectedRole == 'trainer') {
      if (organizationController.text.isEmpty) {
        organizationError = 'Please enter your organization';
        isValid = false;
      }
      if (specializationController.text.isEmpty) {
        specializationError = 'Please enter your specialization';
        isValid = false;
      }
    }

    if (_selectedTechStacks.isEmpty) {
      techStackError = 'Please select at least one tech stack';
      isValid = false;
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: 'Please select at least one tech stack',
        duration: const Duration(seconds: 2),
      );
    }

    if (!_termsAccepted) {
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: 'Please accept the terms and conditions',
        duration: const Duration(seconds: 2),
      );
      isValid = false;
    }

    notifyListeners();
    return isValid;
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

  void unfocusPasswordFields() {
    if (passwordFocusNode.hasFocus) {
      passwordFocusNode.unfocus();
    }
    if (confirmPasswordFocusNode.hasFocus) {
      confirmPasswordFocusNode.unfocus();
    }
    isPasswordFieldFocused = false;
    isConfirmPasswordFieldFocused = false;
    notifyListeners();
  }

  void navigateToTermsAndConditions() {
    _navigationService.navigateToTosView();
  }

  void validateFirstName(String value) {
    if (firstNameError != null && value.isNotEmpty) {
      firstNameError = null;
      notifyListeners();
    }
  }

  void validateLastName(String value) {
    if (lastNameError != null && value.isNotEmpty) {
      lastNameError = null;
      notifyListeners();
    }
  }

  void validateEmail(String value) {
    if (emailError != null && value.isNotEmpty) {
      emailError = null;
      notifyListeners();
    }
  }

  void validatePassword(String value) {
    if (passwordError != null) {
      if (value.isNotEmpty) {
        if (isPasswordValid) {
          passwordError = null;
          notifyListeners();
        }
      }
    }
  }

  void validateConfirmPassword(String value) {
    if (confirmPasswordError != null) {
      if (value.isNotEmpty && isConfirmPasswordValid) {
        confirmPasswordError = null;
        notifyListeners();
      }
    }
  }

  void validateOrganization(String value) {
    if (organizationError != null && value.isNotEmpty) {
      organizationError = null;
      notifyListeners();
    }
  }

  void validateSpecialization(String value) {
    if (specializationError != null && value.isNotEmpty) {
      specializationError = null;
      notifyListeners();
    }
  }

  void validateTechStack() {
    if (techStackError != null && _selectedTechStacks.isNotEmpty) {
      techStackError = null;
      notifyListeners();
    }
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
