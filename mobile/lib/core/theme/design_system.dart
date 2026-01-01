import 'package:flutter/material.dart';
import 'app_colors.dart';

/// FanSupport Design System
/// 8pt 그리드 기반 스페이싱 및 사이징 토큰
class DS {
  DS._();

  // ============ Spacing Scale (8pt grid) ============
  static const double space0 = 0;
  static const double space1 = 4;   // xs
  static const double space2 = 8;   // sm
  static const double space3 = 12;  // md
  static const double space4 = 16;  // base
  static const double space5 = 20;  // lg
  static const double space6 = 24;  // xl
  static const double space7 = 32;  // 2xl
  static const double space8 = 40;  // 3xl
  static const double space9 = 48;  // 4xl
  static const double space10 = 64; // 5xl

  // ============ Border Radius ============
  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radius2xl = 28;
  static const double radiusFull = 999;

  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadius2xl => BorderRadius.circular(radius2xl);

  // ============ Component Heights ============
  static const double buttonHeightSm = 40;
  static const double buttonHeightMd = 48;
  static const double buttonHeightLg = 56;

  static const double inputHeight = 52;
  static const double chipHeight = 36;
  static const double bottomNavHeight = 64;
  static const double appBarHeight = 56;

  // ============ Icon Sizes ============
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 28;
  static const double iconXl = 32;
  static const double icon2xl = 40;

  // ============ Avatar Sizes ============
  static const double avatarXs = 24;
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 48;
  static const double avatarXl = 64;
  static const double avatar2xl = 80;

  // ============ Typography Scale ============
  static const double fontXs = 11;
  static const double fontSm = 12;
  static const double fontBase = 14;
  static const double fontMd = 15;
  static const double fontLg = 16;
  static const double fontXl = 18;
  static const double font2xl = 20;
  static const double font3xl = 24;
  static const double font4xl = 28;
  static const double font5xl = 32;

  // ============ Font Weights ============
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtrabold = FontWeight.w800;

  // ============ Line Heights ============
  static const double lineHeightTight = 1.2;
  static const double lineHeightSnug = 1.35;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.65;

  // ============ Horizontal Padding (Screen) ============
  static const double screenPadding = 20;

  static EdgeInsets get screenPaddingH =>
    const EdgeInsets.symmetric(horizontal: screenPadding);

  // ============ Card Styles ============
  static BoxDecoration cardDecoration({
    Color? color,
    bool hasShadow = true,
    double radius = radiusLg,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: hasShadow ? AppColors.cardShadow() : null,
    );
  }

  static BoxDecoration elevatedCardDecoration({
    Color? color,
    double radius = radiusLg,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppColors.elevatedShadow(),
    );
  }

  // ============ Text Styles ============
  static TextStyle textXs({
    Color? color,
    FontWeight weight = weightRegular,
    double height = lineHeightNormal,
  }) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: fontXs,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle textSm({
    Color? color,
    FontWeight weight = weightRegular,
    double height = lineHeightNormal,
  }) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: fontSm,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle textBase({
    Color? color,
    FontWeight weight = weightRegular,
    double height = lineHeightNormal,
  }) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: fontBase,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle textLg({
    Color? color,
    FontWeight weight = weightMedium,
    double height = lineHeightSnug,
  }) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: fontLg,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
  );

  static TextStyle textXl({
    Color? color,
    FontWeight weight = weightSemibold,
    double height = lineHeightSnug,
  }) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: fontXl,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
    letterSpacing: -0.2,
  );

  static TextStyle text2xl({
    Color? color,
    FontWeight weight = weightBold,
    double height = lineHeightTight,
  }) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: font2xl,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
    letterSpacing: -0.3,
  );

  static TextStyle text3xl({
    Color? color,
    FontWeight weight = weightBold,
    double height = lineHeightTight,
  }) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: font3xl,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
    letterSpacing: -0.5,
  );

  static TextStyle text4xl({
    Color? color,
    FontWeight weight = weightExtrabold,
    double height = lineHeightTight,
  }) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: font4xl,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
    letterSpacing: -0.5,
  );

  // ============ Semantic Text Styles ============
  static TextStyle get heading1 => text4xl(weight: weightExtrabold);
  static TextStyle get heading2 => text3xl(weight: weightBold);
  static TextStyle get heading3 => text2xl(weight: weightBold);
  static TextStyle get heading4 => textXl(weight: weightSemibold);

  static TextStyle get body => textBase();
  static TextStyle get bodySmall => textSm(color: AppColors.textSecondary);
  static TextStyle get caption => textXs(color: AppColors.textTertiary);

  static TextStyle get label => textSm(weight: weightMedium);
  static TextStyle get labelSmall => textXs(weight: weightMedium);

  static TextStyle get buttonText => textLg(
    weight: weightBold,
    color: Colors.white,
  );

  // ============ Animation Durations ============
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // ============ Animation Curves ============
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  static const Curve curveBounce = Curves.elasticOut;
}
