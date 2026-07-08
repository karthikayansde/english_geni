import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'core/theme/app_color_schemes.dart';
import 'core/theme/app_text_theme.dart';
import 'core/theme/app_theme.dart';
import 'core/services/local_storage_service.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_names.dart';
import 'package:get/get.dart';
import 'core/services/smart_snack_bars.dart';
import 'core/services/supabase_service.dart';
import 'core/services/auth_service.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/domain/usecases/resend_otp_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/verify_recovery_otp_usecase.dart';
import 'features/auth/domain/usecases/update_password_usecase.dart';
import 'features/auth/domain/usecases/change_password_from_profile_usecase.dart';
import 'features/auth/domain/usecases/update_display_name_usecase.dart';
import 'features/auth/domain/usecases/soft_delete_account_usecase.dart';
import 'features/auth/domain/usecases/complete_reactivation_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  // Register clean architecture global dependencies
  final remoteDataSource = AuthRemoteDataSourceImpl(supabase: supabase);
  final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
  Get.put<AuthService>(
    AuthService(
      signUpUseCase: SignUpUseCase(repository),
      verifyOtpUseCase: VerifyOtpUseCase(repository),
      resendOtpUseCase: ResendOtpUseCase(repository),
      loginUseCase: LoginUseCase(repository),
      forgotPasswordUseCase: ForgotPasswordUseCase(repository),
      verifyRecoveryOtpUseCase: VerifyRecoveryOtpUseCase(repository),
      updatePasswordUseCase: UpdatePasswordUseCase(repository),
      changePasswordFromProfileUseCase: ChangePasswordFromProfileUseCase(repository),
      updateDisplayNameUseCase: UpdateDisplayNameUseCase(repository),
      softDeleteAccountUseCase: SoftDeleteAccountUseCase(repository),
      completeReactivationUseCase: CompleteReactivationUseCase(repository),
    ),
    permanent: true,
  );

  final storage = LocalStorageService();
  await storage.init();
  Get.put<LocalStorageService>(storage, permanent: true);

  final schemes = AppColorSchemes(AppTextTheme.textTheme);
  AppTheme(
    isNative: true,
    colorSchemes: schemes.options,
    storage: storage,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    // 1. Handle app launch from cold state when clicking a video
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    });

    // 2. Handle app wake up from background state when clicking a video
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    final path = uri.toString();
    if (path.isNotEmpty) {
      AppRouter.router.push(
        Uri(
          path: RouteNames.videoPlayer,
          queryParameters: {'path': path},
        ).toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme.instance.themeWrapper(
      (theme, darkTheme, themeMode) {
        return MaterialApp.router(
          scaffoldMessengerKey: SmartSnackBars.messengerKey,
          debugShowCheckedModeBanner: false,
          title: 'English Geni',
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}