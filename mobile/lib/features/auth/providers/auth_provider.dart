import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../core/config/app_config.dart';
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
          .single();

      return User(
        id: data['id'],
        email: data['email'],
        nickname: data['nickname'] ?? 'User',
        profileImage: data['profile_image'],
        role: data['role'] ?? 'FAN',
        isVerified: data['is_verified'] ?? false,
        walletBalance: data['wallets']?[0]?['balance']?.toInt() ?? 0,
      );
    } catch (e) {
      // If user profile doesn't exist, return basic user from auth
      final authUser = _supabase.auth.currentUser;
      return User(
        id: userId,
        email: authUser?.email ?? '',
        nickname: authUser?.userMetadata?['nickname'] ?? 'User',
        profileImage: null,
        role: authUser?.userMetadata?['role'] ?? 'FAN',
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

  Future<void> register(
    String email,
    String password,
    String nickname, {
    String? realName,
    String? phone,
    String? birthDate,
    String accountType = 'FAN',
  }) async {
    state = const AsyncValue.data(AuthState(isLoading: true));

    // Map account type to role (handle both upper/lowercase)
    final role = switch (accountType.toUpperCase()) {
      'FAN' => 'FAN',
      'IDOL' => 'IDOL',
      'AGENCY' => 'AGENCY',
      _ => 'FAN',
    };

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nickname': nickname,
          'role': role,
          if (realName != null) 'real_name': realName,
          if (phone != null) 'phone': phone,
          if (birthDate != null) 'birth_date': birthDate,
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
    // Demo login is only available in development/staging environments
    if (AppConfig.isProduction) {
      state = const AsyncValue.data(AuthState(error: '데모 로그인은 프로덕션 환경에서 사용할 수 없습니다.'));
      return;
    }

    state = const AsyncValue.data(AuthState(isLoading: true));

    try {
      // Use environment-based demo credentials (never hardcoded)
      final demoEmail = const String.fromEnvironment(
        'DEMO_EMAIL',
        defaultValue: '',
      );
      final demoPassword = const String.fromEnvironment(
        'DEMO_PASSWORD',
        defaultValue: '',
      );

      if (demoEmail.isEmpty || demoPassword.isEmpty) {
        // Create anonymous session for demo if credentials not configured
        await _createAnonymousDemoSession(role);
        return;
      }

      await login(demoEmail, demoPassword);
    } catch (e) {
      if (kDebugMode) {
        print('Demo login error: $e');
      }
      state = const AsyncValue.data(AuthState(error: '데모 로그인에 실패했습니다.'));
    }
  }

  /// Create anonymous demo session without real credentials
  Future<void> _createAnonymousDemoSession(String? role) async {
    try {
      // Sign in anonymously (Supabase anonymous auth)
      final response = await _supabase.auth.signInAnonymously();

      if (response.user != null) {
        // Create a temporary demo user
        final demoUser = User(
          id: response.user!.id,
          email: 'demo@pipo.app',
          nickname: '체험 사용자',
          profileImage: null,
          role: role ?? 'FAN',
          isVerified: false,
          walletBalance: 10000, // Demo balance
        );
        state = AsyncValue.data(AuthState(user: demoUser));
      } else {
        state = const AsyncValue.data(AuthState(error: '데모 세션 생성에 실패했습니다.'));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Anonymous demo session error: $e');
      }
      state = const AsyncValue.data(AuthState(error: '데모 로그인에 실패했습니다.'));
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
    try {
      await _supabase.from('users').update({
        'nickname': user.nickname,
        'profile_image': user.profileImage,
      }).eq('id', user.id);

      state = AsyncValue.data(state.value!.copyWith(user: user));
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(error: '프로필 업데이트 실패'));
    }
  }

  void updateWalletBalance(int newBalance) {
    if (state.value?.user != null) {
      final updatedUser = state.value!.user!.copyWith(
        walletBalance: newBalance,
      );
      state = AsyncValue.data(AuthState(user: updatedUser));
    }
  }

  /// Sign in with OAuth provider (Google, Apple, Kakao, Naver)
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    state = const AsyncValue.data(AuthState(isLoading: true));

    try {
      final supabaseProvider = _mapToSupabaseProvider(provider);

      // Start OAuth flow
      final success = await _supabase.auth.signInWithOAuth(
        supabaseProvider,
        redirectTo: _getRedirectUrl(provider),
        authScreenLaunchMode: sb.LaunchMode.externalApplication,
      );

      if (!success) {
        state = const AsyncValue.data(
          AuthState(error: '소셜 로그인을 시작할 수 없습니다'),
        );
      }
      // Auth state will be updated via onAuthStateChange listener
    } on sb.AuthException catch (e) {
      state = AsyncValue.data(AuthState(error: _handleAuthError(e)));
    } catch (e) {
      if (kDebugMode) {
        print('OAuth error: $e');
      }
      state = AsyncValue.data(
        AuthState(error: '소셜 로그인 중 오류가 발생했습니다'),
      );
    }
  }

  /// Handle OAuth callback (for deep link handling)
  Future<void> handleOAuthCallback(Uri uri) async {
    try {
      state = const AsyncValue.data(AuthState(isLoading: true));

      // Extract tokens from callback URL
      final session = await _supabase.auth.getSessionFromUrl(uri);

      if (session.session != null) {
        final user = await _fetchUserProfile(session.session!.user.id);
        state = AsyncValue.data(AuthState(user: user));
      } else {
        state = const AsyncValue.data(
          AuthState(error: '소셜 로그인에 실패했습니다'),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('OAuth callback error: $e');
      }
      state = const AsyncValue.data(
        AuthState(error: '로그인 처리 중 오류가 발생했습니다'),
      );
    }
  }

  /// Map custom provider enum to Supabase provider
  sb.OAuthProvider _mapToSupabaseProvider(OAuthProvider provider) {
    switch (provider) {
      case OAuthProvider.google:
        return sb.OAuthProvider.google;
      case OAuthProvider.apple:
        return sb.OAuthProvider.apple;
      case OAuthProvider.kakao:
        return sb.OAuthProvider.kakao;
      case OAuthProvider.naver:
        // Naver is not natively supported, use custom OIDC
        throw UnsupportedError('Naver OAuth requires custom implementation');
    }
  }

  /// Get OAuth redirect URL for the provider
  String _getRedirectUrl(OAuthProvider provider) {
    // Deep link scheme for the app
    const scheme = 'com.pipo.app';
    return '$scheme://login-callback';
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

/// OAuth provider types
enum OAuthProvider {
  google,
  apple,
  kakao,
  naver,
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
