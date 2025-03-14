import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      'animation': PngImages.communityAnim,
    },
    {
      'title': 'Expert Tech Mentors',
      'description':
          'Get guided by Bohol\'s finest software developers who understand both global standards and local industry needs. Learn practical coding skills that matter.',
      'animation': PngImages.mentorAnim,
    },
    {
      'title': 'Hands-on Coding Projects',
      'description':
          'Build real-world applications while learning. Practice with projects relevant to Bohol\'s growing tech scene, from tourism apps to business solutions.',
      'animation': PngImages.codingAnim,
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

  void navigateToAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    _navigationService.navigateTo(Routes.authView);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
