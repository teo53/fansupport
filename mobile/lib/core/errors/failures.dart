/// 앱 전체에서 사용하는 에러 타입 정의
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// 서버 에러 (API 통신 실패)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  factory ServerFailure.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return const ServerFailure(message: '잘못된 요청입니다', code: 'BAD_REQUEST');
      case 401:
        return const ServerFailure(message: '인증이 필요합니다', code: 'UNAUTHORIZED');
      case 403:
        return const ServerFailure(message: '접근 권한이 없습니다', code: 'FORBIDDEN');
      case 404:
        return const ServerFailure(message: '요청한 리소스를 찾을 수 없습니다', code: 'NOT_FOUND');
      case 500:
        return const ServerFailure(message: '서버 오류가 발생했습니다', code: 'SERVER_ERROR');
      default:
        return ServerFailure(
          message: '알 수 없는 오류가 발생했습니다 ($statusCode)',
          code: 'UNKNOWN',
          statusCode: statusCode,
        );
    }
  }
}

/// 네트워크 에러 (연결 실패)
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = '네트워크 연결을 확인해주세요',
    super.code = 'NETWORK_ERROR',
  });
}

/// 캐시 에러 (로컬 저장 실패)
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = '데이터를 불러올 수 없습니다',
    super.code = 'CACHE_ERROR',
  });
}

/// 인증 에러
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = '로그인이 필요합니다',
    super.code = 'AUTH_ERROR',
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: '이메일 또는 비밀번호가 올바르지 않습니다',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: '세션이 만료되었습니다. 다시 로그인해주세요',
        code: 'SESSION_EXPIRED',
      );
}

/// 유효성 검사 에러
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });
}

/// 비즈니스 로직 에러
class BusinessFailure extends Failure {
  const BusinessFailure({
    required super.message,
    super.code,
  });
}
