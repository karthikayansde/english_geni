import '../repositories/auth_repository.dart';

class VerifyRecoveryOtpUseCase {
  final AuthRepository repository;

  VerifyRecoveryOtpUseCase(this.repository);

  Future<void> call({
    required String email,
    required String token,
  }) {
    return repository.verifyRecoveryOtp(
      email: email,
      token: token,
    );
  }
}
