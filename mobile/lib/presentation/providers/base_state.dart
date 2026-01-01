import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';

/// 비동기 상태를 나타내는 Sealed 클래스
sealed class AsyncState<T> {
  const AsyncState();
}

/// 초기 상태
class Initial<T> extends AsyncState<T> {
  const Initial();
}

/// 로딩 상태
class Loading<T> extends AsyncState<T> {
  final T? previousData;

  const Loading({this.previousData});
}

/// 성공 상태
class Success<T> extends AsyncState<T> {
  final T data;

  const Success(this.data);
}

/// 에러 상태
class Error<T> extends AsyncState<T> {
  final Failure failure;
  final T? previousData;

  const Error(this.failure, {this.previousData});
}

/// AsyncState 확장 메서드
extension AsyncStateExtensions<T> on AsyncState<T> {
  /// 로딩 중인지
  bool get isLoading => this is Loading<T>;

  /// 성공인지
  bool get isSuccess => this is Success<T>;

  /// 에러인지
  bool get isError => this is Error<T>;

  /// 데이터 (성공 시 반환)
  T? get data {
    if (this is Success<T>) return (this as Success<T>).data;
    if (this is Loading<T>) return (this as Loading<T>).previousData;
    if (this is Error<T>) return (this as Error<T>).previousData;
    return null;
  }

  /// 에러 (에러 시 반환)
  Failure? get failure {
    if (this is Error<T>) return (this as Error<T>).failure;
    return null;
  }

  /// 상태에 따라 다른 값 반환
  R when<R>({
    required R Function() initial,
    required R Function(T? previousData) loading,
    required R Function(T data) success,
    required R Function(Failure failure, T? previousData) error,
  }) {
    return switch (this) {
      Initial() => initial(),
      Loading(:final previousData) => loading(previousData),
      Success(:final data) => success(data),
      Error(:final failure, :final previousData) => error(failure, previousData),
    };
  }

  /// 성공 데이터만 처리, 나머지는 기본값
  R maybeWhen<R>({
    R Function()? initial,
    R Function(T? previousData)? loading,
    R Function(T data)? success,
    R Function(Failure failure, T? previousData)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      Initial() => initial?.call() ?? orElse(),
      Loading(:final previousData) => loading?.call(previousData) ?? orElse(),
      Success(:final data) => success?.call(data) ?? orElse(),
      Error(:final failure, :final previousData) =>
        error?.call(failure, previousData) ?? orElse(),
    };
  }
}

/// 페이지네이션 상태
@immutable
class PaginatedState<T> {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final Failure? error;

  const PaginatedState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  bool get isEmpty => items.isEmpty && !isLoading;
  bool get isLoadingMore => isLoading && items.isNotEmpty;
  bool get isInitialLoading => isLoading && items.isEmpty;

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    Failure? error,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }

  PaginatedState<T> startLoading() {
    return copyWith(isLoading: true, error: null);
  }

  PaginatedState<T> appendItems(List<T> newItems, {bool hasMore = true}) {
    return copyWith(
      items: [...items, ...newItems],
      isLoading: false,
      hasMore: hasMore,
      currentPage: currentPage + 1,
    );
  }

  PaginatedState<T> setError(Failure failure) {
    return copyWith(isLoading: false, error: failure);
  }

  PaginatedState<T> reset() {
    return const PaginatedState();
  }
}
