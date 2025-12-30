/// 앱 예외 시스템
/// 모든 예외의 기본 클래스와 특화된 예외 타입 정의

/// 기본 앱 예외
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// 네트워크 관련 예외
class NetworkException extends AppException {
  final int? statusCode;
  final String? url;

  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.statusCode,
    this.url,
  });

  factory NetworkException.noConnection() => const NetworkException(
        message: '네트워크에 연결되어 있지 않습니다',
        code: 'NO_CONNECTION',
      );

  factory NetworkException.timeout() => const NetworkException(
        message: '요청 시간이 초과되었습니다',
        code: 'TIMEOUT',
      );

  factory NetworkException.serverError({int? statusCode, String? url}) =>
      NetworkException(
        message: '서버 오류가 발생했습니다',
        code: 'SERVER_ERROR',
        statusCode: statusCode,
        url: url,
      );

  factory NetworkException.badRequest({String? message}) => NetworkException(
        message: message ?? '잘못된 요청입니다',
        code: 'BAD_REQUEST',
        statusCode: 400,
      );

  factory NetworkException.notFound({String? resource}) => NetworkException(
        message: '${resource ?? '리소스'}를 찾을 수 없습니다',
        code: 'NOT_FOUND',
        statusCode: 404,
      );

  @override
  String toString() => 'NetworkException($code, $statusCode): $message';
}

/// 인증 관련 예외
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AuthException.invalidCredentials() => const AuthException(
        message: '이메일 또는 비밀번호가 올바르지 않습니다',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthException.sessionExpired() => const AuthException(
        message: '세션이 만료되었습니다. 다시 로그인해주세요',
        code: 'SESSION_EXPIRED',
      );

  factory AuthException.unauthorized() => const AuthException(
        message: '접근 권한이 없습니다',
        code: 'UNAUTHORIZED',
      );

  factory AuthException.emailAlreadyExists() => const AuthException(
        message: '이미 사용 중인 이메일입니다',
        code: 'EMAIL_EXISTS',
      );

  factory AuthException.weakPassword() => const AuthException(
        message: '비밀번호가 너무 약합니다',
        code: 'WEAK_PASSWORD',
      );

  @override
  String toString() => 'AuthException($code): $message';
}

/// 검증 관련 예외
class ValidationException extends AppException {
  final String? field;
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    this.field,
    this.fieldErrors,
  });

  factory ValidationException.required(String fieldName) => ValidationException(
        message: '$fieldName을(를) 입력해주세요',
        code: 'REQUIRED',
        field: fieldName,
      );

  factory ValidationException.invalidFormat(String fieldName) =>
      ValidationException(
        message: '$fieldName 형식이 올바르지 않습니다',
        code: 'INVALID_FORMAT',
        field: fieldName,
      );

  factory ValidationException.multiple(Map<String, String> errors) =>
      ValidationException(
        message: '입력값을 확인해주세요',
        code: 'MULTIPLE_ERRORS',
        fieldErrors: errors,
      );

  @override
  String toString() => 'ValidationException($code, $field): $message';
}

/// 캐시/저장소 관련 예외
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory StorageException.readError({String? key}) => StorageException(
        message: '데이터를 읽는 중 오류가 발생했습니다',
        code: 'READ_ERROR',
      );

  factory StorageException.writeError({String? key}) => StorageException(
        message: '데이터를 저장하는 중 오류가 발생했습니다',
        code: 'WRITE_ERROR',
      );

  factory StorageException.notFound({String? key}) => StorageException(
        message: '저장된 데이터를 찾을 수 없습니다',
        code: 'NOT_FOUND',
      );

  @override
  String toString() => 'StorageException($code): $message';
}

/// 비즈니스 로직 예외
class BusinessException extends AppException {
  const BusinessException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory BusinessException.insufficientBalance() => const BusinessException(
        message: '잔액이 부족합니다',
        code: 'INSUFFICIENT_BALANCE',
      );

  factory BusinessException.alreadySubscribed() => const BusinessException(
        message: '이미 구독 중입니다',
        code: 'ALREADY_SUBSCRIBED',
      );

  factory BusinessException.notAvailable() => const BusinessException(
        message: '현재 이용할 수 없습니다',
        code: 'NOT_AVAILABLE',
      );

  factory BusinessException.limitExceeded() => const BusinessException(
        message: '제한을 초과했습니다',
        code: 'LIMIT_EXCEEDED',
      );

  @override
  String toString() => 'BusinessException($code): $message';
}

/// 예외를 사용자 친화적 메시지로 변환
String getExceptionMessage(dynamic error) {
  if (error is AppException) {
    return error.message;
  } else if (error is Exception) {
    return '오류가 발생했습니다';
  } else {
    return error?.toString() ?? '알 수 없는 오류가 발생했습니다';
  }
}

/// 예외 코드 추출
String? getExceptionCode(dynamic error) {
  if (error is AppException) {
    return error.code;
  }
  return null;
}
