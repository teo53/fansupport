import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/user_model.dart';

/// Supabase Client Provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Supabase Auth State Notifier
class SupabaseAuthNotifier extends Notifier<AsyncValue<User?>> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  AsyncValue<User?> build() {
    // Auth 상태 변경 감지
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      state = AsyncValue.data(session?.user);
    });

    return AsyncValue.data(_supabase.auth.currentUser);
  }

  /// 이메일 로그인
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      state = AsyncValue.data(response.user);
    } catch (e, stack) {
      state = AsyncValue.error(_handleAuthError(e), stack);
    }
  }

  /// 이메일 회원가입
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nickname': nickname,
          'role': 'FAN',
        },
      );

      if (response.user == null) {
        throw Exception('회원가입에 실패했습니다');
      }

      state = AsyncValue.data(response.user);
    } catch (e, stack) {
      state = AsyncValue.error(_handleAuthError(e), stack);
    }
  }

  /// Google 로그인
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'pipo://callback',
      );
    } catch (e, stack) {
      state = AsyncValue.error(_handleAuthError(e), stack);
    }
  }

  /// Apple 로그인
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'pipo://callback',
      );
    } catch (e, stack) {
      state = AsyncValue.error(_handleAuthError(e), stack);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(_handleAuthError(e), stack);
    }
  }

  /// 비밀번호 재설정
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// 에러 핸들링
  String _handleAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.statusCode) {
        case '400':
          return '잘못된 요청입니다';
        case '401':
          return '이메일 또는 비밀번호가 올바르지 않습니다';
        case '422':
          return '이미 가입된 이메일입니다';
        default:
          return error.message;
      }
    }
    return '알 수 없는 오류가 발생했습니다';
  }
}

/// Auth Notifier Provider
final supabaseAuthProvider =
    NotifierProvider<SupabaseAuthNotifier, AsyncValue<User?>>(() {
  return SupabaseAuthNotifier();
});

/// 현재 사용자 Provider
final currentSupabaseUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseAuthProvider).value;
});

/// 로그인 상태 Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentSupabaseUserProvider) != null;
});
