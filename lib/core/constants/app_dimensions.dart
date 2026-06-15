class AppDimensions {
  const AppDimensions._();

  static const AppDimensions instance = AppDimensions._();

  double get xs => 4;
  double get sm => 8;
  double get md => 16;
  double get lg => 24;
  double get xl => 32;

  double get radiusSm => 4;
  double get radiusMd => 8;
  double get radiusLg => 16;

  double get iconSm => 16;
  double get iconMd => 24;
  double get iconLg => 32;

  double get buttonHeight => 48;
}