import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'dark_theme';
  final _prefs = SharedPreferences.getInstance();

  bool _isDarkTheme = false;
  bool get isDarkTheme => _isDarkTheme;

  Future<void> initialize() async {
    final prefs = await _prefs;
    _isDarkTheme = prefs.getBool(_themeKey) ?? false;
  }

  Future<void> toggleTheme() async {
    final prefs = await _prefs;
    _isDarkTheme = !_isDarkTheme;
    await prefs.setBool(_themeKey, _isDarkTheme);
  }
}
