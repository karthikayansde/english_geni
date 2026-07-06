import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class AppThemeModel {
  final String key;
  final String name;
  final ThemeData data;
  final ThemeMode mode;

  AppThemeModel({
    required this.key,
    required this.name,
    required this.data,
    required this.mode,
  });
}

class AppColorSchemes {
  final TextTheme _textTheme;

  AppColorSchemes(this._textTheme);

  ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // Soft tint canvas background seen in shared image.jpg
    scaffoldBackgroundColor: AppColors.lightScaffoldBg,
    cardColor: AppColors.white,

    colorScheme: ColorScheme.light(
      // The core structural anchor components use pure black
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.white,

      // Secondary boundaries map to subtle slate variations
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.white,

      surface: AppColors.white,
      surfaceDim: AppColors.lightSurfaceDim,
      surfaceBright: AppColors.white,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.lightSurfaceContainerLow,
      // Default material container color mapping
      surfaceContainer: AppColors.lightSurfaceContainer,
      surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,

      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      outline: AppColors.lightOutline,
      error: AppColors.lightError,
      onError: AppColors.white,
    ),
    extensions: [_lightPastelExtensions],
    textTheme: _textTheme,
  );

  ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkScaffoldBg,
    cardColor: AppColors.darkCard,

    colorScheme: ColorScheme.dark(
      primary: AppColors.white,
      onPrimary: AppColors.darkScaffoldBg,

      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkScaffoldBg,
      tertiary: AppColors.darkTertiary,
      onTertiary: AppColors.darkCard,

      surface: AppColors.darkSurface,
      surfaceDim: AppColors.darkSurfaceDim,
      surfaceBright: AppColors.darkSurfaceBright,
      surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
      surfaceContainerLow: AppColors.darkSurfaceContainerLow,
      surfaceContainer: AppColors.darkSurfaceContainer,
      surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,

      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.darkOutline,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
    ),
    extensions: [_darkPastelExtensions],
    textTheme: _textTheme,
  );

  static const String defaultThemeKey = "system";

  List<AppThemeModel> get options => [
    AppThemeModel(
      key: "system",
      name: AppStrings.themeSystem,
      mode: ThemeMode.system,
      data: light, // Set light theme as initial baseline presentation reference
    ),
    AppThemeModel(
      key: "light",
      name: AppStrings.themeLight,
      mode: ThemeMode.light,
      data: light,
    ),
    AppThemeModel(
      key: "dark",
      name: AppStrings.themeDark,
      mode: ThemeMode.dark,
      data: dark,
    ),
  ];

  static const _lightPastelExtensions = AppColorsExtension(
    featureLavender: AppColors.lightFeatureLavender, // Used on Top Challenge Card
    featureOrange: AppColors.lightFeatureOrange,   // Used on Yoga / Progress Tracker Card
    featureMint: AppColors.lightFeatureMint,     // Used on Metric / Calorie Chip
    featureBlue: AppColors.lightFeatureBlue,     // Used on Balance Display Layout
    featurePink: AppColors.lightFeaturePink,     // Used on Bottom Decorative Grid Content
    featureYellow: AppColors.lightFeatureYellow,
    featureTeal: AppColors.lightFeatureTeal,
    featureRose: AppColors.lightFeatureRose,
    featureSage: AppColors.lightFeatureSage,
    featurePurple: AppColors.lightFeaturePurple,
    success: AppColors.successGreen,
    warning: AppColors.warning,
    info: AppColors.infoBlue,
  );

  static const _darkPastelExtensions = AppColorsExtension(
    featureLavender: AppColors.darkFeatureLavender,
    featureOrange: AppColors.darkFeatureOrange,
    featureMint: AppColors.darkFeatureMint,
    featureBlue: AppColors.darkFeatureBlue,
    featurePink: AppColors.darkFeaturePink,
    featureYellow: AppColors.darkFeatureYellow,
    featureTeal: AppColors.darkFeatureTeal,
    featureRose: AppColors.darkFeatureRose,
    featureSage: AppColors.darkFeatureSage,
    featurePurple: AppColors.darkFeaturePurple,
    success: AppColors.successGreen,
    warning: AppColors.warning,
    info: AppColors.infoBlue,
  );
}

// ==========================================
// EXPANDED THEME EXTENSIONS PROPERTIES
// Custom architectural fields for the English Geni Dashboard Sub-cards
// ==========================================
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color featureLavender;
  final Color featureOrange;
  final Color featureMint;
  final Color featureBlue;
  final Color featurePink;
  final Color featureYellow;
  final Color featureTeal;
  final Color featureRose;
  final Color featureSage;
  final Color featurePurple;
  final Color success;
  final Color warning;
  final Color info;

  const AppColorsExtension({
    required this.featureLavender,
    required this.featureOrange,
    required this.featureMint,
    required this.featureBlue,
    required this.featurePink,
    required this.featureYellow,
    required this.featureTeal,
    required this.featureRose,
    required this.featureSage,
    required this.featurePurple,
    required this.success,
    required this.warning,
    required this.info,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? featureLavender,
    Color? featureOrange,
    Color? featureMint,
    Color? featureBlue,
    Color? featurePink,
    Color? featureYellow,
    Color? featureTeal,
    Color? featureRose,
    Color? featureSage,
    Color? featurePurple,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppColorsExtension(
      featureLavender: featureLavender ?? this.featureLavender,
      featureOrange: featureOrange ?? this.featureOrange,
      featureMint: featureMint ?? this.featureMint,
      featureBlue: featureBlue ?? this.featureBlue,
      featurePink: featurePink ?? this.featurePink,
      featureYellow: featureYellow ?? this.featureYellow,
      featureTeal: featureTeal ?? this.featureTeal,
      featureRose: featureRose ?? this.featureRose,
      featureSage: featureSage ?? this.featureSage,
      featurePurple: featurePurple ?? this.featurePurple,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      featureLavender: Color.lerp(featureLavender, other.featureLavender, t)!,
      featureOrange: Color.lerp(featureOrange, other.featureOrange, t)!,
      featureMint: Color.lerp(featureMint, other.featureMint, t)!,
      featureBlue: Color.lerp(featureBlue, other.featureBlue, t)!,
      featurePink: Color.lerp(featurePink, other.featurePink, t)!,
      featureYellow: Color.lerp(featureYellow, other.featureYellow, t)!,
      featureTeal: Color.lerp(featureTeal, other.featureTeal, t)!,
      featureRose: Color.lerp(featureRose, other.featureRose, t)!,
      featureSage: Color.lerp(featureSage, other.featureSage, t)!,
      featurePurple: Color.lerp(featurePurple, other.featurePurple, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}