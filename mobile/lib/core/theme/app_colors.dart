import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Coral Pink - 사용자 선호)
  static const Color primary = Color(0xFFFB7185); // Coral Pink (rose-400)
  static const Color primaryDark = Color(0xFFF43F5E); // Deeper coral (rose-500)
  static const Color primaryLight = Color(0xFFFDA4AF); // Light coral (rose-300)
  static const Color primarySoft = Color(0xFFFFF1F2); // Very light coral tint

  // Secondary Brand Colors (Neutral Dark)
  static const Color secondary = Color(0xFF1B1B1E);
  static const Color secondaryLight = Color(0xFF333333);
  static const Color secondarySoft = Color(0xFFF2F4F6);

  // Backgrounds (Clean Surface)
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundAlt = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Colors.white;
  static const Color darkBackground = Color(0xFF121212);

  // Text Colors (High Contrast)
  static const Color textPrimary = Color(0xFF191F28);
  static const Color textSecondary = Color(0xFF8B95A1);
  static const Color textTertiary = Color(0xFFB0B8C1);
  static const Color textHint = Color(0xFFB0B8C1);
  static const Color textWhite = Colors.white;

  // Status Colors
  static const Color error = Color(0xFFF04452);
  static const Color success = Color(0xFF32D74B);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color info = Color(0xFF0A84FF);

  // Soft Status Colors
  static const Color infoSoft = Color(0xFFE5F1FF);
  static const Color successSoft = Color(0xFFEAF9EB);
  static const Color errorSoft = Color(0xFFFDECEC);
  static const Color warningSoft = Color(0xFFFFF5E5);

  // Accent & Utility
  static const Color accent = Color(0xFFFB7185);
  static const Color shadowColor = Color(0xFF000000);
  static const Color surfaceElevated = Colors.white;
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkSurfaceElevated = Color(0xFF383838);
  static const Color inputBackground = Color(0xFFF9FAFB);
  static const Color divider = Color(0xFFE5E8EB);
  static const Color border = Color(0xFFE5E8EB);

  // Social Colors
  static const Color kakao = Color(0xFFFFE812);
  static const Color naver = Color(0xFF03C75A);
  static const Color google = Colors.white;
  static const Color apple = Colors.black;

  // Category Colors (Coral Pink 계열 조화)
  static const Color idolCategory = Color(0xFFFB7185);
  static const Color maidCategory = Color(0xFFF472B6);
  static const Color cosplayCategory = Color(0xFFE879F9);
  static const Color vtuberCategory = Color(0xFF38BDF8);
  static const Color streamerCategory = Color(0xFFFB923C);
  static const Color cosplayerCategory = cosplayCategory;

  // Premium Gradients (Subtle Coral Pink)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFB7185), Color(0xFFFDA4AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFFDA4AF), Color(0xFFFECDD3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0xCCFFFFFF), Color(0x99FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shimmer Colors (for loading effects)
  static const Color shimmerBase = Color(0xFFFFF1F2);
  static const Color shimmerHighlight = Color(0xFFFFFFFF);

  // Glow Colors (Coral Pink)
  static const Color glowPink = Color(0xFFFB7185);
  static const Color glowLight = Color(0xFFFDA4AF);

  // Glassmorphism Colors
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x66FFFFFF);
  static const Color glassOverlay = Color(0x1AFFFFFF);

  // Premium Holographic Gradient (Coral Pink 기반)
  static const LinearGradient holographicGradient = LinearGradient(
    colors: [
      Color(0xFFFB7185),
      Color(0xFFF472B6),
      Color(0xFFFDA4AF),
      Color(0xFFFECDD3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Coral Glow Gradient (for borders)
  static const LinearGradient glowBorderGradient = LinearGradient(
    colors: [Color(0xFFFB7185), Color(0xFFFDA4AF), Color(0xFFFECDD3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ranking Colors
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // Legacy Neon Colors (Coral Pink 계열로 대체 - 호환성 유지)
  static const Color neonPink = Color(0xFFFB7185);
  static const Color neonPurple = Color(0xFFF472B6); // pink-400 대체
  static const Color neonBlue = Color(0xFF38BDF8);
  static const Color neonCyan = Color(0xFF22D3EE);
  static const Color neonMagenta = Color(0xFFF472B6);

  // Legacy Holo Colors (호환성 유지)
  static const Color holoGold = Color(0xFFFFD700);
  static const Color holoPink = Color(0xFFFDA4AF);
  static const Color holoBlue = Color(0xFF38BDF8);
  static const Color holoGreen = Color(0xFF4ADE80);

  // Legacy Neon Gradient (Coral Pink)
  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFFFB7185), Color(0xFFFDA4AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonBorderGradient = LinearGradient(
    colors: [Color(0xFFFB7185), Color(0xFFFDA4AF), Color(0xFFFECDD3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows (Soft & Diffuse)
  static List<BoxShadow> cardShadow({double opacity = 0.04}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> softShadow({double opacity = 0.03}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 10,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> elevatedShadow({double opacity = 0.08}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.2}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: -4,
      ),
    ];
  }

  /// Convert hex string to Color
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
}
