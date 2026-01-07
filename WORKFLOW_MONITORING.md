# 🔍 GitHub Actions APK 빌드 모니터링 가이드

## ✅ 워크플로우 트리거 완료!

변경사항이 `claude/project-review-IlFoF` 브랜치에 푸시되었습니다.
GitHub Actions가 자동으로 APK 빌드를 시작했습니다!

---

## 📊 실시간 모니터링 방법

### 1. GitHub Actions 페이지로 이동

```
https://github.com/teo53/fansupport/actions
```

또는:
```
https://github.com/teo53/fansupport/actions/workflows/build-apk.yml
```

### 2. 최근 워크플로우 실행 확인

- **"Build APK"** 워크플로우를 찾습니다
- 가장 위에 있는 실행이 현재 진행 중인 빌드입니다
- 아이콘으로 상태 확인:
  - 🟡 노란색 점: 진행 중
  - ✅ 초록색 체크: 성공
  - ❌ 빨간색 X: 실패

### 3. 상세 로그 확인

1. 실행 중인 워크플로우를 클릭
2. "Build APK" Job 클릭
3. 각 단계별 로그 확인:
   - **Setup Java** - Java 17 설치
   - **Setup Flutter** - Flutter Beta 설치
   - **Install dependencies** - `flutter pub get`
   - **Generate code** - `build_runner` 실행
   - **Build APK** - APK 빌드 (약 3-5분 소요)
   - **Upload APK** - 아티팩트 업로드

---

## ⏱️ 예상 빌드 시간

| 단계 | 소요 시간 |
|------|-----------|
| Setup Java & Flutter | 1-2분 |
| Install dependencies | 30초-1분 |
| Generate code | 30초-1분 |
| **Build APK** | **3-5분** |
| Upload APK | 10-30초 |
| **전체** | **5-10분** |

---

## 🎯 APK 다운로드 방법

### 빌드 성공 후:

1. 워크플로우 실행 페이지 하단으로 스크롤
2. **"Artifacts"** 섹션 찾기
3. **`app-debug-apk`** 다운로드 (ZIP 파일)
4. ZIP 압축 해제하면 APK 파일이 나옵니다

### APK 설치:

```bash
# Android 기기에 파일 전송 후
adb install app-debug.apk

# 또는 기기에서 직접 APK 파일을 열어서 설치
```

**주의:** Debug APK는 "알 수 없는 출처" 설치를 허용해야 합니다.

---

## 🐛 자주 발생하는 에러와 해결 방법

### 1. ❌ `build_runner` 에러

**증상:**
```
[ERROR] Conflicting outputs were detected...
```

**해결:**
워크플로우에 이미 `--delete-conflicting-outputs` 플래그가 포함되어 있습니다.
이 에러는 자동으로 해결됩니다.

---

### 2. ❌ Gradle Build 실패

**증상:**
```
FAILURE: Build failed with an exception.
```

**확인 사항:**
1. `mobile/android/app/build.gradle` 확인
2. `compileSdkVersion`이 최신인지 확인 (권장: 34)
3. `minSdkVersion`과 `targetSdkVersion` 확인

**일반적인 원인:**
- 의존성 버전 충돌
- Android SDK 버전 불일치
- 메모리 부족

---

### 3. ❌ Flutter Version 에러

**증상:**
```
The current Flutter SDK version is X.Y.Z
```

**확인:**
워크플로우는 **Flutter Beta** 채널을 사용합니다.
`mobile/pubspec.yaml`의 Flutter SDK 버전 요구사항을 확인하세요.

---

### 4. ❌ Dependency Resolution 에러

**증상:**
```
Because package A depends on B...
version solving failed
```

**해결:**
1. `mobile/pubspec.yaml` 확인
2. 충돌하는 패키지 버전 조정
3. 필요시 `dependency_overrides` 사용

---

### 5. ❌ Code Generation 에러

**증상:**
```
[SEVERE] Missing required dependencies
```

**확인:**
1. `mobile/pubspec.yaml`에 `build_runner` 포함 확인
2. `freezed`, `json_serializable` 등 코드 생성 패키지 확인
3. 어노테이션이 올바르게 작성되었는지 확인

---

## 🔧 워크플로우 로그 분석 팁

### 중요한 로그 패턴:

#### ✅ 성공 시그널:
```
✓ Built build/app/outputs/flutter-apk/app-debug.apk (XX.XMB)
```

#### ⚠️ 경고 (무시 가능):
```
Warning: The plugin `xxx` requires a higher Android SDK version
```
→ 일반적으로 빌드는 계속 진행됩니다.

#### ❌ 치명적 에러:
```
FAILURE: Build failed with an exception
Error: Gradle task assembleDebug failed
```
→ 이 경우 상세 로그를 확인하여 원인 파악이 필요합니다.

---

## 📋 실시간 상태 확인 (터미널에서)

GitHub CLI 설치 시:

```bash
# 워크플로우 실행 목록
gh run list --workflow=build-apk.yml --branch=claude/project-review-IlFoF

# 특정 실행 상태 확인
gh run view <run-id>

# 실시간 로그 확인
gh run watch <run-id>

# 아티팩트 다운로드
gh run download <run-id>
```

---

## 🎉 빌드 성공 후 다음 단계

### 1. APK 테스트
- 실제 Android 기기에 설치
- 주요 기능 테스트
- 크래시 및 버그 확인

### 2. Release APK 빌드 (배포용)

수동 실행:
1. GitHub Actions 페이지로 이동
2. "Build APK" 워크플로우 선택
3. "Run workflow" 클릭
4. Build type: **`release`** 선택
5. 실행

### 3. 앱 번들 생성 (Google Play 배포용)

```bash
flutter build appbundle --release
```

---

## 📱 현재 설정 요약

- **브랜치:** `claude/project-review-IlFoF`
- **워크플로우:** `.github/workflows/build-apk.yml`
- **자동 트리거:** `mobile/**` 파일 변경 시
- **기본 빌드 타입:** `debug`
- **아티팩트 보관:** 30일

---

## 🆘 추가 도움이 필요한 경우

1. **워크플로우 로그 전체 복사**
2. **에러 메시지 정확히 확인**
3. **관련 파일 수정 필요 시 알려주세요**

---

**현재 상태:** 🚀 APK 빌드가 진행 중입니다!

**Actions 페이지:** https://github.com/teo53/fansupport/actions

**완료 예상 시간:** 약 5-10분
