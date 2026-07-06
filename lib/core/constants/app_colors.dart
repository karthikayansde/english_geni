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

  // --- LIGHT THEME PALETTE ---
  static const Color lightScaffoldBg = Color(0xFFF5F5FA);
  static const Color lightPrimary = Color(0xFF111115);
  static const Color lightSecondary = Color(0xFF6C6E7A);
  static const Color lightSurfaceDim = Color(0xFFEAEAF2);
  static const Color lightSurfaceContainerLow = Color(0xFFF1F1F7);
  static const Color lightSurfaceContainer = Color(0xFFEBEBEF);
  static const Color lightSurfaceContainerHigh = Color(0xFFDCDCE2);
  static const Color lightSurfaceContainerHighest = Color(0xFFC0C0C6);
  static const Color lightOnSurface = Color(0xFF111115);
  static const Color lightOnSurfaceVariant = Color(0xFF767986);
  static const Color lightOutline = Color(0xFFBCBCC6);
  static const Color lightError = Color(0xFFBA1A1A);

  // --- LIGHT PASTEL EXTENSION PALETTE ---
  static const Color lightFeatureLavender = Color(0xFFCDCEFF);
  static const Color lightFeatureOrange = Color(0xFFFFCE9F);
  static const Color lightFeatureMint = Color(0xFFBFF2C8);
  static const Color lightFeatureBlue = Color(0xFFBFE0FF);
  static const Color lightFeaturePink = Color(0xFFFFC0EA);

  // --- ADDITIONAL LIGHT PASTEL EXTENSION PALETTE ---
  static const Color lightFeatureYellow = Color(0xFFFFF0B3);
  static const Color lightFeatureTeal = Color(0xFFBFFCFA);
  static const Color lightFeatureRose = Color(0xFFFFC6C6);
  static const Color lightFeatureSage = Color(0xFFE2F0D9);
  static const Color lightFeaturePurple = Color(0xFFE8D5FF);

  // --- DARK THEME PALETTE ---
  static const Color darkScaffoldBg = Color(0xFF0D0D11);
  static const Color darkCard = Color(0xFF1A1A22);
  static const Color darkSecondary = Color(0xFF9094A6);
  static const Color darkTertiary = Color(0xFFB9BFFF);
  static const Color darkSurface = Color(0xFF14141A);
  static const Color darkSurfaceDim = Color(0xFF0D0D11);
  static const Color darkSurfaceBright = Color(0xFF23232F);
  static const Color darkSurfaceContainerLowest = Color(0xFF050507);
  static const Color darkSurfaceContainerLow = Color(0xFF171721);
  static const Color darkSurfaceContainer = Color(0xFF1E1E29);
  static const Color darkSurfaceContainerHigh = Color(0xFF282837);
  static const Color darkSurfaceContainerHighest = Color(0xFF333346);
  static const Color darkOnSurface = Color(0xFFE4E4ED);
  static const Color darkOnSurfaceVariant = Color(0xFFC7C7D4);
  static const Color darkOutline = Color(0xFF464654);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);

  // --- DARK PASTEL EXTENSION PALETTE ---
  static const Color darkFeatureLavender = Color(0xFF353659);
  static const Color darkFeatureOrange = Color(0xFF543D28);
  static const Color darkFeatureMint = Color(0xFF234A2B);
  static const Color darkFeatureBlue = Color(0xFF243B52);
  static const Color darkFeaturePink = Color(0xFF542544);

  // --- ADDITIONAL DARK PASTEL EXTENSION PALETTE ---
  static const Color darkFeatureYellow = Color(0xFF4A442D);
  static const Color darkFeatureTeal = Color(0xFF20484A);
  static const Color darkFeatureRose = Color(0xFF542828);
  static const Color darkFeatureSage = Color(0xFF2B3A24);
  static const Color darkFeaturePurple = Color(0xFF412854);
}