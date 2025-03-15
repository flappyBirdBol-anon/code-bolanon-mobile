import 'dart:io';

import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/utils/tech_stack_colors.dart';
import 'package:code_bolanon/ui/common/widgets/tech_stack_modal.dart';
import 'package:code_bolanon/ui/views/change_password/change_password_view.dart';
import 'package:code_bolanon/ui/views/edit_profile/edit_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfileViewModel extends AppBaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _imageService = locator<ImageService>();

  // User data getters
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
    if (profilePictureUrl.isEmpty) return '';
    try {
      final uri = Uri.parse(profilePictureUrl);
      return uri.hasScheme
          ? profilePictureUrl
          : 'https://example.com/$profilePictureUrl';
    } catch (e) {
      return '';
    }
  }

  // Tech stack management
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

  // Navigation methods
  Future<void> showEditProfileModal(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: EditProfileView(),
      ),
    );
  }

  void navigateToChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const ChangePasswordView(),
      ),
    );
  }

  // Initialize and update
  ProfileViewModel() {
    userService.addListener(() {
      notifyListeners();
    });
  }

  Widget getProfileImageWidget({
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (profilePictureUrl.isEmpty) {
      return errorWidget ??
          const Icon(Icons.person, size: 35, color: Colors.white70);
    }

    // For local files (from cache/camera)
    if (profilePictureUrl.startsWith('/data/')) {
      return Image.file(
        File(profilePictureUrl),
        width: 70,
        height: 70,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Icon(Icons.person, size: 35, color: Colors.white70),
      );
    }

    // For network images
    return Image.network(
      profilePictureUrl,
      width: 70,
      height: 70,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ??
          const Icon(Icons.person, size: 35, color: Colors.white70),
    );
  }
}
