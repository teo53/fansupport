import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// 🎨 앱 전체의 일관된 spacing/padding 상수
/// Bubble Style 디자인 시스템에 맞춘 표준 값
class AppSpacing {
  AppSpacing._();

  // ============ 화면 패딩 ============

  /// 화면 좌우 기본 패딩 (Responsive)
  static double get screenHorizontal => Responsive.wp(6);

  /// 화면 상하 기본 패딩 (Responsive)
  static double get screenVertical => Responsive.hp(2);

  /// EdgeInsets: 화면 전체 패딩
  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
        horizontal: screenHorizontal,
        vertical: screenVertical,
      );

  /// EdgeInsets: 화면 좌우만 패딩
  static EdgeInsets get screenHorizontalPadding => EdgeInsets.symmetric(
        horizontal: screenHorizontal,
      );

  // ============ 섹션 간격 ============

  /// 섹션 간 큰 간격 (32-40px)
  static const double sectionLarge = 32.0;

  /// 섹션 간 중간 간격 (24px)
  static const double sectionMedium = 24.0;

  /// 섹션 간 작은 간격 (16px)
  static const double sectionSmall = 16.0;

  /// SizedBox: 섹션 간 큰 간격
  static const SizedBox sectionLargeBox = SizedBox(height: sectionLarge);

  /// SizedBox: 섹션 간 중간 간격
  static const SizedBox sectionMediumBox = SizedBox(height: sectionMedium);

  /// SizedBox: 섹션 간 작은 간격
  static const SizedBox sectionSmallBox = SizedBox(height: sectionSmall);

  // ============ 카드/컨테이너 패딩 ============

  /// 카드 내부 패딩 (큰 카드)
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20.0);

  /// 카드 내부 패딩 (중간 카드)
  static const EdgeInsets cardPaddingMedium = EdgeInsets.all(16.0);

  /// 카드 내부 패딩 (작은 카드)
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(12.0);

  // ============ 리스트 아이템 간격 ============

  /// 리스트 아이템 간 간격 (큰)
  static const double listItemLarge = 16.0;

  /// 리스트 아이템 간 간격 (중간)
  static const double listItemMedium = 12.0;

  /// 리스트 아이템 간 간격 (작은)
  static const double listItemSmall = 8.0;

  // ============ 버튼 관련 ============

  /// 버튼 기본 높이 (Bubble Style)
  static const double buttonHeight = 60.0;

  /// 버튼 작은 높이
  static const double buttonHeightSmall = 48.0;

  /// 버튼 큰 높이
  static const double buttonHeightLarge = 68.0;

  /// 버튼 내부 패딩
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 28.0);

  /// 버튼 간 간격
  static const double buttonGap = 12.0;

  // ============ 텍스트 간격 ============

  /// 제목과 내용 사이 간격
  static const double textTitleContent = 8.0;

  /// 라벨과 입력 필드 사이 간격
  static const double textLabelInput = 6.0;

  /// 텍스트 줄 간격
  static const double textLineGap = 4.0;

  // ============ Border Radius ============

  /// 카드/버튼 기본 radius (Bubble Style)
  static const double radiusLarge = 20.0;

  /// 중간 radius
  static const double radiusMedium = 16.0;

  /// 작은 radius
  static const double radiusSmall = 12.0;

  /// 아주 작은 radius (칩, 배지)
  static const double radiusXSmall = 8.0;

  /// BorderRadius: 큰
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(radiusLarge));

  /// BorderRadius: 중간
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(radiusMedium));

  /// BorderRadius: 작은
  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(radiusSmall));

  /// BorderRadius: 아주 작은
  static const BorderRadius borderRadiusXSmall = BorderRadius.all(Radius.circular(radiusXSmall));

  // ============ Icon Sizes ============

  /// 아이콘 기본 크기
  static const double iconNormal = 24.0;

  /// 아이콘 작은 크기
  static const double iconSmall = 20.0;

  /// 아이콘 큰 크기
  static const double iconLarge = 32.0;

  /// 아이콘 아주 큰 크기 (Hero icons)
  static const double iconXLarge = 48.0;

  // ============ Avatar Sizes ============

  /// 프로필 아바타 크기
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 100.0;

  // ============ Divider ============

  /// Divider 두께
  static const double dividerThickness = 1.0;

  /// Divider 간격
  static const double dividerIndent = 0.0;
}
