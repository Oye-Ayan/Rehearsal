// Backup of previous main.dart code is preserved below as comment:
/*
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ...
}
class RehearsalApp extends StatelessWidget { ... }
*/

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/theme_notifier.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgot_password_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait for interview recording
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.primaryDark,
  ));

  runApp(const RehearsalApp());
}

class RehearsalApp extends StatefulWidget {
  const RehearsalApp({super.key});

  @override
  State<RehearsalApp> createState() => _RehearsalAppState();
}

class _RehearsalAppState extends State<RehearsalApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Error listening to deep link stream: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'rehearsal' && (uri.host == 'reset-password' || uri.path.contains('reset-password'))) {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ForgotPasswordScreen(initialToken: token),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..init()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()..init()),
      ],
      child: Consumer2<AuthService, ThemeNotifier>(
        builder: (context, auth, themeNotifier, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Rehearsal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode,
            home: auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}
