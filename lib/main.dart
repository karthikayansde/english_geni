import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'core/theme/app_color_schemes.dart';
import 'core/theme/app_text_theme.dart';
import 'core/theme/app_theme.dart';
import 'core/services/local_storage_service.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_names.dart';
import 'core/services/smart_snack_bars.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = LocalStorageService();
  await storage.init();

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
    final path = uri.toString().toLowerCase();
    
    // Only allow mkv, mp4, mov, webm formats
    final isAllowedExtension = path.endsWith('.mp4') ||
                               path.endsWith('.mkv') ||
                               path.endsWith('.mov') ||
                               path.endsWith('.webm');
                               
    final isContentUri = uri.scheme == 'content';

    if (isAllowedExtension || isContentUri) {
      AppRouter.router.push(
        Uri(
          path: RouteNames.videoPlayer,
          queryParameters: {'path': uri.toString()},
        ).toString(),
      );
    } else {
      debugPrint("Unsupported video format clicked: $path");
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