abstract class AuthRepository {
  Future<void> signUp({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> verifySignupOtp({
    required String email,
    required String token,
  });

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> resendSignupOtp(String email);

  Future<void> sendPasswordResetEmail(String email);

  Future<void> verifyRecoveryOtp({
    required String email,
    required String token,
  });

  Future<void> updatePassword(String newPassword);

  Future<void> changePasswordFromProfile({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> updateDisplayName(String newDisplayName);

  Future<void> softDeleteAccount();

  Future<void> completeReactivation({
    required String email,
    required String token,
    required String newPassword,
    required String displayName,
  });
}
