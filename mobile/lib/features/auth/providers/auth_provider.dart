import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AsyncValue<AuthState>> {
  @override
  AsyncValue<AuthState> build() {
    _init();
    return const AsyncValue.loading();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = const AsyncValue.data(AuthState());
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.data(AuthState(isLoading: true));

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['accessToken'] != null) {
        // Save tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', response['accessToken']);
        await prefs.setString('refreshToken', response['refreshToken']);

        // Create user from response
        final userData = response['user'];
        final user = User(
          id: userData['id'],
          email: userData['email'],
          nickname: userData['nickname'],
          profileImage: userData['profileImage'],
          role: userData['role'],
          isVerified: userData['isVerified'] ?? false,
          walletBalance: userData['walletBalance'] ?? 0,
        );

        state = AsyncValue.data(AuthState(user: user));
      } else {
        state = AsyncValue.data(AuthState(error: '로그인에 실패했습니다.'));
      }
    } catch (e) {
      state = AsyncValue.data(AuthState(error: '서버 오류: ${e.toString()}'));
    }
  }

  Future<void> register(
    String email,
    String password,
    String nickname,
    String dateOfBirth,
    bool termsConsent,
    bool privacyConsent,
    bool marketingConsent,
  ) async {
    state = const AsyncValue.data(AuthState(isLoading: true));

    try {
      final response = await ApiService.post('/auth/register', {
        'email': email,
        'password': password,
        'nickname': nickname,
        'dateOfBirth': dateOfBirth,
        'termsConsent': termsConsent,
        'privacyConsent': privacyConsent,
        'marketingConsent': marketingConsent,
      });

      if (response['accessToken'] != null) {
        // Save tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', response['accessToken']);
        await prefs.setString('refreshToken', response['refreshToken']);

        // Create user from response
        final userData = response['user'];
        final user = User(
          id: userData['id'],
          email: userData['email'],
          nickname: userData['nickname'],
          profileImage: userData['profileImage'],
          role: userData['role'] ?? 'FAN',
          isVerified: userData['isVerified'] ?? false,
          walletBalance: userData['walletBalance'] ?? 0,
        );

        state = AsyncValue.data(AuthState(user: user));
      } else {
        state = AsyncValue.data(AuthState(error: '회원가입에 실패했습니다.'));
      }
    } catch (e) {
      state = AsyncValue.data(AuthState(error: '서버 오류: ${e.toString()}'));
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.data(AuthState(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');

      // Call backend logout endpoint
      if (refreshToken != null) {
        await ApiService.post('/auth/logout', {
          'refreshToken': refreshToken,
        });
      }

      // Clear tokens
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');

      state = const AsyncValue.data(AuthState());
    } catch (e) {
      // Even if logout fails on backend, clear local tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      state = const AsyncValue.data(AuthState());
    }
  }

  Future<void> updateUser(User user) async {
    state = AsyncValue.data(state.value!.copyWith(user: user));
  }

  void updateWalletBalance(int newBalance) {
    if (state.value?.user != null) {
      final updatedUser = User(
        id: state.value!.user!.id,
        email: state.value!.user!.email,
        nickname: state.value!.user!.nickname,
        profileImage: state.value!.user!.profileImage,
        role: state.value!.user!.role,
        isVerified: state.value!.user!.isVerified,
        walletBalance: newBalance,
      );
      state = AsyncValue.data(AuthState(user: updatedUser));
    }
  }
}

final authStateProvider =
    NotifierProvider<AuthNotifier, AsyncValue<AuthState>>(() {
  return AuthNotifier();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value?.user;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value?.isLoggedIn ?? false;
});

final walletBalanceProvider = Provider<int>((ref) {
  return ref.watch(currentUserProvider)?.walletBalance ?? 0;
});
