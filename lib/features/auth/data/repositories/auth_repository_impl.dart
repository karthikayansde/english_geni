import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> signUp({
    required String displayName,
    required String email,
    required String password,
  }) {
    return remoteDataSource.signUp(
      displayName: displayName,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> verifySignupOtp({
    required String email,
    required String token,
  }) {
    return remoteDataSource.verifySignupOtp(
      email: email,
      token: token,
    );
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return remoteDataSource.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> resendSignupOtp(String email) {
    return remoteDataSource.resendSignupOtp(email);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> verifyRecoveryOtp({
    required String email,
    required String token,
  }) {
    return remoteDataSource.verifyRecoveryOtp(
      email: email,
      token: token,
    );
  }

  @override
  Future<void> updatePassword(String newPassword) {
    return remoteDataSource.updatePassword(newPassword);
  }

  @override
  Future<void> changePasswordFromProfile({
    required String currentPassword,
    required String newPassword,
  }) {
    return remoteDataSource.changePasswordFromProfile(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> updateDisplayName(String newDisplayName) {
    return remoteDataSource.updateDisplayName(newDisplayName);
  }

  @override
  Future<void> softDeleteAccount() {
    return remoteDataSource.softDeleteAccount();
  }

  @override
  Future<void> completeReactivation({
    required String email,
    required String token,
    required String newPassword,
    required String displayName,
  }) {
    return remoteDataSource.completeReactivation(
      email: email,
      token: token,
      newPassword: newPassword,
      displayName: displayName,
    );
  }
}
