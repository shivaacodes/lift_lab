import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color scaffoldBackground = Color(0xFF0A0D12);
  static const Color navBarColor = Color(0xFF111A17);
  static const Color fabColor = Color(0xFF121A24);
  static const Color cardColor = Color(0xFF121821);
  static const Color textColor = Color(0xFFF2F6FF);
  static const Color primaryColor = Color(0xFF7CFFB2);

  static ThemeData darkGreenTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: scaffoldBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: Color(0xFF8FD3FF),
      surface: cardColor,
      onPrimary: Color(0xFF00140A),
      onSecondary: Color(0xFF05111B),
      onSurface: textColor,
    ),
    cardColor: cardColor,
    cardTheme: const CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: Color(0x22FFFFFF)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Color(0xFF00140A),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      titleLarge: const TextStyle(
        fontWeight: FontWeight.w700,
        color: textColor,
        fontSize: 24,
        letterSpacing: -0.2,
      ),
      bodyLarge: const TextStyle(
        fontWeight: FontWeight.w600,
        color: textColor,
        fontSize: 16,
      ),
      bodyMedium: const TextStyle(
        color: Color(0xFFA9B4C7),
        fontSize: 15,
        height: 1.45,
      ),
      labelLarge: const TextStyle(
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.4,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: const Color(0xFF00140A),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fabColor,
      hintStyle: const TextStyle(color: Color(0xFFA9B4C7), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x887CFFB2)),
      ),
    ),
  );
}
