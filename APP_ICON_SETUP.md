# 📱 PIPO 앱 아이콘 설정 가이드

## 🎨 제공해주신 로고 사용하기

업로드하신 PIPO 로고 이미지 (Coral Pink 배경 + 흰색 PIPO 텍스트)를 앱 아이콘으로 사용하는 방법입니다.

## 📂 1단계: 이미지 파일 준비

### 필요한 파일:

1. **`app_icon.png`** (1024x1024)
   - 업로드하신 PIPO 로고 이미지
   - Coral Pink (#FF7169) 배경
   - 흰색 PIPO 텍스트

2. **`app_icon_foreground.png`** (1024x1024)
   - 투명 배경
   - 흰색 PIPO 텍스트만 (Android Adaptive Icon용)

### 파일 위치:
```
mobile/
└── assets/
    └── images/
        ├── app_icon.png           (1024x1024, 전체 아이콘)
        └── app_icon_foreground.png (1024x1024, 투명 배경 + 텍스트만)
```

## ⚙️ 2단계: 아이콘 생성

이미 pubspec.yaml에 설정이 추가되어 있습니다:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/app_icon.png"
  adaptive_icon_background: "#FF7169"  # Coral Pink
  adaptive_icon_foreground: "assets/images/app_icon_foreground.png"
  remove_alpha_ios: true
```

### 터미널에서 실행:

```bash
cd mobile

# 패키지 설치
flutter pub get

# 아이콘 생성
flutter pub run flutter_launcher_icons
```

이 명령어가 자동으로 다음을 생성합니다:
- ✅ Android: `android/app/src/main/res/mipmap-*/`
- ✅ iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- ✅ Android Adaptive Icons (배경 + 전경)

## 🎨 3단계: 이미지 준비 방법 (옵션)

업로드하신 이미지를 그대로 사용하시거나, 다음 도구로 준비 가능합니다:

### 온라인 도구:
1. **Canva**: https://www.canva.com
   - 1024x1024 캔버스 생성
   - 배경색: #FF7169 (Coral Pink)
   - 텍스트: "PIPO" (흰색, 굵은 글씨체)

2. **Figma**: https://www.figma.com
   - 벡터 기반 작업
   - Export as PNG (1024x1024)

### Foreground 이미지:
- 같은 이미지에서 배경만 제거
- 온라인 배경 제거 도구: https://www.remove.bg

## 🚀 4단계: 빌드 확인

```bash
# Android 빌드
flutter build apk --release

# iOS 빌드 (Mac에서만)
flutter build ios --release
```

## ✅ 완료!

- ✅ Android: Coral Pink 원형 + 사각형 아이콘
- ✅ iOS: 둥근 사각형 아이콘
- ✅ Adaptive Icons: 다양한 런처에서 완벽한 표시

## 💡 현재 설정

이미 다음이 설정되어 있습니다:
- ✅ `flutter_launcher_icons` 패키지 추가됨
- ✅ Coral Pink (#FF7169) 배경색 설정
- ✅ Android & iOS 자동 생성 설정

**이미지 파일만 추가하고 명령어를 실행하시면 됩니다!**

---

**Made with ❤️ by PIPO Team**
