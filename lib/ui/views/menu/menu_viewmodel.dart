import 'dart:io';

import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/theme_service.dart';
import 'package:flutter/material.dart';

class MenuViewModel extends AppBaseViewModel {
  final _themeService = locator<ThemeService>();
  final _imageService = locator<ImageService>();
  bool get isDarkMode => _themeService.isDarkTheme;

  String get userName => userService.currentUser?.fullName ?? 'User';
  String get userRole => userService.currentUser?.role ?? 'Guest';
  String get userImage => userService.currentUser?.profileImage ?? '';
  String get userEmail => userService.currentUser?.email ?? '';

  MenuViewModel() {
    userService.addListener(_onUserChanged);
    _themeService.addListener(_onThemeChanged);
  }

  void _onUserChanged() {
    notifyListeners();
  }

  void _onThemeChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    userService.removeListener(_onUserChanged);
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> toggleDarkMode(bool value) async {
    await _themeService.toggleTheme();
  }

  Future<void> profile() async {
    await navigationService.navigateToProfileView();
  }

  Future<void> navigateToAnalytics() async {
    await navigationService.navigateToTrainerAnalyticsView();
  }

  Future<void> logout() async {
    if (isBusy) return;

    setBusy(true);
    try {
      await authService.logout();
      await navigationService.clearStackAndShow(Routes.authView);
    } finally {
      setBusy(false);
    }
  }

  Widget getProfileImageWidget({
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (userImage.isEmpty) {
      return errorWidget ??
          const Icon(Icons.person, size: 35, color: Colors.white70);
    }

    // For local files (from cache/camera)
    if (userImage.startsWith('/data/')) {
      return Image.asset(
        userImage,
        width: 60,
        height: 60,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Icon(Icons.person, size: 35, color: Colors.white70),
      );
    }

    final imageUrl = _imageService.getCourseThumbnailFromPath(userImage);

    // For network images
    return _imageService.loadImage(
      imageUrl: imageUrl,
      courseId: '',
      width: 60,
      height: 60,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
