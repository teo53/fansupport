import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_system.dart';

/// Unified Feedback Helper for consistent user feedback
///
/// Provides standardized SnackBars, Toasts, and Haptic feedback
class FeedbackHelper {
  FeedbackHelper._();

  // ============================================================================
  // SnackBar Methods
  // ============================================================================

  /// Show informational message
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: PipoColors.info,
      icon: Icons.info_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show success message
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: PipoColors.success,
      icon: Icons.check_circle_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show error message
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: PipoColors.error,
      icon: Icons.error_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show warning message
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: PipoColors.warning,
      icon: Icons.warning_amber_rounded,
      duration: duration,
      action: action,
    );
  }

  /// Show coming soon message (준비중)
  static void showComingSoon(
    BuildContext context, {
    String feature = '이 기능',
  }) {
    showInfo(
      context,
      '$feature은 곧 준비됩니다',
      duration: const Duration(seconds: 2),
    );
  }

  // ============================================================================
  // Haptic Feedback Methods
  // ============================================================================

  /// Light haptic feedback for general interactions
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for selections
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Heavy haptic feedback for important actions
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Success haptic pattern
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Error haptic pattern
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  // ============================================================================
  // Dialog Methods
  // ============================================================================

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PipoRadius.xl),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: TextStyle(color: PipoColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDangerous ? PipoColors.error : PipoColors.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show loading dialog
  static void showLoading(
    BuildContext context, {
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(PipoSpacing.xxl),
            decoration: BoxDecoration(
              color: PipoColors.surface,
              borderRadius: BorderRadius.circular(PipoRadius.xl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: PipoSpacing.lg),
                  Text(
                    message,
                    style: PipoTypography.bodyMedium.copyWith(
                      color: PipoColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: PipoSpacing.md),
            Expanded(
              child: Text(
                message,
                style: PipoTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PipoRadius.md),
        ),
        margin: const EdgeInsets.all(PipoSpacing.md),
        action: action,
      ),
    );
  }
}
