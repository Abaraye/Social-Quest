// =============================================================
// lib/core/theme/app_theme.dart  – light + dark ThemeData
// =============================================================
import 'package:flutter/material.dart';

class AppTheme {
  // Palette de base
  static const _primary = Colors.deepPurple;

  /// Thème clair principal (hérite de ton ancien `main`)
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey[50],
    primaryColor: _primary,
    colorScheme: ColorScheme.fromSeed(seedColor: _primary),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: _primary),
        foregroundColor: _primary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _primary),
        borderRadius: BorderRadius.circular(12),
      ),
      labelStyle: const TextStyle(color: Colors.black54),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _primary.shade50,
      selectedColor: _primary.shade200,
      disabledColor: Colors.grey.shade200,
      labelStyle: const TextStyle(color: Colors.black),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
  );

  /// Thème sombre rapide (à ajuster au besoin)
  static final ThemeData dark = ThemeData.dark(useMaterial3: true).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.dark,
    ),
    primaryColor: _primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 1,
    ),
  );
}
