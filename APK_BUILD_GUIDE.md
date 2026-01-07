# PIPO APK 빌드 가이드

## 방법 1: GitHub Actions 사용 (권장)

프로젝트에 이미 APK 자동 빌드 워크플로우가 설정되어 있습니다.

### 단계:

1. **GitHub 저장소로 이동**
   ```
   https://github.com/teo53/fansupport
   ```

2. **Actions 탭 클릭**

3. **"Build APK (Manual)" 워크플로우 선택**

4. **"Run workflow" 버튼 클릭**

5. **빌드 타입 선택:**
   - `release`: 배포용 APK (앱 스토어 출시용)
   - `debug`: 테스트용 APK (개발/테스트용)

6. **"Run workflow" 확인**

7. **빌드 완료 후 (약 5-10분):**
   - 워크플로우 실행 결과로 이동
   - "Artifacts" 섹션에서 APK 다운로드
   - 파일명: `app-release-apk` 또는 `app-debug-apk`

### 워크플로우 설정 파일 위치:
```
.github/workflows/build-apk.yml
```

---

## 방법 2: 로컬 빌드 (Flutter 설치 필요)

### 사전 요구사항:
- Flutter SDK (beta 채널)
- Java 17
- Android SDK

### 빌드 명령어:

```bash
# 프로젝트 디렉토리로 이동
cd mobile

# 의존성 설치
flutter pub get

# 코드 생성
dart run build_runner build --delete-conflicting-outputs

# Release APK 빌드
flutter build apk --release

# 또는 Debug APK 빌드
flutter build apk --debug
```

### APK 파일 위치:
```
mobile/build/app/outputs/flutter-apk/app-release.apk
또는
mobile/build/app/outputs/flutter-apk/app-debug.apk
```

---

## APK 파일 크기 최적화 팁

### 1. 앱 번들 사용 (Google Play 배포 시):
```bash
flutter build appbundle --release
```
위치: `mobile/build/app/outputs/bundle/release/app-release.aab`

### 2. 특정 CPU 아키텍처만 빌드:
```bash
# ARM 64비트만 (대부분의 최신 기기)
flutter build apk --release --target-platform android-arm64

# 여러 아키텍처별로 분리 빌드 (파일 크기 감소)
flutter build apk --release --split-per-abi
```

### 3. 난독화 적용 (보안 강화):
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

---

## 현재 프로젝트 설정

### 앱 정보:
- **앱 이름:** PIPO (Fan Support Platform)
- **패키지명:** `com.idolsupport.idol_support`
- **Flutter 버전:** beta 채널

### 빌드 구성:
- 코드 생성: `build_runner` 사용
- 상태 관리: Riverpod
- 라우팅: go_router
- API 통신: dio
- 캐싱: flutter_cache_manager

---

## 문제 해결

### "build_runner 에러"
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### "Android SDK 에러"
```bash
flutter doctor -v
```
위 명령으로 누락된 요구사항 확인 후 설치

### "서명 에러" (Release 빌드 시)
`mobile/android/app/build.gradle`에서 서명 설정 확인

---

## 권장 방법

**개발/테스트:** GitHub Actions로 debug APK 빌드
**배포:** GitHub Actions로 release AAB 빌드

GitHub Actions를 사용하면:
- ✅ 환경 설정 불필요
- ✅ 일관된 빌드 환경
- ✅ 빌드 히스토리 관리
- ✅ 자동화된 워크플로우
- ✅ 30일간 아티팩트 보관

---

**더 도움이 필요하시면 말씀해주세요!**
