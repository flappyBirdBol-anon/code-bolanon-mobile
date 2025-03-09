import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(255, 0, 0, 0); // Light Green
  static const Color accentColor = Color(0xFF607D8B); // Blue Grey
  static const Color backgroundColorLight = Colors.white;
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
    textTheme: TextTheme(
      displayLarge: GoogleFonts.figtree(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColorLight,
      ),
      displayMedium: GoogleFonts.figtree(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColorLight,
      ),
      bodyLarge: GoogleFonts.figtree(
        fontSize: 16,
        color: textColorLight,
      ),
      bodyMedium: GoogleFonts.figtree(
        fontSize: 14,
        color: secondaryTextColorLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        textStyle: GoogleFonts.figtree(fontSize: 18),
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
      hintStyle: GoogleFonts.figtree(color: secondaryTextColorLight),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color.fromARGB(255, 174, 102, 25),
    hintColor: accentColor,
    scaffoldBackgroundColor: backgroundColorDark,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.figtree(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColorDark,
      ),
      displayMedium: GoogleFonts.figtree(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColorDark,
      ),
      bodyLarge: GoogleFonts.figtree(
        fontSize: 16,
        color: textColorDark,
      ),
      bodyMedium: GoogleFonts.figtree(
        fontSize: 14,
        color: secondaryTextColorDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        textStyle: GoogleFonts.figtree(fontSize: 18),
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
      hintStyle: GoogleFonts.figtree(color: secondaryTextColorDark),
    ),
  );
}
