import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/ui/common/utils/tech_stack_colors.dart';
import 'package:code_bolanon/ui/common/widgets/change_password_modal.dart';
import 'package:code_bolanon/ui/common/widgets/edit_profile_modal.dart';
import 'package:code_bolanon/ui/common/widgets/tech_stack_modal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends AppBaseViewModel {
  String get firstName => userService.currentUser?.firstName ?? 'Example';
  String get lastName => userService.currentUser?.lastName ?? 'User';
  String get email =>
      userService.currentUser?.email ?? 'example.user@example.com';
  String get role => userService.currentUser?.role ?? 'Unknown';
  String get profilePictureUrl => userService.currentUser?.profileImage ?? '';
  String get specialization => userService.currentUser?.specialization ?? '';
  String get organization => userService.currentUser?.organization ?? '';
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

  Color getTechColor(String tech, ThemeData theme) {
    return TechStackColors.getColorForTech(tech, theme);
  }

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
      snackbarService.showSnackbar(
        message: 'Please fill in all required fields',
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (!isNewPasswordValid) {
      snackbarService.showSnackbar(
        message: 'Password does not meet requirements',
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (!isConfirmNewPasswordValid) {
      snackbarService.showSnackbar(
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

  Future<void> showChangePasswordModal(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordModal(viewModel: this),
    );
  }

  void changePassword() async {
    if (!_validateInputs()) return;

    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;
    final newPasswordConfirmation = confirmNewPasswordController.text;

    final success = await userService.updatePassword(
        oldPassword, newPassword, newPasswordConfirmation);

    if (success) {
      snackbarService.showSnackbar(
        message: 'Password updated successfully',
        duration: const Duration(seconds: 2),
      );
    } else {
      snackbarService.showSnackbar(
        message: 'Failed to update password',
        duration: const Duration(seconds: 2),
      );
    }
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

  void showTechStackModal(BuildContext context) {
    final theme = Theme.of(context);
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

  Future<void> showEditProfileModal(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => EditProfileModal(viewModel: this),
    );
  }

  void updateControllers() {
    firstNameController.text = userService.currentUser?.firstName ?? '';
    lastNameController.text = userService.currentUser?.lastName ?? '';
    organizationController.text = userService.currentUser?.organization ?? '';
    specializationController.text =
        userService.currentUser?.specialization ?? '';
    notifyListeners();
  }

  ProfileViewModel() {
    userService.addListener(() {
      updateControllers();
      notifyListeners();
    });
    updateControllers();
  }

  // Add user ID getter
  int get userId => userService.currentUser?.id ?? 0;

  XFile? selectedProfileImage;

  void handleProfilePictureSelection(XFile? image) {
    selectedProfileImage = image;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateProfile() async {
    if (userId == 0) {
      snackbarService.showSnackbar(
        message: 'Unable to update profile: User ID not found',
        duration: const Duration(seconds: 2),
      );
      return {'success': false};
    }

    final firstName = firstNameController.text;
    final lastName = lastNameController.text;
    const profilePicture = '';
    final specialization = specializationController.text;
    final organization = organizationController.text;

    try {
      // First upload the image if there's a new one selected
      String? newImageUrl;
      if (selectedProfileImage != null) {
        // Add your image upload logic here
        // newImageUrl = await _uploadImage(selectedProfileImage!);
      }

      // Then update the profile with all the data including the new image URL if any
      final updatedProfile = {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        if (role == 'trainer') ...{
          'organization': organizationController.text,
          'specialization': specializationController.text,
        },
        if (newImageUrl != null) 'profilePicture': newImageUrl,
      };

      // Add your profile update API call here
      // await _profileService.updateProfile(updatedProfile);

      selectedProfileImage = null;
      notifyListeners();
    } catch (e) {
      // Handle errors
    }

    final success = await runBusyFuture(userService.updateProfile(
      firstName,
      lastName,
      profilePicture,
      specialization,
      organization,
      userId, // Pass the user ID
    ));

    if (success) {
      updateControllers();
      snackbarService.showSnackbar(
        message: 'Profile updated successfully',
        duration: const Duration(seconds: 2),
      );
    } else {
      snackbarService.showSnackbar(
        message: 'Failed to update profile',
        duration: const Duration(seconds: 2),
      );
    }

    return {'success': success};
  }

  final List<TextEditingController> _controllers = [];

  TextEditingController createController(String initialText) {
    final controller = TextEditingController(text: initialText);
    _controllers.add(controller);
    return controller;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}
