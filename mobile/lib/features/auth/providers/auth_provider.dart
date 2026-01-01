import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/user_model.dart';

// Demo mode flag - set to true for demo without backend
const bool isDemoMode = true;

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
    await Future.delayed(const Duration(seconds: 1));

    if (isDemoMode) {
      state = AsyncValue.data(AuthState(user: MockData.demoUser));
    } else {
      state = AsyncValue.data(AuthState(error: '서버에 연결할 수 없습니다.'));
    }
  }

  Future<void> register(String email, String password, String nickname) async {
    state = const AsyncValue.data(AuthState(isLoading: true));
    await Future.delayed(const Duration(seconds: 1));

    if (isDemoMode) {
      final user = User(
        id: 'new-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        nickname: nickname,
        profileImage: 'https://ui-avatars.com/api/?name=$nickname&background=5046E5&color=fff&size=150&font-size=0.4&rounded=true',
        role: 'FAN',
        isVerified: false,
        walletBalance: 50000,
      );
      state = AsyncValue.data(AuthState(user: user));
    } else {
      state = AsyncValue.data(AuthState(error: '서버에 연결할 수 없습니다.'));
    }
  }

  Future<void> loginAsDemo() async {
    state = const AsyncValue.data(AuthState(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 800));
    state = AsyncValue.data(AuthState(user: MockData.demoUser));
  }

  Future<void> logout() async {
    state = const AsyncValue.data(AuthState());
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
