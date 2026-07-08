import '../repositories/auth_repository.dart';

class ChangePasswordFromProfileUseCase {
  final AuthRepository repository;

  ChangePasswordFromProfileUseCase(this.repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return repository.changePasswordFromProfile(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
