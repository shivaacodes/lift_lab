import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiftLabTheme {
  // ─── Design Tokens ──────────────────────────────────────────────────────────
  static const Color _bgWhite = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  
  static const Color _orangePrimary = Color(0xFFFF7A00);
  static const Color _orangeSecondary = Color(0xFFFF9D42);
  
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [_orangePrimary, _orangeSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _bgWhite,
      colorScheme: const ColorScheme.light(
        primary: _orangePrimary,
        onPrimary: Colors.white,
        secondary: _orangeSecondary,
        onSecondary: Colors.white,
        tertiary: Color(0xFF0F172A),
        onTertiary: Colors.white,
        surface: _bgWhite,
        onSurface: _textDark,
        error: Color(0xFFEF4444),
      ),
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: _textDark,
          letterSpacing: -1.0,
        ),
        headlineSmall: baseText.headlineSmall?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: _textDark,
          letterSpacing: -0.5,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: _textDark,
          letterSpacing: -0.3,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _textDark,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.5,
          color: _textDark,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.5,
          color: _textMuted,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: _textDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: _textDark, size: 24),
        titleTextStyle: TextStyle(
          color: _textDark,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          fontFamily: 'Poppins',
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x0D000000), width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500),
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0x0D000000), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _orangePrimary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _orangePrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          elevation: 0,
          shadowColor: _orangePrimary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 58),
          side: const BorderSide(color: Color(0x1A000000), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          foregroundColor: _textDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _textDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: _orangePrimary,
        labelStyle: const TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      iconTheme: const IconThemeData(color: _textDark, size: 24),
      dividerColor: const Color(0x0D000000),
    );
  }

  // Dark theme is now just light theme because user only wants white theme.
  static ThemeData get darkTheme => lightTheme;
}
