import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/core/services/logger_service.dart';

void main() {
  group('LoggerService', () {
    late LoggerService loggerService;

    setUp(() {
      loggerService = LoggerService();
      loggerService.clear();
    });

    group('Logging', () {
      test('로그를 기록한다', () {
        loggerService.log(LogLevel.info, 'Test', 'Test message');

        final logs = loggerService.getAllLogs();
        expect(logs.length, 1);
        expect(logs.first.level, LogLevel.info);
        expect(logs.first.tag, 'Test');
        expect(logs.first.message, 'Test message');
      });

      test('편의 메서드로 로그를 기록한다', () {
        loggerService.v('Test', 'Verbose');
        loggerService.d('Test', 'Debug');
        loggerService.i('Test', 'Info');
        loggerService.w('Test', 'Warning');
        loggerService.e('Test', 'Error');
        loggerService.f('Test', 'Fatal');

        final logs = loggerService.getAllLogs();
        expect(logs.length, 6);
      });

      test('에러와 스택트레이스를 기록한다', () {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        loggerService.e(
          'Test',
          'Error occurred',
          error: error,
          stackTrace: stackTrace,
        );

        final logs = loggerService.getAllLogs();
        expect(logs.first.error, error);
        expect(logs.first.stackTrace, stackTrace);
      });
    });

    group('Log Filtering', () {
      test('레벨별로 로그를 필터링한다', () {
        loggerService.i('Test', 'Info');
        loggerService.e('Test', 'Error');
        loggerService.e('Test', 'Another Error');

        final errorLogs = loggerService.getLogsByLevel(LogLevel.error);
        expect(errorLogs.length, 2);
      });

      test('태그별로 로그를 필터링한다', () {
        loggerService.i('API', 'API call');
        loggerService.i('UI', 'UI update');
        loggerService.i('API', 'API response');

        final apiLogs = loggerService.getLogsByTag('API');
        expect(apiLogs.length, 2);
      });
    });

    group('Log Management', () {
      test('로그를 초기화한다', () {
        loggerService.i('Test', 'Message 1');
        loggerService.i('Test', 'Message 2');

        loggerService.clear();

        expect(loggerService.getAllLogs().isEmpty, true);
      });

      test('에러 리포트를 생성한다', () {
        loggerService.i('Test', 'Info message');
        loggerService.e('Test', 'Error message');
        loggerService.f('Test', 'Fatal message');

        final report = loggerService.getErrorReport();
        expect(report.contains('Error message'), true);
        expect(report.contains('Fatal message'), true);
        expect(report.contains('Info message'), false);
      });

      test('에러가 없으면 빈 리포트를 반환한다', () {
        loggerService.i('Test', 'Info only');

        final report = loggerService.getErrorReport();
        expect(report, 'No errors recorded');
      });
    });

    group('Log Level', () {
      test('최소 로그 레벨을 설정한다', () {
        loggerService.setMinLevel(LogLevel.warning);

        loggerService.i('Test', 'Info'); // 무시됨
        loggerService.w('Test', 'Warning'); // 기록됨
        loggerService.e('Test', 'Error'); // 기록됨

        final logs = loggerService.getAllLogs();
        expect(logs.length, 2);
      });
    });

    group('LogEntry', () {
      test('로그 엔트리를 문자열로 변환한다', () {
        final entry = LogEntry(
          timestamp: DateTime(2024, 12, 30, 14, 30),
          level: LogLevel.error,
          tag: 'TestTag',
          message: 'Test message',
        );

        final str = entry.toString();
        expect(str.contains('ERROR'), true);
        expect(str.contains('TestTag'), true);
        expect(str.contains('Test message'), true);
      });
    });
  });
}
