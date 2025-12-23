

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Light Theme Colors ---
  static const Color primaryBlue = Color(0xFF2196F3); // Material Blue
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5); // Light Grey for cards
  static const Color lightText = Colors.black87;

  // --- Dark Theme Colors ---
  static const Color darkBackground = Color(0xFF121212); // Almost Black
  static const Color darkSurface = Color(0xFF1E1E1E); // Dark Grey for cards
  static const Color darkText = Colors.white;

  // Light Theme Configuration
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightSurface,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: Colors.blueAccent,
      surface: lightSurface,
      background: lightBackground,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: lightText,
      displayColor: lightText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
  );

  // Dark Theme Configuration
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryBlue, // Keep blue accent in dark mode
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkSurface,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: Colors.blueGrey,
      surface: darkSurface,
      background: darkBackground,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: darkText,
      displayColor: darkText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
  );
}