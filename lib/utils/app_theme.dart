import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF30D6B8);      // teal/green accent
  static const Color secondary = Color(0xFF00B894);
  static const Color background = Color(0xFF000000);   // true black
  static const Color surface = Color(0xFF1C1C1E);       // card base (glass tint)
  static const Color success = Color(0xFF30D6B8);
  static const Color warning = Color(0xFFFFB340);
  static const Color danger = Color(0xFFFF4D4D);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF9A9A9E);

  // Add this new method inside AppTheme class
static Widget glassCard({
  required Widget child,
  double borderRadius = 16,
  Color? color,
  EdgeInsetsGeometry? padding,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: padding,
        decoration: glassDecoration(borderRadius: borderRadius, color: color),
        child: child,
      ),
    ),
  );
}

  // Liquid glass card decoration
  static BoxDecoration glassDecoration({
    double borderRadius = 16,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? surface).withValues(alpha:0.15),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha:0.08),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.4),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Background gradient for screens (subtle, dark, glassy)
  static BoxDecoration get screenBackground => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E0D),
            Color(0xFF000000),
          ],
        ),
      );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: GoogleFonts.inter(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha:0.06),
        hintStyle: GoogleFonts.inter(color: textSecondary),
        labelStyle: GoogleFonts.inter(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.black,
      ),
    );
  }
}