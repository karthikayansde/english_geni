import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
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

  Future<void> verifyRecoveryOtp({required String email, required String token});

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

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl({required this.supabase});
  @override
  Future<void> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    User? user;
    bool isDuplicate = false;

    try {
      final res = await supabase.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: {'display_name': displayName},
      );
      user = res.user;
      if (user != null &&
          user.identities != null &&
          user.identities!.isEmpty) {
        isDuplicate = true;
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already exists') ||
          msg.contains('already registered') ||
          msg.contains('already been registered')) {
        isDuplicate = true;
      } else {
        throw Exception(e.message);
      }
    }

    if (isDuplicate) {
      Map<String, dynamic>? existing;
      
      // Try querying by uid first if we have the user object
      if (user != null) {
        try {
          existing = await supabase
              .from('profiles')
              .select('uid, is_deleted')
              .eq('uid', user.id)
              .maybeSingle();
        } catch (_) {}
      }

      // Fall back to querying by email
      if (existing == null) {
        try {
          existing = await supabase
              .from('profiles')
              .select('uid, is_deleted')
              .eq('email', trimmedEmail)
              .maybeSingle();
        } catch (_) {}
      }

      if (existing != null && existing['is_deleted'] == true) {
        // send OTP instead of requiring old password
        await supabase.auth.resetPasswordForEmail(trimmedEmail);
        throw Exception('RECOVER_DELETED_ACCOUNT'); // special signal, not a real error
      }

      throw Exception(
        'An account with this email already exists. Please log in or reset your password.',
      );
    }
  }

  @override
  Future<void> verifySignupOtp({
    required String email,
    required String token,
  }) async {
    try {
      await supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email.trim().toLowerCase(),
        token: token.trim(),
      );

      final user = supabase.auth.currentUser;
      if (user != null) {
        final displayName = user.userMetadata?['display_name'] as String? ?? '';
        await supabase.from('profiles').upsert({
          'uid': user.id,
          'display_name': displayName,
          'email': user.email ?? email.trim().toLowerCase(),
          'is_deleted': false,
        });
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> resendSignupOtp(String email) async {
    try {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: email.trim().toLowerCase(),
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = supabase.auth.currentUser;
      if (user != null) {
        final profile = await supabase
            .from('profiles')
            .select('is_deleted')
            .eq('uid', user.id)
            .maybeSingle();

        if (profile == null) {
          final displayName = user.userMetadata?['display_name'] as String? ?? '';
          await supabase.from('profiles').upsert({
            'uid': user.id,
            'display_name': displayName,
            'email': user.email ?? email.trim().toLowerCase(),
            'is_deleted': false,
          });
        } else if (profile['is_deleted'] == true) {
          await supabase.auth.signOut();
          throw Exception('This account has been deleted');
        }
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email.trim().toLowerCase());
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  // Future<void> verifyRecoveryOtp({
  //   required String email,
  //   required String token,
  // }) async {
  //   try {
  //     await supabase.auth.verifyOTP(
  //       type: OtpType.recovery,
  //       email: email.trim().toLowerCase(),
  //       token: token.trim(),
  //     );
  //   } on AuthException catch (e) {
  //     throw Exception(e.message);
  //   }
  // }
  Future<void> verifyRecoveryOtp({
    required String email,
    required String token,
  }) async {
    try {
      await supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: email.trim().toLowerCase(),
        token: token.trim(),
      );

      // NEW: block deleted accounts right here too
      final userId = supabase.auth.currentUser!.id;
      final profile = await supabase.from('profiles')
          .select('is_deleted')
          .eq('uid', userId)
          .single();

      if (profile['is_deleted'] == true) {
        await supabase.auth.signOut();
        throw Exception('This account has been deleted');
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }
  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> changePasswordFromProfile({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = supabase.auth.currentUser?.email;
    if (email == null) {
      throw Exception('No active session. Please log in again.');
    }

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } on AuthException {
      throw Exception('Current password is incorrect');
    }

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> updateDisplayName(String newDisplayName) async {
    final trimmed = newDisplayName.trim();

    if (trimmed.isEmpty) {
      throw Exception('Display name cannot be empty');
    }
    if (trimmed.length < 3) {
      throw Exception('Display name must be at least 3 characters');
    }

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No active session. Please log in again.');
    }

    try {
      await supabase.from('profiles')
          .update({'display_name': trimmed})
          .eq('uid', userId);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> softDeleteAccount() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No active session. Please log in again.');
    }

    try {
      await supabase.from('profiles').update({
        'is_deleted': true,
      }).eq('uid', userId);


      await supabase.auth.signOut();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> completeReactivation({
    required String email,
    required String token,
    required String newPassword,
    required String displayName,
  }) async {
    try {
      // Verify OTP (type: recovery)
      await supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: email.trim().toLowerCase(),
        token: token.trim(),
      );

      // Update user password and display_name metadata
      await supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
          data: {'display_name': displayName},
        ),
      );

      // Reactivate the profile row and update username
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Reactivation failed. No active session established.');
      }

      await supabase.from('profiles').update({
        'is_deleted': false,
        'display_name': displayName,
        'email': email.trim().toLowerCase(),
      }).eq('uid', userId);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
