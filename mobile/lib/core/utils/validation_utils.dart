/// 입력 유효성 검사 유틸리티
class ValidationUtils {
  // ============ 이메일 ============

  /// 이메일 형식 검증
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// 이메일 검증 에러 메시지
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!isValidEmail(email)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  // ============ 비밀번호 ============

  /// 비밀번호 강도 검증 (최소 요구사항)
  static bool isValidPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    // 최소 8자, 영문/숫자 포함
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$');
    return regex.hasMatch(password);
  }

  /// 비밀번호 검증 에러 메시지
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (password.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return '비밀번호에 영문자를 포함해주세요';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return '비밀번호에 숫자를 포함해주세요';
    }
    return null;
  }

  /// 비밀번호 확인 검증
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (password != confirmPassword) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  // ============ 닉네임 ============

  /// 닉네임 유효성 검증
  static bool isValidNickname(String? nickname) {
    if (nickname == null || nickname.isEmpty) return false;
    // 2-20자, 한글/영문/숫자/언더스코어만 허용
    final regex = RegExp(r'^[가-힣a-zA-Z0-9_]{2,20}$');
    return regex.hasMatch(nickname);
  }

  /// 닉네임 검증 에러 메시지
  static String? validateNickname(String? nickname) {
    if (nickname == null || nickname.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    if (nickname.length < 2) {
      return '닉네임은 2자 이상이어야 합니다';
    }
    if (nickname.length > 20) {
      return '닉네임은 20자 이하여야 합니다';
    }
    if (!isValidNickname(nickname)) {
      return '닉네임은 한글, 영문, 숫자, 언더스코어만 사용 가능합니다';
    }
    return null;
  }

  // ============ 전화번호 ============

  /// 한국 전화번호 형식 검증
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    // 숫자만 추출
    final numbers = phone.replaceAll(RegExp(r'[^0-9]'), '');
    // 010-XXXX-XXXX 형식
    return RegExp(r'^01[0-9]{8,9}$').hasMatch(numbers);
  }

  /// 전화번호 검증 에러 메시지
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return '전화번호를 입력해주세요';
    }
    if (!isValidPhoneNumber(phone)) {
      return '올바른 전화번호 형식이 아닙니다';
    }
    return null;
  }

  /// 전화번호 포맷팅 (010-1234-5678)
  static String formatPhoneNumber(String phone) {
    final numbers = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length == 11) {
      return '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7)}';
    }
    if (numbers.length == 10) {
      return '${numbers.substring(0, 3)}-${numbers.substring(3, 6)}-${numbers.substring(6)}';
    }
    return phone;
  }

  // ============ 금액 ============

  /// 금액 유효성 검증
  static bool isValidAmount(int? amount) {
    return amount != null && amount > 0;
  }

  /// 금액 검증 에러 메시지
  static String? validateAmount(String? amountStr, {int? minAmount, int? maxAmount}) {
    if (amountStr == null || amountStr.isEmpty) {
      return '금액을 입력해주세요';
    }
    final amount = int.tryParse(amountStr.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null) {
      return '올바른 금액을 입력해주세요';
    }
    if (amount <= 0) {
      return '0보다 큰 금액을 입력해주세요';
    }
    if (minAmount != null && amount < minAmount) {
      return '최소 금액은 ${_formatCurrency(minAmount)}원입니다';
    }
    if (maxAmount != null && amount > maxAmount) {
      return '최대 금액은 ${_formatCurrency(maxAmount)}원입니다';
    }
    return null;
  }

  /// 금액 포맷팅
  static String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  // ============ URL ============

  /// URL 유효성 검증
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (_) {
      return false;
    }
  }

  /// URL 검증 에러 메시지
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null; // URL은 선택 필드인 경우가 많음
    }
    if (!isValidUrl(url)) {
      return '올바른 URL 형식이 아닙니다';
    }
    return null;
  }

  // ============ 일반 텍스트 ============

  /// 필수 필드 검증
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    return null;
  }

  /// 최대 길이 검증
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName은(는) $maxLength자 이하여야 합니다';
    }
    return null;
  }

  /// 최소 길이 검증
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value != null && value.length < minLength) {
      return '$fieldName은(는) $minLength자 이상이어야 합니다';
    }
    return null;
  }

  // ============ XSS/인젝션 방지 ============

  /// HTML 태그 제거
  static String stripHtmlTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// 스크립트 태그 제거
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');
  }
}
