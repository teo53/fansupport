import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Loading overlay widget
///
/// Shows a loading indicator overlay on top of content
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? overlayColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor ?? Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(PipoSpacing.xxl),
                  decoration: BoxDecoration(
                    color: PipoColors.surface,
                    borderRadius: BorderRadius.circular(PipoRadius.xl),
                    boxShadow: PipoShadows.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(PipoColors.primary),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: PipoSpacing.lg),
                        Text(
                          message!,
                          style: PipoTypography.bodyMedium.copyWith(
                            color: PipoColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Show loading dialog
  static Future<void> show(
    BuildContext context, {
    String? message,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(PipoSpacing.xxl),
            decoration: BoxDecoration(
              color: PipoColors.surface,
              borderRadius: BorderRadius.circular(PipoRadius.xl),
              boxShadow: PipoShadows.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(PipoColors.primary),
                ),
                if (message != null) ...[
                  const SizedBox(height: PipoSpacing.lg),
                  Text(
                    message,
                    style: PipoTypography.bodyMedium.copyWith(
                      color: PipoColors.textPrimary,
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
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
