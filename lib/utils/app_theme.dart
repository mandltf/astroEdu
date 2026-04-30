// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color deepSpace = Color(0xFF080C1A);
  static const Color nebula = Color(0xFF0D1B3E);
  static const Color starlight = Color(0xFFE8F0FE);
  static const Color cosmicPurple = Color(0xFF7C3AED);
  static const Color auroraBlue = Color(0xFF3B82F6);
  static const Color solarGold = Color(0xFFF59E0B);
  static const Color marsRed = Color(0xFFEF4444);
  static const Color nebulaGreen = Color(0xFF10B981);
  static const Color cardBg = Color(0xFF111827);
  static const Color cardBorder = Color(0xFF1F2937);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepSpace,
      primaryColor: auroraBlue,
      colorScheme: const ColorScheme.dark(
        primary: auroraBlue,
        secondary: cosmicPurple,
        surface: cardBg,
        error: marsRed,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: deepSpace,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: starlight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: starlight),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: starlight, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: starlight, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: starlight, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: starlight),
        bodyLarge: TextStyle(color: Color(0xFFD1D5DB)),
        bodyMedium: TextStyle(color: Color(0xFF9CA3AF)),
        labelLarge: TextStyle(color: starlight, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: auroraBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: auroraBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: auroraBlue,
        unselectedItemColor: Color(0xFF6B7280),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}