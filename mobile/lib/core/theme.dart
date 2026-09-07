import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ==========================================
  // LIGHT MODE PALETTE (60-30-10 Rule)
  // ==========================================
  // Dominant Background (60%): Pure White (#FFFFFF) & Soft Ice Blue (#F4F7FA)
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softIceBlue = Color(0xFFF4F7FA);
  static const Color primaryLight = Color(0xFFF4F7FA); // Soft Ice Blue scaffold
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White cards/inputs
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200 structural outline

  // Structural Text & Cards (30%): Deep Slate Blue (#1E293B) & Muted Cool Gray (#64748B)
  static const Color deepSlateBlue = Color(0xFF1E293B);
  static const Color mutedCoolGray = Color(0xFF64748B);
  static const Color textPrimaryLight = Color(0xFF1E293B); // Deep Slate Blue replaces harsh pure black
  static const Color textSecondaryLight = Color(0xFF64748B); // Muted Cool Gray
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  // Accent & Interactive (10%): Confidence Teal (#0D9488) & Alert Coral (#F43F5E)
  static const Color confidenceTeal = Color(0xFF0D9488); // Primary action color ("Start Interview", "Record Answer")
  static const Color alertCoral = Color(0xFFF43F5E); // Strictly for live recording indicator or error states

  // ==========================================
  // DARK MODE PALETTE (60-30-10 Rule)
  // ==========================================
  // Dominant Background (60%): Midnight Blue-Gray (#0F172A) & Dark Charcoal (#1E293B)
  static const Color midnightBlueGray = Color(0xFF0F172A);
  static const Color darkCharcoal = Color(0xFF1E293B);
  static const Color primaryDark = Color(0xFF0F172A); // Midnight Blue-Gray (avoids pure black to prevent severe contrast glare)
  static const Color surfaceDark = Color(0xFF1E293B); // Dark Charcoal surface & cards
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155); // Slate 700 structural outline

  // Structural Text & Cards (30%): Crisp Off-White (#F8FAFC) & Slate Gray (#94A3B8)
  static const Color crispOffWhite = Color(0xFFF8FAFC);
  static const Color slateGray = Color(0xFF94A3B8);
  static const Color textPrimary = Color(0xFFF8FAFC); // Crisp Off-White pops clearly without eyestrain
  static const Color textSecondary = Color(0xFF94A3B8); // Slate Gray
  static const Color textMuted = Color(0xFF64748B); // Muted Cool Gray

  // Accent & Interactive (10%): Electric Teal (#14B8A6) & Glowing Amber (#F59E0B)
  static const Color electricTeal = Color(0xFF14B8A6); // High-visibility luminous teal for interactive actions
  static const Color glowingAmber = Color(0xFFF59E0B); // Feedback highlights & tip callouts

  // Backward compatibility & semantic aliases
  static const Color accentBlue = electricTeal; // Electric Teal
  static const Color accentIndigo = confidenceTeal; // Confidence Teal
  static const Color accentCyan = electricTeal;
  static const Color accentGreen = confidenceTeal;
  static const Color accentPurple = electricTeal;
  static const Color accentAmber = glowingAmber;
  static const Color accentSilver = slateGray; // Crisp Slate Gray (#94A3B8)
  static const Color errorRed = alertCoral; // Alert Coral (#F43F5E)
  static const Color recordingRed = alertCoral; // Alert Coral (#F43F5E)

  // Dynamic helper for interactive actions
  static Color primaryActionColor(bool isDark) => isDark ? electricTeal : confidenceTeal;
  static Color feedbackHighlightColor(bool isDark) => isDark ? glowingAmber : confidenceTeal;

  // Liquid Glass Aesthetic Colors & Gradients
  static const Color glassBorderDark = Color(0x33334155); // Slate 700 specular stroke
  static const Color glassBorderLight = Color(0x66E2E8F0); // Slate 200 specular stroke
  
  static const LinearGradient liquidGlassGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xCC1E293B), // Dark Charcoal glass with specular highlight
      Color(0xE60F172A), // Midnight Blue-Gray base
    ],
  );

  static const LinearGradient liquidGlassGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF2FFFFFF), // Frosted Pure White surface
      Color(0xE6F4F7FA), // Soft Ice Blue tint
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
          color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x0F0F172A),
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
        primary: electricTeal,
        secondary: glowingAmber,
        surface: surfaceDark,
        error: alertCoral,
        onPrimary: primaryDark,
        onSecondary: primaryDark,
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
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricTeal,
          foregroundColor: primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.1),
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
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: electricTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: alertCoral),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDark,
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
        primary: confidenceTeal,
        secondary: confidenceTeal,
        surface: surfaceLight,
        error: alertCoral,
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
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: confidenceTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.1),
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
          borderSide: const BorderSide(color: confidenceTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: alertCoral),
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
