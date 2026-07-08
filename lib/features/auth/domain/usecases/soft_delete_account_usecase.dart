import '../repositories/auth_repository.dart';

class SoftDeleteAccountUseCase {
  final AuthRepository repository;

  SoftDeleteAccountUseCase(this.repository);

  Future<void> call() {
    return repository.softDeleteAccount();
  }
}
