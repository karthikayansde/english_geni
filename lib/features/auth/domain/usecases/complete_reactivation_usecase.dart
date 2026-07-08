import '../repositories/auth_repository.dart';

class CompleteReactivationUseCase {
  final AuthRepository repository;

  CompleteReactivationUseCase(this.repository);

  Future<void> call({
    required String email,
    required String token,
    required String newPassword,
    required String displayName,
  }) {
    return repository.completeReactivation(
      email: email,
      token: token,
      newPassword: newPassword,
      displayName: displayName,
    );
  }
}
