---
name: flutter-dev
description: |
  Flutter mobile development skill for Idol Support app.
  Use when working on mobile/ directory: creating widgets, screens, providers, or fixing Flutter-related issues.
  Includes Riverpod state management, GoRouter navigation, and Dio/Retrofit networking patterns.
---

# Flutter Development Skill

## Project Structure

```
mobile/
├── lib/
│   ├── core/           # Core utilities, constants, themes
│   ├── data/           # Data layer (API, repositories)
│   ├── domain/         # Domain models, entities
│   ├── presentation/   # UI (screens, widgets, providers)
│   └── main.dart
├── test/               # Unit tests
└── integration_test/   # Integration tests
```

## State Management (Riverpod)

```dart
// Provider definition
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  AsyncValue<User> build() => const AsyncValue.loading();

  Future<void> fetchUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(userRepository).getUser());
  }
}

// Usage in widget
final userAsync = ref.watch(userNotifierProvider);
userAsync.when(
  data: (user) => Text(user.name),
  loading: () => const CircularProgressIndicator(),
  error: (e, st) => Text('Error: $e'),
);
```

## Navigation (GoRouter)

```dart
GoRoute(
  path: '/idol/:id',
  builder: (context, state) => IdolDetailScreen(
    idolId: state.pathParameters['id']!,
  ),
)

// Navigate
context.go('/idol/123');
context.push('/idol/123');
```

## Networking (Dio + Retrofit)

```dart
@RestApi(baseUrl: '')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET('/api/users/idols')
  Future<List<IdolProfile>> getIdols();

  @POST('/api/support')
  Future<Support> createSupport(@Body() CreateSupportDto dto);
}
```

## Data Classes (Freezed)

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String displayName,
    String? avatarUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

## Error Handling

```dart
// Custom exceptions with Korean messages
class NetworkException implements Exception {
  final String userMessage;
  NetworkException([this.userMessage = '네트워크 연결을 확인해주세요']);
}

class AuthException implements Exception {
  final String userMessage;
  AuthException([this.userMessage = '인증에 실패했습니다. 다시 로그인해주세요']);
}
```

## Commands

```bash
flutter pub get                    # Install dependencies
flutter pub run build_runner build # Generate code
flutter run                        # Run app
flutter test                       # Run tests
flutter analyze                    # Static analysis
flutter build apk --release        # Build release APK
```

## Code Generation

After modifying freezed/retrofit/riverpod files:
```bash
dart run build_runner build --delete-conflicting-outputs
```
