class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, 'NETWORK_ERROR');
}

class ServerException extends AppException {
  final int? statusCode;

  ServerException(String message, [this.statusCode])
      : super(message, 'SERVER_ERROR');
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = '인증이 필요합니다'])
      : super(message, 'UNAUTHORIZED');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, 'VALIDATION_ERROR');
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 'NOT_FOUND');
}

class TimeoutException extends AppException {
  TimeoutException([String message = '요청 시간이 초과되었습니다'])
      : super(message, 'TIMEOUT');
}
