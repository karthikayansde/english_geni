import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper utility class for device-specific screen, keyboard, and system UI operations.
class UDeviceHelper {
  UDeviceHelper._();

  /// Hides the soft keyboard by unfocusing the current focus node.
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  /// Sets the status bar color (defaults to [Theme.of(context).scaffoldBackgroundColor])
  /// and automatically adjusts the icon brightness to ensure readability.
  static Future<void> setStatusBarColor(BuildContext context, {Color? color, Brightness? iconBrightness}) async {
    final targetColor = color ?? Theme.of(context).scaffoldBackgroundColor;
    final targetIconBrightness = iconBrightness ?? 
        (targetColor.computeLuminance() > 0.5 ? Brightness.dark : Brightness.light);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: targetColor,
        statusBarIconBrightness: targetIconBrightness,
        statusBarBrightness: targetIconBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark, // iOS status bar text color alignment (light status bar brightness = dark text)
      ),
    );
  }
  /// Checks if the device is currently in landscape orientation.
  static bool isLandscapeOrientation(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Checks if the device is currently in portrait orientation.
  static bool isPortraitOrientation(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.portrait;
  }

  /// Enables or disables fullscreen mode.
  static Future<void> setFullScreen(bool enable) async {
    await SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  /// Gets the height of the default Bottom Navigation Bar.
  static double getBottomNavigationBarHeight() {
    return kBottomNavigationBarHeight;
  }

  /// Gets the full height of the device screen.
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  /// Gets the full width of the device screen.
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  /// Gets the height of the default AppBar.
  static double getAppBarHeight() {
    return kToolbarHeight;
  }

  /// Gets the height of the onscreen keyboard if visible.
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.viewInsetsOf(context).bottom;
  }

  /// Checks if the onscreen keyboard is currently visible.
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.viewInsetsOf(context).bottom > 0;
  }
}
