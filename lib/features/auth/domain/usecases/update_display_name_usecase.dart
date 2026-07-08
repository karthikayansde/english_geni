import '../repositories/auth_repository.dart';

class UpdateDisplayNameUseCase {
  final AuthRepository repository;

  UpdateDisplayNameUseCase(this.repository);

  Future<void> call(String newDisplayName) {
    return repository.updateDisplayName(newDisplayName);
  }
}
