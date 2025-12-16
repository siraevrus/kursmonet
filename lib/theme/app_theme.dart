import 'package:flutter/material.dart';

class AppTheme {
  // Цветовая палитра
  static const Color backgroundApp = Color(0xFF020617); // Slate-950
  static const Color backgroundCard = Color(0xFF1E293B); // Slate-800
  static const Color backgroundHeader = Color(0xFF0F172A); // Slate-900
  static const Color accentPrimary = Color(0xFF2563EB); // Blue-600
  static const Color textPrimary = Color(0xFFFFFFFF); // Белый
  static const Color textSecondary = Color(0xFF94A3B8); // Slate-400
  static const Color dividerBorder = Color(0xFF334155); // Slate-700
  static const Color deleteButton = Color(0xFFEF4444); // Red-500

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundApp,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        surface: backgroundCard,
        onSurface: textPrimary,
        onPrimary: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundHeader,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}





