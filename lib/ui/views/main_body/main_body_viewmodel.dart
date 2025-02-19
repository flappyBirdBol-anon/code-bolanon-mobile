import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class MainBodyViewModel extends BaseViewModel {
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
