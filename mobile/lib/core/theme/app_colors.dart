import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Sophisticated Blue-Violet)
  static const Color primary = Color(0xFF5D5FEF); // 'Toss-like' Blue-Violet
  static const Color primaryDark = Color(0xFF4244CC);
  static const Color primaryLight = Color(0xFFA5A6F6);

  // Secondary Brand Colors (Clean accents)
  static const Color secondary = Color(0xFF1B1B1E); // Almost Black accent
  static const Color secondaryLight = Color(0xFF333333);

  // Backgrounds (Clean Surface)
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color backgroundAlt =
      Color(0xFFF9FAFB); // Very Light Grey for contrast
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Colors.white; // Alias for surface
  static const Color darkBackground = Color(0xFF121212);

  // Text Colors (High Contrast)
  static const Color textPrimary = Color(0xFF191F28); // Sharp Black-Grey
  static const Color textSecondary = Color(0xFF8B95A1); // Soft Grey
  static const Color textTertiary = Color(0xFFB0B8C1); // Light Grey
  static const Color textHint = Color(0xFFB0B8C1); // Alias for tertiary
  static const Color textWhite = Colors.white;

  // Status Colors (Softened)
  static const Color error = Color(0xFFF04452); // Soft Red
  static const Color success = Color(0xFF32D74B); // Soft Green
  static const Color warning = Color(0xFFFF9F0A); // Soft Orange
  static const Color info = Color(0xFF0A84FF); // Soft Blue

  // Legacy/Compatibility definitions (Mapped to new minimal palette or kept neutral)
  static const Color primarySoft = Color(0xFFEFEFFD); // Very light primary tint
  static const Color secondarySoft = Color(0xFFF2F4F6); // Neutral Grey
  static const Color accent = Color(0xFF5D5FEF);
  static const Color infoSoft = Color(0xFFE5F1FF);
  static const Color successSoft = Color(0xFFEAF9EB);
  static const Color errorSoft = Color(0xFFFDECEC);
  static const Color warningSoft = Color(0xFFFFF5E5);
  static const Color shadowColor = Color(0xFF000000);
  static const Color surfaceElevated = Colors.white;
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkSurfaceElevated = Color(0xFF383838);
  static const Color inputBackground =
      Color(0xFFF9FAFB); // Light grey for inputs
  static const Color divider = Color(0xFFE5E8EB);

  // Social Colors (Kept as is for brand recognition)
  static const Color kakao = Color(0xFFFFE812);
  static const Color naver = Color(0xFF03C75A);
  static const Color google = Colors.white;
  static const Color apple = Colors.black;

  // Category Colors (Restored)
  static const Color idolCategory = Color(0xFFF27898);
  static const Color maidCategory = Color(0xFFFF5DAD);
  static const Color cosplayCategory = Color(0xFF904CA8);
  static const Color vtuberCategory = Color(0xFF5796F3);
  static const Color streamerCategory = Color(0xFFFF9747);
  // Aliases for compatibility
  static const Color cosplayerCategory = cosplayCategory;

  // Gradients (Subtle, not aggressive)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5D5FEF), Color(0xFF7B7DF5)], // Subtle shift
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF1B1B1E), Color(0xFF333333)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Replaced "Neon" with a soft primary glow for compatibility
  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF5D5FEF), Color(0xFF7B7DF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0xCCFFFFFF), Color(0x99FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color neonPink = Color(0xFFF04452);
  static const Color neonPurple = Color(0xFF5D5FEF);

  // Ranking Colors
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // Borders
  static const Color border = Color(0xFFE5E8EB); // Very subtle border

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
