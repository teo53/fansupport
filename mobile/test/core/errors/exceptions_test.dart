import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/core/errors/exceptions.dart';

void main() {
  group('NetworkException', () {
    test('noConnection 팩토리가 올바른 예외를 생성한다', () {
      final exception = NetworkException.noConnection();

      expect(exception.code, 'NO_CONNECTION');
      expect(exception.message, '네트워크에 연결되어 있지 않습니다');
    });

    test('timeout 팩토리가 올바른 예외를 생성한다', () {
      final exception = NetworkException.timeout();

      expect(exception.code, 'TIMEOUT');
      expect(exception.message, '요청 시간이 초과되었습니다');
    });

    test('serverError 팩토리가 상태 코드를 포함한다', () {
      final exception = NetworkException.serverError(
        statusCode: 500,
        url: '/api/test',
      );

      expect(exception.code, 'SERVER_ERROR');
      expect(exception.statusCode, 500);
      expect(exception.url, '/api/test');
    });

    test('notFound 팩토리가 리소스 이름을 포함한다', () {
      final exception = NetworkException.notFound(resource: 'User');

      expect(exception.code, 'NOT_FOUND');
      expect(exception.statusCode, 404);
      expect(exception.message, 'User를 찾을 수 없습니다');
    });
  });

  group('AuthException', () {
    test('invalidCredentials 팩토리가 올바른 예외를 생성한다', () {
      final exception = AuthException.invalidCredentials();

      expect(exception.code, 'INVALID_CREDENTIALS');
      expect(exception.message, '이메일 또는 비밀번호가 올바르지 않습니다');
    });

    test('sessionExpired 팩토리가 올바른 예외를 생성한다', () {
      final exception = AuthException.sessionExpired();

      expect(exception.code, 'SESSION_EXPIRED');
      expect(exception.message, contains('다시 로그인'));
    });

    test('unauthorized 팩토리가 올바른 예외를 생성한다', () {
      final exception = AuthException.unauthorized();

      expect(exception.code, 'UNAUTHORIZED');
    });
  });

  group('ValidationException', () {
    test('required 팩토리가 필드 이름을 포함한다', () {
      final exception = ValidationException.required('이메일');

      expect(exception.code, 'REQUIRED');
      expect(exception.field, '이메일');
      expect(exception.message, contains('이메일'));
    });

    test('invalidFormat 팩토리가 필드 이름을 포함한다', () {
      final exception = ValidationException.invalidFormat('전화번호');

      expect(exception.code, 'INVALID_FORMAT');
      expect(exception.field, '전화번호');
    });

    test('multiple 팩토리가 여러 필드 에러를 포함한다', () {
      final exception = ValidationException.multiple({
        'email': '이메일 형식이 올바르지 않습니다',
        'password': '비밀번호는 8자 이상이어야 합니다',
      });

      expect(exception.code, 'MULTIPLE_ERRORS');
      expect(exception.fieldErrors?.length, 2);
    });
  });

  group('BusinessException', () {
    test('insufficientBalance 팩토리가 올바른 예외를 생성한다', () {
      final exception = BusinessException.insufficientBalance();

      expect(exception.code, 'INSUFFICIENT_BALANCE');
      expect(exception.message, '잔액이 부족합니다');
    });

    test('alreadySubscribed 팩토리가 올바른 예외를 생성한다', () {
      final exception = BusinessException.alreadySubscribed();

      expect(exception.code, 'ALREADY_SUBSCRIBED');
    });
  });

  group('getExceptionMessage', () {
    test('AppException에서 메시지를 추출한다', () {
      final exception = NetworkException.noConnection();
      expect(getExceptionMessage(exception), '네트워크에 연결되어 있지 않습니다');
    });

    test('일반 Exception에서 기본 메시지를 반환한다', () {
      final exception = Exception('Some error');
      expect(getExceptionMessage(exception), '오류가 발생했습니다');
    });

    test('null에서 기본 메시지를 반환한다', () {
      expect(getExceptionMessage(null), '알 수 없는 오류가 발생했습니다');
    });
  });

  group('getExceptionCode', () {
    test('AppException에서 코드를 추출한다', () {
      final exception = AuthException.sessionExpired();
      expect(getExceptionCode(exception), 'SESSION_EXPIRED');
    });

    test('일반 객체에서 null을 반환한다', () {
      expect(getExceptionCode(Exception('error')), null);
    });
  });
}
