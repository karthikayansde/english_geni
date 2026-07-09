import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/video_player/video_player_screen.dart';
import '../../features/speed_reading/speed_reading_screen.dart';
import '../services/smart_dialogs.dart';
import '../services/local_storage_service.dart';
import 'route_names.dart';

class AppTransitions {
  static Page fadeIn(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  static Page slideFromRight(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, child) =>
          SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                .animate(animation),
            child: child,
          ),
    );
  }

  static Page noTransition(GoRouterState state, Widget child) {
    return NoTransitionPage(key: state.pageKey, child: child);
  }
}

class AppRouter {
  static GlobalKey<NavigatorState> get navigatorKey => SmartDialogs.navigatorKey;

  static String get initialRoute {
    try {
      final storage = Get.find<LocalStorageService>();
      final bool isLoggedIn = storage.read<bool>('isLoggedIn') ?? false;
      return isLoggedIn ? RouteNames.home : RouteNames.login;
    } catch (_) {
      return RouteNames.login;
    }
  }

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialRoute,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) {
      final location = state.uri.toString();
      final lowercaseLocation = location.toLowerCase();
      final hasVideoExtension = lowercaseLocation.contains('.mkv') || 
                                lowercaseLocation.contains('.mp4') || 
                                lowercaseLocation.contains('.avi') || 
                                lowercaseLocation.contains('.mov') || 
                                lowercaseLocation.contains('.3gp') || 
                                lowercaseLocation.contains('.webm');

      // If it is a platform file path / content intent, redirect to the video player
      if (location.startsWith('content://') || 
          location.startsWith('file://') || 
          state.uri.scheme == 'content' ||
          state.uri.scheme == 'file' ||
          hasVideoExtension) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go(
            Uri(
              path: RouteNames.videoPlayer,
              queryParameters: {'path': location},
            ).toString(),
          );
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Default error screen
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Route not found:\n${state.error}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => initialRoute,
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) => AppTransitions.fadeIn(
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.signup,
        pageBuilder: (context, state) => AppTransitions.slideFromRight(
          state,
          const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPass,
        pageBuilder: (context, state) => AppTransitions.slideFromRight(
          state,
          const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.videoPlayer,
        builder: (context, state) {
          final path = state.uri.queryParameters['path'] ?? (state.extra as String? ?? '');
          return VideoPlayerScreen(videoPath: path);
        },
      ),
      GoRoute(
        path: RouteNames.speedReading,
        builder: (context, state) => const SpeedReadingScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
