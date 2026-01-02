/// Design Tokens for Idol Support App
/// Modern Glassmorphism Design System
///
/// Based on 8pt grid system for consistent spacing

import 'package:flutter/material.dart';

/// Spacing tokens based on 8pt grid system
abstract class Spacing {
  /// 4px - Extra small spacing
  static const double xs = 4.0;

  /// 8px - Small spacing
  static const double sm = 8.0;

  /// 12px - Medium-small spacing
  static const double md = 12.0;

  /// 16px - Medium spacing (base unit)
  static const double base = 16.0;

  /// 20px - Medium-large spacing
  static const double lg = 20.0;

  /// 24px - Large spacing
  static const double xl = 24.0;

  /// 32px - Extra large spacing
  static const double xxl = 32.0;

  /// 40px - 2X extra large spacing
  static const double xxxl = 40.0;

  /// 48px - Section spacing
  static const double section = 48.0;

  /// 64px - Page margin
  static const double page = 64.0;

  /// Screen horizontal padding
  static const double screenHorizontal = 20.0;

  /// Screen vertical padding
  static const double screenVertical = 24.0;

  /// Card internal padding
  static const double cardPadding = 16.0;

  /// List item spacing
  static const double listSpacing = 12.0;
}

/// Border radius tokens
abstract class Radii {
  /// 4px - Extra small radius
  static const double xs = 4.0;

  /// 8px - Small radius
  static const double sm = 8.0;

  /// 12px - Medium radius
  static const double md = 12.0;

  /// 16px - Large radius (default for cards)
  static const double lg = 16.0;

  /// 20px - Extra large radius
  static const double xl = 20.0;

  /// 24px - 2X extra large radius
  static const double xxl = 24.0;

  /// 32px - Rounded containers
  static const double rounded = 32.0;

  /// 9999px - Full circular
  static const double full = 9999.0;

  /// Default card border radius
  static BorderRadius get card => BorderRadius.circular(lg);

  /// Default button border radius
  static BorderRadius get button => BorderRadius.circular(md);

  /// Default input border radius
  static BorderRadius get input => BorderRadius.circular(md);

  /// Default chip border radius
  static BorderRadius get chip => BorderRadius.circular(full);

  /// Bottom sheet border radius
  static BorderRadius get bottomSheet => const BorderRadius.vertical(
    top: Radius.circular(24),
  );
}

/// Typography scale following Material Design 3
abstract class TypographyTokens {
  static const String fontFamily = 'Pretendard';

  // Display styles - for hero sections
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline styles - for section headers
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title styles - for card titles, app bars
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body styles - for content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label styles - for buttons, chips
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
  );
}

/// Shadow tokens for elevation
abstract class Shadows {
  /// No shadow
  static const List<BoxShadow> none = [];

  /// Subtle shadow for cards
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: const Color(0xFF2563EB).withOpacity(0.04),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow for elevated elements
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: const Color(0xFF2563EB).withOpacity(0.08),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Strong shadow for floating elements
  static List<BoxShadow> get strong => [
    BoxShadow(
      color: const Color(0xFF2563EB).withOpacity(0.12),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Glass shadow for glassmorphism
  static List<BoxShadow> get glass => [
    BoxShadow(
      color: const Color(0xFF2563EB).withOpacity(0.06),
      offset: const Offset(0, 4),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.8),
      offset: const Offset(0, -1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Glow effect for active elements
  static List<BoxShadow> get glow => [
    BoxShadow(
      color: const Color(0xFF2563EB).withOpacity(0.3),
      offset: Offset.zero,
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  /// Bottom navigation shadow
  static List<BoxShadow> get bottomNav => [
    BoxShadow(
      color: const Color(0xFF2563EB).withOpacity(0.05),
      offset: const Offset(0, -4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
}

/// Animation duration tokens
abstract class AnimDurations {
  /// 100ms - Instant feedback
  static const Duration instant = Duration(milliseconds: 100);

  /// 150ms - Quick transitions
  static const Duration fast = Duration(milliseconds: 150);

  /// 200ms - Default transitions
  static const Duration normal = Duration(milliseconds: 200);

  /// 300ms - Smooth transitions
  static const Duration smooth = Duration(milliseconds: 300);

  /// 400ms - Slow transitions
  static const Duration slow = Duration(milliseconds: 400);

  /// 600ms - Page transitions
  static const Duration page = Duration(milliseconds: 600);
}

/// Animation curve tokens
abstract class AnimCurves {
  /// Standard easing for most animations
  static const Curve standard = Curves.easeInOut;

  /// Emphasized easing for important transitions
  static const Curve emphasized = Curves.easeOutCubic;

  /// Spring-like bounce effect
  static const Curve bounce = Curves.elasticOut;

  /// Quick start, slow end
  static const Curve decelerate = Curves.decelerate;

  /// Slow start, quick end
  static const Curve accelerate = Curves.easeIn;
}

/// Icon size tokens
abstract class IconSizes {
  /// 16px - Extra small icons
  static const double xs = 16.0;

  /// 20px - Small icons
  static const double sm = 20.0;

  /// 24px - Default icon size
  static const double md = 24.0;

  /// 28px - Large icons
  static const double lg = 28.0;

  /// 32px - Extra large icons
  static const double xl = 32.0;

  /// 48px - Feature icons
  static const double xxl = 48.0;

  /// 64px - Hero icons
  static const double hero = 64.0;
}

/// Button size configurations
abstract class ButtonSizes {
  /// Small button height
  static const double small = 36.0;

  /// Medium button height (default)
  static const double medium = 44.0;

  /// Large button height
  static const double large = 52.0;

  /// Extra large button height
  static const double extraLarge = 60.0;
}

/// Input field configurations
abstract class InputSizes {
  /// Small input height
  static const double small = 40.0;

  /// Medium input height (default)
  static const double medium = 48.0;

  /// Large input height
  static const double large = 56.0;
}
