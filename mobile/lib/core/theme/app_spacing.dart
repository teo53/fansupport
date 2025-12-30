import 'package:flutter/material.dart';

/// 앱 간격 정의 (Spacing System)
/// 일관된 간격 사용으로 UI 통일성 확보
class AppSpacing {
  // ============ 기본 간격 ============

  /// 4px - 최소 간격
  static const double xxs = 4;

  /// 8px - 작은 간격
  static const double xs = 8;

  /// 12px - 약간 작은 간격
  static const double sm = 12;

  /// 16px - 기본 간격
  static const double md = 16;

  /// 20px - 약간 큰 간격
  static const double lg = 20;

  /// 24px - 큰 간격
  static const double xl = 24;

  /// 32px - 아주 큰 간격
  static const double xxl = 32;

  /// 48px - 섹션 간격
  static const double xxxl = 48;

  // ============ 패딩 ============

  /// 화면 기본 패딩
  static const EdgeInsets screenPadding = EdgeInsets.all(md);

  /// 화면 수평 패딩
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: md);

  /// 카드 내부 패딩
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// 리스트 아이템 패딩
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// 버튼 내부 패딩
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );

  /// 입력 필드 내부 패딩
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// 칩 내부 패딩
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xxs,
  );

  /// 다이얼로그 패딩
  static const EdgeInsets dialogPadding = EdgeInsets.all(xl);

  /// 바텀시트 패딩
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(md, xs, md, md);

  // ============ 마진 ============

  /// 아이템 간 수직 간격
  static const double itemGapVertical = sm;

  /// 아이템 간 수평 간격
  static const double itemGapHorizontal = xs;

  /// 섹션 간 간격
  static const double sectionGap = xl;

  // ============ 둥근 모서리 ============

  /// 작은 모서리 (버튼, 칩)
  static const double radiusSmall = 4;

  /// 기본 모서리 (카드, 입력필드)
  static const double radiusMedium = 8;

  /// 큰 모서리 (다이얼로그, 바텀시트)
  static const double radiusLarge = 12;

  /// 아주 큰 모서리 (풀 라운드 버튼)
  static const double radiusXLarge = 16;

  /// 원형
  static const double radiusCircle = 999;

  /// BorderRadius 객체
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusXLarge => BorderRadius.circular(radiusXLarge);

  // ============ 아이콘 크기 ============

  /// 작은 아이콘 (인라인)
  static const double iconSmall = 16;

  /// 기본 아이콘
  static const double iconMedium = 24;

  /// 큰 아이콘
  static const double iconLarge = 32;

  /// 아주 큰 아이콘 (빈 상태 등)
  static const double iconXLarge = 48;

  // ============ 아바타/프로필 크기 ============

  /// 작은 아바타 (댓글, 리스트)
  static const double avatarSmall = 32;

  /// 기본 아바타 (게시물, 카드)
  static const double avatarMedium = 40;

  /// 큰 아바타 (프로필 헤더)
  static const double avatarLarge = 64;

  /// 아주 큰 아바타 (프로필 상세)
  static const double avatarXLarge = 100;

  // ============ 높이 ============

  /// 앱바 높이
  static const double appBarHeight = 56;

  /// 바텀 내비게이션 높이
  static const double bottomNavHeight = 64;

  /// 버튼 높이
  static const double buttonHeight = 48;

  /// 입력 필드 높이
  static const double inputHeight = 48;

  /// 리스트 아이템 최소 높이
  static const double listItemMinHeight = 56;

  /// 섬네일 높이
  static const double thumbnailHeight = 120;

  // ============ 유틸리티 메서드 ============

  /// 수직 간격 위젯
  static SizedBox verticalGap(double height) => SizedBox(height: height);

  /// 수평 간격 위젯
  static SizedBox horizontalGap(double width) => SizedBox(width: width);

  /// 기본 수직 간격들
  static SizedBox get gapXxs => const SizedBox(height: xxs);
  static SizedBox get gapXs => const SizedBox(height: xs);
  static SizedBox get gapSm => const SizedBox(height: sm);
  static SizedBox get gapMd => const SizedBox(height: md);
  static SizedBox get gapLg => const SizedBox(height: lg);
  static SizedBox get gapXl => const SizedBox(height: xl);
  static SizedBox get gapXxl => const SizedBox(height: xxl);

  /// 기본 수평 간격들
  static SizedBox get hGapXxs => const SizedBox(width: xxs);
  static SizedBox get hGapXs => const SizedBox(width: xs);
  static SizedBox get hGapSm => const SizedBox(width: sm);
  static SizedBox get hGapMd => const SizedBox(width: md);
  static SizedBox get hGapLg => const SizedBox(width: lg);
}
