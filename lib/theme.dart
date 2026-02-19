import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiftLabTheme {
  static const Color _black = Color(0xFF000000);
  static const Color _darkGrey = Color(0xFF1E1E1E);
  static const Color _lightGrey = Color(0xFFB3B3B3);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _primary = Color(0xFFD0FD3E); // Neon Lime for accents

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _black,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        onPrimary: _black,
        secondary: _white,
        onSecondary: _black,
        surface: _darkGrey,
        onSurface: _white,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: _white,
        displayColor: _white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkGrey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: _lightGrey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
