import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('default environment should be development', () {
      // AppConfig uses const String.fromEnvironment which returns empty
      // in tests, so it defaults to development
      expect(AppConfig.isDevelopment, isTrue);
      expect(AppConfig.isProduction, isFalse);
      expect(AppConfig.isStaging, isFalse);
    });

    test('should provide default values when .env is not loaded', () {
      expect(AppConfig.supabaseUrl, isNotEmpty);
      expect(AppConfig.apiUrl, isNotEmpty);
    });

    test('apiTimeout should vary by environment', () {
      // In development mode (default), timeout should be longer
      expect(AppConfig.apiTimeout.inSeconds, greaterThanOrEqualTo(15));
    });

    test('maxRetries should be positive', () {
      expect(AppConfig.maxRetries, greaterThan(0));
    });

    test('cacheSize should be positive', () {
      expect(AppConfig.cacheSize, greaterThan(0));
    });

    test('cacheDuration should be positive', () {
      expect(AppConfig.cacheDuration.inMinutes, greaterThan(0));
    });
  });
}
