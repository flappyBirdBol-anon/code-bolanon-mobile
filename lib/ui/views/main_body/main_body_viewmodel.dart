import 'package:code_bolanon/app/app.locator.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MainBodyViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void onTabTapped(int index) {
    if (_currentIndex == index) {
      navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
