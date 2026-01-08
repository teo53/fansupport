import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/config/app_config.dart';
import 'core/utils/logger.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'shared/providers/router_provider.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration from .env file
  await AppConfig.init();

  // Initialize Supabase with config from .env
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
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

class _IdolSupportAppState extends ConsumerState<IdolSupportApp>
    with SingleTickerProviderStateMixin {
  AppState _appState = AppState.splash;
  bool _isInitialized = false;
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeOut),
    );
    _initialize();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
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

      // Splash screen will call onComplete when ready
      // No manual delay here - splash handles its own timing
    } catch (e) {
      AppLogger.error('Failed to initialize app', error: e);
      if (mounted) {
        setState(() {
          _appState = AppState.main;
          _isInitialized = true;
        });
      }
    }
  }

  /// Handle splash screen completion with smooth transition
  void _onSplashComplete() async {
    // Start fade transition
    await _transitionController.forward();
    if (mounted) {
      setState(() {
        _appState = AppState.main;
      });
    }
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
    final localeState = ref.watch(localeProvider);

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

    // Common localization config
    const localizationsDelegates = [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    // Build MaterialApp with router for main app, regular MaterialApp for splash/onboarding
    if (useRouter) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
          localizationsDelegates: localizationsDelegates,
          supportedLocales: supportedLocales,
          locale: localeState.locale,
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: home,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      locale: localeState.locale,
    );
  }
}
