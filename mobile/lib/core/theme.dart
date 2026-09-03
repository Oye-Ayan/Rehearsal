import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium "Pro Max" Palette (Zinc / Slate based)
  static const Color primaryDark = Color(0xFF09090B); // Zinc 950
  static const Color surfaceDark = Color(0xFF18181B); // Zinc 900
  static const Color cardDark = Color(0xFF27272A); // Zinc 800
  static const Color borderDark = Color(0xFF3F3F46); // Zinc 700
  
  // Light Palette
  static const Color primaryLight = Color(0xFFF4F4F5); // Zinc 100
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color cardLight = Color(0xFFFAFAFA); // Zinc 50
  static const Color borderLight = Color(0xFFE4E4E7); // Zinc 200

  // Accents are subtle and sophisticated (Aligned with app icon blue/indigo)
  static const Color accentIndigo = Color(0xFF6366F1); // Muted Indigo
  static const Color accentSilver = Color(0xFFA1A1AA); // Zinc 400
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color accentBlue = Color(0xFF3B82F6); // Blue 500
  static const Color accentPurple = Color(0xFF8B5CF6); // Violet 500
  
  static const Color textPrimary = Color(0xFFFAFAFA); // Zinc 50
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc 400
  static const Color textMuted = Color(0xFF71717A); // Zinc 500
  static const Color errorRed = Color(0xFFF87171); // Red 400

  static const Color textPrimaryLight = Color(0xFF09090B); // Zinc 950
  static const Color textSecondaryLight = Color(0xFF52525B); // Zinc 600
  static const Color textMutedLight = Color(0xFFA1A1AA); // Zinc 400

  // Liquid Glass Aesthetic Colors & Gradients
  static const Color glassBorderDark = Color(0x26FFFFFF); // 15% White specular stroke
  static const Color glassBorderLight = Color(0x33000000); // 20% Dark specular stroke
  
  static const LinearGradient liquidGlassGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x24FFFFFF), // Translucent specular top-left highlight
      Color(0x0CFFFFFF), // Soft liquid glass surface
    ],
  );

  static const LinearGradient liquidGlassGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xCCFFFFFF), // Frosted glass light surface
      Color(0x99FFFFFF), // Soft reflection
    ],
  );

  // Helper widget to wrap any content in a Liquid Glass Container
  static Widget glassCard({
    Key? key,
    required Widget child,
    required bool isDark,
    double blur = 16.0,
    double borderRadius = 24.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? borderColor,
    double borderWidth = 1.0,
    VoidCallback? onTap,
  }) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: isDark ? liquidGlassGradientDark : liquidGlassGradientLight,
      border: Border.all(
        color: borderColor ?? (isDark ? glassBorderDark : glassBorderLight),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.25) : accentBlue.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: decoration,
          child: child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin, child: content);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  // Standard Cubic Bezier for smooth spring-like fluid motion
  static const Curve fluidCurve = Cubic(0.32, 0.72, 0.0, 1.0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: textPrimary,
        secondary: accentBlue,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderDark, width: 1),
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
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
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
          side: const BorderSide(color: borderDark),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: primaryLight,
      colorScheme: const ColorScheme.light(
        primary: textPrimaryLight,
        secondary: accentBlue,
        surface: surfaceLight,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: const TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w700, letterSpacing: -1.5, height: 1.1),
          displayMedium: const TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w600, letterSpacing: -1.0, height: 1.15),
          headlineLarge: const TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w600, letterSpacing: -0.5, height: 1.2),
          headlineMedium: const TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w500, letterSpacing: -0.2),
          titleLarge: const TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w500),
          titleMedium: const TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w500),
          bodyLarge: const TextStyle(color: textPrimaryLight, fontSize: 16, height: 1.6, letterSpacing: -0.2),
          bodyMedium: const TextStyle(color: textSecondaryLight, fontSize: 15, height: 1.5, letterSpacing: -0.1),
          bodySmall: const TextStyle(color: textMutedLight, fontSize: 13),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textPrimaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryLight,
          side: const BorderSide(color: borderLight, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(color: textSecondaryLight),
        hintStyle: const TextStyle(color: textMutedLight),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: GoogleFonts.inter(color: textPrimaryLight, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderLight),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
