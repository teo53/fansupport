import 'package:flutter/material.dart';

/// PIPO Design System
/// 브랜드 키컬러: #FF5A5F
///
/// 이 파일은 앱 전체의 일관된 디자인을 위한 시스템을 정의합니다.

// ============================================================================
// COLOR SYSTEM
// ============================================================================

class PipoColors {
  PipoColors._();

  // ---------------------------------------------------------------------------
  // Primary Colors (Brand)
  // ---------------------------------------------------------------------------
  /// 브랜드 메인 컬러 - CTA, 강조, 로고
  static const Color primary = Color(0xFFFF5A5F);

  /// 더 진한 Primary - Pressed 상태, 그라데이션
  static const Color primaryDark = Color(0xFFE84C51);

  /// 밝은 Primary - Hover, Secondary CTA
  static const Color primaryLight = Color(0xFFFF8A8E);

  /// 매우 밝은 Primary - 배경, 컨테이너
  static const Color primarySoft = Color(0xFFFFF0F0);

  /// 가장 밝은 Primary - Subtle 배경
  static const Color primarySubtle = Color(0xFFFFF8F8);

  // ---------------------------------------------------------------------------
  // Secondary Colors (Accent)
  // ---------------------------------------------------------------------------
  /// Purple Accent - 프리미엄, VIP
  static const Color purple = Color(0xFF6366F1);
  static const Color purpleLight = Color(0xFF8B5CF6);
  static const Color purpleSoft = Color(0xFFEEF2FF);

  /// Teal Accent - 성공, 완료, 긍정
  static const Color teal = Color(0xFF10B981);
  static const Color tealLight = Color(0xFF34D399);
  static const Color tealSoft = Color(0xFFECFDF5);

  /// Orange Accent - 경고, 주목
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFB923C);
  static const Color orangeSoft = Color(0xFFFFF7ED);

  // ---------------------------------------------------------------------------
  // Semantic Colors
  // ---------------------------------------------------------------------------
  /// Success - 성공, 완료
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  /// Warning - 경고, 주의
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  /// Error - 오류, 실패
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  /// Info - 정보
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ---------------------------------------------------------------------------
  // Neutral Colors (Grayscale)
  // ---------------------------------------------------------------------------
  /// Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFBBBBBB);
  static const Color textInverse = Color(0xFFFFFFFF);

  /// Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF9FAFB);
  static const Color backgroundTertiary = Color(0xFFF3F4F6);

  /// Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFFD1D5DB);

  /// Divider
  static const Color divider = Color(0xFFE5E7EB);

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF5A5F), Color(0xFFFF8A8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFFF5A5F), Color(0xFFE84C51), Color(0xFFD43F44)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ============================================================================
// TYPOGRAPHY SYSTEM
// ============================================================================

class PipoTypography {
  PipoTypography._();

  /// Font Family
  static const String fontFamily = 'Pretendard';

  // ---------------------------------------------------------------------------
  // Display Styles - 대형 타이틀 (Hero, Splash)
  // ---------------------------------------------------------------------------
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.2,
    color: PipoColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.2,
    color: PipoColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
    color: PipoColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Headline Styles - 섹션 타이틀
  // ---------------------------------------------------------------------------
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
    color: PipoColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
    color: PipoColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
    color: PipoColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Title Styles - 카드, 리스트 아이템 타이틀
  // ---------------------------------------------------------------------------
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
    color: PipoColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
    color: PipoColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: PipoColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Body Styles - 본문 텍스트
  // ---------------------------------------------------------------------------
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: PipoColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: PipoColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: PipoColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // Label Styles - 버튼, 라벨, 태그
  // ---------------------------------------------------------------------------
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: PipoColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: PipoColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: PipoColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // Caption Styles - 작은 설명 텍스트
  // ---------------------------------------------------------------------------
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: PipoColors.textTertiary,
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: PipoColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // Button Styles
  // ---------------------------------------------------------------------------
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );
}

// ============================================================================
// SPACING SYSTEM (8pt Grid)
// ============================================================================

class PipoSpacing {
  PipoSpacing._();

  /// 4pt - Extra Small
  static const double xs = 4;

  /// 8pt - Small
  static const double sm = 8;

