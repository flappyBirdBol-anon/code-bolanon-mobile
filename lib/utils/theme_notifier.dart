import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  final String key = "theme";
  SharedPreferences? _prefs;
  bool? _darkTheme;

  bool get darkTheme => _darkTheme ?? false;

  ThemeNotifier() {
    _darkTheme = false; // Default to light theme
    _loadFromPrefs();
  }

  toggleTheme() {
    _darkTheme = !_darkTheme!;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _darkTheme = _prefs?.getBool(key) ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _prefs?.setBool(key, _darkTheme!);
  }
}
