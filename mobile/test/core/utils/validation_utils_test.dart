import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/core/utils/validation_utils.dart';

void main() {
  group('ValidationUtils', () {
    group('Email Validation', () {
      test('유효한 이메일 형식을 허용한다', () {
        expect(ValidationUtils.isValidEmail('test@example.com'), true);
        expect(ValidationUtils.isValidEmail('user.name@domain.co.kr'), true);
        expect(ValidationUtils.isValidEmail('user+tag@example.org'), true);
      });

      test('유효하지 않은 이메일 형식을 거부한다', () {
        expect(ValidationUtils.isValidEmail(''), false);
        expect(ValidationUtils.isValidEmail('test'), false);
        expect(ValidationUtils.isValidEmail('test@'), false);
        expect(ValidationUtils.isValidEmail('@example.com'), false);
        expect(ValidationUtils.isValidEmail('test @example.com'), false);
        expect(ValidationUtils.isValidEmail(null), false);
      });

      test('이메일 검증 에러 메시지를 반환한다', () {
        expect(ValidationUtils.validateEmail(null), '이메일을 입력해주세요');
        expect(ValidationUtils.validateEmail(''), '이메일을 입력해주세요');
        expect(ValidationUtils.validateEmail('invalid'), '올바른 이메일 형식이 아닙니다');
        expect(ValidationUtils.validateEmail('test@example.com'), null);
      });
    });

    group('Password Validation', () {
      test('유효한 비밀번호를 허용한다', () {
        expect(ValidationUtils.isValidPassword('Password1'), true);
        expect(ValidationUtils.isValidPassword('MyP@ssw0rd'), true);
        expect(ValidationUtils.isValidPassword('test1234'), true);
      });

      test('유효하지 않은 비밀번호를 거부한다', () {
        expect(ValidationUtils.isValidPassword(''), false);
        expect(ValidationUtils.isValidPassword('short1'), false);
        expect(ValidationUtils.isValidPassword('noletter'), false);
        expect(ValidationUtils.isValidPassword('NoNumber'), false);
        expect(ValidationUtils.isValidPassword(null), false);
      });

      test('비밀번호 검증 에러 메시지를 반환한다', () {
        expect(ValidationUtils.validatePassword(null), '비밀번호를 입력해주세요');
        expect(ValidationUtils.validatePassword(''), '비밀번호를 입력해주세요');
        expect(ValidationUtils.validatePassword('short'), '비밀번호는 8자 이상이어야 합니다');
        expect(ValidationUtils.validatePassword('12345678'), '비밀번호에 영문자를 포함해주세요');
        expect(ValidationUtils.validatePassword('password'), '비밀번호에 숫자를 포함해주세요');
        expect(ValidationUtils.validatePassword('Password1'), null);
      });

      test('비밀번호 확인 검증을 수행한다', () {
        expect(
          ValidationUtils.validateConfirmPassword('Password1', null),
          '비밀번호 확인을 입력해주세요',
        );
        expect(
          ValidationUtils.validateConfirmPassword('Password1', 'Different1'),
          '비밀번호가 일치하지 않습니다',
        );
        expect(
          ValidationUtils.validateConfirmPassword('Password1', 'Password1'),
          null,
        );
      });
    });

    group('Nickname Validation', () {
      test('유효한 닉네임을 허용한다', () {
        expect(ValidationUtils.isValidNickname('별빛팬'), true);
        expect(ValidationUtils.isValidNickname('user123'), true);
        expect(ValidationUtils.isValidNickname('my_name'), true);
        expect(ValidationUtils.isValidNickname('하늘별팬_01'), true);
      });

      test('유효하지 않은 닉네임을 거부한다', () {
        expect(ValidationUtils.isValidNickname(''), false);
        expect(ValidationUtils.isValidNickname('a'), false); // 너무 짧음
        expect(ValidationUtils.isValidNickname('a' * 21), false); // 너무 김
        expect(ValidationUtils.isValidNickname('name@test'), false); // 특수문자
        expect(ValidationUtils.isValidNickname('name space'), false); // 공백
      });
    });

    group('Phone Number Validation', () {
      test('유효한 전화번호를 허용한다', () {
        expect(ValidationUtils.isValidPhoneNumber('01012345678'), true);
        expect(ValidationUtils.isValidPhoneNumber('010-1234-5678'), true);
        expect(ValidationUtils.isValidPhoneNumber('011-234-5678'), true);
      });

      test('유효하지 않은 전화번호를 거부한다', () {
        expect(ValidationUtils.isValidPhoneNumber(''), false);
        expect(ValidationUtils.isValidPhoneNumber('1234567890'), false);
        expect(ValidationUtils.isValidPhoneNumber('02-1234-5678'), false);
        expect(ValidationUtils.isValidPhoneNumber(null), false);
      });

      test('전화번호를 포맷팅한다', () {
        expect(ValidationUtils.formatPhoneNumber('01012345678'), '010-1234-5678');
        expect(ValidationUtils.formatPhoneNumber('0101234567'), '010-123-4567');
      });
    });

    group('Amount Validation', () {
      test('유효한 금액을 허용한다', () {
        expect(ValidationUtils.isValidAmount(1000), true);
        expect(ValidationUtils.isValidAmount(1), true);
      });

      test('유효하지 않은 금액을 거부한다', () {
        expect(ValidationUtils.isValidAmount(0), false);
        expect(ValidationUtils.isValidAmount(-1000), false);
        expect(ValidationUtils.isValidAmount(null), false);
      });

      test('금액 검증 에러 메시지를 반환한다', () {
        expect(ValidationUtils.validateAmount(null), '금액을 입력해주세요');
        expect(ValidationUtils.validateAmount(''), '금액을 입력해주세요');
        expect(ValidationUtils.validateAmount('0'), '0보다 큰 금액을 입력해주세요');
        expect(
          ValidationUtils.validateAmount('500', minAmount: 1000),
          '최소 금액은 1,000원입니다',
        );
        expect(
          ValidationUtils.validateAmount('100000', maxAmount: 50000),
          '최대 금액은 50,000원입니다',
        );
        expect(ValidationUtils.validateAmount('1000'), null);
      });
    });

    group('URL Validation', () {
      test('유효한 URL을 허용한다', () {
        expect(ValidationUtils.isValidUrl('https://example.com'), true);
        expect(ValidationUtils.isValidUrl('http://test.co.kr/path'), true);
        expect(ValidationUtils.isValidUrl('https://sub.domain.com/path?q=1'), true);
      });

      test('유효하지 않은 URL을 거부한다', () {
        expect(ValidationUtils.isValidUrl(''), false);
        expect(ValidationUtils.isValidUrl('example.com'), false);
        expect(ValidationUtils.isValidUrl('ftp://example.com'), false);
        expect(ValidationUtils.isValidUrl(null), false);
      });
    });

    group('Input Sanitization', () {
      test('HTML 태그를 제거한다', () {
        expect(
          ValidationUtils.stripHtmlTags('<p>Hello</p> <strong>World</strong>'),
          'Hello World',
        );
      });

      test('스크립트 태그를 제거한다', () {
        expect(
          ValidationUtils.sanitizeInput('<script>alert("xss")</script>Hello'),
          'Hello',
        );
        expect(
          ValidationUtils.sanitizeInput('onclick="alert(1)"'),
          '"alert(1)"',
        );
      });
    });

    group('Required Field Validation', () {
      test('필수 필드 검증을 수행한다', () {
        expect(
          ValidationUtils.validateRequired(null, '이름'),
          '이름을(를) 입력해주세요',
        );
        expect(
          ValidationUtils.validateRequired('', '이름'),
          '이름을(를) 입력해주세요',
        );
        expect(
          ValidationUtils.validateRequired('   ', '이름'),
          '이름을(를) 입력해주세요',
        );
        expect(ValidationUtils.validateRequired('홍길동', '이름'), null);
      });
    });
  });
}
