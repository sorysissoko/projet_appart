// screens/dashboard/constants.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── COULEURS PRINCIPALES ───
const Color primaryColor = Color(0xFF1A237E);
const Color secondaryColor = Color(0xFF2D2D35);
const Color bgColor = Color(0xFF0B1120);

// ─── COULEURS DE STATUT ───
const Color successColor = Color(0xFF10B981);
const Color warningColor = Color(0xFFF59E0B);
const Color errorColor = Color(0xFFEF4444);
const Color infoColor = Color(0xFF3B82F6);

// ─── COULEURS DE L'APPLICATION ───
const Color appPrimary = Color(0xFFE85D26);
const Color appPrimaryDark = Color(0xFFD35400);
const Color appBackground = Color(0xFFFFEFE0);
const Color appSurface = Color(0xFFF6DAC5);
const Color appTextPrimary = Color(0xFF1A1A2E);
const Color appTextSecondary = Color(0xFF4A4A6A);

// ─── PADDINGS & MARGINS ───
const double defaultPadding = 16.0;
const double defaultBorderRadius = 12.0;
const double defaultSpacing = 8.0;

// ─── SIZES ───
const double defaultIconSize = 20.0;
const double defaultFontSize = 14.0;
const double defaultTitleSize = 20.0;

// ─── ANIMATIONS ───
const Duration defaultDuration = Duration(milliseconds: 300);
const Duration quickDuration = Duration(milliseconds: 150);
const Duration longDuration = Duration(milliseconds: 500);

// ─── TEXT STYLES ───
TextStyle headingStyle = GoogleFonts.manrope(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

TextStyle subHeadingStyle = GoogleFonts.manrope(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.white70,
);

TextStyle bodyTextStyle = GoogleFonts.manrope(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: Colors.white,
);

TextStyle captionStyle = GoogleFonts.manrope(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  color: Colors.white54,
);

List<BoxShadow> defaultShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0x1A),
    blurRadius: 10,
    offset: const Offset(0, 4),
  ),
];

// ─── DECORATIONS ───
BoxDecoration cardDecoration = BoxDecoration(
  color: secondaryColor,
  borderRadius: BorderRadius.circular(defaultBorderRadius),
  border: Border.all(color: Colors.white10),
  boxShadow: defaultShadow,
);

// ─── RESPONSIVE BREAKPOINTS ───
const double mobileBreakpoint = 650;
const double tabletBreakpoint = 1100;
const double desktopBreakpoint = 1400;

// ─── URLS ───
const String supabaseUrl = 'https://rcaujtlhfyumkuwdfpcm.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';