import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Purple Palette ──────────────────────────────────────────────────
  static const Color primaryPurple     = Color(0xFF7C3AED); // Violet-600
  static const Color primaryPurpleLight = Color(0xFF9F5FF1);
  static const Color primaryPurpleDark  = Color(0xFF5B21B6);
  static const Color accentPurple      = Color(0xFFA855F7); // Purple-500

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static const Color darkBackground    = Color(0xFF0F0A1E);
  static const Color darkSurface       = Color(0xFF1A1030);
  static const Color darkCard          = Color(0xFF221640);
  static const Color darkDivider       = Color(0xFF2D1F50);
  static const Color darkTextPrimary   = Color(0xFFF3F0FF);
  static const Color darkTextSecondary = Color(0xFFB39DDB);
  static const Color darkIcon          = Color(0xFFCE93D8);

  // ── Light Theme ───────────────────────────────────────────────────────────
  static const Color lightBackground    = Color(0xFFF8F5FF);
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightCard          = Color(0xFFFFFFFF);
  static const Color lightDivider       = Color(0xFFE9E0FF);
  static const Color lightTextPrimary   = Color(0xFF1A0050);
  static const Color lightTextSecondary = Color(0xFF6B4FA0);
  static const Color lightIcon          = Color(0xFF7C3AED);

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF22C55E);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color error    = Color(0xFFEF4444);
  static const Color info     = Color(0xFF3B82F6);

  // ── Ad Status Colors ──────────────────────────────────────────────────────
  static const Color statusPending  = Color(0xFFF59E0B);
  static const Color statusApproved = Color(0xFF22C55E);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusLive     = Color(0xFF8B5CF6);

  // ── Signage Board ─────────────────────────────────────────────────────────
  static const Color signageBoardBg    = Color(0xFF111827);
  static const Color signageBoardBezel = Color(0xFF1F2937);
  static const Color signageBoardLed   = Color(0xFF10B981);
}
