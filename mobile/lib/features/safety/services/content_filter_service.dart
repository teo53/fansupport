import 'package:flutter/foundation.dart';

/// Service for filtering prohibited content in request messages
class ContentFilterService {
  static final ContentFilterService _instance = ContentFilterService._internal();
  factory ContentFilterService() => _instance;
  ContentFilterService._internal();

  // Prohibited patterns (Korean + English)
  static const List<String> _prohibitedPatterns = [
    // Personal contact info requests
    r'전화번호',
    r'폰번호',
    r'연락처',
    r'카카오톡?\s*아이디',
    r'카톡\s*아이디',
    r'라인\s*아이디',
    r'인스타\s*아이디',
    r'개인\s*연락',
    r'phone\s*number',
    r'contact\s*info',
    r'kakao\s*id',
    r'line\s*id',
    // Meeting requests
    r'만나자',
    r'만나요',
    r'만남',
    r'데이트',
    r'실제로\s*만나',
    r'직접\s*만나',
    r"let'?s\s*meet",
    r'meet\s*up',
    r'in\s*person',
    // Location disclosure
    r'집\s*주소',
    r'거주지',
    r'어디\s*살',
    r'home\s*address',
    r'where.*live',
    // Inappropriate content
    r'선정적',
    r'야한',
    r'섹시한',
    r'벗어',
    r'노출',
    r'19금',
    r'성인',
    r'explicit',
    r'sexual',
    r'nude',
    r'naked',
    // Financial scam patterns
    r'입금',
    r'계좌',
    r'송금',
    r'투자',
    r'코인',
    r'bank\s*account',
    r'transfer.*money',
    r'invest',
    r'crypto',
  ];

  /// Check if content contains prohibited patterns
  ContentFilterResult checkContent(String content) {
    final lowerContent = content.toLowerCase();
    final violations = <String>[];

    for (final pattern in _prohibitedPatterns) {
      try {
        final regex = RegExp(pattern, caseSensitive: false);
        if (regex.hasMatch(lowerContent)) {
          violations.add(pattern);
        }
      } catch (e) {
        debugPrint('Invalid regex pattern: $pattern');
      }
    }

    return ContentFilterResult(
      isClean: violations.isEmpty,
      violations: violations,
      severity: _calculateSeverity(violations),
    );
  }

  ContentSeverity _calculateSeverity(List<String> violations) {
    if (violations.isEmpty) return ContentSeverity.none;
    if (violations.length >= 3) return ContentSeverity.high;
    if (violations.length >= 2) return ContentSeverity.medium;
    return ContentSeverity.low;
  }

  /// Get user-friendly warning message
  String getWarningMessage(ContentSeverity severity) {
    switch (severity) {
      case ContentSeverity.none:
        return '';
      case ContentSeverity.low:
        return '요청 내용에 부적절한 표현이 포함되어 있을 수 있습니다. 확인해 주세요.';
      case ContentSeverity.medium:
        return '요청 내용에 금지된 표현이 포함되어 있습니다. 수정이 필요합니다.';
      case ContentSeverity.high:
        return '요청 내용에 심각한 정책 위반이 감지되었습니다. 해당 요청은 전송할 수 없습니다.';
    }
  }

  /// Get list of prohibited content guidelines for display
  List<String> getProhibitedContentGuidelines() {
    return [
      '개인 연락처 요청 (전화번호, SNS 아이디 등)',
      '실제 만남 요청',
      '주거지 등 개인정보 요청',
      '선정적이거나 부적절한 콘텐츠 요청',
      '금융 관련 요청 (계좌번호, 송금 등)',
      '서비스 외부 거래 유도',
    ];
  }
}

class ContentFilterResult {
  final bool isClean;
  final List<String> violations;
  final ContentSeverity severity;

  ContentFilterResult({
    required this.isClean,
    required this.violations,
    required this.severity,
  });

  bool get canProceed => severity != ContentSeverity.high;
  bool get needsWarning => severity != ContentSeverity.none;
}

enum ContentSeverity { none, low, medium, high }
