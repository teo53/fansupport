import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/config/env_config.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/logger.dart';
import 'core/providers/theme_provider.dart';
import 'shared/providers/router_provider.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  EnvConfig.init();
  EnvConfig.printConfig();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Set up global error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter error',
      tag: 'FLUTTER',
      error: details.exception,
      stackTrace: details.stack,
    );

    // In production, send to crash reporting service
    // e.g., Sentry.captureException(details.exception, stackTrace: details.stack);
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

enum AppState {
  splash,
  onboarding,
  main,
}

class _IdolSupportAppState extends ConsumerState<IdolSupportApp> {
  AppState _appState = AppState.splash;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Initialize app and check first launch status
  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('first_launch') ?? true;

      if (mounted) {
        setState(() {
          _appState = AppState.splash;
          _isInitialized = true;
        });
      }

      // Simulate splash screen delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _appState = isFirstLaunch ? AppState.onboarding : AppState.main;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to initialize app', error: e);
      // Default to main app on error
      if (mounted) {
        setState(() {
          _appState = AppState.main;
          _isInitialized = true;
        });
      }
    }
  }

  /// Handle splash screen completion
  void _onSplashComplete() {
    setState(() {
      _appState = AppState.main;
    });
  }

  /// Handle onboarding completion
  Future<void> _onOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_launch', false);

      if (mounted) {
        setState(() {
          _appState = AppState.main;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to save onboarding status', error: e);
      // Continue to main app anyway
      if (mounted) {
        setState(() {
          _appState = AppState.main;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Determine which screen to show based on app state
    Widget? home;
    bool useRouter = false;

    switch (_appState) {
      case AppState.splash:
        home = SplashScreen(onComplete: _onSplashComplete);
        break;
      case AppState.onboarding:
        home = OnboardingScreen(onComplete: _onOnboardingComplete);
        break;
      case AppState.main:
        useRouter = true;
        break;
    }

    // Build MaterialApp with router for main app, regular MaterialApp for splash/onboarding
    if (useRouter) {
      return MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: home,
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
