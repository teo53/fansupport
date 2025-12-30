import 'package:flutter/material.dart';
import '../../core/services/logger_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

/// 에러 바운더리 위젯
/// 자식 위젯에서 발생하는 에러를 잡아서 fallback UI 표시
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? onError;
  final VoidCallback? onRetry;
  final String? errorMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.onRetry,
    this.errorMessage,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    // ErrorWidget.builder를 오버라이드하여 에러 캡처
    FlutterError.onError = (details) {
      logger.e('ErrorBoundary', 'Widget error caught',
          error: details.exception, stackTrace: details.stack);
      setState(() => _error = details);
    };
  }

  void _retry() {
    setState(() => _error = null);
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.onError != null) {
        return widget.onError!(_error!);
      }
      return _DefaultErrorWidget(
        message: widget.errorMessage ?? '오류가 발생했습니다',
        onRetry: widget.onRetry != null ? _retry : null,
      );
    }
    return widget.child;
  }
}

/// 기본 에러 위젯
class _DefaultErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(6)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: Responsive.sp(48),
              color: AppColors.error,
            ),
            SizedBox(height: Responsive.hp(2)),
            Text(
              message,
              style: TextStyle(
                fontSize: Responsive.sp(16),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: Responsive.hp(3)),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.wp(6),
                    vertical: Responsive.hp(1.5),
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

/// 비동기 작업의 에러 상태를 처리하는 빌더
class AsyncErrorBuilder<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data) builder;
  final Widget? loading;
  final Widget Function(Object error)? onError;
  final VoidCallback? onRetry;

  const AsyncErrorBuilder({
    super.key,
    required this.snapshot,
    required this.builder,
    this.loading,
    this.onError,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      if (onError != null) {
        return onError!(snapshot.error!);
      }
      return _DefaultErrorWidget(
        message: snapshot.error.toString(),
        onRetry: onRetry,
      );
    }

    if (!snapshot.hasData) {
      return loading ?? const Center(child: CircularProgressIndicator());
    }

    return builder(snapshot.data as T);
  }
}

/// 네트워크 연결 상태 위젯
class NetworkAwareWidget extends StatelessWidget {
  final Widget child;
  final Widget? offlineWidget;
  final bool isConnected;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    required this.isConnected,
    this.offlineWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (!isConnected) {
      return offlineWidget ?? const _OfflineWidget();
    }
    return child;
  }
}

class _OfflineWidget extends StatelessWidget {
  const _OfflineWidget();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(6)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: Responsive.sp(48),
              color: AppColors.textHint,
            ),
            SizedBox(height: Responsive.hp(2)),
            Text(
              '인터넷 연결을 확인해주세요',
              style: TextStyle(
                fontSize: Responsive.sp(16),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.hp(1)),
            Text(
              '네트워크 연결 후 다시 시도해주세요',
              style: TextStyle(
                fontSize: Responsive.sp(14),
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 안전하게 위젯을 빌드하는 래퍼
Widget safeBuilder(Widget Function() builder, {Widget? fallback}) {
  try {
    return builder();
  } catch (e, stack) {
    logger.e('SafeBuilder', 'Build error', error: e, stackTrace: stack);
    return fallback ??
        const Center(
          child: Text('화면을 표시할 수 없습니다'),
        );
  }
}
