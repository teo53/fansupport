import 'package:flutter/foundation.dart';

/// 보안 저장소 서비스
/// 프로덕션에서는 flutter_secure_storage 사용 권장
/// 현재는 데모용으로 메모리 저장소 사용
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // 메모리 저장소 (데모용)
  // TODO: 프로덕션에서 flutter_secure_storage로 교체
  final Map<String, String> _memoryStorage = {};

  // 키 상수
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyPinCode = 'pin_code';

  /// 값 저장
  Future<void> write({required String key, required String value}) async {
    _memoryStorage[key] = value;
    debugPrint('[SecureStorage] Saved: $key');
  }

  /// 값 읽기
  Future<String?> read({required String key}) async {
    return _memoryStorage[key];
  }

  /// 값 삭제
  Future<void> delete({required String key}) async {
    _memoryStorage.remove(key);
    debugPrint('[SecureStorage] Deleted: $key');
  }

  /// 모든 값 삭제
  Future<void> deleteAll() async {
    _memoryStorage.clear();
    debugPrint('[SecureStorage] Cleared all');
  }

  /// 키 존재 여부 확인
  Future<bool> containsKey({required String key}) async {
    return _memoryStorage.containsKey(key);
  }

  // ============ 편의 메서드 ============

  /// 액세스 토큰 저장
  Future<void> saveAccessToken(String token) async {
    await write(key: keyAccessToken, value: token);
  }

  /// 액세스 토큰 조회
  Future<String?> getAccessToken() async {
    return await read(key: keyAccessToken);
  }

  /// 리프레시 토큰 저장
  Future<void> saveRefreshToken(String token) async {
    await write(key: keyRefreshToken, value: token);
  }

  /// 리프레시 토큰 조회
  Future<String?> getRefreshToken() async {
    return await read(key: keyRefreshToken);
  }

  /// 사용자 인증 정보 저장
  Future<void> saveUserCredentials({
    required String userId,
    required String accessToken,
    String? refreshToken,
  }) async {
    await write(key: keyUserId, value: userId);
    await write(key: keyAccessToken, value: accessToken);
    if (refreshToken != null) {
      await write(key: keyRefreshToken, value: refreshToken);
    }
  }

  /// 로그아웃 시 인증 정보 삭제
  Future<void> clearAuthData() async {
    await delete(key: keyAccessToken);
    await delete(key: keyRefreshToken);
    await delete(key: keyUserId);
    await delete(key: keyUserEmail);
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
