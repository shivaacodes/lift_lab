import 'package:flutter/material.dart';

class AppTheme {
  static const Color scaffoldBackground = Color(0xFF05100E);
  static const Color navBarColor = Color(0xFFB4E61D);
  static const Color fabColor = Color(0xFF0B241E);
  static const Color cardColor = Color(0xFF0B241E);
  static const Color textColor = Color(0xFFF0FDF4);
  static const Color primaryColor = Color(0xFFB4E61D); // Using Nav Bar color as primary for consistency

  static ThemeData darkGreenTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: scaffoldBackground,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      surface: fabColor,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: textColor,
    ),
    cardColor: fabColor,
    cardTheme: const CardThemeData(
      color: fabColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: textColor, fontSize: 20),
      bodyLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: textColor),
      bodyMedium: TextStyle(fontFamily: 'Montserrat', color: textColor),
      labelLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: textColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fabColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );
}
