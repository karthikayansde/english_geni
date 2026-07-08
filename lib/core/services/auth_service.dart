import 'package:get/get.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/verify_recovery_otp_usecase.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/auth/domain/usecases/change_password_from_profile_usecase.dart';
import '../../features/auth/domain/usecases/update_display_name_usecase.dart';
import '../../features/auth/domain/usecases/soft_delete_account_usecase.dart';
import '../../features/auth/domain/usecases/complete_reactivation_usecase.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';
import '../../features/home/profile_controller.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final SignUpUseCase signUpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final LoginUseCase loginUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyRecoveryOtpUseCase verifyRecoveryOtpUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final ChangePasswordFromProfileUseCase changePasswordFromProfileUseCase;
  final UpdateDisplayNameUseCase updateDisplayNameUseCase;
  final SoftDeleteAccountUseCase softDeleteAccountUseCase;
  final CompleteReactivationUseCase completeReactivationUseCase;

  AuthService({
    required this.signUpUseCase,
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
    required this.loginUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyRecoveryOtpUseCase,
    required this.updatePasswordUseCase,
    required this.changePasswordFromProfileUseCase,
    required this.updateDisplayNameUseCase,
    required this.softDeleteAccountUseCase,
    required this.completeReactivationUseCase,
  });

  @override
  void onInit() {
    super.onInit();
    if (supabase.auth.currentUser != null) {
      syncUserProfileToLocalStorage();
    }
  }

  /// Signs up a new user using displayName, email, and password
  Future<void> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    await signUpUseCase.call(
      displayName: displayName,
      email: email,
      password: password,
    );
  }

  /// Verifies the OTP token sent to the user's email during signup
  Future<void> verifySignupOtp({
    required String email,
    required String token,
  }) async {
    await verifyOtpUseCase.call(
      email: email,
      token: token,
    );

    await syncUserProfileToLocalStorage();
  }

  /// Resends the signup OTP token to the user's email
  Future<void> resendSignupOtp(String email) async {
    await resendOtpUseCase.call(email);
  }

  /// Signs in an existing user
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await loginUseCase.call(
      email: email,
      password: password,
    );

    await syncUserProfileToLocalStorage();
  }

  /// Sends a password reset email/OTP
  Future<void> sendPasswordResetEmail(String email) async {
    await forgotPasswordUseCase.call(email);
  }

  /// Verifies recovery OTP
  Future<void> verifyRecoveryOtp({
    required String email,
    required String token,
  }) async {
    await verifyRecoveryOtpUseCase.call(
      email: email,
      token: token,
    );

    await syncUserProfileToLocalStorage();
  }

  /// Updates the logged-in user's password
  Future<void> updatePassword(String newPassword) async {
    await updatePasswordUseCase.call(newPassword);

    await syncUserProfileToLocalStorage();
  }

  /// Changes password from Profile screen by verifying current password first
  Future<void> changePasswordFromProfile({
    required String currentPassword,
    required String newPassword,
  }) async {
    await changePasswordFromProfileUseCase.call(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Updates the user's display name
  Future<void> updateDisplayName(String newDisplayName) async {
    await updateDisplayNameUseCase.call(newDisplayName);
    await syncUserProfileToLocalStorage();
  }

  /// Soft deletes the current user account
  Future<void> softDeleteAccount() async {
    await softDeleteAccountUseCase.call();
    final storage = Get.find<LocalStorageService>();
    await storage.write('isLoggedIn', false);
    await storage.delete('userName');
    await storage.delete('userEmail');
  }

  /// Verifies recovery OTP and reactivates a soft-deleted account
  Future<void> completeReactivation({
    required String email,
    required String token,
    required String newPassword,
    required String displayName,
  }) async {
    await completeReactivationUseCase.call(
      email: email,
      token: token,
      newPassword: newPassword,
      displayName: displayName,
    );

    await syncUserProfileToLocalStorage();
  }

  /// Syncs user profile data from the database (`profiles` table) to local storage.
  Future<void> syncUserProfileToLocalStorage() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await supabase
          .from('profiles')
          .select('display_name, email')
          .eq('uid', user.id)
          .maybeSingle();

      final storage = Get.find<LocalStorageService>();
      if (profile != null) {
        final name = profile['display_name'] as String? ?? '';
        final email = profile['email'] as String? ?? user.email ?? '';
        final trimmedName = name.trim();
        final trimmedEmail = email.trim().toLowerCase();

        await storage.write('userName', trimmedName);
        await storage.write('userEmail', trimmedEmail);

        if (Get.isRegistered<ProfileController>()) {
          final controller = Get.find<ProfileController>();
          controller.displayName.value = trimmedName;
          controller.email.value = trimmedEmail;
        }
      } else {
        final name = user.userMetadata?['display_name'] as String? ?? '';
        final email = user.email ?? '';
        final trimmedName = name.trim();
        final trimmedEmail = email.trim().toLowerCase();

        await storage.write('userName', trimmedName);
        await storage.write('userEmail', trimmedEmail);

        if (Get.isRegistered<ProfileController>()) {
          final controller = Get.find<ProfileController>();
          controller.displayName.value = trimmedName;
          controller.email.value = trimmedEmail;
        }
      }
      await storage.write('isLoggedIn', true);
    } catch (_) {
      final storage = Get.find<LocalStorageService>();
      final name = user.userMetadata?['display_name'] as String? ?? '';
      final email = user.email ?? '';
      final trimmedName = name.trim();
      final trimmedEmail = email.trim().toLowerCase();

      await storage.write('userName', trimmedName);
      await storage.write('userEmail', trimmedEmail);

      if (Get.isRegistered<ProfileController>()) {
        final controller = Get.find<ProfileController>();
        controller.displayName.value = trimmedName;
        controller.email.value = trimmedEmail;
      }
      await storage.write('isLoggedIn', true);
    }
  }

  /// Signs out the user and clears local session storage
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (_) {}
    final storage = Get.find<LocalStorageService>();
    await storage.write('isLoggedIn', false);
    await storage.delete('userName');
    await storage.delete('userEmail');
  }
}
