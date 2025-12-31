import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_datasource.dart';

/// AuthRepository 구현체
class AuthRepositoryImpl implements AuthRepository {
  final LocalDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Result<AuthenticatedUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.login(email, password);
      return Success(user);
    } catch (e) {
      return Fail(_mapException(e, ErrorMessages.invalidCredentials));
    }
  }

  @override
  Future<Result<AuthenticatedUser>> loginAsDemo() async {
    try {
      final user = await _dataSource.loginAsDemo();
      return Success(user);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<AuthenticatedUser>> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    // Demo: 회원가입은 항상 성공
    try {
      await Future.delayed(UIConstants.mockDelay);
      final user = await _dataSource.loginAsDemo();
      return Success(user.copyWith(
        email: email,
        nickname: nickname,
      ));
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<AuthenticatedUser>> socialLogin({
    required String provider,
    required String token,
  }) async {
    // Demo: 소셜 로그인은 데모 유저로 처리
    try {
      await Future.delayed(UIConstants.mockDelay);
      final user = await _dataSource.loginAsDemo();
      return Success(user);
    } catch (e) {
      return Fail(_mapException(e, '$provider 로그인 실패'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _dataSource.logout();
      return const Success(null);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  @override
  Future<Result<AuthenticatedUser?>> getCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return Success(user);
    } catch (e) {
      return Fail(const CacheFailure());
    }
  }

  @override
  Future<Result<AuthenticatedUser?>> tryAutoLogin() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return Success(user);
    } catch (e) {
      // 자동 로그인 실패는 조용히 처리
      return const Success(null);
    }
  }

  @override
  Future<Result<AuthenticatedUser>> refreshToken(String refreshToken) async {
    // Demo: 토큰 갱신은 현재 유저 반환
    try {
      final user = await _dataSource.getCurrentUser();
      if (user != null) {
        return Success(user);
      }
      return Fail(AuthFailure.sessionExpired());
    } catch (e) {
      return Fail(AuthFailure.sessionExpired());
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    // Demo: 항상 성공
    await Future.delayed(UIConstants.mockDelay);
    return const Success(null);
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Demo: 항상 성공
    await Future.delayed(UIConstants.mockDelay);
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _dataSource.logout();
      return const Success(null);
    } catch (e) {
      return Fail(_mapException(e));
    }
  }

  /// 예외를 Failure로 변환
  Failure _mapException(dynamic e, [String? fallbackMessage]) {
    if (e is AuthException) {
      return AuthFailure(message: e.message, code: e.code);
    } else if (e is NetworkException) {
      return ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } else if (e is AppException) {
      return ServerFailure(message: e.message, code: e.code);
    }
    return AuthFailure(
      message: fallbackMessage ?? ErrorMessages.generic,
    );
  }
}
