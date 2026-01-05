import 'package:intl/intl.dart';

/// 🛠️ 포맷 유틸리티 함수 모음
/// 중복 코드 제거를 위한 공통 유틸리티
class FormatUtils {
  // ============================================
  // 💰 Currency & Number Formatting
  // ============================================

  /// 통화 포맷 (원화)
  /// 10,000 → "10,000원"
  /// 1,000,000 → "1,000,000원"
  static String formatCurrency(int amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount)}원';
  }

  /// 통화 포맷 (간단 표시)
  /// 1,000 → "1천"
  /// 10,000 → "1만"
  /// 100,000 → "10만"
  /// 1,000,000 → "100만"
  static String formatCurrencyShort(int amount) {
    if (amount >= 100000000) {
      return '${(amount / 100000000).toStringAsFixed(1)}억';
    } else if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(0)}만';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}천';
    }
    return amount.toString();
  }

  /// 숫자 포맷 (콤마 구분)
  /// 1000 → "1,000"
  /// 1000000 → "1,000,000"
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  /// 숫자 포맷 (간단 표시)
  /// 1,000 → "1천"
  /// 10,000 → "1만"
  /// 1,000,000 → "100만"
  static String formatNumberShort(int number) {
    if (number >= 100000000) {
      return '${(number / 100000000).toStringAsFixed(1)}억';
    } else if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}만';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}천';
    }
    return number.toString();
  }

  /// 조회수/좋아요 등 카운트 포맷
  /// 999 → "999"
  /// 1,234 → "1.2K"
  /// 12,345 → "12.3K"
  /// 1,234,567 → "1.2M"
  static String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// 가격 포맷 (천/만 단위)
  /// 사용처: 버블 구독료 등
  static String formatPrice(int price) {
    if (price >= 10000) {
      return '${(price / 10000).toStringAsFixed(0)}만';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}천';
    }
    return price.toString();
  }

  // ============================================
  // ⏰ Time & Date Formatting
  // ============================================

  /// 상대 시간 포맷 (SNS 스타일)
  /// 방금 전, 1분 전, 1시간 전, 1일 전, etc.
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
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

  /// 날짜 포맷 (간단)
  /// 1/15, 12/25
  static String formatDateShort(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}';
  }

  /// 날짜 포맷 (전체)
  /// 2024년 1월 15일
  static String formatDateFull(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일';
  }

  /// 시간 포맷 (한국식)
  /// 오전 9:30, 오후 2:45
  static String formatTimeKorean(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }

  /// 날짜+시간 포맷
  /// 2024.01.15 14:30
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // ============================================
  // 📊 Percentage & Progress
  // ============================================

  /// 퍼센트 포맷
  /// 0.5 → "50%"
  /// 0.756 → "75.6%"
  static String formatPercentage(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// 진행률 포맷 (목표 대비)
  /// current: 75000, goal: 100000 → "75%"
  static String formatProgress(int current, int goal) {
    if (goal == 0) return '0%';
    final percentage = (current / goal * 100).toStringAsFixed(0);
    return '$percentage%';
  }

  // ============================================
  // 🎯 Duration Formatting
  // ============================================

  /// 기간 포맷 (D-day)
  /// 오늘: D-Day, 내일: D-1, 어제: D+1
  static String formatDday(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'D-Day';
    if (diff > 0) return 'D-$diff';
    return 'D+${-diff}';
  }

  /// 재생 시간 포맷
  /// 65 seconds → "1:05"
  /// 3665 seconds → "1:01:05"
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
  }

  // ============================================
  // 📱 Phone & Input Formatting
  // ============================================

  /// 전화번호 포맷
  /// "01012345678" → "010-1234-5678"
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }

    return phone;
  }

  /// 사업자번호 포맷
  /// "1234567890" → "123-45-67890"
  static String formatBusinessNumber(String number) {
    final cleaned = number.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 5)}-${cleaned.substring(5)}';
    }

    return number;
  }
}
