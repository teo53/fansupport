import 'package:flutter/material.dart';

/// 🎨 PIPO - Bubble Style Color System
/// Coral Pink 기반의 트렌디하고 깔끔한 디자인 시스템
class AppColors {
  // ============================================
  // 🧡 Primary Brand Colors (Coral Pink)
  // ============================================
  static const Color primary = Color(0xFFFF7169); // Coral Pink - 메인 브랜드 컬러
  static const Color primaryDark = Color(0xFFFF4500); // Fiery Orange - CTA 강조
  static const Color primaryLight = Color(0xFFFF8E87); // Pastel Pink - 라이트 액센트
  static const Color primarySoft = Color(0xFFFFE5E3); // Very light pink - 배경 틴트

  // Legacy alias for compatibility
  static const Color accent = primary;

  // ============================================
  // ⚪ Neutral Base Colors
  // ============================================
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color backgroundAlt = Color(0xFFF8F9FA); // Lexical Neutral - Light Grey
  static const Color surface = Color(0xFFFFFFFF); // Card/Container surface
  static const Color cardBackground = Color(0xFFFFFFFF); // Alias
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF8F9FA);

  // ============================================
  // 🌑 Dark Mode Colors
  // ============================================
  static const Color darkBackground = Color(0xFF0F0F0F); // Almost Black
  static const Color darkSurface = Color(0xFF1A1A1A); // Dark Charcoal
  static const Color darkSurfaceElevated = Color(0xFF262626); // Slightly lighter
  static const Color darkBorder = Color(0xFF2D2D2D);

  // ============================================
  // 📝 Text Colors
  // ============================================
  static const Color textPrimary = Color(0xFF1A1A1A); // Dark Charcoal - 주요 텍스트
  static const Color textSecondary = Color(0xFF6B7280); // Medium Grey - 보조 텍스트
  static const Color textTertiary = Color(0xFF9CA3AF); // Light Grey - 힌트 텍스트
  static const Color textHint = Color(0xFF9CA3AF); // Alias
  static const Color textWhite = Color(0xFFFFFFFF);

  // Dark mode text
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextTertiary = Color(0xFF71717A);

  // ============================================
  // ✨ Status Colors
  // ============================================
  static const Color success = Color(0xFF28C76F); // Fresh Green - 성공/완료
  static const Color error = Color(0xFFFA3E3E); // Alert Red - 오류/경고
  static const Color warning = Color(0xFFFF9F0A); // Orange - 주의
  static const Color info = Color(0xFF9ED9F6); // Light Blue Tint - 정보

  // Soft variants for backgrounds
  static const Color successSoft = Color(0xFFE8F8F0);
  static const Color errorSoft = Color(0xFFFEE5E5);
  static const Color warningSoft = Color(0xFFFFF5E5);
  static const Color infoSoft = Color(0xFFEBF7FD);

  // ============================================
  // 🎭 Secondary & Supporting Colors
  // ============================================
  static const Color secondary = Color(0xFF1A1A1A); // Dark for contrast
  static const Color secondaryLight = Color(0xFF3D3D3D);
  static const Color secondarySoft = Color(0xFFF3F4F6);

  static const Color secondaryAccent = Color(0xFFFF8E87); // Pastel Pink - 강조 포인트
  static const Color highlightTint = Color(0xFF9ED9F6); // Light Blue - 하이라이트
  static const Color disabled = Color(0xFFC0C0C0); // Grey - 비활성화

  // ============================================
  // 🔲 Borders & Dividers
  // ============================================
  static const Color border = Color(0xFFE5E7EB); // Subtle border
  static const Color divider = Color(0xFFF3F4F6); // Very light divider
  static const Color shadowColor = Color(0xFF000000);

  // ============================================
  // 🌈 Category Colors (아이돌 카테고리)
  // ============================================
  static const Color idolCategory = Color(0xFFFF7169); // Coral Pink
  static const Color maidCategory = Color(0xFFFF8E87); // Pastel Pink
  static const Color cosplayCategory = Color(0xFFAB7EED); // Soft Purple
  static const Color vtuberCategory = Color(0xFF9ED9F6); // Light Blue
  static const Color streamerCategory = Color(0xFFFFB84D); // Warm Orange
  static const Color cosplayerCategory = cosplayCategory; // Alias

  // ============================================
  // 🎨 Social Login Colors
  // ============================================
  static const Color kakao = Color(0xFFFFE812);
  static const Color naver = Color(0xFF03C75A);
  static const Color google = Color(0xFFFFFFFF);
  static const Color apple = Color(0xFF000000);

  // ============================================
  // 🏆 Ranking Colors
  // ============================================
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // Legacy compatibility
  static const Color neonPink = primary;
  static const Color neonPurple = Color(0xFFAB7EED);

  // ============================================
  // 🎨 Gradients (Bubble Style - Soft & Modern)
  // ============================================

  /// Primary gradient - Coral Pink
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF7169), Color(0xFFFF8E87)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// CTA gradient - Fiery Orange (for important actions)
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFFFF4500), Color(0xFFFF7169)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Premium gradient - Dark elegant
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF3D3D3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass effect gradient
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0xCCFFFFFF), Color(0x99FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft background gradient
  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFFFFAF9), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Legacy compatibility
  static const LinearGradient neonGradient = primaryGradient;

  // ============================================
  // 💫 Shadows (Bubble Style - Soft & Subtle)
  // ============================================

  /// 카드 그림자 - 매우 부드러운 느낌
  static List<BoxShadow> cardShadow({double opacity = 0.06}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  /// 소프트 그림자 - 작은 요소용
  static List<BoxShadow> softShadow({double opacity = 0.04}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  /// Elevated 그림자 - 떠있는 느낌
  static List<BoxShadow> elevatedShadow({double opacity = 0.10}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
      ];

  /// Glow 그림자 - CTA 버튼용
  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.25}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: -4,
      ),
    ];
  }

  /// Bottom sheet 그림자
  static List<BoxShadow> bottomSheetShadow({double opacity = 0.12}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 32,
          offset: const Offset(0, -4),
          spreadRadius: 0,
        ),
      ];

  // ============================================
  // 🛠️ Utility Functions
  // ============================================

  /// Hex string을 Color로 변환
  static Color fromHex(String? hexString, {Color defaultColor = primary}) {
    if (hexString == null) return defaultColor;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return defaultColor;
    }
  }

  /// 밝기에 따른 텍스트 색상 반환
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : textWhite;
  }

  /// Opacity 조절된 색상 반환
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
