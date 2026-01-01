import 'package:intl/intl.dart';

/// 포맷 유틸리티
class FormatUtils {
  // ============ 금액 ============

  /// 금액 포맷 (₩1,000,000)
  static String formatCurrency(int amount, {bool showSymbol = true}) {
    final formatter = NumberFormat('#,###');
    final formatted = formatter.format(amount);
    return showSymbol ? '₩$formatted' : formatted;
  }

  /// 금액 축약 (1.5만, 150만, 1.5억)
  static String formatCurrencyShort(int amount) {
    if (amount >= 100000000) {
      return '${(amount / 100000000).toStringAsFixed(1)}억';
    } else if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(amount % 10000 == 0 ? 0 : 1)}만';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}천';
    }
    return amount.toString();
  }

  // ============ 숫자 ============

  /// 숫자 축약 (1.2K, 1.5M)
  static String formatNumberShort(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// 숫자 콤마 포맷 (1,234,567)
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  /// 퍼센트 포맷
  static String formatPercent(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  // ============ 날짜/시간 ============

  /// 날짜 포맷 (2024.12.30)
  static String formatDate(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date);
  }

  /// 시간 포맷 (14:30)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// 날짜+시간 포맷 (2024.12.30 14:30)
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy.MM.dd HH:mm').format(date);
  }

  /// 상대 시간 (방금 전, 5분 전, 2시간 전, 어제, 3일 전)
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays == 1) {
      return '어제';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}주 전';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}개월 전';
    } else {
      return '${(diff.inDays / 365).floor()}년 전';
    }
  }

  /// D-Day 포맷
  static String formatDDay(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) {
      return 'D-Day';
    } else if (diff > 0) {
      return 'D-$diff';
    } else {
      return 'D+${-diff}';
    }
  }

  /// 기간 포맷 (12월 1일 ~ 1월 31일)
  static String formatDateRange(DateTime start, DateTime end) {
    final startStr = DateFormat('M월 d일').format(start);
    final endStr = DateFormat('M월 d일').format(end);
    return '$startStr ~ $endStr';
  }

  // ============ 문자열 ============

  /// 텍스트 말줄임 (최대 길이 초과 시 ... 추가)
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// 줄바꿈 제한
  static String limitLines(String text, int maxLines) {
    final lines = text.split('\n');
    if (lines.length <= maxLines) return text;
    return '${lines.take(maxLines).join('\n')}...';
  }

  /// 전화번호 마스킹 (010-****-5678)
  static String maskPhoneNumber(String phone) {
    final numbers = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length < 11) return phone;
    return '${numbers.substring(0, 3)}-****-${numbers.substring(7)}';
  }

  /// 이메일 마스킹 (te**@example.com)
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email;
    return '${name.substring(0, 2)}${'*' * (name.length - 2)}@$domain';
  }

  // ============ 파일 ============

  /// 파일 크기 포맷 (1.5 MB, 500 KB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // ============ 시간 ============

  /// 초를 시간:분:초로 변환 (1:30:00)
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// 분을 사람이 읽기 쉬운 형태로 (1시간 30분)
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes분';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours시간';
    }
    return '$hours시간 $mins분';
  }
}
