import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(255, 0, 0, 0);
  static const Color accentColor = Color(0xFF607D8B);
  static const Color backgroundColorLight = Colors.white;
  static const Color textColorLight = Colors.black87;
  static const Color secondaryTextColorLight = Colors.grey;

  static const Color backgroundColorDark = Color(0xFF1E293B);
  static const Color cardBackgroundColorDark = Color(0xFF0F172A);
  static const Color textColorDark = Colors.white;
  static const Color secondaryTextColorDark = Color(0xFFB4B4B4);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    hintColor: accentColor,
    scaffoldBackgroundColor: const Color(0xFFF5F8F8),
    cardColor: Colors.white,
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
        foregroundColor: Colors.white,
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
    primaryColor: primaryColor,
    hintColor: accentColor,
    scaffoldBackgroundColor: backgroundColorDark,
    cardColor: cardBackgroundColorDark,
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
        foregroundColor: Colors.white,
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
      fillColor: cardBackgroundColorDark,
      hintStyle: GoogleFonts.figtree(color: secondaryTextColorDark),
    ),
  );
}
