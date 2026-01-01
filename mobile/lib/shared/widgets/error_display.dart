import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 에러 표시 위젯
class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryLabel;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.icon,
    this.retryLabel,
  });

  /// 네트워크 에러
  factory ErrorDisplay.network({VoidCallback? onRetry}) {
    return ErrorDisplay(
      message: '네트워크 연결을 확인해주세요',
      details: '인터넷 연결이 불안정하거나 서버에 접속할 수 없습니다.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }

  /// 서버 에러
  factory ErrorDisplay.server({VoidCallback? onRetry}) {
    return ErrorDisplay(
      message: '서버에 문제가 발생했습니다',
      details: '잠시 후 다시 시도해주세요.',
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
    );
  }

  /// 권한 에러
  factory ErrorDisplay.unauthorized({VoidCallback? onRetry}) {
    return ErrorDisplay(
      message: '접근 권한이 없습니다',
      details: '로그인이 필요하거나 권한이 부족합니다.',
      icon: Icons.lock_outline_rounded,
      onRetry: onRetry,
      retryLabel: '로그인',
    );
  }

  /// 찾을 수 없음
  factory ErrorDisplay.notFound({String? itemName}) {
    return ErrorDisplay(
      message: '${itemName ?? '콘텐츠'}을(를) 찾을 수 없습니다',
      details: '삭제되었거나 존재하지 않는 항목입니다.',
      icon: Icons.search_off_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '오류: $message',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.errorSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.error_outline_rounded,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (details != null) ...[
                const SizedBox(height: 8),
                Text(
                  details!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(retryLabel ?? '다시 시도'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 인라인 에러 배너
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        border: Border(
          left: BorderSide(color: AppColors.error, width: 4),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              color: AppColors.error,
              onPressed: onRetry,
              tooltip: '다시 시도',
            ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.error,
              onPressed: onDismiss,
              tooltip: '닫기',
            ),
        ],
      ),
    );
  }
}

/// 스낵바용 에러 헬퍼
class ErrorSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: '다시 시도',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}
