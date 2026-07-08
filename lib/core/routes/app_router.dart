import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/home/home_screen.dart';
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
    routes: [
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
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}



class VideoPlayerScreen extends StatelessWidget {
  final String videoPath;
  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_fill, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                "Playing Video From Path:\n$videoPath",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
