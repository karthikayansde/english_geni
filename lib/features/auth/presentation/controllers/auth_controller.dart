import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/smart_snack_bars.dart';
import '../../../../core/services/smart_dialogs.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;

  String? validateSignupInput(String displayName, String email, String password) {
    if (displayName.trim().isEmpty) return 'Display name cannot be empty';
    if (email.trim().isEmpty) return 'Email cannot be empty';
    if (password.isEmpty) return 'Password cannot be empty';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> handleSignup(
    BuildContext context, {
    required String displayName,
    required String email,
    required String password,
    required VoidCallback onVerificationRequired,
    required VoidCallback onReactivated,
    required VoidCallback onReactivationRequired,
  }) async {
    final error = validateSignupInput(displayName, email, password);
    if (error != null) {
      SmartSnackBars.showOverlay(context, message: error, type: NotificationType.error);
      return;
    }

    try {
      isLoading.value = true;
      SmartDialogs.showLoading();

      await AuthService.to.signUp(
        displayName: displayName,
        email: email,
        password: password,
      );

      // Check if a session already exists (reactivation path)
      if (supabase.auth.currentSession != null) {
        SmartDialogs.hideLoading();
        SmartSnackBars.showOverlay(
          context,
          message: 'Welcome back! Your account has been reactivated.',
          type: NotificationType.success,
        );
        onReactivated();
      } else {
        SmartDialogs.hideLoading();
        onVerificationRequired();
      }
    } catch (e) {
      SmartDialogs.hideLoading();
      final errStr = e.toString();
      if (errStr.contains('RECOVER_DELETED_ACCOUNT')) {
        onReactivationRequired();
      } else {
        SmartSnackBars.showOverlay(
          context,
          message: errStr.replaceAll('Exception: ', ''),
          type: NotificationType.error,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
