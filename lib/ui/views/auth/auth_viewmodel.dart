import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import '../../../app/app.locator.dart';
import '../../../services/theme_service.dart';

class AuthViewModel extends BaseViewModel {
  final _themeService = locator<ThemeService>();
  final PageController pageController = PageController();

  int _currentPage = 0;
  int get currentPage => _currentPage;

  bool get isDarkTheme => _themeService.isDarkTheme;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void toggleTheme() {
    _themeService.toggleTheme();
    notifyListeners();
  }

  void navigateToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
