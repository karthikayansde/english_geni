import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';

class OtpController extends GetxController {
  final isLoading = false.obs;
  final resendCooldown = 0.obs; // seconds remaining before resend allowed
  Timer? _timer;

  late final String email; // passed in via Get.arguments

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['email'] != null) {
      email = args['email'];
    } else if (args is String) {
      email = args;
    } else {
      email = '';
    }
    startCooldown();
  }

  void startCooldown() {
    resendCooldown.value = 30; // 30s cooldown
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value <= 1) {
        timer.cancel();
      }
      resendCooldown.value--;
    });
  }

  Future<void> handleVerify(String token) async {
    if (token.length != 6) {
      Get.snackbar('Error', 'Enter the 6-digit code');
      return;
    }
    try {
      isLoading.value = true;
      await AuthService.to.verifySignupOtp(email: email, token: token);
      Get.offAllNamed('/home'); // user is logged in now
    } catch (e) {
      Get.snackbar('Verification failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleResend() async {
    if (resendCooldown.value > 0) return;
    try {
      await AuthService.to.resendSignupOtp(email);
      Get.snackbar('Sent', 'A new code has been sent to $email');
      startCooldown();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
