import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

class AppTextTheme {
  AppTextTheme._();

  static const TextTheme textTheme = TextTheme(
    // ==========================================
    // DISPLAY STYLES (Branding, Big Feature Intros)
    // ==========================================

    /// Main splash/onboarding big bold taglines
    displayLarge: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 57,
      fontWeight: FontWeight.w900, // Maximized for the "Kinetic Gym" energetic hook
      letterSpacing: -1.0,        // Tighter tracking for extra punch
      height: 1.12,
    ),

    /// Section Hero Title headers (e.g., inside empty "Mirror Lab" states)
    displayMedium: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 45,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1.15,
    ),

    displaySmall: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      height: 1.22,
    ),

    // ==========================================
    // HEADLINE STYLES (Screen Titles, Top Core Modifiers)
    // ==========================================

    /// Core Top App Bar screen titles (e.g., "English Geni" logo typography)
    headlineLarge: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 32,
      fontWeight: FontWeight.w900, // Styled heavy for branding identity
      letterSpacing: -0.5,
      height: 1.25,
    ),

    /// Section Title Headers across your 5-Tabs
    headlineMedium: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.28,
    ),

    /// Minor component header overlays (e.g., "Cinema Hub" video categories)
    headlineSmall: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.33,
    ),

    // ==========================================
    // TITLE STYLES (Cards, List Header Components)
    // ==========================================

    /// Primary Card Header titles (e.g., "Basic training", "Tongue Twister 1")
    titleLarge: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.27,
    ),

    /// Secondary subheadings inside your exercise cards
    titleMedium: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.5,
    ),

    /// Small bold text markers inside drill rows
    titleSmall: TextStyle(
      fontFamily: AppAssets.fontHead, // Kept as fontHead for crisp category labels
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
    ),

    // ==========================================
    // BODY STYLES (Core Data, Subtitles, News Feeds)
    // ==========================================

    /// CRITICAL FIELD: Core Video Interactive Subtitle Engine UI
    /// Optimized for the `Wrap` widget to give tap-to-translate tokens vertical spacing clearance.
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,    // Medium weight holds up better on dark backgrounds
      letterSpacing: 0.2,
      height: 1.6,                    // Enhanced vertical line clearance to prevent overlapping touch targets
    ),

    /// Regular running informational text blocks or dictionary explanations
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.45,
    ),

    /// Secondary minor informational captions (e.g., video timestamps, flashcard counts)
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),

    // ==========================================
    // LABEL STYLES (Buttons, Interactive Navigation Items)
    // ==========================================

    /// Core Action Button Labels (e.g., "Login Now ->", "[GET STARTED]")
    labelLarge: TextStyle(
      fontFamily: AppAssets.fontHead, // Montserrat ensures buttons look punchy and athletic
      fontSize: 14,
      fontWeight: FontWeight.w800,   // Ultra-bold for quick interactive prioritization
      letterSpacing: 0.5,
      height: 1.42,
    ),

    /// Sub-tab indicator tags / Pill filter configurations
    labelMedium: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      height: 1.33,
    ),

    /// Tiny informational tags (e.g., "4+ min", "ARTICULATION")
    labelSmall: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 10,                 // dropped slightly to fit tags nicely in micro-containers
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,           // Spaced out for clear readability at micro sizes
      height: 1.45,
    ),
  );

}


/// use case

//     Text(
//       'Water the plants 🌿',
//       style: Theme.of(context).textTheme.bodyLarge,
//     )
//
// // Custom Usage for your "Red Underline" scenario
//     Text(
//     'Task Overdue!',
//     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//       color: Colors.red,
//       decoration: TextDecoration.underline,
//       decorationColor: Colors.red,
//     ),
//   )

// Category -- Widget Examples -- Recommended Style -- Font Used
// App Navigation -- "AppBar Title --  SliverAppBar" -- headlineSmall -- Satoshi
// Page Headers -- Large Page Titles (Splash/Onboarding) -- headlineLarge -- Satoshi
// List Items -- "ListTile title --  Card Heading" -- titleMedium -- Plus Jakarta Sans
// Descriptions -- "ListTile subtitle --  Paragraphs" -- bodyMedium -- Plus Jakarta Sans
// User Input -- "TextField input text --  TextFormField" -- bodyLarge -- Plus Jakarta Sans
// Input Decoration -- "TextField hint text --  Helper text" -- bodyMedium -- Plus Jakarta Sans
// Buttons -- "ElevatedButton --  TextButton --  OutlinedButton" -- labelLarge -- Satoshi
// Dialogs -- AlertDialog Title -- titleLarge -- Plus Jakarta Sans
// Gantt Chart -- "Time labels (08:00) --  Date indicators" -- labelSmall -- Plus Jakarta Sans
// Tags/Chips -- "Category tags (e.g. --  ""Health"" --  ""Work"")" -- labelMedium -- Plus Jakarta Sans
