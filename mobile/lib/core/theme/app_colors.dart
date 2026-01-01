import 'package:flutter/material.dart';

class AppColors {
  // ============ Primary Colors (프리미엄 인디고) ============
  static const Color primary = Color(0xFF5046E5);
  static const Color primaryLight = Color(0xFF7B73FF);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primarySoft = Color(0xFFEEF2FF);

  // ============ Secondary Colors (코랄 핑크 - 아이돌 에너지) ============
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryLight = Color(0xFFFF9BC0);
  static const Color secondaryDark = Color(0xFFE84C7A);
  static const Color secondarySoft = Color(0xFFFFF0F5);

  // ============ Accent Colors (포인트 컬러) ============
  static const Color accent = Color(0xFF06B6D4);
  static const Color accentAlt = Color(0xFFF59E0B);
  static const Color neonPink = Color(0xFFFF6B9D);
  static const Color neonBlue = Color(0xFF3B82F6);
  static const Color neonPurple = Color(0xFF8B5CF6);

  // ============ Semantic Colors ============
  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFFDBEAFE);

  // ============ Background Colors (클린 & 미니멀) ============
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundAlt = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ============ Dark Theme ============
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkBackgroundAlt = Color(0xFF1E293B);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceElevated = Color(0xFF334155);

  // ============ Text Colors (가독성 최적화) ============
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFFCBD5E1);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============ Border & Divider ============
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color shadowColor = Color(0x1A0F172A);

  // ============ Gradients ============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5046E5), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFFF6B9D), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFE2E8F0),
      Color(0xFFF8FAFC),
      Color(0xFFE2E8F0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF5046E5), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonPink, neonPurple, neonBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF9BC0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Ranking Colors ============
  static const Color gold = Color(0xFFFBBF24);
  static const Color goldDark = Color(0xFFD97706);
  static const Color silver = Color(0xFF94A3B8);
  static const Color silverDark = Color(0xFF64748B);
  static const Color bronze = Color(0xFFF97316);
  static const Color bronzeDark = Color(0xFFEA580C);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient silverGradient = LinearGradient(
    colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bronzeGradient = LinearGradient(
    colors: [Color(0xFFFB923C), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Category Colors ============
  static const Color idolCategory = Color(0xFF5046E5);
  static const Color maidCategory = Color(0xFFFF6B9D);
  static const Color cosplayCategory = Color(0xFFF97316);
  static const Color cosplayerCategory = Color(0xFFF97316);
  static const Color vtuberCategory = Color(0xFF06B6D4);

  // ============ Social Colors ============
  static const Color kakao = Color(0xFFFEE500);
  static const Color naver = Color(0xFF03C75A);
  static const Color google = Color(0xFF4285F4);
  static const Color apple = Color(0xFF000000);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color instagram = Color(0xFFE4405F);

  // ============ Helper Methods ============
  static Color withAlpha(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static List<BoxShadow> cardShadow({double opacity = 0.04}) {
    return [
      BoxShadow(
        color: Color.fromRGBO(15, 23, 42, opacity),
        blurRadius: 16,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> elevatedShadow({double opacity = 0.08}) {
    return [
      BoxShadow(
        color: Color.fromRGBO(15, 23, 42, opacity),
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 16,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      ),
    ];
  }

  static List<BoxShadow> softShadow({double opacity = 0.03}) {
    return [
      BoxShadow(
        color: Color.fromRGBO(15, 23, 42, opacity),
        blurRadius: 12,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> bottomNavShadow() {
    return [
      BoxShadow(
        color: Color.fromRGBO(15, 23, 42, 0.06),
        blurRadius: 20,
        offset: const Offset(0, -4),
        spreadRadius: 0,
      ),
    ];
  }
}
