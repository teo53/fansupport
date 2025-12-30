import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/errors/failures.dart';
import '../../presentation/providers/base_state.dart';

/// 비동기 상태를 처리하는 공통 위젯
class AsyncStateWidget<T> extends StatelessWidget {
  final AsyncState<T> state;
  final Widget Function(T data) builder;
  final Widget Function()? loadingBuilder;
  final Widget Function(Failure failure)? errorBuilder;
  final Widget Function()? initialBuilder;
  final VoidCallback? onRetry;

  const AsyncStateWidget({
    super.key,
    required this.state,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.initialBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      initial: () => initialBuilder?.call() ?? const SizedBox.shrink(),
      loading: (previousData) {
        if (previousData != null) {
          // 이전 데이터가 있으면 데이터와 함께 로딩 표시
          return Stack(
            children: [
              builder(previousData),
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          );
        }
        return loadingBuilder?.call() ?? const LoadingWidget();
      },
      success: (data) => builder(data),
      error: (failure, previousData) {
        if (previousData != null) {
          // 이전 데이터가 있으면 에러 메시지만 표시
          return Column(
            children: [
              _buildErrorBanner(failure),
              Expanded(child: builder(previousData)),
            ],
          );
        }
        return errorBuilder?.call(failure) ??
            ErrorWidget(failure: failure, onRetry: onRetry);
      },
    );
  }

  Widget _buildErrorBanner(Failure failure) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.wp(3)),
      color: AppColors.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          SizedBox(width: Responsive.wp(2)),
          Expanded(
            child: Text(
              failure.message,
              style: TextStyle(
                color: AppColors.error,
                fontSize: Responsive.sp(12),
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                '재시도',
                style: TextStyle(fontSize: Responsive.sp(12)),
              ),
            ),
        ],
      ),
    );
  }
}

/// 로딩 위젯
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: Responsive.hp(2)),
            Text(
              message!,
              style: TextStyle(
                fontSize: Responsive.sp(14),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 에러 위젯
class ErrorWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorWidget({
    super.key,
    required this.failure,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? _getIcon(),
              size: Responsive.sp(60),
              color: AppColors.textHint,
            ),
            SizedBox(height: Responsive.hp(2)),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.sp(16),
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: Responsive.hp(3)),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (failure is NetworkFailure) {
      return Icons.wifi_off_rounded;
    } else if (failure is ServerFailure) {
      return Icons.cloud_off_rounded;
    } else if (failure is AuthFailure) {
      return Icons.lock_outline_rounded;
    }
    return Icons.error_outline_rounded;
  }
}

/// 페이지네이션 리스트 위젯
class PaginatedListWidget<T> extends StatelessWidget {
  final PaginatedState<T> state;
  final Widget Function(T item, int index) itemBuilder;
  final Widget Function()? loadingBuilder;
  final Widget Function(Failure failure)? errorBuilder;
  final Widget Function()? emptyBuilder;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;
  final EdgeInsets? padding;
  final ScrollController? scrollController;

  const PaginatedListWidget({
    super.key,
    required this.state,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.onLoadMore,
    this.onRefresh,
    this.padding,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isInitialLoading) {
      return loadingBuilder?.call() ?? const LoadingWidget();
    }

    if (state.error != null && state.items.isEmpty) {
      return errorBuilder?.call(state.error!) ??
          ErrorWidget(failure: state.error!, onRetry: onRefresh);
    }

    if (state.isEmpty) {
      return emptyBuilder?.call() ?? const EmptyListWidget();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          if (state.hasMore && !state.isLoading && onLoadMore != null) {
            onLoadMore!();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async => onRefresh?.call(),
        child: ListView.builder(
          controller: scrollController,
          padding: padding,
          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            return itemBuilder(state.items[index], index);
          },
        ),
      ),
    );
  }
}

/// 빈 리스트 위젯
class EmptyListWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;
  final Widget? action;

  const EmptyListWidget({
    super.key,
    this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: Responsive.sp(60),
              color: AppColors.textHint,
            ),
            SizedBox(height: Responsive.hp(2)),
            Text(
              message ?? '데이터가 없습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.sp(16),
                color: AppColors.textSecondary,
              ),
            ),
            if (action != null) ...[
              SizedBox(height: Responsive.hp(3)),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
