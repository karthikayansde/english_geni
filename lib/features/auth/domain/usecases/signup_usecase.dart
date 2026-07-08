import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<void> call({
    required String displayName,
    required String email,
    required String password,
  }) {
    return repository.signUp(
      displayName: displayName,
      email: email,
      password: password,
    );
  }
}
