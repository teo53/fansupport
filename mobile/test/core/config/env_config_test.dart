import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/core/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    setUpAll(() {
      EnvConfig.init();
    });

    test('should initialize with development environment by default', () {
      expect(EnvConfig.isDevelopment, isTrue);
    });

    test('should return development API URL', () {
      expect(EnvConfig.apiBaseUrl, isNotEmpty);
      expect(EnvConfig.apiBaseUrl, contains('localhost'));
    });

    test('should enable debug features in development', () {
      expect(EnvConfig.enableDebugFeatures, isTrue);
    });

    test('should disable crash reporting in development', () {
      expect(EnvConfig.enableCrashReporting, isFalse);
    });

    test('should have valid timeout values', () {
      expect(EnvConfig.connectionTimeout, greaterThan(0));
      expect(EnvConfig.receiveTimeout, greaterThan(0));
    });

    test('should have valid version strings', () {
      expect(EnvConfig.appVersion, isNotEmpty);
      expect(EnvConfig.buildNumber, isNotEmpty);
    });

    test('should not be production environment', () {
      expect(EnvConfig.isProduction, isFalse);
    });

    test('should enable logging in development', () {
      expect(EnvConfig.enableLogging, isTrue);
    });

    test('printConfig should not throw', () {
      expect(() => EnvConfig.printConfig(), returnsNormally);
    });
  });
}
