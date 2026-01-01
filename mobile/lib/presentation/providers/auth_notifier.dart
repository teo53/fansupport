import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'base_state.dart';
import 'di_providers.dart';

/// 인증 상태
class AuthState {
  final AuthenticatedUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    AuthenticatedUser? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  AuthState clearError() => copyWith(error: null);
}

/// 인증 상태 관리 Notifier
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(AuthState())) {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final result = await _repository.tryAutoLogin();
    result.fold(
      onSuccess: (user) {
        if (user != null) {
          state = AsyncValue.data(AuthState(user: user));
        }
      },
      onFailure: (_) {
        // 자동 로그인 실패는 무시
      },
    );
  }

  Future<void> login(String email, String password) async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true, error: null));

    final result = await _repository.login(email: email, password: password);

    result.fold(
      onSuccess: (user) {
        state = AsyncValue.data(AuthState(user: user));
      },
      onFailure: (failure) {
        state = AsyncValue.data(state.value!.copyWith(
          isLoading: false,
          error: failure.message,
        ));
      },
    );
  }

  Future<void> loginAsDemo() async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true, error: null));

    final result = await _repository.loginAsDemo();

    result.fold(
      onSuccess: (user) {
        state = AsyncValue.data(AuthState(user: user));
      },
      onFailure: (failure) {
        state = AsyncValue.data(state.value!.copyWith(
          isLoading: false,
          error: failure.message,
        ));
      },
    );
  }

  Future<void> register(String email, String password, String nickname) async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true, error: null));

    final result = await _repository.register(
      email: email,
      password: password,
      nickname: nickname,
    );

    result.fold(
      onSuccess: (user) {
        state = AsyncValue.data(AuthState(user: user));
      },
      onFailure: (failure) {
        state = AsyncValue.data(state.value!.copyWith(
          isLoading: false,
          error: failure.message,
        ));
      },
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(AuthState());
  }

  void clearError() {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.clearError());
    }
  }
}

/// 인증 상태 Provider
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

/// 현재 로그인한 사용자 Provider
final currentUserProvider = Provider<AuthenticatedUser?>((ref) {
  return ref.watch(authStateProvider).value?.user;
});

/// 로그인 여부 Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
