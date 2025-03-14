import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'dark_theme';
  SharedPreferences? _prefs;
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isDarkTheme = _prefs?.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Error initializing theme service: $e');
      _isDarkTheme = false;
    }
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkTheme = !_isDarkTheme;
      await _prefs?.setBool(_themeKey, _isDarkTheme);
      notifyListeners();
    } catch (e) {
      print('Error toggling theme: $e');
      // Revert the change if saving fails
      _isDarkTheme = !_isDarkTheme;
      notifyListeners();
    }
  }
}
