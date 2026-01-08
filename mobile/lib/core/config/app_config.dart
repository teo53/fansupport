import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment types
enum Environment {
  development,
  staging,
  production,
}

/// App Configuration using flutter_dotenv
///
/// This replaces the old EnvConfig class.
/// Environment variables are loaded from .env files at runtime.
///
/// Usage:
/// ```dart
/// await AppConfig.init(); // Call in main()
/// final url = AppConfig.supabaseUrl;
/// ```
class AppConfig {
  AppConfig._();

  static bool _initialized = false;

  /// Initialize configuration from .env file
  static Future<void> init({String? fileName}) async {
    if (_initialized) return;

    final envFile = fileName ?? _getEnvFileName();
    try {
      await dotenv.load(fileName: envFile);
      _initialized = true;
      if (kDebugMode) {
        printConfig();
      }
    } catch (e) {
      // Fallback to default .env if environment-specific file not found
      try {
        await dotenv.load(fileName: '.env');
        _initialized = true;
      } catch (_) {
        if (kDebugMode) {
          print('Warning: Could not load .env file');
        }
      }
    }
  }

  /// Get environment-specific .env file name
  static String _getEnvFileName() {
    const envString = String.fromEnvironment('ENV', defaultValue: 'development');
    switch (envString.toLowerCase()) {
      case 'production':
      case 'prod':
        return '.env.production';
      case 'staging':
      case 'stage':
        return '.env.staging';
      default:
        return '.env.development';
    }
  }

  /// Current environment
  static Environment get environment {
    final env = dotenv.env['ENV'] ?? 'development';
    switch (env.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
      case 'stage':
        return Environment.staging;
      default:
        return Environment.development;
    }
  }

  // Environment checks
  static bool get isDevelopment => environment == Environment.development;
  static bool get isStaging => environment == Environment.staging;
  static bool get isProduction => environment == Environment.production;

  // Supabase Configuration
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // API Configuration
  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'http://localhost:3000';

  // Stripe Configuration
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  // Feature Flags
  static bool get useMockData =>
      dotenv.env['USE_MOCK']?.toLowerCase() == 'true';

  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() != 'false';

  static bool get enableDebugMode =>
      dotenv.env['ENABLE_DEBUG_MODE']?.toLowerCase() == 'true' || isDevelopment;

  static bool get enableCrashReporting =>
      dotenv.env['ENABLE_CRASH_REPORTING']?.toLowerCase() == 'true';

  static bool get enablePerformanceMonitoring =>
      dotenv.env['ENABLE_PERFORMANCE_MONITORING']?.toLowerCase() == 'true';

  // Timeout Configuration
  static Duration get apiTimeout {
    final seconds = int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '');
    if (seconds != null) return Duration(seconds: seconds);

    switch (environment) {
      case Environment.development:
        return const Duration(seconds: 30);
      case Environment.staging:
        return const Duration(seconds: 20);
      case Environment.production:
        return const Duration(seconds: 15);
    }
  }

  static int get maxRetries {
    final retries = int.tryParse(dotenv.env['MAX_RETRIES'] ?? '');
    if (retries != null) return retries;

    switch (environment) {
      case Environment.development:
        return 5;
      case Environment.staging:
        return 3;
      case Environment.production:
        return 2;
    }
  }

  // Cache Configuration
  static int get cacheSize {
    final size = int.tryParse(dotenv.env['CACHE_SIZE'] ?? '');
    if (size != null) return size;

    switch (environment) {
      case Environment.development:
        return 50;
      case Environment.staging:
        return 100;
      case Environment.production:
        return 200;
    }
  }

  static Duration get cacheDuration {
    final minutes = int.tryParse(dotenv.env['CACHE_DURATION_MINUTES'] ?? '');
    if (minutes != null) return Duration(minutes: minutes);

    switch (environment) {
      case Environment.development:
        return const Duration(minutes: 5);
      case Environment.staging:
        return const Duration(minutes: 15);
      case Environment.production:
        return const Duration(hours: 1);
    }
  }

  // App Info
  static String get appVersion =>
      dotenv.env['APP_VERSION'] ?? '1.0.0';

  static String get buildNumber =>
      dotenv.env['BUILD_NUMBER'] ?? '1';

  /// Print current configuration (debug only)
  static void printConfig() {
    if (!kDebugMode) return;

    print('═══════════════════════════════════════');
    print('🚀 App Configuration');
    print('═══════════════════════════════════════');
    print('Environment: ${environment.name}');
    print('Supabase URL: $supabaseUrl');
    print('API URL: $apiUrl');
    print('Enable Logging: $enableLogging');
    print('Enable Debug Mode: $enableDebugMode');
    print('Use Mock Data: $useMockData');
    print('API Timeout: ${apiTimeout.inSeconds}s');
    print('Max Retries: $maxRetries');
    print('Cache Size: $cacheSize');
    print('Cache Duration: ${cacheDuration.inMinutes}min');
    print('App Version: $appVersion+$buildNumber');
    print('═══════════════════════════════════════');
  }
}
