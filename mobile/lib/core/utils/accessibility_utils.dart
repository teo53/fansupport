import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// 접근성 유틸리티
class AccessibilityUtils {
  /// 시맨틱 레이블 생성 헬퍼

  /// 버튼 레이블 생성
  static String buttonLabel(String action, {String? target}) {
    if (target != null) {
      return '$target $action 버튼';
    }
    return '$action 버튼';
  }

  /// 이미지 레이블 생성
  static String imageLabel(String description) {
    return '$description 이미지';
  }

  /// 프로필 이미지 레이블
  static String profileImageLabel(String name) {
    return '$name 프로필 이미지';
  }

  /// 아이콘 레이블
  static String iconLabel(String meaning) {
    return '$meaning 아이콘';
  }

  /// 링크 레이블
  static String linkLabel(String destination) {
    return '$destination (으)로 이동 링크';
  }

  /// 상태 레이블 (활성/비활성)
  static String stateLabel(String item, bool isActive) {
    return '$item ${isActive ? "활성화됨" : "비활성화됨"}';
  }

  /// 카운터 레이블
  static String counterLabel(String item, int count) {
    return '$item $count개';
  }

  /// 진행률 레이블
  static String progressLabel(int percent, {String? context}) {
    if (context != null) {
      return '$context $percent% 진행됨';
    }
    return '$percent% 진행됨';
  }

  /// 날짜 레이블
  static String dateLabel(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 시간 레이블
  static String timeLabel(DateTime time) {
    return '${time.hour}시 ${time.minute}분';
  }

  /// 가격 레이블
  static String priceLabel(int price) {
    return '$price원';
  }

  /// 리스트 아이템 레이블
  static String listItemLabel(int index, int total, String itemName) {
    return '${total}개 중 ${index + 1}번째 $itemName';
  }
}

/// 접근성 래퍼 위젯들

/// 탭 가능한 영역에 시맨틱 추가
class TappableSemantic extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback onTap;
  final bool enabled;

  const TappableSemantic({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: child,
      ),
    );
  }
}

/// 헤더 시맨틱
class HeaderSemantic extends StatelessWidget {
  final Widget child;
  final String label;

  const HeaderSemantic({
    super.key,
    required this.child,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: label,
      child: child,
    );
  }
}

/// 이미지 시맨틱
class ImageSemantic extends StatelessWidget {
  final Widget child;
  final String label;

  const ImageSemantic({
    super.key,
    required this.child,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: label,
      child: child,
    );
  }
}

/// 라이브 리전 (동적 콘텐츠 알림)
class LiveRegion extends StatelessWidget {
  final Widget child;
  final String? label;
  final bool polite;

  const LiveRegion({
    super.key,
    required this.child,
    this.label,
    this.polite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: child,
    );
  }
}

/// 접근성 확장 - MediaQuery
extension AccessibilityMediaQuery on MediaQueryData {
  /// 볼드 텍스트 사용 여부
  bool get isBoldTextEnabled => boldText;

  /// 고대비 모드 여부
  bool get isHighContrastEnabled => highContrast;

  /// 애니메이션 감소 여부
  bool get reduceMotionEnabled => disableAnimations;

  /// 텍스트 스케일 팩터
  double get textScaling => textScaler.scale(1.0);
}

/// 접근성 확장 - BuildContext
extension AccessibilityContext on BuildContext {
  /// 현재 접근성 설정 조회
  MediaQueryData get accessibility => MediaQuery.of(this);

  /// 볼드 텍스트 사용 여부
  bool get isBoldTextEnabled => accessibility.isBoldTextEnabled;

  /// 애니메이션 감소 여부
  bool get reduceMotionEnabled => accessibility.reduceMotionEnabled;

  /// 텍스트 스케일
  double get textScale => accessibility.textScaling;
}

/// 포커스 관리 헬퍼
class FocusHelper {
  /// 다음 포커스 가능 요소로 이동
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// 이전 포커스 가능 요소로 이동
  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// 포커스 해제
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// 특정 노드에 포커스
  static void focusOn(FocusNode node) {
    node.requestFocus();
  }
}

/// 스크린리더 알림 헬퍼
class ScreenReaderAnnouncement {
  /// 메시지 알림 (Polite)
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// 긴급 알림 (Assertive) - 즉시 읽어줌
  static void announceUrgent(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr, assertiveness: Assertiveness.assertive);
  }
}
