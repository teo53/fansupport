# 🔥 Firebase 설정 가이드

## 📋 개요

PIPO 앱은 다음 Firebase 서비스를 사용합니다:
- **Firebase Cloud Messaging (FCM)**: Push 알림
- **Firebase Analytics** (선택): 사용자 분석
- **Firebase Crashlytics** (선택): 크래시 리포팅

---

## 🚀 설정 단계

### 1️⃣ Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름: **PIPO** 또는 원하는 이름
4. Google Analytics 활성화 (선택사항)

---

### 2️⃣ Flutter 앱 등록

#### Android 앱 등록

1. Firebase Console → 프로젝트 → Android 아이콘 클릭
2. Android 패키지 이름: `com.idolsupport.pipo` (또는 `pubspec.yaml` 참고)
3. `google-services.json` 다운로드
4. 파일 위치: `/mobile/android/app/google-services.json`

#### iOS 앱 등록

1. Firebase Console → 프로젝트 → iOS 아이콘 클릭
2. iOS 번들 ID: `com.idolsupport.pipo`
3. `GoogleService-Info.plist` 다운로드
4. Xcode에서 `Runner` 프로젝트에 추가

---

### 3️⃣ Firebase CLI 설정

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# Flutter 프로젝트 디렉토리로 이동
cd /home/user/fansupport/mobile

# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 초기화
flutterfire configure
```

**선택사항:**
- 프로젝트: PIPO (또는 생성한 프로젝트)
- 플랫폼: Android, iOS 선택
- 자동으로 `firebase_options.dart` 생성됨

---

### 4️⃣ Android 설정

#### `android/build.gradle`

```gradle
buildscript {
    dependencies {
        // Firebase
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### `android/app/build.gradle`

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // ✅ 추가
}

android {
    defaultConfig {
        minSdkVersion 21  // ✅ FCM 최소 버전
    }
}
```

#### `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />  <!-- ✅ Android 13+ -->

    <application>
        <!-- FCM Default Channel -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="pipo_high_importance" />

        <!-- FCM Icon -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />
    </application>
</manifest>
```

---

### 5️⃣ iOS 설정

#### `ios/Runner/Info.plist`

```xml
<dict>
    <!-- Push Notifications -->
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
    </array>
</dict>
```

#### Xcode 설정

1. Xcode에서 `ios/Runner.xcworkspace` 열기
2. Runner → Signing & Capabilities
3. "+ Capability" 클릭
4. "Push Notifications" 추가
5. "Background Modes" 추가 → "Remote notifications" 체크

---

### 6️⃣ main.dart 업데이트 (이미 완료됨)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM Service
  await FCMService().initialize();

  runApp(const ProviderScope(child: IdolSupportApp()));
}
```

---

## 🧪 테스트

### FCM 토큰 확인

앱 실행 시 로그 확인:
```
✅ Firebase initialized successfully
✅ FCM Service initialized successfully
📱 FCM Token: <토큰값>
```

### 테스트 알림 전송

Firebase Console → Cloud Messaging → 새 알림:
1. 알림 제목: "테스트"
2. 알림 텍스트: "PIPO 알림 테스트"
3. 타겟: FCM 토큰 (위에서 확인한 토큰)
4. 전송!

---

## 📌 주의사항

### Android
- `minSdkVersion 21` 이상 필요
- `google-services.json` 파일 **절대** git에 커밋하지 말 것 (`.gitignore`에 추가됨)
- ProGuard 사용 시 Firebase rules 추가

### iOS
- Xcode에서 Signing 설정 필요
- APNs 인증 키 Firebase Console에 업로드 필요
- `GoogleService-Info.plist` **절대** git에 커밋하지 말 것

---

## 🔧 트러블슈팅

### "MissingPluginException"
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd ios && pod install
flutter run
```

### "FirebaseApp not initialized"
- `main.dart`에서 `Firebase.initializeApp()` 호출 확인
- `firebase_options.dart` 생성 확인 (`flutterfire configure`)

### FCM 토큰 null
- 인터넷 연결 확인
- Google Play Services 설치 확인 (Android)
- 앱 재시작

---

## 📚 참고 문서

- [FlutterFire 공식 문서](https://firebase.flutter.dev/)
- [FCM 설정 가이드](https://firebase.google.com/docs/cloud-messaging/flutter/client)
- [Firebase Console](https://console.firebase.google.com/)
