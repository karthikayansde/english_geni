class AppDimensions {
  const AppDimensions._();

  static const AppDimensions instance = AppDimensions._();

  // Static constants
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double giant = 48.0;
  static const double colossal = 60.0;

  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 16.0;
  static const double radiusFull = 30.0;

  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;

  static const double buttonHeight = 48.0;
  static const double buttonHeightLarge = 52.0;

  static const double scaffoldPaddingHorizontal = 16.0;
  static const double scaffoldPaddingVertical = 20.0;

  static const double logoSize = 80.0;
  static const double formMaxWidth = 400.0;

  // Instance Getters (to allow access via wrapper instance param)
  double get valXs => xs;
  double get valSm => sm;
  double get valMd => md;
  double get valLg => lg;
  double get valXl => xl;
  double get valXxl => xxl;
  double get valXxxl => xxxl;
  double get valHuge => huge;
  double get valGiant => giant;
  double get valColossal => colossal;

  double get radSm => radiusSm;
  double get radMd => radiusMd;
  double get radLg => radiusLg;
  double get radFull => radiusFull;

  double get icSm => iconSm;
  double get icMd => iconMd;
  double get icLg => iconLg;
  double get icXl => iconXl;

  double get btnHeight => buttonHeight;
  double get btnHeightLg => buttonHeightLarge;

  double get padHorizontal => scaffoldPaddingHorizontal;
  double get padVertical => scaffoldPaddingVertical;

  double get sizeLogo => logoSize;
  double get maxWidthForm => formMaxWidth;
}