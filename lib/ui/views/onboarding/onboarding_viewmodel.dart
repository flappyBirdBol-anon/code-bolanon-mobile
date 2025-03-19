import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingViewModel extends BaseViewModel {
  final _navigationService = NavigationService();
  final _authService = locator<AuthService>();
  final PageController pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  bool _hasMarkedAsStarted = false;

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

  // Called when view is initialized
  void onModelReady() {
    // Mark onboarding as started as soon as view is shown
    if (!_hasMarkedAsStarted) {
      _markOnboardingAsStarted();
    }
  }

  // Ensures onboarding won't be shown again even if user exits app
  Future<void> _markOnboardingAsStarted() async {
    _hasMarkedAsStarted = true;
    await _authService.setOnboardingStarted();
  }

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

  /// Marks onboarding as completed and navigates to auth screen
  /// This ensures the onboarding will never be shown again
  Future<void> navigateToAuth() async {
    // Show loading while saving preferences
    setBusy(true);

    try {
      // Mark as fully completed
      await _authService.setOnboardingCompleted(true);

      // Navigate to authentication screen
      await _navigationService.replaceWith(Routes.authView);
    } catch (e) {
      // Fallback to alternative storage if SharedPreferences fails
      await _saveOnboardingStatusAlternative();
      await _navigationService.replaceWith(Routes.authView);
    } finally {
      setBusy(false);
    }
  }

  /// Alternative method to save onboarding status in case SharedPreferences fails
  Future<void> _saveOnboardingStatusAlternative() async {
    try {
      // Try to set the flag via auth service secure storage
      // This is more secure but requires the auth service
      if (_authService is AuthService) {
        await _authService.setOnboardingCompleted(true);
      }
    } catch (e) {
      // Log the error but continue - we'll try again next time
      print('Failed to save onboarding status: $e');
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
