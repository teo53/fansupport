import 'dart:async';

import 'package:flutter/foundation.dart';

/// 디바운서 유틸리티
/// 연속적인 호출을 지연시켜 마지막 호출만 실행
class Debouncer {
  final Duration delay;
  Timer? _timer;
  VoidCallback? _lastAction;

  Debouncer({
    this.delay = const Duration(milliseconds: 300),
  });

  /// 디바운스된 액션 실행
  void call(VoidCallback action) {
    _lastAction = action;
    _timer?.cancel();
    _timer = Timer(delay, () {
      _lastAction?.call();
      _lastAction = null;
    });
  }

  /// 즉시 실행 (대기 중인 타이머 취소 후)
  void runImmediately(VoidCallback action) {
    _timer?.cancel();
    action();
  }

  /// 대기 중인 액션 취소
  void cancel() {
    _timer?.cancel();
    _lastAction = null;
  }

  /// 대기 중인 액션 즉시 실행
  void flush() {
    _timer?.cancel();
    _lastAction?.call();
    _lastAction = null;
  }

  /// 리소스 정리
  void dispose() {
    cancel();
  }

  /// 대기 중인 액션이 있는지 확인
  bool get isPending => _timer?.isActive ?? false;
}

/// 쓰로틀러 유틸리티
/// 지정된 시간 동안 한 번만 실행 허용
class Throttler {
  final Duration interval;
  DateTime? _lastExecutionTime;
  Timer? _pendingTimer;
  VoidCallback? _pendingAction;

  Throttler({
    this.interval = const Duration(milliseconds: 300),
  });

  /// 쓰로틀된 액션 실행
  void call(VoidCallback action) {
    final now = DateTime.now();

    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) >= interval) {
      // 즉시 실행 가능
      _lastExecutionTime = now;
      _pendingTimer?.cancel();
      _pendingAction = null;
      action();
    } else {
      // 다음 간격까지 대기
      _pendingAction = action;
      _pendingTimer?.cancel();
      _pendingTimer = Timer(
        interval - now.difference(_lastExecutionTime!),
        () {
          _lastExecutionTime = DateTime.now();
          _pendingAction?.call();
          _pendingAction = null;
        },
      );
    }
  }

  /// 대기 중인 액션 취소
  void cancel() {
    _pendingTimer?.cancel();
    _pendingAction = null;
  }

  /// 리소스 정리
  void dispose() {
    cancel();
  }

  /// 대기 중인 액션이 있는지 확인
  bool get isPending => _pendingTimer?.isActive ?? false;
}

/// 검색용 디바운서 (타이핑 완료 후 검색)
class SearchDebouncer {
  final Debouncer _debouncer;
  final void Function(String query) onSearch;
  String _lastQuery = '';

  SearchDebouncer({
    Duration delay = const Duration(milliseconds: 500),
    required this.onSearch,
  }) : _debouncer = Debouncer(delay: delay);

  /// 검색어 입력
  void search(String query) {
    final trimmed = query.trim();
    if (trimmed == _lastQuery) return;

    _lastQuery = trimmed;
    if (trimmed.isEmpty) {
      _debouncer.cancel();
      onSearch('');
    } else {
      _debouncer.call(() => onSearch(trimmed));
    }
  }

  /// 즉시 검색 실행
  void searchNow(String query) {
    _lastQuery = query.trim();
    _debouncer.cancel();
    onSearch(_lastQuery);
  }

  /// 취소
  void cancel() {
    _debouncer.cancel();
  }

  /// 정리
  void dispose() {
    _debouncer.dispose();
  }
}

/// 비동기 디바운서
class AsyncDebouncer<T> {
  final Duration delay;
  Timer? _timer;
  Completer<T>? _completer;

  AsyncDebouncer({
    this.delay = const Duration(milliseconds: 300),
  });

  /// 비동기 액션을 디바운스하여 실행
  Future<T> call(Future<T> Function() action) {
    _timer?.cancel();
    _completer?.completeError(const _DebounceCancelledException());

    final completer = Completer<T>();
    _completer = completer;

    _timer = Timer(delay, () async {
      try {
        final result = await action();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (e, stack) {
        if (!completer.isCompleted) {
          completer.completeError(e, stack);
        }
      }
    });

    return completer.future;
  }

  /// 취소
  void cancel() {
    _timer?.cancel();
    _completer?.completeError(const _DebounceCancelledException());
    _completer = null;
  }

  /// 정리
  void dispose() {
    cancel();
  }
}

class _DebounceCancelledException implements Exception {
  const _DebounceCancelledException();

  @override
  String toString() => 'Debounce operation was cancelled';
}

/// 디바운스 취소 여부 확인
bool isDebounceException(dynamic error) {
  return error is _DebounceCancelledException;
}
