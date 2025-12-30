import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Model Tests', () {
    test('User role parsing should work correctly', () {
      expect(_parseRole('FAN'), 'fan');
      expect(_parseRole('IDOL'), 'idol');
      expect(_parseRole('MAID'), 'maid');
      expect(_parseRole('ADMIN'), 'admin');
      expect(_parseRole('UNKNOWN'), 'fan');
    });

    test('Amount formatting should work correctly', () {
      expect(_formatAmount(1000), '1,000');
      expect(_formatAmount(10000), '10,000');
      expect(_formatAmount(1000000), '1,000,000');
      expect(_formatAmount(0), '0');
    });

    test('Date formatting should work correctly', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      expect(_formatDate(date), '2024.01.15');
      expect(_formatDateTime(date), '2024.01.15 14:30');
    });
  });

  group('Validation Tests', () {
    test('Email validation should work correctly', () {
      expect(_isValidEmail('test@example.com'), isTrue);
      expect(_isValidEmail('test@example.co.kr'), isTrue);
      expect(_isValidEmail('invalid-email'), isFalse);
      expect(_isValidEmail('test@'), isFalse);
      expect(_isValidEmail('@example.com'), isFalse);
    });

    test('Password validation should work correctly', () {
      expect(_isValidPassword('password123'), isTrue);
      expect(_isValidPassword('12345678'), isTrue);
      expect(_isValidPassword('short'), isFalse);
      expect(_isValidPassword('1234567'), isFalse);
    });

    test('Nickname validation should work correctly', () {
      expect(_isValidNickname('User'), isTrue);
      expect(_isValidNickname('TestUser123'), isTrue);
      expect(_isValidNickname('A'), isFalse);
      expect(_isValidNickname('ThisNicknameIsWayTooLongToBeValid12345'), isFalse);
    });
  });

  group('Support Amount Tests', () {
    test('Support amount should be within valid range', () {
      expect(_isValidSupportAmount(100), isTrue);
      expect(_isValidSupportAmount(1000), isTrue);
      expect(_isValidSupportAmount(10000000), isTrue);
      expect(_isValidSupportAmount(0), isFalse);
      expect(_isValidSupportAmount(-100), isFalse);
      expect(_isValidSupportAmount(99), isFalse);
    });
  });
}

// Helper functions for testing
String _parseRole(String role) {
  switch (role.toUpperCase()) {
    case 'IDOL':
      return 'idol';
    case 'MAID':
      return 'maid';
    case 'ADMIN':
      return 'admin';
    default:
      return 'fan';
  }
}

String _formatAmount(int amount) {
  return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
}

String _formatDate(DateTime date) {
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime date) {
  return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

bool _isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool _isValidPassword(String password) {
  return password.length >= 8;
}

bool _isValidNickname(String nickname) {
  return nickname.length >= 2 && nickname.length <= 30;
}

bool _isValidSupportAmount(int amount) {
  return amount >= 100 && amount <= 10000000;
}
