import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/config/env_config.dart';
import 'core/utils/logger.dart';
import 'shared/providers/router_provider.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  EnvConfig.init();
  EnvConfig.printConfig();

  // Set up global error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter error',
      tag: 'FLUTTER',
      error: details.exception,
      stackTrace: details.stack,
    );

    // In production, you might want to send this to a crash reporting service
    // like Sentry or Firebase Crashlytics
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error(
      'Platform error',
      tag: 'PLATFORM',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  runApp(const ProviderScope(child: IdolSupportApp()));
}

class IdolSupportApp extends ConsumerStatefulWidget {
  const IdolSupportApp({super.key});

  @override
  ConsumerState<IdolSupportApp> createState() => _IdolSupportAppState();
}

class _IdolSupportAppState extends ConsumerState<IdolSupportApp> {
  bool _showSplash = true;
  bool _showOnboarding = false;
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('first_launch') ?? true;
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
      if (_isFirstLaunch) {
        _showOnboarding = true;
      }
    });
  }

  Future<void> _onOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // Show splash screen first
    if (_showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: SplashScreen(onComplete: _onSplashComplete),
      );
    }

    // Show onboarding for first-time users
    if (_showOnboarding) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: OnboardingScreen(onComplete: _onOnboardingComplete),
      );
    }

    // Main app
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
        Locale('ja', 'JP'),
      ],
      locale: const Locale('ko', 'KR'),
    );
  }
}
