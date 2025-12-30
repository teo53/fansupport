import 'package:flutter/material.dart';

class AppColors {
  // ============ Primary Colors (모던 핑크-퍼플 그라데이션) ============
  static const Color primary = Color(0xFFE91E63);
  static const Color primaryLight = Color(0xFFFF5C8D);
  static const Color primaryDark = Color(0xFFC2185B);
  static const Color primarySoft = Color(0xFFFCE4EC);

  // ============ Secondary Colors (딥 퍼플) ============
  static const Color secondary = Color(0xFF7C4DFF);
  static const Color secondaryLight = Color(0xFFB388FF);
  static const Color secondaryDark = Color(0xFF651FFF);
  static const Color secondarySoft = Color(0xFFEDE7F6);

  // ============ Accent Colors (네온 효과) ============
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentAlt = Color(0xFFFFD600);
  static const Color neonPink = Color(0xFFFF1493);
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonPurple = Color(0xFF9D4EDD);

  // ============ Semantic Colors ============
  static const Color success = Color(0xFF00C853);
  static const Color successSoft = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFAB00);
  static const Color warningSoft = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFFF1744);
  static const Color errorSoft = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2979FF);
  static const Color infoSoft = Color(0xFFE3F2FD);

  // ============ Background Colors ============
  static const Color background = Color(0xFFFAFAFC);
  static const Color backgroundAlt = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF5F6F8);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ============ Dark Theme ============
  static const Color darkBackground = Color(0xFF0D0D0F);
  static const Color darkBackgroundAlt = Color(0xFF1A1A1F);
  static const Color darkSurface = Color(0xFF1E1E24);
  static const Color darkSurfaceElevated = Color(0xFF2A2A32);

  // ============ Text Colors ============
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============ Border & Divider ============
  static const Color border = Color(0xFFE8E8EC);
  static const Color borderLight = Color(0xFFF0F0F4);
  static const Color divider = Color(0xFFF5F5F7);
  static const Color shadowColor = Color(0x1A000000);

  // ============ Gradients ============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFFE91E63), Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
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
      Color(0xFFEEEEEE),
      Color(0xFFF5F5F5),
      Color(0xFFEEEEEE),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF9BC3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonPink, neonPurple, neonBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Ranking Colors ============
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFDAA520);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color silverDark = Color(0xFFA8A8A8);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color bronzeDark = Color(0xFFB87333);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient silverGradient = LinearGradient(
    colors: [Color(0xFFE8E8E8), Color(0xFFC0C0C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bronzeGradient = LinearGradient(
    colors: [Color(0xFFCD7F32), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Category Colors ============
  static const Color idolCategory = Color(0xFFE91E63);
  static const Color maidCategory = Color(0xFF9C27B0);
  static const Color cosplayCategory = Color(0xFFFF5722);
  static const Color cosplayerCategory = Color(0xFFFF5722);
  static const Color vtuberCategory = Color(0xFF00BCD4);

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

  static List<BoxShadow> cardShadow({double opacity = 0.08}) {
    return [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, opacity),
        blurRadius: 20,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> elevatedShadow({double opacity = 0.12}) {
    return [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, opacity),
        blurRadius: 30,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.4}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 20,
        offset: const Offset(0, 4),
        spreadRadius: -4,
      ),
    ];
  }

  static List<BoxShadow> softShadow({double opacity = 0.06}) {
    return [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, opacity),
        blurRadius: 16,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
    ];
  }
}
