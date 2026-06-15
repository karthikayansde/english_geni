class AppStrings {
  const AppStrings._();

  static const AppStrings instance = AppStrings._();

  String get appName => "English Geni";
  
  // theme
  String get themeSystem => "System";
  String get themeLight => "Light";
  String get themeDark => "Dark";

  // Dashboard / Tabs
  String get homeTabTitle => "Home Tab";
  String get homeTabDesc => "Welcome to English Geni! This dashboard screen is wrapped in a ScaffoldWrapper and uses static constant files directly.";
  String get successMsg => "Success theme colors are active!";

  String get analyticsTabTitle => "Analytics Tab";
  String get analyticsTabDesc => "This screen is scrollable and padded automatically using preset styling values.";
  String get infoMsg => "Info style color: infoBlue.";

  String get settingsTabTitle => "Settings Tab";
  String get settingsTabDesc => "You can toggle between different theme states with these helper classes.";
  String get warningMsg => "Warning style color: warning.";
}

const AppStrings appStrings = AppStrings.instance;