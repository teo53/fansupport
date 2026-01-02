import 'package:flutter/material.dart';

/// Modern Blue Glassmorphism Color System
/// Clean, minimal UI design with refined blue tones
class AppColors {
  // ============================================
  // PRIMARY BLUE PALETTE
  // ============================================

  /// Primary blue - Main brand color
  static const Color primary = Color(0xFF2563EB);

  /// Primary variants
  static const Color primary50 = Color(0xFFEFF6FF);
  static const Color primary100 = Color(0xFFDBEAFE);
  static const Color primary200 = Color(0xFFBFDBFE);
  static const Color primary300 = Color(0xFF93C5FD);
  static const Color primary400 = Color(0xFF60A5FA);
  static const Color primary500 = Color(0xFF3B82F6);
  static const Color primary600 = Color(0xFF2563EB);
  static const Color primary700 = Color(0xFF1D4ED8);
  static const Color primary800 = Color(0xFF1E40AF);
  static const Color primary900 = Color(0xFF1E3A8A);

  /// Legacy aliases
  static const Color primaryDark = primary700;
  static const Color primaryLight = primary300;
  static const Color primarySoft = primary50;
  static const Color accent = primary;

  // ============================================
  // SECONDARY PALETTE
  // ============================================

  static const Color secondary = Color(0xFF1E293B);
  static const Color secondaryLight = Color(0xFF334155);
  static const Color secondarySoft = Color(0xFFF1F5F9);

  // ============================================
  // NEUTRAL PALETTE
  // ============================================

  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Grey scale
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // ============================================
  // BACKGROUND & SURFACE
  // ============================================

  /// Main background - soft white
  static const Color background = Color(0xFFFAFBFC);

  /// Alternative background
  static const Color backgroundAlt = Color(0xFFF1F5F9);

  /// Surface color
  static const Color surface = Color(0xFFFFFFFF);

  /// Card background
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Elevated surface
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Dark mode backgrounds
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceElevated = Color(0xFF334155);

  /// Input background
  static const Color inputBackground = Color(0xFFF8FAFC);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Primary text - deep slate
  static const Color textPrimary = Color(0xFF1E293B);

  /// Secondary text - medium grey
  static const Color textSecondary = Color(0xFF64748B);

  /// Tertiary text - light grey
  static const Color textTertiary = Color(0xFF94A3B8);

  /// Hint text
  static const Color textHint = Color(0xFFCBD5E1);

  /// White text
  static const Color textWhite = Color(0xFFFFFFFF);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  /// Success green
  static const Color success = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFFDCFCE7);

  /// Warning orange
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);

  /// Error red
  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEE2E2);

  /// Info blue
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFFDBEAFE);

  // ============================================
  // BORDERS & DIVIDERS
  // ============================================

  /// Default border
  static const Color border = Color(0xFFE2E8F0);

  /// Light border
  static const Color borderLight = Color(0xFFF1F5F9);

  /// Divider color
  static const Color divider = Color(0xFFE2E8F0);

  // ============================================
  // SOCIAL COLORS
  // ============================================

  static const Color kakao = Color(0xFFFEE500);
  static const Color naver = Color(0xFF03C75A);
  static const Color google = Color(0xFFFFFFFF);
  static const Color apple = Color(0xFF000000);

  // ============================================
  // CATEGORY COLORS
  // ============================================

  /// Blue-based category colors for consistency
  static const Color idolCategory = Color(0xFF3B82F6);
  static const Color maidCategory = Color(0xFFEC4899);
  static const Color cosplayCategory = Color(0xFF8B5CF6);
  static const Color vtuberCategory = Color(0xFF06B6D4);
  static const Color streamerCategory = Color(0xFF10B981);
  static const Color cosplayerCategory = cosplayCategory;

  // ============================================
  // RANKING COLORS
  // ============================================

  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // ============================================
  // SPECIAL EFFECTS
  // ============================================

  static const Color neonPink = Color(0xFFEC4899);
  static const Color neonPurple = Color(0xFF8B5CF6);

  /// Shadow base color
  static const Color shadowColor = Color(0xFF2563EB);

  // ============================================
  // GRADIENTS
  // ============================================

  /// Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary400, primary600],
  );

  /// Premium gradient
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  /// Neon gradient (soft version)
  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
  );

  /// Glass gradient
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xE6FFFFFF), Color(0x99FFFFFF)],
  );

  /// Shimmer gradient
  static LinearGradient get shimmerGradient => const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [grey100, grey200, grey100],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================
  // SHADOWS
  // ============================================

  /// Soft card shadow with blue tint
  static List<BoxShadow> cardShadow({double opacity = 0.06}) => [
    BoxShadow(
      color: shadowColor.withOpacity(opacity),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Subtle soft shadow
  static List<BoxShadow> softShadow({double opacity = 0.04}) => [
    BoxShadow(
      color: shadowColor.withOpacity(opacity),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Elevated shadow
  static List<BoxShadow> elevatedShadow({double opacity = 0.10}) => [
    BoxShadow(
      color: shadowColor.withOpacity(opacity),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Glow shadow for focus states
  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.25}) => [
    BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: -4,
    ),
  ];

  /// Glass shadow effect
  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: shadowColor.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 4),
      spreadRadius: -8,
    ),
    BoxShadow(
      color: white.withOpacity(0.5),
      blurRadius: 4,
      offset: const Offset(0, -1),
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // UTILITY METHODS
  // ============================================

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

  /// Get category color by name
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'idol':
        return idolCategory;
      case 'maid':
        return maidCategory;
      case 'cosplay':
      case 'cosplayer':
        return cosplayCategory;
      case 'vtuber':
        return vtuberCategory;
      case 'streamer':
        return streamerCategory;
      default:
        return primary;
    }
  }

  /// Get ranking color by position
  static Color getRankingColor(int position) {
    switch (position) {
      case 1:
        return gold;
      case 2:
        return silver;
      case 3:
        return bronze;
      default:
        return grey400;
    }
  }
}