  /// 12pt - Medium Small
  static const double md = 12;

  /// 16pt - Medium
  static const double lg = 16;

  /// 20pt - Medium Large
  static const double xl = 20;

  /// 24pt - Large
  static const double xxl = 24;

  /// 32pt - Extra Large
  static const double xxxl = 32;

  /// 40pt - 2X Extra Large
  static const double huge = 40;

  /// 48pt - 3X Extra Large
  static const double massive = 48;

  /// 64pt - Screen Level
  static const double screen = 64;

  // ---------------------------------------------------------------------------
  // Common Paddings
  // ---------------------------------------------------------------------------
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);
}

// ============================================================================
// RADIUS SYSTEM
// ============================================================================

class PipoRadius {
  PipoRadius._();

  /// 4pt - Extra Small (Tags, Chips)
  static const double xs = 4;

  /// 8pt - Small (Small Buttons)
  static const double sm = 8;

  /// 12pt - Medium (Cards, Inputs)
  static const double md = 12;

  /// 16pt - Large (Buttons, Containers)
  static const double lg = 16;

  /// 20pt - Extra Large (Large Cards)
  static const double xl = 20;

  /// 24pt - 2X Large (Bottom Sheets)
  static const double xxl = 24;

  /// 32pt - 3X Large (Modal, Special Cards)
  static const double xxxl = 32;

  /// Full - Circle
  static const double full = 999;

  // ---------------------------------------------------------------------------
  // Common BorderRadius
  // ---------------------------------------------------------------------------
  static BorderRadius get button => BorderRadius.circular(lg);
  static BorderRadius get card => BorderRadius.circular(xl);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get bottomSheet => const BorderRadius.vertical(top: Radius.circular(24));
  static BorderRadius get chip => BorderRadius.circular(sm);
}

// ============================================================================
// SHADOW SYSTEM (Elevation)
// ============================================================================

class PipoShadows {
  PipoShadows._();

  /// Level 1 - Subtle (Cards, Containers)
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Level 2 - Medium (Elevated Cards, Dropdowns)
  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Level 3 - Strong (Modals, Popovers)
  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Level 4 - Extra Strong (Bottom Sheets, Dialogs)
  static List<BoxShadow> get xl => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  /// Primary Glow - CTA Buttons
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: PipoColors.primary.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Purple Glow - Premium Buttons
  static List<BoxShadow> get purpleGlow => [
    BoxShadow(
      color: PipoColors.purple.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

// ============================================================================
// ANIMATION SYSTEM
// ============================================================================

class PipoAnimations {
  PipoAnimations._();

  // ---------------------------------------------------------------------------
  // Durations
  // ---------------------------------------------------------------------------
  /// 100ms - Micro interactions (hover, press)
  static const Duration fast = Duration(milliseconds: 100);

  /// 200ms - Small transitions (tabs, toggles)
  static const Duration normal = Duration(milliseconds: 200);

  /// 300ms - Medium transitions (page transitions)
  static const Duration medium = Duration(milliseconds: 300);

  /// 400ms - Larger transitions (modals, sheets)
  static const Duration slow = Duration(milliseconds: 400);

  /// 600ms - Complex animations
  static const Duration slower = Duration(milliseconds: 600);

  // ---------------------------------------------------------------------------
  // Curves
  // ---------------------------------------------------------------------------
  /// Standard easing for most animations
  static const Curve standard = Curves.easeOutCubic;

  /// For elements entering screen
  static const Curve enter = Curves.easeOut;

  /// For elements leaving screen
  static const Curve exit = Curves.easeIn;

  /// For bounce effects
  static const Curve bounce = Curves.elasticOut;

  /// For spring effects
  static const Curve spring = Curves.easeOutBack;
}

// ============================================================================
// ICON SIZES
// ============================================================================

class PipoIconSizes {
  PipoIconSizes._();

  /// 16pt - Extra Small
  static const double xs = 16;

  /// 20pt - Small
  static const double sm = 20;

  /// 24pt - Medium (Default)
  static const double md = 24;

  /// 28pt - Large
  static const double lg = 28;

  /// 32pt - Extra Large
  static const double xl = 32;

  /// 40pt - 2X Large
  static const double xxl = 40;

  /// 48pt - 3X Large
  static const double xxxl = 48;
}
