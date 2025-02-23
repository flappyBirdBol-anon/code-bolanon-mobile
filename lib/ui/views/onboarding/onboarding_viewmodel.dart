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
      'title': 'Learn Programming in Bohol',
      'description':
          'Join our local tech community and learn programming from experienced Boholano developers. From web development to mobile apps, start your coding journey here.',
      'animation': 'assets/animations/team_sucesss.json',
    },
    {
      'title': 'Expert Tech Mentors',
      'description':
          'Get guided by Bohol\'s finest software developers who understand both global standards and local industry needs. Learn practical coding skills that matter.',
      'animation': 'assets/animations/user_friendly.json',
    },
    {
      'title': 'Hands-on Coding Projects',
      'description':
          'Build real-world applications while learning. Practice with projects relevant to Bohol\'s growing tech scene, from tourism apps to business solutions.',
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
