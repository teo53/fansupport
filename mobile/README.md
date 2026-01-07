# PIPO Mobile App

> Underground Idol & Maid Cafe Fan Support Platform

좋아하는 크리에이터를 응원하는 팬 후원 플랫폼 PIPO의 모바일 앱입니다.

## 목차

1. [시작하기](#시작하기)
2. [환경 설정](#환경-설정)
3. [개발 환경 실행](#개발-환경-실행)
4. [빌드](#빌드)
5. [테스트](#테스트)
6. [배포](#배포)
7. [프로젝트 구조](#프로젝트-구조)
8. [기술 스택](#기술-스택)

---

## 시작하기

### 사전 요구사항

- **Flutter SDK**: 3.27.0 이상
- **Dart SDK**: 3.6.0 이상
- **Android Studio** (Android 개발) 또는 **Xcode** (iOS 개발)
- **Node.js**: 18.x 이상 (백엔드 연동 시)

### 설치

1. **저장소 클론**

```bash
git clone https://github.com/teo53/fansupport.git
cd fansupport/mobile
```

2. **의존성 설치**

```bash
flutter pub get
```

3. **코드 생성** (필요한 경우)

```bash
# Riverpod, Freezed, JSON Serialization 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 환경 설정

PIPO 앱은 3가지 환경을 지원합니다:
- **Development**: 개발 환경
- **Staging**: 스테이징 환경
- **Production**: 프로덕션 환경

### 환경 변수 설정

환경 변수는 `--dart-define`을 통해 전달됩니다.

#### 필수 환경 변수

| 변수명 | 설명 | 예시 |
|--------|------|------|
| `ENV` | 환경 (development/staging/production) | `development` |
| `SUPABASE_URL` | Supabase 프로젝트 URL | `https://xxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase Anon Key | `eyJhbGc...` |
| `STRIPE_KEY` | Stripe Publishable Key | `pk_test_...` |

#### 선택적 환경 변수

| 변수명 | 설명 | 기본값 |
|--------|------|--------|
| `API_URL` | API 베이스 URL | `http://localhost:3000` |
| `USE_MOCK` | Mock 데이터 사용 여부 | `false` |
| `APP_VERSION` | 앱 버전 | `1.0.0` |
| `BUILD_NUMBER` | 빌드 번호 | `1` |

### 환경별 Supabase 설정

각 환경마다 별도의 Supabase 프로젝트를 사용하는 것을 권장합니다:

```bash
# Development
SUPABASE_URL=https://your-dev-project.supabase.co
SUPABASE_ANON_KEY=your-dev-anon-key

# Staging
SUPABASE_URL=https://your-staging-project.supabase.co
SUPABASE_ANON_KEY=your-staging-anon-key

# Production
SUPABASE_URL=https://your-prod-project.supabase.co
SUPABASE_ANON_KEY=your-prod-anon-key
```

### Stripe 설정

결제 기능을 위해 Stripe 키가 필요합니다:

```bash
# Development/Staging - Test Key 사용
STRIPE_KEY=pk_test_51xxxxx

# Production - Live Key 사용
STRIPE_KEY=pk_live_51xxxxx
```

---

## 개발 환경 실행

### 방법 1: 스크립트 사용 (권장)

각 환경별 실행 스크립트가 제공됩니다:

```bash
# Development 환경
./scripts/run_dev.sh

# Staging 환경
./scripts/run_staging.sh

# Production 환경
./scripts/run_prod.sh
```

### 방법 2: 직접 실행

```bash
flutter run \
  --dart-define=ENV=development \
  --dart-define=SUPABASE_URL=https://your-dev.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-dev-key \
  --dart-define=STRIPE_KEY=pk_test_xxx \
  --dart-define=USE_MOCK=false
```

### 디바이스 선택

```bash
# 연결된 디바이스 목록
flutter devices

# 특정 디바이스에서 실행
flutter run -d <device-id>

# iOS 시뮬레이터
flutter run -d "iPhone 15 Pro"

# Android 에뮬레이터
flutter run -d emulator-5554
```

---

## 빌드

### Android APK 빌드

#### 방법 1: 스크립트 사용

```bash
# Development APK
./scripts/build_apk.sh dev

# Staging APK
./scripts/build_apk.sh staging

# Production APK (Release)
./scripts/build_apk.sh prod
```

#### 방법 2: 직접 빌드

```bash
# Debug APK
flutter build apk --debug \
  --dart-define=ENV=development \
  --dart-define=SUPABASE_URL=https://your-dev.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-dev-key \
  --dart-define=STRIPE_KEY=pk_test_xxx

# Release APK
flutter build apk --release \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL=https://your-prod.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-prod-key \
  --dart-define=STRIPE_KEY=pk_live_xxx
```

**빌드 결과**:
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (AAB) 빌드

Google Play Store에 업로드하기 위한 AAB 빌드:

```bash
flutter build appbundle --release \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL=https://your-prod.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-prod-key \
  --dart-define=STRIPE_KEY=pk_live_xxx
```

**빌드 결과**: `build/app/outputs/bundle/release/app-release.aab`

### iOS 빌드

```bash
# Debug 빌드
flutter build ios --debug \
  --dart-define=ENV=development \
  --dart-define=SUPABASE_URL=https://your-dev.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-dev-key

# Release 빌드 (코드 사이닝 필요)
flutter build ios --release \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL=https://your-prod.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-prod-key
```

**주의**: iOS Release 빌드는 Apple Developer 계정과 코드 사이닝 설정이 필요합니다.

---

## 테스트

### 단위 및 위젯 테스트

```bash
# 모든 테스트 실행
flutter test

# 특정 테스트 파일 실행
flutter test test/features/splash/screens/splash_screen_test.dart

# 커버리지와 함께 실행
flutter test --coverage
```

### 통합 테스트

안드로이드 에뮬레이터 또는 실제 기기 연결 후:

```bash
flutter test integration_test/app_test.dart
```

### 테스트 문서

자세한 테스트 가이드는 [test/README.md](test/README.md)를 참조하세요.

---

## 배포

### Android 배포 (Google Play Store)

1. **App Bundle 빌드**

```bash
./scripts/build_apk.sh prod  # AAB도 함께 생성됨
```

2. **Google Play Console에 업로드**
   - [Google Play Console](https://play.google.com/console) 접속
   - 앱 선택 → 프로덕션 → 새 릴리스 만들기
   - `build/app/outputs/bundle/release/app-release.aab` 업로드
   - 릴리스 노트 작성 및 출시

### iOS 배포 (App Store)

1. **아카이브 생성** (Xcode 필요)

```bash
flutter build ios --release \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL=https://your-prod.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-prod-key
```

2. **Xcode에서 Archive 및 Upload**
   - Xcode에서 `ios/Runner.xcworkspace` 열기
   - Product → Archive
   - Distribute App → App Store Connect

### CI/CD를 통한 자동 배포

GitHub Actions가 설정되어 있습니다:

- **main 브랜치 푸시 시**: Android APK/AAB 및 iOS 빌드 자동 생성
- 빌드 결과는 GitHub Actions Artifacts에 저장됨

워크플로우: `.github/workflows/mobile.yml`

---

## 프로젝트 구조

```
mobile/
├── lib/
│   ├── core/                      # 핵심 기능
│   │   ├── config/                # 환경 설정
│   │   │   ├── env_config.dart    # 환경 변수 관리
│   │   │   └── supabase_config.dart
│   │   ├── theme/                 # 테마 및 디자인
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   ├── utils/                 # 유틸리티
│   │   │   ├── logger.dart
│   │   │   ├── memory_monitor.dart
│   │   │   └── list_optimization.dart
│   │   ├── constants/             # 상수
│   │   └── providers/             # 전역 Provider
│   │
│   ├── features/                  # 기능별 모듈
│   │   ├── splash/                # 스플래시 화면
│   │   ├── onboarding/            # 온보딩
│   │   ├── auth/                  # 인증
│   │   ├── home/                  # 홈
│   │   ├── creator/               # 크리에이터
│   │   ├── support/               # 후원
│   │   ├── message/               # 메시지
│   │   └── profile/               # 프로필
│   │
│   ├── shared/                    # 공유 컴포넌트
│   │   ├── widgets/               # 공용 위젯
│   │   ├── models/                # 공용 모델
│   │   └── providers/             # 공용 Provider
│   │
│   └── main.dart                  # 앱 엔트리 포인트
│
├── test/                          # 단위 및 위젯 테스트
│   ├── features/
│   ├── core/
│   └── README.md                  # 테스트 가이드
│
├── integration_test/              # 통합 테스트
│   └── app_test.dart
│
├── scripts/                       # 빌드/실행 스크립트
│   ├── run_dev.sh
│   ├── run_staging.sh
│   ├── run_prod.sh
│   └── build_apk.sh
│
├── android/                       # Android 네이티브 코드
├── ios/                           # iOS 네이티브 코드
├── assets/                        # 이미지, 폰트 등
├── .env.example                   # 환경 변수 예시
├── pubspec.yaml                   # 의존성 관리
├── PERFORMANCE.md                 # 성능 최적화 가이드
└── README.md                      # 본 문서
```

---

## 기술 스택

### 프레임워크
- **Flutter**: 3.27.0+
- **Dart**: 3.6.0+

### 상태 관리
- **Riverpod**: 3.1.0 (Notifier API)
- **riverpod_annotation**: 4.0.0

### 네비게이션
- **GoRouter**: 17.0.0

### 백엔드 & 인증
- **Supabase Flutter**: 2.3.0
  - PostgreSQL 데이터베이스
  - Realtime subscriptions
  - Row Level Security (RLS)
  - 소셜 로그인 (Google, Apple)

### 네트워크
- **Dio**: 5.4.0 (HTTP 클라이언트)
- **Retrofit**: 4.9.0 (REST API)

### 로컬 스토리지
- **SharedPreferences**: 2.2.2
- **Flutter Secure Storage**: 10.0.0

### UI 컴포넌트
- **Cached Network Image**: 3.3.0
- **Shimmer**: 3.0.0 (로딩 애니메이션)
- **FL Chart**: 1.1.0 (차트)
- **Table Calendar**: 3.0.9

### 결제
- **Flutter Stripe**: 12.1.1
- **In App Purchase**: 3.1.13

### 개발 도구
- **build_runner**: 2.4.7
- **freezed**: 3.2.3 (불변 모델)
- **json_serializable**: 6.7.1
- **mockito**: 5.4.3 (테스트 Mock)

### 성능 최적화
- RepaintBoundary를 활용한 리스트 최적화
- 이미지 캐시 관리
- Debouncing & Throttling
- 메모리 모니터링

자세한 성능 최적화 가이드는 [PERFORMANCE.md](PERFORMANCE.md)를 참조하세요.

---

## 코드 스타일

### Linting

프로젝트는 `flutter_lints` 6.0.0을 사용합니다.

```bash
# Lint 검사
flutter analyze

# 자동 포맷팅
dart format .
```

### 네이밍 컨벤션

- **파일**: `snake_case` (예: `home_screen.dart`)
- **클래스**: `PascalCase` (예: `HomeScreen`)
- **변수/함수**: `camelCase` (예: `userName`, `fetchData()`)
- **상수**: `lowerCamelCase` 또는 `UPPER_CASE` (예: `apiTimeout`, `MAX_RETRIES`)
- **Private**: `_`로 시작 (예: `_privateMethod`)

---

## 환경별 설정 요약

### Development
```bash
ENV=development
SUPABASE_URL=https://dev-xxx.supabase.co
SUPABASE_ANON_KEY=dev-key
STRIPE_KEY=pk_test_xxx
USE_MOCK=false
```

### Staging
```bash
ENV=staging
SUPABASE_URL=https://staging-xxx.supabase.co
SUPABASE_ANON_KEY=staging-key
STRIPE_KEY=pk_test_xxx
USE_MOCK=false
```

### Production
```bash
ENV=production
SUPABASE_URL=https://prod-xxx.supabase.co
SUPABASE_ANON_KEY=prod-key
STRIPE_KEY=pk_live_xxx
USE_MOCK=false
```

---

## 문제 해결

### "No such file or directory" 에러

```bash
# 의존성 재설치
flutter clean
flutter pub get
```

### 코드 생성 에러

```bash
# 빌드 캐시 삭제 후 재생성
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Android 빌드 실패

```bash
# Gradle 캐시 삭제
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### iOS 빌드 실패

```bash
# CocoaPods 재설치
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

---

## 기여 가이드

1. Feature 브랜치 생성
2. 코드 작성 및 테스트
3. Lint 및 Format 확인
4. PR 생성
5. CI/CD 통과 확인
6. 코드 리뷰 후 머지

---

## 라이선스

Copyright © 2024 PIPO. All rights reserved.

---

## 문의

- **이슈 제기**: [GitHub Issues](https://github.com/teo53/fansupport/issues)
- **기술 문서**: [Wiki](https://github.com/teo53/fansupport/wiki)

---

## 참고 자료

- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Riverpod 문서](https://riverpod.dev/)
- [Supabase 문서](https://supabase.com/docs)
- [GoRouter 문서](https://pub.dev/packages/go_router)
- [성능 최적화 가이드](PERFORMANCE.md)
- [테스트 가이드](test/README.md)

## CI/CD 상태

GitHub Actions를 통해 자동화된 CI/CD 파이프라인이 구축되어 있습니다.
