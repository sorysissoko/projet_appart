import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette de couleurs issue de la configuration Tailwind / CSS
abstract class AppColors {
  static const Color background = Color(0xFFF4F6FB);
  static const Color foreground = Color(0xFF3127ED);

  static const Color card = Color(0xFF000075);
  static const Color cardForeground = Color(0xFF2563EB);

  static const Color primary = Color(0xFF0C0CDF);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFFEEF2FA);
  static const Color secondaryForeground = Color(0xFF1B3A6B);

  static const Color mutedForeground = Color(0xFF64748B);

  static const Color accent = Color(0xFFC9913A);
  static const Color accentForeground = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color border = Color(0xFFE2E8F0);

  static const Color inputText = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF1E3A5F);
  static const Color muted = Color(0xFF64748B);
  static const Color iconcolor = Color(0xFF2563EB);

  static const Color cardbo = Color(0xFFC3D3F4);
  static const Color avatarRes = Color(0xFF1B3A6B);
}

/// Configuration globale du thème ThemeData pour l'application Flutter
class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,

      // Palette de couleurs Material 3
      colorScheme: const ColorScheme.light(
        surface: AppColors.card,
        onSurface: AppColors.cardForeground,
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        error: AppColors.danger,
        outline: AppColors.border,
      ),

      // Typographie : Inter pour le texte courant, Outfit pour les titres (h1-h6)
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.foreground,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.foreground,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.outfit(
          color: AppColors.foreground,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: AppColors.foreground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.outfit(
          color: AppColors.foreground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.outfit(
          color: AppColors.foreground,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.foreground,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.foreground,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.mutedForeground,
          fontSize: 12,
        ),
      ),
    );
  }
}