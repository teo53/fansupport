# 🌐 PIPO 앱 웹 테스트 가이드

## 📱 PC에서 앱 테스트하기

### 방법 1: Flutter Web (권장 ⭐)

#### 1-1. 개발 서버 실행
```bash
cd mobile
flutter run -d chrome
```
- 자동으로 Chrome 브라우저가 열립니다
- Hot Reload 지원으로 실시간 수정 가능
- 개발자 도구로 모바일 화면 시뮬레이션 가능

#### 1-2. 릴리즈 빌드 실행
```bash
cd mobile
flutter build web --release
cd build/web
python -m http.server 8000
```
- 브라우저에서 `http://localhost:8000` 접속

### 방법 2: Chrome 개발자 도구로 모바일 시뮬레이션

1. Chrome 개발자 도구 열기 (F12)
2. 디바이스 툴바 토글 (Ctrl + Shift + M)
3. 디바이스 선택:
   - **iPhone 14 Pro Max** (430 x 932)
   - **Galaxy S23 Ultra** (412 x 915)
   - **Pixel 7** (412 x 915)

### 방법 3: Windows 데스크톱 앱으로 실행

```bash
cd mobile
flutter run -d windows
```
- 네이티브 Windows 앱으로 실행
- 크기 조절 가능한 창

---

## 🎯 테스트할 주요 기능

### ✅ 1. 로그인 화면
- **애니메이션**: 페이드 & 슬라이드 효과 확인
- **"PIPO" 로고**: Coral Pink 그라데이션 확인
- **데모 로그인**: "데모 계정으로 체험하기" 버튼 클릭
  - 팬/아이돌/소속사 선택 모달 확인
  - **팬 체험** 선택

### ✅ 2. 홈 화면
- **Story Section**:
  - 첫 번째 아이돌에 **"SOON"** 오렌지 배지 확인
  - 클릭 시 → **"라이브 기능 준비 중"** 다이얼로그 팝업
- **다이얼로그 확인사항**:
  - 오렌지 그라데이션 비디오 아이콘
  - "출시 예정 기능" 목록 (스트리밍, 채팅, 하트)
  - **"알림 받기"** 버튼 클릭 시 성공 SnackBar

### ✅ 3. 홈 화면 전체 섹션
- Story Section (Live 아이돌들)
- Quick Actions (멤버십, Bubble, 피드, 스케줄)
- 인기 아이돌 (Photocard 스타일)
- **인기 펀딩** (캠페인 카드)
- **스페셜 이벤트** (VIP 팬미팅, 1:1 영상통화)
- 카테고리 (지하돌, 메이드카페 등)
- 최근 소식 (커뮤니티 포스트)

### ✅ 4. Bubble 스타일 확인
- Coral Pink 색상 (#FF7169)
- 큰 타이포그래피 (32px 제목)
- 둥근 모서리 (20-24px)
- 부드러운 그림자 효과

---

## 🖥️ 브라우저에서 모바일 화면 비율 설정

### Chrome DevTools 단축키
1. `F12` - 개발자 도구 열기
2. `Ctrl + Shift + M` - 디바이스 모드
3. 화면 비율 선택:
   ```
   - Responsive (커스텀 크기)
   - iPhone 14 Pro Max (430 x 932)
   - iPad Air (820 x 1180)
   ```

### 추천 설정
```
Width: 430px (iPhone 14 Pro Max)
Height: 932px
Pixel Ratio: 3
User Agent: iPhone
```

---

## 📸 스크린샷 테스트

### 1. 로그인 화면
- PIPO 로고와 그라데이션
- 데모 로그인 버튼

### 2. 데모 계정 선택 모달
- 팬/아이돌/소속사 카드
- Bubble 스타일 디자인

### 3. 홈 화면
- Story Section with SOON 배지
- 모든 섹션이 표시되는지 확인

### 4. 라이브 준비 중 다이얼로그
- 오렌지 그라데이션 아이콘
- 출시 예정 기능 목록
- 알림 받기 버튼

---

## 🐛 문제 해결

### "Connection refused" 오류
```bash
# Flutter 웹 서버가 실행 중인지 확인
flutter run -d chrome
```

### 빌드 오류
```bash
# 캐시 클리어 후 재빌드
flutter clean
flutter pub get
flutter build web --release
```

### 화면이 깨져 보임
- 브라우저 줌 100%로 설정
- Chrome DevTools에서 디바이스 픽셀 비율 확인

---

## 🎨 Bubble 스타일 체크리스트

- [ ] Coral Pink 메인 컬러 (#FF7169)
- [ ] 큰 타이포그래피 (헤더 32px+)
- [ ] 둥근 모서리 (20-24px radius)
- [ ] 넓은 패딩 (18-20px)
- [ ] 부드러운 그림자
- [ ] 그라데이션 버튼
- [ ] 애니메이션 효과

---

## 📞 빠른 테스트 순서

1. **웹 서버 실행**
   ```bash
   cd mobile
   flutter run -d chrome
   ```

2. **브라우저에서 F12 → Ctrl+Shift+M**

3. **디바이스: iPhone 14 Pro Max 선택**

4. **테스트 시나리오**:
   - 로그인 화면 확인
   - "데모 계정으로 체험하기" 클릭
   - "팬 체험" 선택
   - 홈 화면 로드 확인
   - **첫 번째 Story (SOON 배지) 클릭**
   - **"라이브 기능 준비 중" 다이얼로그 확인**
   - "알림 받기" 클릭
   - 성공 메시지 확인

---

## 🎯 핵심 확인 사항

### ✅ LIVE 기능이 "준비 중"으로 표시되는가?
- Story Circle에 "SOON" 오렌지 배지
- 클릭 시 안내 다이얼로그

### ✅ 사용자가 기대감을 느끼는가?
- "출시 예정 기능" 목록
- "알림 받기" 액션

### ✅ Bubble 스타일이 일관되는가?
- 전체적으로 Coral Pink
- 둥근 모서리와 부드러운 느낌

---

## 💡 추가 팁

### Hot Reload (개발 서버 실행 시)
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

### 성능 최적화
```bash
# 릴리즈 모드로 빌드 (최적화됨)
flutter build web --release --web-renderer canvaskit
```

### 다크 모드 테스트
- Chrome DevTools → Rendering → Emulate CSS media feature prefers-color-scheme: dark

---

## 🚀 배포 준비

웹 빌드 완료 후:
```bash
cd mobile/build/web
# 정적 파일 서버로 배포 가능
# - Netlify
# - Vercel
# - Firebase Hosting
# - GitHub Pages
```

---

**Made with ❤️ by PIPO Team**
