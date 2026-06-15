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

  // ==========================================
  // PASTEL MINIMAL LIGHT THEME CONFIGURATION
  // Matches the exact visual profiles in your images
  // ==========================================
  ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // Soft tint canvas background seen in shared image.jpg
    scaffoldBackgroundColor: const Color(0xFFF5F5FA),
    cardColor: Colors.white,

    colorScheme: ColorScheme.light(
      // The core structural anchor components use pure black
      primary: const Color(0xFF111115),
      onPrimary: Colors.white,

      // Secondary boundaries map to subtle slate variations
      secondary: const Color(0xFF6C6E7A),
      onSecondary: Colors.white,

      surface: Colors.white,
      surfaceDim: const Color(0xFFEAEAF2),
      surfaceBright: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF1F1F7),
      // Default material container color mapping
      surfaceContainer: const Color(0xFFEBEBEF),
      surfaceContainerHigh: const Color(0xFFDCDCE2),
      surfaceContainerHighest: const Color(0xFFC0C0C6),

      onSurface: const Color(0xFF111115),
      onSurfaceVariant: const Color(0xFF767986),
      outline: const Color(0xFFBCBCC6),
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
    ),
    extensions: [_lightPastelExtensions],
    textTheme: _textTheme,
  );

  // ==========================================
  // PREMIUM CONTRAST DARK THEME CONFIGURATION
  // ==========================================
  ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0D11),
    cardColor: const Color(0xFF1A1A22),

    colorScheme: ColorScheme.dark(
      primary: Colors.white,
      onPrimary: const Color(0xFF0D0D11),

      secondary: const Color(0xFF9094A6),
      onSecondary: const Color(0xFF0D0D11),
      tertiary: const Color(0xFFB9BFFF),
      onTertiary: const Color(0xFF1A1A22),

      surface: const Color(0xFF14141A),
      surfaceDim: const Color(0xFF0D0D11),
      surfaceBright: const Color(0xFF23232F),
      surfaceContainerLowest: const Color(0xFF050507),
      surfaceContainerLow: const Color(0xFF171721),
      surfaceContainer: const Color(0xFF1E1E29),
      surfaceContainerHigh: const Color(0xFF282837),
      surfaceContainerHighest: const Color(0xFF333346),

      onSurface: const Color(0xFFE4E4ED),
      onSurfaceVariant: const Color(0xFFC7C7D4),
      outline: const Color(0xFF464654),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
    ),
    extensions: [_darkPastelExtensions],
    textTheme: _textTheme,
  );

  static const String defaultThemeKey = "system";

  List<AppThemeModel> get options => [
    AppThemeModel(
      key: "system",
      name: appStrings.themeSystem,
      mode: ThemeMode.system,
      data: light, // Set light theme as initial baseline presentation reference
    ),
    AppThemeModel(
      key: "light",
      name: appStrings.themeLight,
      mode: ThemeMode.light,
      data: light,
    ),
    AppThemeModel(
      key: "dark",
      name: appStrings.themeDark,
      mode: ThemeMode.dark,
      data: dark,
    ),
  ];

  // Dedicated feature pastel mappings extracted from shared image.jpg and shared image (3).jpg
  static const _lightPastelExtensions = AppColorsExtension(
    featureLavender: Color(0xFFCDCEFF), // Used on Top Challenge Card
    featureOrange: Color(0xFFFFCE9F),   // Used on Yoga / Progress Tracker Card
    featureMint: Color(0xFFBFF2C8),     // Used on Metric / Calorie Chip
    featureBlue: Color(0xFFBFE0FF),     // Used on Balance Display Layout
    featurePink: Color(0xFFFFC0EA),     // Used on Bottom Decorative Grid Content
  );

  static const _darkPastelExtensions = AppColorsExtension(
    featureLavender: Color(0xFF353659),
    featureOrange: Color(0xFF543D28),
    featureMint: Color(0xFF234A2B),
    featureBlue: Color(0xFF243B52),
    featurePink: Color(0xFF542544),
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

  const AppColorsExtension({
    required this.featureLavender,
    required this.featureOrange,
    required this.featureMint,
    required this.featureBlue,
    required this.featurePink,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? featureLavender,
    Color? featureOrange,
    Color? featureMint,
    Color? featureBlue,
    Color? featurePink,
  }) {
    return AppColorsExtension(
      featureLavender: featureLavender ?? this.featureLavender,
      featureOrange: featureOrange ?? this.featureOrange,
      featureMint: featureMint ?? this.featureMint,
      featureBlue: featureBlue ?? this.featureBlue,
      featurePink: featurePink ?? this.featurePink,
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
    );
  }
}