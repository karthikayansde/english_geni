import 'package:flutter/material.dart';
import 'smart_snack_bars.dart';

class SmartDialogs {
  // Global key to access navigator
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Get context from the global key
  static BuildContext? get _context => navigatorKey.currentContext;

  // Show alert dialog
  static Future<void> showAlert({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    if (_context == null) return;

    return showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog
  static Future<bool?> showConfirmation({
    required String title,
    required String message,
    Color? buttonColor,
    String buttonText = 'OK',
    String cancelButtonText = 'Cancel',
  }) async {
    if (_context == null) return null;

    return showDialog<bool>(
      context: _context!,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelButtonText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(buttonText, style: TextStyle(color: buttonColor)),
          ),
        ],
      ),
    );
  }

  static DateTime? _lastLoadingBackPress;

  // Show full-screen loading
  static void showLoading({String message = 'Please wait...'}) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) {
        return PopScope(
          canPop: false, // Prevents closing by back button
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            
            final now = DateTime.now();
            if (_lastLoadingBackPress == null || 
                now.difference(_lastLoadingBackPress!) > const Duration(seconds: 2)) {
              _lastLoadingBackPress = now;
              SmartSnackBars.showOverlay(
                _context!,
                message: 'Please wait for the process to complete',
                type: NotificationType.info,
                duration: const Duration(seconds: 2),
              );
            }
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void hideLoading() {
    if (_context == null) return;
    Navigator.of(_context!).pop();
  }
}

// Typedef to allow usage of DialogService matching comments
typedef DialogService = SmartDialogs;
