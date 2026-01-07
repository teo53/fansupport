/// Environment configuration for different build flavors
enum Environment {
  development,
  staging,
  production,
}

/// Global environment configuration
class EnvironmentConfig {
  EnvironmentConfig._();

  // Current environment - can be set via --dart-define=ENV=production
  static Environment get current {
    const envString = String.fromEnvironment('ENV', defaultValue: 'development');

    switch (envString.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }

  // Environment checks
  static bool get isDevelopment => current == Environment.development;
  static bool get isStaging => current == Environment.staging;
  static bool get isProduction => current == Environment.production;
  static bool get isNotProduction => !isProduction;

  // Environment name
  static String get name => current.name;

  // Supabase configuration
  static String get supabaseUrl {
    switch (current) {
      case Environment.development:
        return const String.fromEnvironment(
          'SUPABASE_URL_DEV',
          defaultValue: 'https://your-project.supabase.co',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'SUPABASE_URL_STAGING',
          defaultValue: 'https://your-staging-project.supabase.co',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: 'https://your-production-project.supabase.co',
        );
    }
  }

  static String get supabaseAnonKey {
    switch (current) {
      case Environment.development:
        return const String.fromEnvironment(
          'SUPABASE_ANON_KEY_DEV',
          defaultValue: 'your-dev-anon-key',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'SUPABASE_ANON_KEY_STAGING',
          defaultValue: 'your-staging-anon-key',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue: 'your-production-anon-key',
        );
    }
  }

  // Feature flags
  static bool get enableLogging => isDevelopment || isStaging;
  static bool get enableDebugMode => isDevelopment;
  static bool get enablePerformanceMonitoring => !isDevelopment;
  static bool get enableCrashReporting => isProduction;
  static bool get useMockData => isDevelopment && const bool.fromEnvironment('USE_MOCK', defaultValue: false);

  // API configuration
  static Duration get apiTimeout {
    switch (current) {
      case Environment.development:
        return const Duration(seconds: 30);
      case Environment.staging:
        return const Duration(seconds: 20);
      case Environment.production:
        return const Duration(seconds: 15);
    }
  }

  static int get maxRetries {
    switch (current) {
      case Environment.development:
        return 5;
      case Environment.staging:
        return 3;
      case Environment.production:
        return 2;
    }
  }

  // Cache configuration
  static int get cacheSize {
    switch (current) {
      case Environment.development:
        return 50; // Smaller cache for faster testing
      case Environment.staging:
        return 100;
      case Environment.production:
        return 200; // Larger cache for better performance
    }
  }

  static Duration get cacheDuration {
    switch (current) {
      case Environment.development:
        return const Duration(minutes: 5);
      case Environment.staging:
        return const Duration(minutes: 15);
      case Environment.production:
        return const Duration(hours: 1);
    }
  }

  // Print current configuration (dev only)
  static void printConfig() {
    if (!enableLogging) return;

    print('═══════════════════════════════════════');
    print('🚀 Environment: $name');
    print('═══════════════════════════════════════');
    print('Supabase URL: $supabaseUrl');
    print('Enable Logging: $enableLogging');
    print('Enable Debug Mode: $enableDebugMode');
    print('Use Mock Data: $useMockData');
    print('API Timeout: ${apiTimeout.inSeconds}s');
    print('Max Retries: $maxRetries');
    print('Cache Size: $cacheSize');
    print('Cache Duration: ${cacheDuration.inMinutes}min');
    print('═══════════════════════════════════════');
  }
}
