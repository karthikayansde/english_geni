import 'package:flutter/material.dart';

class AppTextStyles {
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  AppTextStyles(this.textTheme, this.colorScheme);

  // --- Auth & Generic Titles ---
  
  TextStyle? get screenTitle => textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
      );

  TextStyle? get screenSubtitle => textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      );

  TextStyle? get appBarTitle => textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
      );

  TextStyle? get actionLinkLabel => textTheme.titleSmall?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w800,
      );

  TextStyle? get actionLinkUnderlined => textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
      );

  TextStyle? get actionTextSecondary => textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      );

  TextStyle? get buttonLabelOnPrimary => textTheme.labelLarge?.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.w800,
      );

  TextStyle? get buttonLabelPrimary => textTheme.labelLarge?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w800,
      );

  // --- Home Dashboard ---

  TextStyle? get homeHeadline => textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w900,
      );

  TextStyle? get homeCardTitleBold => textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      );

  TextStyle? get homeCardSubtitleMuted => textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      );

  TextStyle? get homeCardBodyMuted => textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      );

  TextStyle? get progressTargetText => textTheme.titleMedium?.copyWith(
        color: colorScheme.onPrimary.withOpacity(0.8),
      );

  TextStyle? get progressHoursText => textTheme.headlineMedium?.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
      );

  TextStyle? get profileNameBold => textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      );

  TextStyle? get profileOptionTitleBold => textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      );

  TextStyle profileOptionTitleCustomColor(Color color) => textTheme.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ) ?? TextStyle(color: color, fontWeight: FontWeight.bold);

  // --- New Home Mockup Styles ---
  TextStyle? get homeGreeting => textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      );

  TextStyle? get homeDate => textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      );

  TextStyle? get challengeTitle => textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w900,
      );

  TextStyle? get challengeSubtitle => textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      );

  TextStyle? get calendarDaySelected => textTheme.bodyMedium?.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
      );

  TextStyle? get calendarDayUnselected => textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      );

  TextStyle? get calendarWeekdaySelected => textTheme.bodySmall?.copyWith(
        color: colorScheme.onPrimary.withOpacity(0.85),
        fontWeight: FontWeight.bold,
      );

  TextStyle? get calendarWeekdayUnselected => textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      );
}
