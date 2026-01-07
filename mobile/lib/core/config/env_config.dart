import 'package:flutter/foundation.dart';

/// Environment configuration
///
/// Manages environment-specific settings like API URLs, feature flags, etc.
/// To use different environments, pass --dart-define=ENV=production when building
enum Environment {
  development,
  staging,
  production,
}

class EnvConfig {
  static Environment _environment = Environment.development;

  /// Initialize environment from build args
  static void init() {
    const envString = String.fromEnvironment('ENV', defaultValue: 'development');

    switch (envString.toLowerCase()) {
      case 'production':
      case 'prod':
        _environment = Environment.production;
        break;
      case 'staging':
      case 'stage':
        _environment = Environment.staging;
        break;
      case 'development':
      case 'dev':
      default:
        _environment = Environment.development;
        break;
    }

    if (kDebugMode) {
      print('[EnvConfig] Environment: $_environment');
    }
  }

  /// Get current environment
  static Environment get environment => _environment;

  /// Check if running in production
  static bool get isProduction => _environment == Environment.production;

  /// Check if running in development
  static bool get isDevelopment => _environment == Environment.development;

  /// Check if running in staging
  static bool get isStaging => _environment == Environment.staging;

  /// Get API base URL
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.production:
        return const String.fromEnvironment(
          'API_URL',
          defaultValue: 'https://api.idol-support.com',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'API_URL',
          defaultValue: 'https://staging-api.idol-support.com',
        );
      case Environment.development:
      default:
        return const String.fromEnvironment(
          'API_URL',
          defaultValue: 'http://localhost:3000',
        );
    }
  }

  /// Get WebSocket URL
  static String get websocketUrl {
    switch (_environment) {
      case Environment.production:
        return 'wss://ws.idol-support.com';
      case Environment.staging:
        return 'wss://staging-ws.idol-support.com';
      case Environment.development:
      default:
        return 'ws://localhost:3000';
    }
  }

  /// Enable/disable debug features
  static bool get enableDebugFeatures => !isProduction;

  /// Enable/disable analytics
  static bool get enableAnalytics => isProduction || isStaging;

  /// Enable/disable crash reporting
  static bool get enableCrashReporting => isProduction;

  /// Connection timeout in milliseconds
  static int get connectionTimeout {
    return isDevelopment ? 60000 : 30000;
  }

  /// Receive timeout in milliseconds
  static int get receiveTimeout {
    return isDevelopment ? 60000 : 30000;
  }

  /// Enable/disable logging
  static bool get enableLogging => !isProduction || kDebugMode;

  /// Stripe publishable key
  static String get stripePublishableKey {
    switch (_environment) {
      case Environment.production:
        return const String.fromEnvironment(
          'STRIPE_KEY',
          defaultValue: 'pk_live_...',
        );
      case Environment.staging:
      case Environment.development:
      default:
        return const String.fromEnvironment(
          'STRIPE_KEY',
          defaultValue: 'pk_test_...',
        );
    }
  }

  /// App version
  static String get appVersion {
    return const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  }

  /// Build number
  static String get buildNumber {
    return const String.fromEnvironment('BUILD_NUMBER', defaultValue: '1');
  }

  /// Print configuration (for debugging)
  static void printConfig() {
    if (!kDebugMode) return;

    print('=== Environment Configuration ===');
    print('Environment: $_environment');
    print('API Base URL: $apiBaseUrl');
    print('WebSocket URL: $websocketUrl');
    print('Debug Features: $enableDebugFeatures');
    print('Analytics: $enableAnalytics');
    print('Crash Reporting: $enableCrashReporting');
    print('Logging: $enableLogging');
    print('App Version: $appVersion+$buildNumber');
    print('=================================');
  }
}
