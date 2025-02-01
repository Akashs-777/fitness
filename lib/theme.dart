import 'package:flutter/material.dart';

class FitnessTheme {
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.orange,
      primaryColor: Colors.orange,
      hintColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          color: Colors.black87,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: Colors.black54,
          fontSize: 16,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: Colors.orange,
        secondary: Colors.blue,
      ),
    );
  }
}