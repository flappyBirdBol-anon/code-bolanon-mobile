import 'dart:io';

import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class EditProfileViewModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final _imageService = locator<ImageService>();
  final _snackbarService = locator<SnackbarService>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final organizationController = TextEditingController();
  final specializationController = TextEditingController();

  XFile? selectedProfileImage;

  String get role => _userService.currentUser?.role ?? 'Unknown';
  String get profilePictureUrl => _userService.currentUser?.profileImage ?? '';
  bool get isTrainer => role.toLowerCase() == 'trainer';
  int get userId => _userService.currentUser?.id ?? 0;

  String get formattedProfilePictureUrl {
    return _imageService.getProfilePictureUrl(profilePictureUrl);
  }

  void handleProfilePictureSelection(XFile? image) {
    selectedProfileImage = image;
    notifyListeners();
  }

  void initializeControllers() {
    firstNameController.text = _userService.currentUser?.firstName ?? '';
    lastNameController.text = _userService.currentUser?.lastName ?? '';
    organizationController.text = _userService.currentUser?.organization ?? '';
    specializationController.text =
        _userService.currentUser?.specialization ?? '';
    notifyListeners();
  }

  bool hasProfileChanges() {
    return firstNameController.text !=
            (_userService.currentUser?.firstName ?? '') ||
        lastNameController.text != (_userService.currentUser?.lastName ?? '') ||
        organizationController.text !=
            (_userService.currentUser?.organization ?? '') ||
        specializationController.text !=
            (_userService.currentUser?.specialization ?? '') ||
        selectedProfileImage != null;
  }

  Future<Map<String, dynamic>> updateProfile() async {
    if (userId == 0) return {'success': false};

    // Check if there are any changes before proceeding
    if (!hasProfileChanges()) {
      _snackbarService.showSnackbar(
        message: 'No changes detected',
        duration: const Duration(seconds: 2),
      );
      return {'success': false};
    }

    setBusy(true);

    try {
      // Keep existing image URL if no new image selected
      String imageUrl = profilePictureUrl;
      if (selectedProfileImage != null) {
        // Use the direct file path
        imageUrl = selectedProfileImage!.path;
      }

      final success = await _userService.updateProfile(
        firstNameController.text,
        lastNameController.text,
        imageUrl,
        specializationController.text,
        organizationController.text,
        userId,
      );

      if (success) {
        _snackbarService.showSnackbar(
          message: 'Profile updated successfully',
          duration: const Duration(seconds: 2),
        );
        // Clear the selected image after successful update
        selectedProfileImage = null;
        notifyListeners();
      } else {
        _snackbarService.showSnackbar(
          message: 'Failed to update profile',
          duration: const Duration(seconds: 2),
        );
      }

      return {'success': success};
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'An error occurred while updating profile',
        duration: const Duration(seconds: 2),
      );
      return {'success': false};
    } finally {
      setBusy(false);
    }
  }

  Widget getProfileImageWidget({
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (selectedProfileImage != null) {
      return Image.file(
        File(selectedProfileImage!.path),
        width: 120,
        height: 120,
        fit: fit,
      );
    }

    if (profilePictureUrl.isEmpty) {
      return errorWidget ??
          const Icon(Icons.person, size: 40, color: Colors.grey);
    }

    return _imageService.getProfileImageWidget(
      imageUrl: _imageService.getProfilePictureUrl(profilePictureUrl),
      width: 120,
      height: 120,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    organizationController.dispose();
    specializationController.dispose();
    super.dispose();
  }
}
