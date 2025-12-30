/// 숫자 포맷팅 유틸리티
class NumberFormatter {
  /// 콤마로 구분된 숫자 포맷 (예: 1,234,567)
  static String formatWithComma(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 한국어 축약 숫자 포맷 (예: 1.2만, 3.4천)
  static String formatKorean(int number) {
    if (number >= 100000000) {
      return '${(number / 100000000).toStringAsFixed(1)}억';
    } else if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}만';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}천';
    }
    return number.toString();
  }

  /// 화폐 포맷 (예: ₩1,234,567)
  static String formatCurrency(int amount, {String symbol = '₩'}) {
    return '$symbol${formatWithComma(amount)}';
  }

  /// 퍼센트 포맷
  static String formatPercent(double value, {int decimals = 0}) {
    return '${value.toStringAsFixed(decimals)}%';
  }
}

/// 시간 포맷팅 유틸리티
class TimeFormatter {
  /// 상대 시간 포맷 (예: 방금 전, 5분 전, 3시간 전)
  static String formatRelative(DateTime dateTime) {
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
      return '${dateTime.month}월 ${dateTime.day}일';
    } else {
      return '${dateTime.year}.${dateTime.month}.${dateTime.day}';
    }
  }

  /// 짧은 상대 시간 (예: 5분, 3시간)
  static String formatRelativeShort(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '방금';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  /// 날짜 포맷 (예: 2024년 12월 25일)
  static String formatDate(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일';
  }

  /// 날짜 문자열을 포맷 (예: "2024-12-25" -> "2024년 12월 25일")
  static String formatDateString(String? dateStr) {
    if (dateStr == null) return '';
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    return '${parts[0]}년 ${int.parse(parts[1])}월 ${int.parse(parts[2])}일';
  }

  /// D-Day 계산
  static int calculateDaysLeft(String? endDateStr) {
    if (endDateStr == null) return 0;
    try {
      final endDate = DateTime.parse(endDateStr);
      return endDate.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// D-Day 문자열 포맷
  static String formatDaysLeft(String? endDateStr) {
    final days = calculateDaysLeft(endDateStr);
    if (days < 0) return '종료됨';
    if (days == 0) return 'D-Day';
    return 'D-$days';
  }
}

/// 카테고리 매핑 유틸리티
class CategoryMapper {
  static const Map<String, String> _categoryNames = {
    'UNDERGROUND_IDOL': '지하 아이돌',
    'MAID_CAFE': '메이드카페',
    'COSPLAYER': '코스플레이어',
    'VTUBER': 'VTuber',
    'undergroundIdol': '지하 아이돌',
    'maidCafe': '메이드카페',
    'cosplayer': '코스플레이어',
    'vtuber': 'VTuber',
  };

  static const Map<String, String> _eventCategoryNames = {
    'LIVE': '라이브',
    'CONCERT': '콘서트',
    'FAN_MEETING': '팬미팅',
    'BIRTHDAY': '생일파티',
    'SPECIAL': '스페셜',
  };

  /// 아이돌 카테고리 이름 가져오기
  static String getCategoryName(String? category) {
    if (category == null) return '아이돌';
    return _categoryNames[category] ?? '아이돌';
  }

  /// 이벤트 카테고리 이름 가져오기
  static String getEventCategoryName(String? category) {
    if (category == null) return '이벤트';
    return _eventCategoryNames[category] ?? '이벤트';
  }
}

/// 문자열 유틸리티
class StringUtils {
  /// 텍스트 자르기 (말줄임표 추가)
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// 빈 문자열 또는 null 체크
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  /// 기본값 반환
  static String orDefault(String? value, String defaultValue) {
    return isNullOrEmpty(value) ? defaultValue : value!;
  }
}
