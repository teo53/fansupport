# 환경 설정 가이드

## 개요

PIPO 앱은 3가지 환경을 지원합니다:
- **Development**: 로컬 개발 및 테스트 환경
- **Staging**: QA 및 테스트 배포 환경
- **Production**: 실제 서비스 환경

## 설정 방법

### 1. Supabase 프로젝트 설정

각 환경별로 Supabase 프로젝트를 생성합니다:

1. https://app.supabase.com 에서 프로젝트 생성
2. Project Settings > API 메뉴에서 다음 정보 복사:
   - Project URL
   - Anon/Public Key

### 2. 환경 변수 설정

`scripts/` 폴더의 실행 스크립트를 수정합니다:

#### Development: `scripts/run_dev.sh`
```bash
--dart-define=SUPABASE_URL_DEV="https://your-dev-project.supabase.co"
--dart-define=SUPABASE_ANON_KEY_DEV="your-dev-anon-key"
```

#### Staging: `scripts/run_staging.sh`
```bash
--dart-define=SUPABASE_URL_STAGING="https://your-staging-project.supabase.co"
--dart-define=SUPABASE_ANON_KEY_STAGING="your-staging-anon-key"
```

#### Production: `scripts/run_prod.sh`
```bash
--dart-define=SUPABASE_URL="https://your-production-project.supabase.co"
--dart-define=SUPABASE_ANON_KEY="your-production-anon-key"
```

## 실행 방법

### 앱 실행

```bash
# Development 환경
./scripts/run_dev.sh

# Staging 환경
./scripts/run_staging.sh

# Production 환경
./scripts/run_prod.sh
```

### APK 빌드

```bash
# Development APK
./scripts/build_apk.sh dev

# Staging APK
./scripts/build_apk.sh staging

# Production APK
./scripts/build_apk.sh prod
```

## 환경별 특성

### Development
- **디버그 로그**: 활성화
- **Mock 데이터**: 사용 가능 (`USE_MOCK=true`)
- **API 타임아웃**: 30초
- **재시도 횟수**: 5회
- **캐시 크기**: 50개
- **캐시 유지**: 5분

### Staging
- **디버그 로그**: 활성화
- **Mock 데이터**: 비활성화
- **API 타임아웃**: 20초
- **재시도 횟수**: 3회
- **캐시 크기**: 100개
- **캐시 유지**: 15분

### Production
- **디버그 로그**: 비활성화
- **크래시 리포팅**: 활성화
- **성능 모니터링**: 활성화
- **API 타임아웃**: 15초
- **재시도 횟수**: 2회
- **캐시 크기**: 200개
- **캐시 유지**: 1시간

## 코드에서 사용하기

### 환경 확인

```dart
import 'package:idol_support/core/config/environment.dart';

if (EnvironmentConfig.isDevelopment) {
  print('Development mode');
}

if (EnvironmentConfig.isProduction) {
  // Production-only code
}
```

### 환경별 설정 사용

```dart
// Supabase 설정 자동 적용
final url = SupabaseConfig.url; // 현재 환경에 맞는 URL 반환

// 기능 플래그
if (EnvironmentConfig.enableLogging) {
  print('Logging enabled');
}

// API 설정
final timeout = EnvironmentConfig.apiTimeout;
final maxRetries = EnvironmentConfig.maxRetries;

// 캐시 설정
final cacheSize = EnvironmentConfig.cacheSize;
final cacheDuration = EnvironmentConfig.cacheDuration;
```

### Mock 데이터 사용

Development 환경에서만 Mock 데이터를 사용하려면:

```bash
./scripts/run_dev.sh
```

스크립트 내부의 `USE_MOCK=true` 설정으로 자동으로 활성화됩니다.

## 주의사항

⚠️ **보안**
- 프로덕션 키는 절대 Git에 커밋하지 마세요
- `.env` 파일은 `.gitignore`에 추가되어 있습니다
- 실제 키는 스크립트 파일에만 저장하고, 안전하게 관리하세요

⚠️ **환경 분리**
- 각 환경은 독립된 Supabase 프로젝트를 사용하세요
- Development/Staging에서 Production 데이터에 접근하지 마세요

⚠️ **테스트**
- 새로운 기능은 Development -> Staging -> Production 순으로 배포하세요
- Staging 환경에서 충분한 테스트 후 Production 배포하세요

## 트러블슈팅

### "Invalid Supabase URL" 오류
- 스크립트 파일의 URL이 올바른지 확인
- URL 끝에 `/`가 없는지 확인

### Mock 데이터가 표시되지 않음
- `USE_MOCK=true` 설정 확인
- Development 환경인지 확인

### 환경이 올바르게 적용되지 않음
```bash
# 환경 변수 출력 확인
flutter run --dart-define=ENV=development --verbose
```
