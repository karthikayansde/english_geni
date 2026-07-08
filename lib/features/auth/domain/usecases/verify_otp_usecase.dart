import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<void> call({
    required String email,
    required String token,
  }) {
    return repository.verifySignupOtp(
      email: email,
      token: token,
    );
  }
}
