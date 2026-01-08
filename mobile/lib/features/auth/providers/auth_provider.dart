import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../shared/models/user_model.dart';

// Supabase client provider
final supabaseClientProvider = Provider<sb.SupabaseClient>((ref) {
  return sb.Supabase.instance.client;
});

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
  sb.SupabaseClient get _supabase => sb.Supabase.instance.client;

  @override
  AsyncValue<AuthState> build() {
    _init();
    return const AsyncValue.loading();
  }

  Future<void> _init() async {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((authState) async {
      final supabaseUser = authState.session?.user;
      if (supabaseUser != null) {
        final user = await _fetchUserProfile(supabaseUser.id);
        state = AsyncValue.data(AuthState(user: user));
      } else {
        state = const AsyncValue.data(AuthState());
      }
    });

    // Check current session
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      final user = await _fetchUserProfile(currentUser.id);
      state = AsyncValue.data(AuthState(user: user));
    } else {
      state = const AsyncValue.data(AuthState());
    }
  }

  /// Fetch user profile from Supabase
  Future<User> _fetchUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select('*, wallets(balance)')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        throw Exception('User profile not found');
      }

      // Handle wallet balance safely
      int walletBalance = 0;
      final wallets = data['wallets'];
      if (wallets != null) {
        if (wallets is List && wallets.isNotEmpty) {
          walletBalance = (wallets[0]['balance'] as num?)?.toInt() ?? 0;
        } else if (wallets is Map) {
          walletBalance = (wallets['balance'] as num?)?.toInt() ?? 0;
        }
      }

      return User(
        id: data['id'] as String,
        email: data['email'] as String,
        nickname: data['nickname'] as String? ?? 'User',
        profileImage: data['profile_image'] as String?,
        role: data['role'] as String? ?? 'FAN',
        isVerified: data['is_verified'] as bool? ?? false,
        walletBalance: walletBalance,
      );
    } catch (e) {
      // If user profile doesn't exist, return basic user from auth
      final authUser = _supabase.auth.currentUser;
      return User(
        id: userId,
        email: authUser?.email ?? '',
        nickname: authUser?.userMetadata?['nickname'] as String? ?? 'User',
        profileImage: null,
        role: authUser?.userMetadata?['role'] as String? ?? 'FAN',
        isVerified: false,
        walletBalance: 0,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.data(AuthState(isLoading: true));

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = await _fetchUserProfile(response.user!.id);
        state = AsyncValue.data(AuthState(user: user));
      } else {
        state = const AsyncValue.data(AuthState(error: '로그인에 실패했습니다.'));
      }
    } on sb.AuthException catch (e) {
      state = AsyncValue.data(AuthState(error: _handleAuthError(e)));
    } catch (e) {
      state = AsyncValue.data(AuthState(error: '로그인 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  Future<void> register(String email, String password, String nickname) async {
    state = const AsyncValue.data(AuthState(isLoading: true));

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
        state = const AsyncValue.data(AuthState(error: '회원가입에 실패했습니다.'));
        return;
      }

      // Wait for trigger to create user profile and wallet
      await Future.delayed(const Duration(seconds: 1));

      final user = await _fetchUserProfile(response.user!.id);
      state = AsyncValue.data(AuthState(user: user));
    } on sb.AuthException catch (e) {
      state = AsyncValue.data(AuthState(error: _handleAuthError(e)));
    } catch (e) {
      state = AsyncValue.data(AuthState(error: '회원가입 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  Future<void> loginAsDemo([String? role]) async {
    state = const AsyncValue.data(AuthState(isLoading: true));

    // For demo purposes, try to login with a test account
    // In production, this would be removed
    try {
      await login('test@pipo.com', 'password123');
    } catch (e) {
      state = AsyncValue.data(AuthState(error: '데모 로그인에 실패했습니다.'));
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      state = const AsyncValue.data(AuthState());
    } catch (e) {
      state = AsyncValue.data(AuthState(error: '로그아웃 중 오류가 발생했습니다.'));
    }
  }

  Future<void> updateUser(User user) async {
    final currentState = state.value;
    if (currentState == null) {
      state = const AsyncValue.data(AuthState(error: '사용자 정보를 찾을 수 없습니다'));
      return;
    }

    try {
      await _supabase.from('users').update({
        'nickname': user.nickname,
        'profile_image': user.profileImage,
      }).eq('id', user.id);

      state = AsyncValue.data(currentState.copyWith(user: user, error: null));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(error: '프로필 업데이트 실패'));
    }
  }

  void updateWalletBalance(int newBalance) {
    final currentState = state.value;
    final currentUser = currentState?.user;

    if (currentUser == null) {
      return;
    }

    try {
      final updatedUser = currentUser.copyWith(
        walletBalance: newBalance,
      );
      state = AsyncValue.data(AuthState(
        user: updatedUser,
        isLoading: currentState?.isLoading ?? false,
        error: null,
      ));
    } catch (e) {
      // Fail silently for balance updates
      return;
    }
  }

  String _handleAuthError(sb.AuthException error) {
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
