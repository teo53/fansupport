import 'failures.dart';

/// 함수형 에러 처리를 위한 Result 타입
/// Success 또는 Failure 중 하나의 상태를 가짐
sealed class Result<T> {
  const Result();

  /// 성공 여부
  bool get isSuccess => this is Success<T>;

  /// 실패 여부
  bool get isFailure => this is Failure;

  /// 성공 시 데이터 반환, 실패 시 null
  T? get data => isSuccess ? (this as Success<T>).value : null;

  /// 실패 시 에러 반환, 성공 시 null
  Failure? get failure => isFailure ? (this as Fail<T>).failure : null;

  /// 성공/실패에 따라 다른 함수 실행
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).value);
    } else {
      return onFailure((this as Fail<T>).failure);
    }
  }

  /// 성공 시에만 변환 함수 적용
  Result<R> map<R>(R Function(T data) transform) {
    if (this is Success<T>) {
      return Success(transform((this as Success<T>).value));
    } else {
      return Fail((this as Fail<T>).failure);
    }
  }

  /// 성공 시에만 새로운 Result 반환하는 함수 적용
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    if (this is Success<T>) {
      return transform((this as Success<T>).value);
    } else {
      return Fail((this as Fail<T>).failure);
    }
  }

  /// 실패 시 기본값 반환
  T getOrElse(T defaultValue) {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    return defaultValue;
  }

  /// 실패 시 함수로 기본값 생성
  T getOrElseCompute(T Function(Failure failure) compute) {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    return compute((this as Fail<T>).failure);
  }
}

/// 성공 상태
class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  String toString() => 'Success($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// 실패 상태
class Fail<T> extends Result<T> {
  @override
  final Failure failure;

  const Fail(this.failure);

  @override
  String toString() => 'Fail($failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fail<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

/// Result 생성 헬퍼
extension ResultExtensions<T> on T {
  Result<T> toSuccess() => Success(this);
}

extension FailureExtensions on Failure {
  Result<T> toResult<T>() => Fail<T>(this);
}
