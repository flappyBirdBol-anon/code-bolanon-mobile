import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:flutter/material.dart';

class MainBodyViewModel extends AppBaseViewModel {
  int _currentIndex =
      0; // Private variable to keep track of the current tab index

  int get currentIndex => _currentIndex; // Getter for the current tab index

  // List of navigator keys, one for each tab. These keys allow independent navigation stacks for each tab.
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final _authService = locator<AuthService>();

  // Loading state flag
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String? get role => userService.currentUser?.role;

  @override
  Future<void> futureToRun() async {
    // We need to ensure user data is loaded before showing the UI
    setBusy(true);

    try {
      // Add a timeout to prevent getting stuck
      await Future.wait([
        _initializeUserData(),
      ]).timeout(const Duration(seconds: 5), onTimeout: () {
        // If it times out, just proceed with what we have
        print('Initialization timed out, proceeding with app');
        return [];
      });

      // Always mark as initialized even if there was a timeout
      _isInitialized = true;
    } catch (e) {
      // Handle any errors by still marking as initialized but logging the error
      print('Error during initialization: $e');
      _isInitialized = true;
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<void> _initializeUserData() async {
    try {
      // Check if user is logged in
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Try to load user profile but don't block if it fails
        try {
          await userService.fetchUserProfile();
        } catch (e) {
          print('Error fetching user profile, continuing anyway: $e');
        }
      }
    } catch (e) {
      print('Error in _initializeUserData: $e');
    }
  }

  // Method to handle tab taps
  void onTabTapped(int index) {
    if (_currentIndex == index) {
      // If the tapped tab is already selected, pop all routes until the first route
      navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      // If we want to refresh the selected tab when navigating to it
      if (index != 3) {
        // Don't refresh Menu tab (index 3)
        // Force a rebuild of the tab by recreating its navigation stack
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
        });
      }

      // If a different tab is selected, update the current index and notify listeners to rebuild the UI
      _currentIndex = index;
      notifyListeners();
    }
  }

  // Method to manually refresh the current tab
  void refreshCurrentTab() {
    if (_currentIndex != 3) {
      // Don't refresh the Menu tab (index 3)
      // Reset to first route and force rebuild
      navigatorKeys[_currentIndex]
          .currentState
          ?.popUntil((route) => route.isFirst);
      notifyListeners();
    }
  }
}
