import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildHomivaTheme() {
  const primaryBlue = Color(0xFF1086DB);
  const accentBlue = Color(0xFF63B0E7);
  const textColor = Color(0xFF0F172A);

  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: primaryBlue,
      secondary: accentBlue,
      surface: Colors.white,
      background: Colors.white,
      onPrimary: Colors.white,
      onSurface: textColor,
      onBackground: textColor,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: textColor,
      displayColor: textColor,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: textColor,
    ),
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: const BorderSide(color: primaryBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.all(12),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: accentBlue.withOpacity(0.1),
      selectedColor: accentBlue,
      labelStyle: const TextStyle(color: textColor),
    ),
  );
}
