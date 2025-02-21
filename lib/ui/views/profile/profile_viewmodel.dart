import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/ui/common/widgets/change_password_modal.dart';
import 'package:code_bolanon/ui/common/widgets/edit_profile_modal.dart';
import 'package:code_bolanon/ui/common/widgets/tech_stack_modal.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfileViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _snackbarService = locator<SnackbarService>();

  String get firstName => _authService.currentUser?.firstName ?? 'Example';
  String get lastName => _authService.currentUser?.lastName ?? 'User';
  String get email =>
      _authService.currentUser?.email ?? 'example.user@example.com';
  String get role => _authService.currentUser?.role ?? 'Guest';
  String get profilePictureUrl => _authService.currentUser?.profileImage ?? '';
  String get specialization =>
      _authService.currentUser?.specialization ?? 'None';
  String get organization => _authService.currentUser?.organization ?? 'None';
  bool get isTrainer => role.toLowerCase() == 'trainer';

  String get formattedProfilePictureUrl {
    if (profilePictureUrl.isEmpty) {
      return '';
    }
    try {
      final uri = Uri.parse(profilePictureUrl);
      if (uri.hasScheme) {
        return profilePictureUrl;
      } else {
        return 'https://example.com/$profilePictureUrl'; // Replace with your base URL
      }
    } catch (e) {
      return '';
    }
  }

  final List<String> _techStacks = [
    'Flutter',
    'Dart',
    'Firebase',
    'REST API',
    'Node.js',
    'React',
    'MongoDB'
  ];

  List<String> get techStacks => _techStacks;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  //change password modal
  bool _isOldPasswordVisible = false;
  bool get isOldPasswordVisible => _isOldPasswordVisible;

  bool _isNewPasswordVisible = false;
  bool get isNewPasswordVisible => _isNewPasswordVisible;

  bool _isConfirmNewPasswordVisible = false;
  bool get isConfirmNewPasswordVisible => _isConfirmNewPasswordVisible;

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

  bool get isNewPasswordValid =>
      newPasswordController.text.length >= 8 &&
      newPasswordController.text.contains(RegExp(r'[0-9]')) &&
      newPasswordController.text.contains(RegExp(r'[A-Z]')) &&
      newPasswordController.text.contains(RegExp(r'[a-z]')) &&
      newPasswordController.text == confirmNewPasswordController.text &&
      !newPasswordController.text.contains(' ') &&
      newPasswordController.text.isNotEmpty;

  bool get isConfirmNewPasswordValid =>
      confirmNewPasswordController.text == newPasswordController.text;

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

    if (!isNewPasswordValid) {
      _snackbarService.showSnackbar(
        message: 'Password does not meet requirements',
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (!isConfirmNewPasswordValid) {
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

  void showChangePasswordModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordModal(viewModel: this),
    );
  }

  void changePassword() {
    if (!_validateInputs()) return;
  }

  // edit profile modal
  final firstNameController = TextEditingController(
      text: locator<AuthService>().currentUser?.firstName ?? 'Example');
  final lastNameController = TextEditingController(
      text: locator<AuthService>().currentUser?.lastName ?? 'User');
  final organizationController = TextEditingController(
      text: locator<AuthService>().currentUser?.organization ?? 'None');
  final specializationController = TextEditingController(
      text: locator<AuthService>().currentUser?.specialization ?? 'None');

  void showEditProfileModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditProfileModal(viewModel: this),
    );
  }

  void showTechStackModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TechStackModal(
        techStacks: _techStacks,
        onRemove: (tech) {
          _techStacks.remove(tech);
          notifyListeners();
        },
        onAdd: (tech) {
          _techStacks.add(tech);
          notifyListeners();
        },
      ),
    );
  }

  Future<Map<String, dynamic>> updateProfile() async {
    print('update profile tapped');
    return {'success': true};
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }
}
