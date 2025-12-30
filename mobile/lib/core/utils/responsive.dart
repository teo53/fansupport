import 'package:flutter/material.dart';

/// 반응형 UI 유틸리티 클래스
/// 다양한 화면 크기에 맞게 자동으로 스케일링
class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late TextScaler textScaler;
  static late double devicePixelRatio;
  static late Orientation orientation;
  static late EdgeInsets padding;

  // 기준 디자인 크기 (Galaxy S23 Ultra 기준)
  static const double _baseWidth = 412.0;
  static const double _baseHeight = 892.0;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    textScaler = _mediaQueryData.textScaler;
    devicePixelRatio = _mediaQueryData.devicePixelRatio;
    orientation = _mediaQueryData.orientation;
    padding = _mediaQueryData.padding;

    final safeAreaHorizontalPadding =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    final safeAreaVerticalPadding =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeAreaHorizontal = (screenWidth - safeAreaHorizontalPadding);
    safeAreaVertical = (screenHeight - safeAreaVerticalPadding);
    safeBlockHorizontal = safeAreaHorizontal / 100;
    safeBlockVertical = safeAreaVertical / 100;
  }

  // ============ 화면 크기 분류 ============

  /// 작은 화면 (iPhone SE, Galaxy A 시리즈 등) - 360dp 미만
  static bool get isSmallScreen => screenWidth < 360;

  /// 중간 화면 (대부분의 일반 스마트폰) - 360~413dp
  static bool get isMediumScreen => screenWidth >= 360 && screenWidth < 414;

  /// 큰 화면 (iPhone Pro Max, Galaxy S Ultra 등) - 414dp 이상
  static bool get isLargeScreen => screenWidth >= 414;

  /// 태블릿 - 600dp 이상
  static bool get isTablet => screenWidth >= 600;

  /// 폴더블 (Galaxy Fold 펼침 상태 등) - 700dp 이상
  static bool get isFoldable => screenWidth >= 700;

  /// 가로 모드
  static bool get isLandscape => orientation == Orientation.landscape;

  /// 세로 모드
  static bool get isPortrait => orientation == Orientation.portrait;

  // ============ 기기별 분류 ============

  /// iPhone SE (320~375dp)
  static bool get isIPhoneSE => screenWidth >= 320 && screenWidth < 376;

  /// iPhone 일반 (375~413dp)
  static bool get isIPhoneStandard => screenWidth >= 375 && screenWidth < 414;

  /// iPhone Pro Max / Plus (414~428dp)
  static bool get isIPhoneMax => screenWidth >= 414 && screenWidth < 430;

  /// Galaxy S 시리즈 일반 (360~411dp)
  static bool get isGalaxyS => screenWidth >= 360 && screenWidth < 412;

  /// Galaxy S Ultra / Note (412~420dp)
  static bool get isGalaxySUltra => screenWidth >= 412 && screenWidth <= 420;

  // ============ 스케일링 함수 ============

  /// 화면 너비 기준 퍼센트 (Width Percentage)
  static double wp(double percentage) => screenWidth * (percentage / 100);

  /// 화면 높이 기준 퍼센트 (Height Percentage)
  static double hp(double percentage) => screenHeight * (percentage / 100);

  /// 안전 영역 기준 너비 퍼센트
  static double swp(double percentage) => safeAreaHorizontal * (percentage / 100);

  /// 안전 영역 기준 높이 퍼센트
  static double shp(double percentage) => safeAreaVertical * (percentage / 100);

  /// 폰트 크기 스케일링 (Screen-adaptive font size)
  /// 모든 기기에서 일관된 가독성 유지
  static double sp(double size) {
    // 너비 기반 스케일 팩터
    final widthScale = screenWidth / _baseWidth;

    // 높이 기반 스케일 팩터 (세로가 짧은 기기 대응)
    final heightScale = screenHeight / _baseHeight;

    // 두 스케일의 평균을 사용하되, 극단적인 값은 제한
    final avgScale = (widthScale + heightScale) / 2;

    // 작은 화면에서는 최소 85%, 큰 화면에서는 최대 120%
    final clampedScale = avgScale.clamp(0.85, 1.20);

    return size * clampedScale;
  }

  /// 아이콘 크기 스케일링
  static double iconSize(double size) {
    final scale = screenWidth / _baseWidth;
    return size * scale.clamp(0.8, 1.3);
  }

  /// 반응형 값 반환 (화면 크기에 따라 다른 값)
  static T value<T>({
    required T small,
    required T medium,
    required T large,
    T? tablet,
  }) {
    if (isTablet && tablet != null) return tablet;
    if (isLargeScreen) return large;
    if (isMediumScreen) return medium;
    return small;
  }

  /// 반응형 위젯 빌더
  static Widget builder({
    required Widget Function() small,
    required Widget Function() medium,
    required Widget Function() large,
    Widget Function()? tablet,
  }) {
    if (isTablet && tablet != null) return tablet();
    if (isLargeScreen) return large();
    if (isMediumScreen) return medium();
    return small();
  }

  // ============ 패딩/마진 유틸리티 ============

  static EdgeInsets paddingHorizontal(double percentage) {
    return EdgeInsets.symmetric(horizontal: wp(percentage));
  }

  static EdgeInsets paddingVertical(double percentage) {
    return EdgeInsets.symmetric(vertical: hp(percentage));
  }

  static EdgeInsets paddingAll(double percentage) {
    return EdgeInsets.all(wp(percentage));
  }

  static EdgeInsets paddingSymmetric({double h = 0, double v = 0}) {
    return EdgeInsets.symmetric(horizontal: wp(h), vertical: hp(v));
  }

  // ============ 간격 유틸리티 ============

  static SizedBox verticalSpace(double height) => SizedBox(height: hp(height));
  static SizedBox horizontalSpace(double width) => SizedBox(width: wp(width));

  /// 반응형 간격 (작은 화면에서 더 작게)
  static double gap(double baseGap) {
    if (isSmallScreen) return baseGap * 0.8;
    if (isTablet) return baseGap * 1.2;
    return baseGap;
  }

  // ============ 그리드 유틸리티 ============

  /// 그리드 열 개수 (화면 크기에 따라)
  static int get gridColumns {
    if (isFoldable) return 4;
    if (isTablet) return 3;
    if (isLargeScreen) return 2;
    return 2;
  }

  /// 그리드 아이템 너비
  static double gridItemWidth({double spacing = 16}) {
    final totalSpacing = spacing * (gridColumns + 1);
    return (screenWidth - totalSpacing) / gridColumns;
  }

  // ============ 디버그 정보 ============

  static String get debugInfo => '''
Screen Size: ${screenWidth.toStringAsFixed(1)} x ${screenHeight.toStringAsFixed(1)}
Device Type: ${_deviceType}
Orientation: ${isPortrait ? 'Portrait' : 'Landscape'}
Pixel Ratio: ${devicePixelRatio.toStringAsFixed(2)}
Safe Area: ${safeAreaHorizontal.toStringAsFixed(1)} x ${safeAreaVertical.toStringAsFixed(1)}
''';

  static String get _deviceType {
    if (isFoldable) return 'Foldable';
    if (isTablet) return 'Tablet';
    if (isLargeScreen) return 'Large Phone';
    if (isMediumScreen) return 'Medium Phone';
    return 'Small Phone';
  }
}

/// 숫자 확장 - 간편한 반응형 값 사용
extension ResponsiveExtension on num {
  /// 화면 너비 퍼센트
  double get w => Responsive.wp(toDouble());

  /// 화면 높이 퍼센트
  double get h => Responsive.hp(toDouble());

  /// 스케일된 폰트 크기
  double get sp => Responsive.sp(toDouble());

  /// 스케일된 아이콘 크기
  double get icon => Responsive.iconSize(toDouble());
}
