import 'package:flutter/material.dart';

import 'glassmorphism.dart';

/// Application-wide [ThemeData] factory for dark and light modes.
///
/// Implements a glassmorphism design language with frosted-glass
/// surfaces, soft gradients, and subtle borders.
abstract final class AppTheme {
  // ── Colour Palette ────────────────────────────────────────

  // Primary brand colour — electric blue.
  static const Color _primaryLight = Color(0xFF4A90D9);
  static const Color _primaryDark = Color(0xFF64B5F6);

  // Surface colours for glassmorphism layers.
  static const Color _surfaceLight = Color(0xFFF5F5F7);
  static const Color _surfaceDark = Color(0xFF121212);

  static const Color _cardLight = Color(0xCCFFFFFF); // 80% white
  static const Color _cardDark = Color(0x33FFFFFF); // 20% white

  // ── Light Theme ───────────────────────────────────────────

  /// Creates the light [ThemeData] with glassmorphism tokens.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryLight,
      brightness: Brightness.light,
      surface: _surfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _surfaceLight,
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: _cardLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: Glassmorphism.defaultRadius,
          side: Glassmorphism.borderSide(Brightness.light),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardLight,
        border: OutlineInputBorder(
          borderRadius: Glassmorphism.defaultRadius,
          borderSide: Glassmorphism.borderSide(Brightness.light),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Glassmorphism.defaultRadius,
          borderSide: Glassmorphism.borderSide(Brightness.light),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Glassmorphism.defaultRadius,
          borderSide: BorderSide(color: _primaryLight, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: Glassmorphism.defaultRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      extensions: const [
        GlassmorphismTheme(
          blurSigma: 24,
          tintOpacity: 0.15,
          borderOpacity: 0.18,
          brightness: Brightness.light,
        ),
      ],
    );
  }

  // ── Dark Theme ────────────────────────────────────────────

  /// Creates the dark [ThemeData] with glassmorphism tokens.
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryDark,
      brightness: Brightness.dark,
      surface: _surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _surfaceDark,
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: _cardDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: Glassmorphism.defaultRadius,
          side: Glassmorphism.borderSide(Brightness.dark),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardDark,
        border: OutlineInputBorder(
          borderRadius: Glassmorphism.defaultRadius,
          borderSide: Glassmorphism.borderSide(Brightness.dark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Glassmorphism.defaultRadius,
          borderSide: Glassmorphism.borderSide(Brightness.dark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Glassmorphism.defaultRadius,
          borderSide: BorderSide(color: _primaryDark, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: Glassmorphism.defaultRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      extensions: const [
        GlassmorphismTheme(
          blurSigma: 30,
          tintOpacity: 0.10,
          borderOpacity: 0.12,
          brightness: Brightness.dark,
        ),
      ],
    );
  }
}
