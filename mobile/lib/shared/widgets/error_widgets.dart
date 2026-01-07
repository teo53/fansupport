import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/utils/responsive.dart';
import 'custom_button.dart';

/// Generic error widget with retry button
class ErrorView extends StatelessWidget {
  final String? message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorView({
    super.key,
    this.message,
    this.title,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PipoSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: PipoSpacing.xl),
            Text(
              title ?? '오류가 발생했습니다',
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.w600,
                color: PipoColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PipoSpacing.md),
            Text(
              message ?? '잠시 후 다시 시도해주세요',
              style: TextStyle(
                fontSize: Responsive.sp(14),
                color: PipoColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: PipoSpacing.xxl),
              CustomButton(
                onPressed: onRetry,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: Responsive.sp(20),
                      color: Colors.white,
                    ),
                    const SizedBox(width: PipoSpacing.sm),
                    Text(
                      '다시 시도',
                      style: TextStyle(
                        fontSize: Responsive.sp(16),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error widget
class NetworkErrorView extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorView({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      title: '네트워크 연결 오류',
      message: '인터넷 연결을 확인하고\n다시 시도해주세요',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }
}

/// Empty state widget
class EmptyView extends StatelessWidget {
  final String? message;
  final String? title;
  final IconData? icon;
  final Widget? action;

  const EmptyView({
    super.key,
    this.message,
    this.title,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PipoSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PipoColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_rounded,
                size: 40,
                color: PipoColors.textSecondary,
              ),
            ),
            const SizedBox(height: PipoSpacing.xl),
            Text(
              title ?? '데이터가 없습니다',
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.w600,
                color: PipoColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: PipoSpacing.md),
              Text(
                message!,
                style: TextStyle(
                  fontSize: Responsive.sp(14),
                  color: PipoColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: PipoSpacing.xxl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Not found error (404)
class NotFoundView extends StatelessWidget {
  final VoidCallback? onGoBack;

  const NotFoundView({super.key, this.onGoBack});

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      title: '페이지를 찾을 수 없습니다',
      message: '요청하신 페이지가 존재하지 않거나\n삭제되었습니다',
      icon: Icons.search_off_rounded,
      onRetry: onGoBack,
    );
  }
}

/// Permission denied error
class PermissionDeniedView extends StatelessWidget {
  final String? message;

  const PermissionDeniedView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      title: '접근 권한이 없습니다',
      message: message ?? '이 콘텐츠에 접근할 수 있는\n권한이 없습니다',
      icon: Icons.lock_outline_rounded,
    );
  }
}

/// Maintenance mode view
class MaintenanceView extends StatelessWidget {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      title: '시스템 점검 중',
      message: '더 나은 서비스를 위해\n잠시 시스템 점검 중입니다',
      icon: Icons.build_rounded,
    );
  }
}
