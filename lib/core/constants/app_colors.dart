import 'dart:ui';
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const AppColors instance = AppColors._();

  // Basic System Definitions
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // --- FEEDBACK & STATUS CONTRASTS ---
  static const Color successGreen = Color(0xFF00E676);
  static const Color infoBlue = Color(0xFF00B0FF);
  static const Color warning = Color(0xFFFF9100);
  static const Color error = Color(0xFFFF5252);

  // --- CORE KINETIC GYM SYSTEM PALETTE ---
  static const Color obsidianBase = Color(0xFF121214); // Primary 60% App Backdrop
  static const Color slateSurface = Color(0xFF1E2025); // Secondary 30% Card Container Surfaces
  static const Color slateCardLow = Color(0xFF16181B); // Slightly darker surface containment variation
  static const Color electricLime = Color(0xFFCCFF00); // Accent 10% Interactive High-Performance Pop

  // --- EDITORIAL LIGHT MODE PALETTE ---
  static const Color editorialBg = Color(0xFFF8F9FA); // Off-White clean backdrop
  static const Color paperSurface = Color(0xFFFFFFFF); // Pure white card layers
  static const Color inkText = Color(0xFF121214); // Pure dark text targeting

  // --- DYNAMIC FEATURE PASS-THROUGH SEEDS ---
  // Maps onto the soft pastel dashboard grids cleanly
  static const Color seed1 = Color(0xFFFFB300); // Feature Gold / Orange Accent
  static const Color seed2 = Color(0xFF4DFF00); // Feature Light Mint Accent
  static const Color seed3 = Color(0xFF004CFF); // Feature Lavender / Royal Blue Accent
  static const Color seed4 = Color(0xFFB300FF); // Feature Purple / Pink Accent
}