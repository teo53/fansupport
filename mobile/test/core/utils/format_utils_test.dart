import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/core/utils/format_utils.dart';

void main() {
  group('FormatUtils', () {
    group('Currency Formatting', () {
      test('금액을 원화 형식으로 포맷한다', () {
        expect(FormatUtils.formatCurrency(1000), '₩1,000');
        expect(FormatUtils.formatCurrency(1234567), '₩1,234,567');
        expect(FormatUtils.formatCurrency(0), '₩0');
      });

      test('심볼 없이 금액을 포맷한다', () {
        expect(FormatUtils.formatCurrency(1000, showSymbol: false), '1,000');
      });

      test('금액을 축약 형식으로 포맷한다', () {
        expect(FormatUtils.formatCurrencyShort(500), '500');
        expect(FormatUtils.formatCurrencyShort(1500), '1.5천');
        expect(FormatUtils.formatCurrencyShort(15000), '1.5만');
        expect(FormatUtils.formatCurrencyShort(150000), '15만');
        expect(FormatUtils.formatCurrencyShort(1500000), '150만');
        expect(FormatUtils.formatCurrencyShort(150000000), '1.5억');
      });
    });

    group('Number Formatting', () {
      test('숫자를 축약 형식으로 포맷한다', () {
        expect(FormatUtils.formatNumberShort(500), '500');
        expect(FormatUtils.formatNumberShort(1500), '1.5K');
        expect(FormatUtils.formatNumberShort(15000), '15.0K');
        expect(FormatUtils.formatNumberShort(1500000), '1.5M');
      });

      test('숫자에 콤마를 추가한다', () {
        expect(FormatUtils.formatNumber(1234567), '1,234,567');
        expect(FormatUtils.formatNumber(0), '0');
      });

      test('퍼센트를 포맷한다', () {
        expect(FormatUtils.formatPercent(0.75), '75.0%');
        expect(FormatUtils.formatPercent(0.333, decimals: 2), '33.30%');
        expect(FormatUtils.formatPercent(1.0), '100.0%');
      });
    });

    group('Date Formatting', () {
      test('날짜를 포맷한다', () {
        final date = DateTime(2024, 12, 30);
        expect(FormatUtils.formatDate(date), '2024.12.30');
      });

      test('시간을 포맷한다', () {
        final date = DateTime(2024, 12, 30, 14, 30);
        expect(FormatUtils.formatTime(date), '14:30');
      });

      test('날짜와 시간을 포맷한다', () {
        final date = DateTime(2024, 12, 30, 14, 30);
        expect(FormatUtils.formatDateTime(date), '2024.12.30 14:30');
      });

      test('상대 시간을 포맷한다', () {
        final now = DateTime.now();

        expect(
          FormatUtils.formatRelativeTime(now.subtract(const Duration(seconds: 30))),
          '방금 전',
        );
        expect(
          FormatUtils.formatRelativeTime(now.subtract(const Duration(minutes: 5))),
          '5분 전',
        );
        expect(
          FormatUtils.formatRelativeTime(now.subtract(const Duration(hours: 2))),
          '2시간 전',
        );
        expect(
          FormatUtils.formatRelativeTime(now.subtract(const Duration(days: 1))),
          '어제',
        );
        expect(
          FormatUtils.formatRelativeTime(now.subtract(const Duration(days: 3))),
          '3일 전',
        );
      });

      test('D-Day를 포맷한다', () {
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);

        expect(FormatUtils.formatDDay(todayOnly), 'D-Day');
        expect(
          FormatUtils.formatDDay(todayOnly.add(const Duration(days: 5))),
          'D-5',
        );
        expect(
          FormatUtils.formatDDay(todayOnly.subtract(const Duration(days: 3))),
          'D+3',
        );
      });

      test('날짜 범위를 포맷한다', () {
        final start = DateTime(2024, 12, 1);
        final end = DateTime(2025, 1, 31);
        expect(FormatUtils.formatDateRange(start, end), '12월 1일 ~ 1월 31일');
      });
    });

    group('String Formatting', () {
      test('텍스트를 말줄임한다', () {
        expect(FormatUtils.truncate('Hello World', 5), 'Hello...');
        expect(FormatUtils.truncate('Hi', 10), 'Hi');
      });

      test('전화번호를 마스킹한다', () {
        expect(FormatUtils.maskPhoneNumber('01012345678'), '010-****-5678');
      });

      test('이메일을 마스킹한다', () {
        expect(FormatUtils.maskEmail('test@example.com'), 'te**@example.com');
        expect(FormatUtils.maskEmail('hello@test.com'), 'he***@test.com');
      });
    });

    group('File Size Formatting', () {
      test('파일 크기를 포맷한다', () {
        expect(FormatUtils.formatFileSize(500), '500 B');
        expect(FormatUtils.formatFileSize(1024), '1.0 KB');
        expect(FormatUtils.formatFileSize(1536000), '1.5 MB');
        expect(FormatUtils.formatFileSize(1073741824), '1.0 GB');
      });
    });

    group('Duration Formatting', () {
      test('초를 시간:분:초로 변환한다', () {
        expect(FormatUtils.formatDuration(65), '01:05');
        expect(FormatUtils.formatDuration(3665), '1:01:05');
        expect(FormatUtils.formatDuration(0), '00:00');
      });

      test('분을 읽기 쉬운 형태로 변환한다', () {
        expect(FormatUtils.formatMinutes(30), '30분');
        expect(FormatUtils.formatMinutes(60), '1시간');
        expect(FormatUtils.formatMinutes(90), '1시간 30분');
        expect(FormatUtils.formatMinutes(120), '2시간');
      });
    });
  });
}
