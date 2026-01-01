import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/core/services/secure_storage_service.dart';

void main() {
  group('SecureStorageService', () {
    late SecureStorageService storage;

    setUp(() {
      storage = SecureStorageService();
    });

    tearDown(() async {
      await storage.deleteAll();
    });

    group('Basic Operations', () {
      test('값을 저장하고 읽을 수 있다', () async {
        await storage.write(key: 'test_key', value: 'test_value');
        final result = await storage.read(key: 'test_key');
        expect(result, 'test_value');
      });

      test('존재하지 않는 키는 null을 반환한다', () async {
        final result = await storage.read(key: 'non_existent');
        expect(result, null);
      });

      test('값을 삭제할 수 있다', () async {
        await storage.write(key: 'test_key', value: 'test_value');
        await storage.delete(key: 'test_key');
        final result = await storage.read(key: 'test_key');
        expect(result, null);
      });

      test('키 존재 여부를 확인할 수 있다', () async {
        await storage.write(key: 'test_key', value: 'test_value');
        expect(await storage.containsKey(key: 'test_key'), true);
        expect(await storage.containsKey(key: 'non_existent'), false);
      });

      test('모든 값을 삭제할 수 있다', () async {
        await storage.write(key: 'key1', value: 'value1');
        await storage.write(key: 'key2', value: 'value2');
        await storage.deleteAll();
        expect(await storage.read(key: 'key1'), null);
        expect(await storage.read(key: 'key2'), null);
      });
    });

    group('Token Operations', () {
      test('액세스 토큰을 저장하고 조회할 수 있다', () async {
        await storage.saveAccessToken('test_access_token');
        final token = await storage.getAccessToken();
        expect(token, 'test_access_token');
      });

      test('리프레시 토큰을 저장하고 조회할 수 있다', () async {
        await storage.saveRefreshToken('test_refresh_token');
        final token = await storage.getRefreshToken();
        expect(token, 'test_refresh_token');
      });

      test('사용자 인증 정보를 저장할 수 있다', () async {
        await storage.saveUserCredentials(
          userId: 'user_123',
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
        );

        expect(await storage.read(key: SecureStorageService.keyUserId), 'user_123');
        expect(await storage.getAccessToken(), 'access_token');
        expect(await storage.getRefreshToken(), 'refresh_token');
      });

      test('인증 데이터를 삭제할 수 있다', () async {
        await storage.saveUserCredentials(
          userId: 'user_123',
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
        );

        await storage.clearAuthData();

        expect(await storage.getAccessToken(), null);
        expect(await storage.getRefreshToken(), null);
        expect(await storage.read(key: SecureStorageService.keyUserId), null);
      });
    });

    group('Login State', () {
      test('토큰이 있으면 로그인 상태로 판단한다', () async {
        await storage.saveAccessToken('valid_token');
        expect(await storage.isLoggedIn(), true);
      });

      test('토큰이 없으면 로그아웃 상태로 판단한다', () async {
        expect(await storage.isLoggedIn(), false);
      });

      test('빈 토큰은 로그아웃 상태로 판단한다', () async {
        await storage.saveAccessToken('');
        expect(await storage.isLoggedIn(), false);
      });
    });
  });
}
