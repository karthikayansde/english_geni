import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/smart_snack_bars.dart';
import '../../core/services/smart_dialogs.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;
  final displayName = ''.obs;
  final email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final storage = Get.find<LocalStorageService>();
    displayName.value = storage.read<String>('userName') ?? '';
    email.value = storage.read<String>('userEmail') ?? '';
  }

  Future<void> handleUpdateUsername(String newName) async {
    try {
      isLoading.value = true;
      await AuthService.to.updateDisplayName(newName);
      
      final trimmedName = newName.trim();
      displayName.value = trimmedName;

      final storage = Get.find<LocalStorageService>();
      await storage.write('userName', trimmedName);

      SmartSnackBars.showOverlay(
        Get.context!,
        message: 'Username updated successfully',
        type: NotificationType.success,
      );
    } catch (e) {
      SmartSnackBars.showOverlay(
        Get.context!,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleDeleteAccount({required VoidCallback onSuccess}) async {
    try {
      isLoading.value = true;
      SmartDialogs.showLoading(message: 'Deleting account...');
      await AuthService.to.softDeleteAccount();
      
      SmartDialogs.hideLoading();
      
      SmartSnackBars.showOverlay(
        Get.context!,
        message: 'Your account has been deleted',
        type: NotificationType.success,
      );
      
      onSuccess();
    } catch (e) {
      SmartDialogs.hideLoading();
      SmartSnackBars.showOverlay(
        Get.context!,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
