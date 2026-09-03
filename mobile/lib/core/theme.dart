// lib/core/theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium "Pro Max" Palette (Zinc / Slate based)
  static const Color primaryDark = Color(0xFF09090B); // Zinc 950
  static const Color surfaceDark = Color(0xFF18181B); // Zinc 900
  static const Color cardDark = Color(0xFF27272A); // Zinc 800
  static const Color borderDark = Color(0xFF3F3F46); // Zinc 700
  
  // Accents are subtle and sophisticated
  static const Color accentIndigo = Color(0xFF6366F1); // Muted Indigo
  static const Color accentSilver = Color(0xFFA1A1AA); // Zinc 400
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color accentBlue = Color(0xFF3B82F6); // Blue 500
  static const Color accentPurple = Color(0xFF8B5CF6); // Violet 500
  
  static const Color textPrimary = Color(0xFFFAFAFA); // Zinc 50
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc 400
  static const Color textMuted = Color(0xFF71717A); // Zinc 500
  static const Color errorRed = Color(0xFFF87171); // Red 400

  // High-End Gradients (Monochromatic & Metallic)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF27272A), Color(0xFF18181B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF18181B), Color(0xFF09090B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Standard Cubic Bezier for smooth spring-like fluid motion
  static const Curve fluidCurve = Cubic(0.32, 0.72, 0.0, 1.0);



  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: textPrimary,
        secondary: accentIndigo,
        surface: surfaceDark,
        error: errorRed,
        onPrimary: primaryDark,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1.5, height: 1.1),
          displayMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: -1.0, height: 1.15),
          headlineLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.5, height: 1.2),
          headlineMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500, letterSpacing: -0.2),
          titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          titleMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          bodyLarge: const TextStyle(color: textPrimary, fontSize: 16, height: 1.6, letterSpacing: -0.2),
          bodyMedium: const TextStyle(color: textSecondary, fontSize: 15, height: 1.5, letterSpacing: -0.1),
          bodySmall: const TextStyle(color: textMuted, fontSize: 13),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textPrimary,
          foregroundColor: primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // More structured, less pill-shaped
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: borderDark, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderDark),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
