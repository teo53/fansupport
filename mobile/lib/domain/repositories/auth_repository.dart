import '../../core/errors/result.dart';
import '../entities/user_entity.dart';

/// 인증 Repository 인터페이스
abstract class AuthRepository {
  /// 이메일/비밀번호 로그인
  Future<Result<AuthenticatedUser>> login({
    required String email,
    required String password,
  });

  /// 회원가입
  Future<Result<AuthenticatedUser>> register({
    required String email,
    required String password,
    required String nickname,
  });

  /// 데모 로그인
  Future<Result<AuthenticatedUser>> loginAsDemo();

  /// 소셜 로그인
  Future<Result<AuthenticatedUser>> socialLogin({
    required String provider,
    required String token,
  });

  /// 로그아웃
  Future<Result<void>> logout();

  /// 토큰 갱신
  Future<Result<AuthenticatedUser>> refreshToken(String refreshToken);

  /// 현재 로그인된 사용자 조회
  Future<Result<AuthenticatedUser?>> getCurrentUser();

  /// 저장된 토큰으로 자동 로그인 시도
  Future<Result<AuthenticatedUser?>> tryAutoLogin();

  /// 비밀번호 재설정 이메일 발송
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// 비밀번호 변경
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// 회원 탈퇴
  Future<Result<void>> deleteAccount();
}
