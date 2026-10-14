// core/constants/constants.dart
import 'package:flutter/material.dart';


// COULEURS
class AppColors {
  static const Color primary = Color(0xFFE85D26);
  static const Color primaryDark = Color(0xFFD35400);
  static const Color secondary = Color(0xFF4A90D9);
  static const Color accent = Color(0xFFD4A843);
  static const Color background = Color(0xFFFFEFE0);
  static const Color surface = Color(0xFFF6DAC5);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A4A6A);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Statuts des réservations
  static const Color statusConfirmed = Color(0xFF10B981);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusCompleted = Color(0xFF8B5CF6);
  static const Color statusCancelled = Color(0xFFEF4444);
}

// PADDINGS
const double defaultPadding = 16.0;
const double defaultSpacing = 8.0;
const double defaultBorderRadius = 12.0;


// ANIMATIONS
const Duration defaultDuration = Duration(milliseconds: 300);
const Duration quickDuration = Duration(milliseconds: 150);
const Duration longDuration = Duration(milliseconds: 500);


// COULEURS
const Color primaryColor = AppColors.primary;
const Color secondaryColor = AppColors.secondary;
const Color bgColor = AppColors.background;