import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/otp_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
