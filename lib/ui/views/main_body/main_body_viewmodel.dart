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

  String? get role => userService.currentUser?.role;

  // Method to handle tab taps
  void onTabTapped(int index) {
    if (_currentIndex == index) {
      // If the tapped tab is already selected, pop all routes until the first route
      navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      // If a different tab is selected, update the current index and notify listeners to rebuild the UI
      _currentIndex = index;
      notifyListeners();
    }
  }
}
