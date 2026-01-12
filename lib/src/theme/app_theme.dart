import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: Colors.purple.shade600,
      secondary: Colors.purple.shade400,
      surface: Colors.white,
      background: Colors.grey.shade50,
      error: Colors.red.shade600,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.grey.shade900,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey.shade50,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: Colors.purple.shade500,
      secondary: Colors.purple.shade300,
      surface: Colors.grey.shade900,
      background: Colors.black,
      error: Colors.red.shade400,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.grey.shade100,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Colors.grey.shade900,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade300,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade400,
      ),
    ),
  );
}
