import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(255, 0, 0, 0); // Light Green
  static const Color accentColor = Color(0xFF607D8B); // Blue Grey
  static const Color backgroundColorLight = Color.fromARGB(255, 120, 119, 119);
  static const Color textColorLight = Colors.black87;
  static const Color secondaryTextColorLight = Colors.grey;

  static const Color backgroundColorDark = Color(0xFF303030);
  static const Color textColorDark = Colors.white;
  static const Color secondaryTextColorDark = Colors.grey;

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    hintColor: accentColor,
    scaffoldBackgroundColor: const Color.fromARGB(255, 132, 132, 132),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColorLight,
          fontFamily: 'Poppins'),
      displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColorLight,
          fontFamily: 'Poppins'),
      bodyLarge:
          TextStyle(fontSize: 16, color: textColorLight, fontFamily: 'Poppins'),
      bodyMedium: TextStyle(
          fontSize: 14, color: secondaryTextColorLight, fontFamily: 'Poppins'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 18),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[200],
      hintStyle: const TextStyle(color: secondaryTextColorLight),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color.fromARGB(255, 174, 102, 25),
    hintColor: accentColor,
    scaffoldBackgroundColor: backgroundColorDark,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColorDark,
          fontFamily: 'Poppins'),
      displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColorDark,
          fontFamily: 'Poppins'),
      bodyLarge:
          TextStyle(fontSize: 16, color: textColorDark, fontFamily: 'Poppins'),
      bodyMedium: TextStyle(
          fontSize: 14, color: secondaryTextColorDark, fontFamily: 'Poppins'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 18),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[800],
      hintStyle: const TextStyle(color: secondaryTextColorDark),
    ),
  );
}
