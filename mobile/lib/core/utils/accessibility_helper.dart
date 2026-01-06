import 'package:flutter/material.dart';

/// Accessibility helper utilities
///
/// Provides helpers for improving app accessibility
class AccessibilityHelper {
  /// Announce message to screen reader
  static void announce(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      // Use SnackBar with duration 0 and empty content to trigger announcement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 100),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation;
  }

  /// Get accessible navigation padding
  static EdgeInsets getAccessiblePadding(BuildContext context) {
    // Increase padding for better tap targets when using screen reader
    if (isScreenReaderEnabled(context)) {
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.all(8);
  }

  /// Get minimum tap target size (44x44 as per accessibility guidelines)
  static const double minTapTargetSize = 44.0;

  /// Wrap widget with minimum tap target size
  static Widget ensureMinTapTarget(Widget child, {
    double? width,
    double? height,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width ?? minTapTargetSize,
        minHeight: height ?? minTapTargetSize,
      ),
      child: child,
    );
  }

  /// Create semantic label for currency
  static String formatCurrencyForScreenReader(int amount) {
    if (amount >= 1000000) {
      final millions = (amount / 1000000).toStringAsFixed(1);
      return '$millions백만원';
    } else if (amount >= 10000) {
      final tenThousands = (amount / 10000).toStringAsFixed(0);
      return '$tenThousands만원';
    } else if (amount >= 1000) {
      final thousands = (amount / 1000).toStringAsFixed(0);
      return '$thousands천원';
    }
    return '$amount원';
  }

  /// Create semantic label for numbers
  static String formatNumberForScreenReader(int number) {
    if (number >= 10000) {
      final tenThousands = (number / 10000).toStringAsFixed(1);
      return '$tenThousands만';
    } else if (number >= 1000) {
      final thousands = (number / 1000).toStringAsFixed(1);
      return '$thousands천';
    }
    return number.toString();
  }

  /// Create semantic label for date
  static String formatDateForScreenReader(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// Create semantic label for time
  static String formatTimeForScreenReader(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? '오후' : '오전';
    return '$period $hour시 ${time.minute}분';
  }

  /// Create semantic label for duration
  static String formatDurationForScreenReader(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분';
    }
    return '${duration.inSeconds}초';
  }

  /// Create semantic label for percentage
  static String formatPercentageForScreenReader(double percentage) {
    return '${percentage.toStringAsFixed(0)}퍼센트';
  }
}

/// Semantic wrapper widgets for common patterns
class SemanticButton extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onTap;
  final bool excludeSemantics;

  const SemanticButton({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onTap,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      excludeSemantics: excludeSemantics,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class SemanticImage extends StatelessWidget {
  final Widget child;
  final String label;

  const SemanticImage({
    super.key,
    required this.child,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(child: child),
    );
  }
}

class SemanticHeader extends StatelessWidget {
  final Widget child;
  final String label;
  final bool header;

  const SemanticHeader({
    super.key,
    required this.child,
    required this.label,
    this.header = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      header: header,
      child: ExcludeSemantics(child: child),
    );
  }
}
