import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/core/utils/logger.dart';

void main() {
  group('AppLogger', () {
    test('debug should print message in debug mode', () {
      expect(
        () => AppLogger.debug('Test debug message', 'TEST'),
        returnsNormally,
      );
    });

    test('info should print message', () {
      expect(
        () => AppLogger.info('Test info message', 'TEST'),
        returnsNormally,
      );
    });

    test('warning should print message', () {
      expect(
        () => AppLogger.warning('Test warning message', 'TEST'),
        returnsNormally,
      );
    });

    test('error should print message with error details', () {
      expect(
        () => AppLogger.error(
          'Test error message',
          tag: 'TEST',
          error: Exception('Test exception'),
        ),
        returnsNormally,
      );
    });

    test('network should log HTTP request', () {
      expect(
        () => AppLogger.network('GET', '/api/users', statusCode: 200),
        returnsNormally,
      );
    });

    test('analytics should log event', () {
      expect(
        () => AppLogger.analytics('test_event', {'key': 'value'}),
        returnsNormally,
      );
    });
  });
}
