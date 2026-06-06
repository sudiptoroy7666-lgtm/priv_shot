import 'package:flutter/material.dart';

class AppTheme {
  // Premium Color Palette
  static const Color bgDark = Color(0xFF0B132B);
  static const Color surfaceDark = Color(0xFF1C2541);
  static const Color primary = Color(0xFF3A86FF); // Vibrant Blue
  static const Color secondary = Color(0xFF8338EC); // Purple
  static const Color accent = Color(0xFFFF006E); // Pink/Red for alerts
  static const Color success = Color(0xFF06D6A0); // Mint Green
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA8B2D1);

  static LinearGradient get backgroundGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B132B), Color(0xFF1C2541), Color(0xFF0B132B)],
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surfaceDark,
      error: accent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        elevation: 8,
        shadowColor: primary.withOpacity(0.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: primary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark.withOpacity(0.6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceDark,
      selectedColor: primary.withOpacity(0.2),
      labelStyle: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Colors.white.withOpacity(0.1)),
    ),
  );
}