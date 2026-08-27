// lib/core/theme.dart
// Previous: Empty file (new creation)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium OLED & Editorial Luxury palette
  static const Color primaryDark = Color(0xFF020202); // Deeper OLED black
  static const Color surfaceDark = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF111111);
  static const Color borderDark = Color(0xFF1A1A1A);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color errorRed = Color(0xFFEF4444);

  // High-End Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentBlue, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C1C1C), Color(0xFF111111)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Standard Cubic Bezier for smooth spring-like fluid motion
  static const Curve fluidCurve = Cubic(0.32, 0.72, 0.0, 1.0);

  // Outer Shell Double-Bezel Box Decoration
  static BoxDecoration doubleBezelOuter() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.02),
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
    );
  }

  // Inner Core Double-Bezel Box Decoration
  static BoxDecoration doubleBezelInner() {
    return BoxDecoration(
      color: surfaceDark,
      borderRadius: BorderRadius.circular(28), // Matches outer 32 minus padding
      border: Border.all(color: Colors.white.withValues(alpha: 0.03), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        )
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accentPurple,
        surface: surfaceDark,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -1.5, height: 1.1),
          displayMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1.0, height: 1.15),
          headlineLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2),
          headlineMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.2),
          titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          bodyLarge: const TextStyle(color: textPrimary, fontSize: 18, height: 1.6, letterSpacing: -0.2),
          bodyMedium: const TextStyle(color: textSecondary, fontSize: 16, height: 1.5, letterSpacing: -0.1),
          bodySmall: const TextStyle(color: textMuted, fontSize: 14),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textPrimary, // Invert for high-end look
          foregroundColor: primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), // fully rounded pills
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: textPrimary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
