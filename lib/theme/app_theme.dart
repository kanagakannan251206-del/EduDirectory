import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryDeep = Color(0xFF0D1B2A);
  static const Color primaryNavy = Color(0xFF1B263B);
  static const Color accentGold = Color(0xFFE8B84B);
  static const Color accentTeal = Color(0xFF00B4D8);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentGreen = Color(0xFF2DCE89);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFFADB5BD);
  static const Color divider = Color(0xFFE9ECEF);
  static const Color errorRed = Color(0xFFDC3545);
  static const Color warningAmber = Color(0xFFFFC107);

  // Department Colors
  static const Map<String, Color> departmentColors = {
    'Computer Science': Color(0xFF4361EE),
    'Mathematics': Color(0xFF7209B7),
    'Physics': Color(0xFF3A0CA3),
    'Chemistry': Color(0xFFE63946),
    'Biology': Color(0xFF2DC653),
    'English': Color(0xFFF77F00),
    'History': Color(0xFF8B5E3C),
    'Economics': Color(0xFF00B4D8),
    'Engineering': Color(0xFF0077B6),
    'Arts': Color(0xFFE040FB),
    'Administration': Color(0xFF455A64),
    'Emergency': Color(0xFFFF1744),
  };

  static Color getDepartmentColor(String dept) {
    return departmentColors[dept] ?? accentTeal;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        brightness: Brightness.light,
        primary: primaryNavy,
        secondary: accentGold,
        tertiary: accentTeal,
        surface: surfaceLight,
        error: errorRed,
      ),
      scaffoldBackgroundColor: surfaceLight,
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 28, // Reduced from 32
          fontWeight: FontWeight.bold, 
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 24, // Reduced from 26
          fontWeight: FontWeight.bold, 
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 20, // Reduced from 22
          fontWeight: FontWeight.w700, 
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 16, // Reduced from 18 - This affects your "Overview" titles
          fontWeight: FontWeight.w600, 
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 15, // Reduced from 16
          fontWeight: FontWeight.w600, 
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 13, // Reduced from 14
          fontWeight: FontWeight.w500, 
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(fontSize: 14, color: textPrimary), // Reduced from 16
        bodyMedium: GoogleFonts.dmSans(fontSize: 13, color: textSecondary), // Reduced from 14
        bodySmall: GoogleFonts.dmSans(fontSize: 11, color: textMuted), // Reduced from 12
        labelLarge: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 17, // Reduced from 18
          fontWeight: FontWeight.w700, 
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 1, // Reduced shadow for a cleaner look
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Sharper corners (16 -> 12)
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Tighter padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Sharper corners
          textStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryNavy, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.dmSans(color: textMuted, fontSize: 13),
      ),
      // ... keep other themes same or slightly adjusted ...
    );
  }
}
