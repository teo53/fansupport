# Testing Guide

PIPO 앱의 테스트 가이드입니다.

## 목차

1. [테스트 종류](#테스트-종류)
2. [테스트 실행](#테스트-실행)
3. [테스트 작성](#테스트-작성)
4. [CI/CD](#cicd)
5. [커버리지](#커버리지)

---

## 테스트 종류

### 1. 단위 테스트 (Unit Tests)

개별 함수, 클래스, 메서드를 테스트합니다.

**위치**: `test/`

**예시**:
```dart
// test/unit_test.dart
test('Email validation should work correctly', () {
  expect(isValidEmail('test@example.com'), isTrue);
  expect(isValidEmail('invalid-email'), isFalse);
});
```

### 2. 위젯 테스트 (Widget Tests)

개별 위젯과 UI 컴포넌트를 테스트합니다.

**위치**: `test/`

**예시**:
```dart
// test/features/splash/screens/splash_screen_test.dart
testWidgets('should display PIPO logo text', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SplashScreen(onComplete: () {}),
    ),
  );

  expect(find.text('PIPO'), findsOneWidget);
});
```

### 3. 통합 테스트 (Integration Tests)

앱 전체 흐름을 실제 기기/에뮬레이터에서 테스트합니다.

**위치**: `integration_test/`

**예시**:
```dart
// integration_test/app_test.dart
testWidgets('Complete first launch flow', (WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Test complete user journey
  expect(find.text('PIPO'), findsOneWidget);
});
```

---

## 테스트 실행

### 모든 단위/위젯 테스트 실행

```bash
cd mobile
flutter test
```

### 특정 테스트 파일 실행

```bash
flutter test test/features/splash/screens/splash_screen_test.dart
```

### 커버리지와 함께 실행

```bash
flutter test --coverage
```

커버리지 리포트 보기:
```bash
# HTML 리포트 생성 (lcov 필요)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 통합 테스트 실행

안드로이드 에뮬레이터나 실제 기기를 연결한 후:

```bash
flutter test integration_test/app_test.dart
```

또는:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

---

## 테스트 작성

### 단위 테스트 작성 가이드

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Feature Name Tests', () {
    // 각 테스트 전에 실행
    setUp(() {
      // 초기화 코드
    });

    // 각 테스트 후에 실행
    tearDown(() {
      // 정리 코드
    });

    test('should do something', () {
      // Arrange: 테스트 설정
      final input = 'test';

      // Act: 동작 실행
      final result = someFunction(input);

      // Assert: 결과 검증
      expect(result, equals('expected'));
    });
  });
}
```

### 위젯 테스트 작성 가이드

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget test description', (WidgetTester tester) async {
    // 위젯 빌드
    await tester.pumpWidget(
      MaterialApp(home: MyWidget()),
    );

    // UI 요소 찾기
    expect(find.text('Hello'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byKey(Key('my-key')), findsOneWidget);

    // 인터랙션
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(); // 애니메이션 완료 대기

    // 결과 검증
    expect(find.text('Clicked'), findsOneWidget);
  });
}
```

### Provider/Riverpod 테스트

```dart
testWidgets('Provider test', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Provider를 mock으로 오버라이드
        myProvider.overrideWith((ref) => MockImplementation()),
      ],
      child: MaterialApp(home: MyWidget()),
    ),
  );

  // 테스트 계속...
});
```

### Mock 사용하기

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Mock 생성
@GenerateMocks([MyRepository])
void main() {
  late MockMyRepository mockRepository;

  setUp(() {
    mockRepository = MockMyRepository();
  });

  test('should fetch data', () async {
    // Mock 동작 정의
    when(mockRepository.fetchData())
        .thenAnswer((_) async => 'test data');

    // 테스트...
    final result = await mockRepository.fetchData();

    // 검증
    expect(result, 'test data');
    verify(mockRepository.fetchData()).called(1);
  });
}
```

---

## CI/CD

GitHub Actions에서 자동으로 테스트가 실행됩니다.

### 워크플로우 구조

`.github/workflows/mobile.yml`:

1. **Analyze** - 코드 포맷팅 및 정적 분석
2. **Test** - 모든 단위/위젯 테스트 실행 (커버리지 포함)
3. **Build Android** - APK/AAB 빌드 (main 브랜치만)
4. **Build iOS** - iOS 빌드 (main 브랜치만)

### 로컬에서 CI 검증

```bash
# 포맷 확인
dart format --output=none --set-exit-if-changed .

# 정적 분석
flutter analyze

# 테스트 실행
flutter test --coverage

# 빌드 확인
flutter build apk --debug
```

---

## 커버리지

### 커버리지 목표

- **전체**: 최소 70%
- **핵심 비즈니스 로직**: 최소 80%
- **UI 컴포넌트**: 최소 60%

### 커버리지 확인

```bash
# 커버리지 생성
flutter test --coverage

# 커버리지 리포트 확인
lcov --summary coverage/lcov.info
```

### 특정 파일 제외

`coverage/lcov.info`에서 제외하려면:

```bash
lcov --remove coverage/lcov.info \
  '**/*.g.dart' \
  '**/*.freezed.dart' \
  '**/generated/**' \
  -o coverage/lcov_filtered.info
```

---

## 테스트 전략

### 무엇을 테스트할까?

✅ **반드시 테스트**:
- 비즈니스 로직
- 데이터 변환 및 검증
- 상태 관리 로직
- API 응답 처리
- 에러 핸들링

✅ **테스트 권장**:
- 핵심 UI 컴포넌트
- 사용자 인터랙션 흐름
- 네비게이션
- 폼 검증

⚠️ **테스트 선택적**:
- 단순 UI 위젯
- 디자인 상수
- 생성된 코드 (*.g.dart)

### 테스트 작성 순서

1. **단위 테스트** - 비즈니스 로직부터 시작
2. **위젯 테스트** - 핵심 UI 컴포넌트
3. **통합 테스트** - 주요 사용자 흐름

---

## 문제 해결

### 테스트가 실패할 때

1. **에러 메시지 확인**: 정확한 실패 이유 파악
2. **로그 확인**: `print()` 또는 `debugPrint()` 사용
3. **단계별 디버깅**: `await tester.pump()` 사이에 확인
4. **위젯 트리 출력**: `debugDumpApp()` 또는 `debugDumpRenderTree()`

### 타임아웃 이슈

```dart
// 타임아웃 늘리기
testWidgets('Long running test', (WidgetTester tester) async {
  // ...
}, timeout: const Timeout(Duration(minutes: 2)));
```

### 애니메이션 관련 이슈

```dart
// 애니메이션 완료 대기
await tester.pumpAndSettle();

// 특정 시간만큼 진행
await tester.pump(Duration(seconds: 2));

// 애니메이션 비활성화
WidgetsBinding.instance.disableAnimations = true;
```

---

## 참고 자료

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Riverpod Testing Guide](https://riverpod.dev/docs/cookbooks/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)

---

## 체크리스트

### 새 기능 추가 시

- [ ] 단위 테스트 작성
- [ ] 위젯 테스트 작성 (UI 변경 시)
- [ ] 기존 테스트 모두 통과
- [ ] 커버리지 확인 (감소하지 않았는지)
- [ ] CI/CD 통과 확인

### PR 생성 전

- [ ] `flutter test` 로컬 실행 및 통과
- [ ] `flutter analyze` 경고 없음
- [ ] `dart format .` 코드 포맷팅
- [ ] 새로운 테스트 추가 (해당되는 경우)
- [ ] 테스트 문서 업데이트 (필요한 경우)
