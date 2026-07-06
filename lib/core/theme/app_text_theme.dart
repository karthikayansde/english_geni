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
      fontWeight: FontWeight.w900,
      letterSpacing: -1.0,
      height: 1.12,
    ),

    /// Section Hero Title headers
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
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1.25,
    ),

    /// Section Title Headers
    headlineMedium: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 20,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      height: 1.28,
    ),

    /// Minor component header overlays
    headlineSmall: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.33,
    ),

    // ==========================================
    // TITLE STYLES (Cards, List Header Components)
    // ==========================================

    /// Primary Card Header titles
    titleLarge: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 18,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      height: 1.27,
    ),

    /// Secondary subheadings inside cards / list titles
    titleMedium: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.15,
      height: 1.5,
    ),

    /// Small bold text markers inside drill rows
    titleSmall: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
    ),

    // ==========================================
    // BODY STYLES (Core Data, Subtitles, News Feeds)
    // ==========================================

    /// CRITICAL FIELD: Core Subtitles or body text
    bodyLarge: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.5,
    ),

    /// Regular running informational text blocks
    bodyMedium: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.45,
    ),

    /// Secondary minor informational captions (e.g. metadata)
    bodySmall: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.33,
    ),

    // ==========================================
    // LABEL STYLES (Buttons, Interactive Navigation Items)
    // ==========================================

    /// Core Action Button Labels
    labelLarge: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 13,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
      height: 1.42,
    ),

    /// Sub-tab indicator tags / Pill filter configurations
    labelMedium: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      height: 1.33,
    ),

    /// Tiny informational tags
    labelSmall: TextStyle(
      fontFamily: AppAssets.fontHead,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
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
