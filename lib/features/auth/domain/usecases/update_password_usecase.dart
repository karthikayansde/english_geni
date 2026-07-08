import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<void> call(String newPassword) {
    return repository.updatePassword(newPassword);
  }
}
