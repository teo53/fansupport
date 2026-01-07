import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Error view widget
///
/// Displays error states with optional retry action
class ErrorView extends StatelessWidget {
  final String? title;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final bool showBackButton;

  const ErrorView({
    super.key,
    this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onRetry,
    this.showBackButton = false,
  });

  /// Network error
  factory ErrorView.network({
    VoidCallback? onRetry,
  }) {
    return ErrorView(
      title: '연결 오류',
      message: '인터넷 연결을 확인해주세요.',
      icon: Icons.wifi_off_rounded,
      actionLabel: '다시 시도',
      onRetry: onRetry,
    );
  }

  /// Not found error (404)
  factory ErrorView.notFound({
    String? message,
  }) {
    return ErrorView(
      title: '페이지를 찾을 수 없습니다',
      message: message ?? '요청하신 페이지가 존재하지 않습니다.',
      icon: Icons.search_off_rounded,
      showBackButton: true,
    );
  }

  /// Server error (500)
  factory ErrorView.server({
    VoidCallback? onRetry,
  }) {
    return ErrorView(
      title: '서버 오류',
      message: '일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.',
      icon: Icons.error_outline_rounded,
      actionLabel: '다시 시도',
      onRetry: onRetry,
    );
  }

  /// Unauthorized error (401)
  factory ErrorView.unauthorized({
    VoidCallback? onRetry,
  }) {
    return ErrorView(
      title: '인증 만료',
      message: '로그인이 필요합니다.',
      icon: Icons.lock_outline_rounded,
      actionLabel: '로그인',
      onRetry: onRetry,
    );
  }

  /// Empty state
  factory ErrorView.empty({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return ErrorView(
      message: message,
      icon: Icons.inbox_rounded,
      actionLabel: actionLabel,
      onRetry: onAction,
    );
  }

  /// Generic error
  factory ErrorView.generic({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorView(
      title: '오류가 발생했습니다',
      message: message ?? '알 수 없는 오류가 발생했습니다.',
      icon: Icons.error_outline_rounded,
      actionLabel: '다시 시도',
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PipoSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: PipoColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: PipoColors.primary,
                ),
              ),
            if (icon != null) const SizedBox(height: PipoSpacing.xxl),
            if (title != null)
              Text(
                title!,
                style: PipoTypography.headlineSmall.copyWith(
                  color: PipoColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            if (title != null) const SizedBox(height: PipoSpacing.md),
            Text(
              message,
              style: PipoTypography.bodyMedium.copyWith(
                color: PipoColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null || showBackButton) ...[
              const SizedBox(height: PipoSpacing.xxxl),
              if (onRetry != null)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PipoColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: PipoRadius.button,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      actionLabel ?? '다시 시도',
                      style: PipoTypography.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (showBackButton && onRetry != null)
                const SizedBox(height: PipoSpacing.md),
              if (showBackButton)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PipoColors.textPrimary,
                      side: const BorderSide(color: PipoColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: PipoRadius.button,
                      ),
                    ),
                    child: Text(
                      '돌아가기',
                      style: PipoTypography.buttonMedium.copyWith(
                        color: PipoColors.textPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyStateView extends StatelessWidget {
  final String message;
  final String? description;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    required this.message,
    this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PipoSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 80,
                color: PipoColors.textDisabled,
              ),
            if (icon != null) const SizedBox(height: PipoSpacing.xxl),
            Text(
              message,
              style: PipoTypography.titleLarge.copyWith(
                color: PipoColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: PipoSpacing.md),
              Text(
                description!,
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: PipoSpacing.xxxl),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PipoColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PipoSpacing.xxl,
                    vertical: PipoSpacing.lg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: PipoRadius.button,
                  ),
                ),
                child: Text(actionLabel ?? '시작하기'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
