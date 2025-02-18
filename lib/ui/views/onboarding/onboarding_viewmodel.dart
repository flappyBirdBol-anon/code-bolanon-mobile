import 'package:code_bolanon/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class OnboardingViewModel extends BaseViewModel {
  final _navigationService = NavigationService();
  final PageController pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  String get appName => 'Your App Name';
  int get currentPage => _currentPage;
  bool get isLastPage => _currentPage == onboardingData.length - 1;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Team Up For Success',
      'description':
          'Get ready to unleash your potential and witness the power of teamwork as we embark on this extraordinary project.',
      'animation': 'assets/animations/team_sucesss.json',
    },
    {
      'title': 'User-Friendly at its Core',
      'description':
          'Discover the essence of user-friendliness as our interface empowers you with intuitive controls and effortless interactions',
      'animation': 'assets/animations/user_friendly.json',
    },
    {
      'title': 'Easy Task Creation',
      'description':
          'Quickly add tasks, set due dates, and add descriptions with ease using our task manager app. Simplify your workflow and stay organized.',
      'animation': 'assets/animations/task_creations.json',
    },
  ];

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void navigateToAuth() {
    // Replace with your actual route name
    _navigationService.navigateTo(Routes.authView);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
