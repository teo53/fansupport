# PIPO 런칭 체크리스트

## 🎯 런칭 목표

**목표일**: 2-3주 내 베타 런칭
**플랫폼**: Android (Google Play Store)
**타겟**: 지하 아이돌/메이드카페 팬 커뮤니티

---

## ✅ Phase 1: Supabase 백엔드 설정 (3-4일)

### Day 1: 프로젝트 생성 및 DB 마이그레이션

- [ ] Supabase 계정 생성 (https://app.supabase.com)
- [ ] 프로젝트 생성 (Region: Seoul)
- [ ] `/supabase_migration.sql` 실행
- [ ] 테이블 생성 확인 (14개 테이블)
- [ ] RLS 정책 활성화 확인
- [ ] Realtime 설정 확인

**테스트**:
```sql
-- users 테이블 확인
SELECT * FROM public.users LIMIT 1;

-- create_support Function 테스트
SELECT create_support(
  'test-receiver-id',
  5000,
  '테스트 후원',
  false
);
```

### Day 2: Storage 및 Auth 설정

- [ ] Storage Bucket 생성
  - [ ] `avatars` (프로필 이미지)
  - [ ] `idol-galleries` (갤러리)
  - [ ] `campaign-covers` (캠페인 커버)
- [ ] Storage RLS 정책 설정
- [ ] Email Auth 활성화
- [ ] Google OAuth 설정 (선택)
- [ ] Apple OAuth 설정 (선택)
- [ ] 테스트 계정 생성 및 로그인 테스트

### Day 3-4: 시드 데이터 & 테스트

- [ ] 테스트 아이돌 프로필 10개 생성
- [ ] 테스트 팬 계정 20개 생성
- [ ] 샘플 후원 데이터 생성
- [ ] 샘플 구독 티어 생성
- [ ] Realtime 기능 테스트

```sql
-- 샘플 아이돌 생성 (SQL Editor)
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data)
VALUES (
  'c8f8d8e8-1234-5678-9abc-def012345678',
  'idol1@test.com',
  crypt('password123', gen_salt('bf')),
  NOW(),
  '{"nickname":"사쿠라","role":"IDOL"}'::jsonb
);

INSERT INTO public.idol_profiles (user_id, stage_name, category)
VALUES ('c8f8d8e8-1234-5678-9abc-def012345678', '사쿠라', 'UNDERGROUND_IDOL');
```

---

## ✅ Phase 2: Flutter 앱 연동 (5-7일)

### Day 5: Supabase SDK 통합

- [ ] `pubspec.yaml`에 패키지 추가
  ```yaml
  dependencies:
    supabase_flutter: ^2.3.0
    flutter_stripe: ^10.1.0
  ```
- [ ] `flutter pub get` 실행
- [ ] `main.dart`에 Supabase 초기화 코드 추가
- [ ] `/mobile/lib/core/config/supabase_config.dart` 키 설정
- [ ] 앱 빌드 & 실행 확인

### Day 6-7: Auth 화면 연동

- [ ] 로그인 화면 SupabaseAuth 연동
- [ ] 회원가입 화면 연동
- [ ] 프로필 업데이트 기능 추가
- [ ] 소셜 로그인 딥링크 설정
- [ ] 로그아웃 기능 테스트

**파일 수정**:
- `/mobile/lib/features/auth/screens/login_screen.dart`
- `/mobile/lib/features/auth/screens/register_screen.dart`
- `/mobile/lib/features/auth/providers/auth_provider.dart` → **supabase_auth_provider.dart로 교체**

### Day 8-9: 후원 기능 구현

- [ ] SupportRepository 생성
- [ ] 후원 생성 API 연동
- [ ] 후원 내역 조회
- [ ] Top Supporters 표시
- [ ] Realtime 후원 알림

**파일 수정**:
- `/mobile/lib/features/support/screens/support_screen.dart`
- `/mobile/lib/features/support/repositories/` → **supabase_support_repository.dart 사용**

### Day 10-11: 지갑 & 결제 연동

- [ ] Wallet Repository 구현
- [ ] 잔액 조회 기능
- [ ] 거래 내역 표시
- [ ] Stripe SDK 통합 (다음 Phase)

---

## ✅ Phase 3: 결제 시스템 (4-5일)

### Stripe 설정

- [ ] Stripe 계정 생성 (https://dashboard.stripe.com)
- [ ] Test mode API 키 복사
- [ ] Flutter Stripe SDK 초기화
- [ ] Payment Intent 생성 테스트

### Vercel Edge Functions (Webhook)

- [ ] Vercel 계정 생성 (https://vercel.com)
- [ ] `/vercel` 폴더 생성
- [ ] `/vercel/api/stripe-webhook.ts` 작성
- [ ] `/vercel/api/create-payment-intent.ts` 작성
- [ ] Vercel 배포
- [ ] Stripe Webhook URL 등록

**Vercel 환경 변수**:
```
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGc...
```

### 결제 플로우 구현

- [ ] 지갑 충전 화면
- [ ] Stripe Payment Sheet 표시
- [ ] 결제 성공 처리
- [ ] Webhook 결제 확인
- [ ] 잔액 자동 업데이트

---

## ✅ Phase 4: 기능 완성 (3-4일)

### 구독 시스템

- [ ] 구독 티어 목록 조회
- [ ] 구독 생성 (결제 연동)
- [ ] 내 구독 목록
- [ ] 구독 취소 기능

### 캠페인 시스템

- [ ] 캠페인 목록 조회
- [ ] 캠페인 상세
- [ ] 펀딩 참여 (create_contribution Function)
- [ ] 진행률 표시

### 알림 시스템

- [ ] 알림 목록 조회
- [ ] Realtime 알림 구독
- [ ] 로컬 알림 (flutter_local_notifications)
- [ ] FCM 푸시 알림 (선택)

---

## ✅ Phase 5: 테스트 & 최적화 (3-4일)

### 기능 테스트

- [ ] 회원가입/로그인 플로우
- [ ] 후원 생성 & 확인
- [ ] 구독 결제 & 확인
- [ ] 지갑 충전 & 확인
- [ ] 캠페인 참여 & 확인
- [ ] 알림 수신 & 확인

### 성능 최적화

- [ ] 이미지 캐싱 (cached_network_image)
- [ ] 리스트 최적화 (ListView.builder)
- [ ] Realtime 구독 메모리 누수 체크
- [ ] 불필요한 rebuild 제거 (const 키워드)
- [ ] 로딩 상태 개선

### 에러 핸들링

- [ ] 네트워크 오류 처리
- [ ] 잔액 부족 오류
- [ ] 결제 실패 처리
- [ ] 권한 오류 (RLS)
- [ ] 사용자 친화적 에러 메시지

### 보안 점검

- [ ] RLS 정책 재확인
- [ ] API 키 환경 변수 처리
- [ ] SQL Injection 방지 (Supabase 자동)
- [ ] XSS 방지
- [ ] 민감 정보 로그 제거

---

## ✅ Phase 6: 배포 준비 (2-3일)

### Android 빌드 설정

- [ ] `build.gradle` 버전 확인
  - compileSdk: 36
  - minSdk: 24
  - targetSdk: 36
- [ ] ProGuard 설정 (Release)
- [ ] App 서명 키 생성
- [ ] `key.properties` 설정

### Google Play Console

- [ ] Google Play Console 계정 생성 ($25 등록비)
- [ ] 앱 등록
- [ ] 스토어 목록 작성
  - 앱 이름: PIPO
  - 설명: 지하 아이돌/메이드카페 팬 서포트 플랫폼
  - 스크린샷 준비 (5-8장)
  - 아이콘 (512x512)
- [ ] 개인정보처리방침 URL 작성
- [ ] 연령 등급 설정
- [ ] 카테고리 선택: 엔터테인먼트

### Release 빌드

- [ ] APK 빌드 테스트
  ```bash
  flutter build apk --release
  ```
- [ ] APK 파일 확인 (`build/app/outputs/flutter-apk/app-release.apk`)
- [ ] 실제 기기에서 설치 테스트
- [ ] 모든 기능 동작 확인

### AAB (App Bundle) 빌드

- [ ] AAB 빌드
  ```bash
  flutter build appbundle --release
  ```
- [ ] Google Play Console에 업로드
- [ ] 내부 테스트 트랙 설정
- [ ] 테스터 초대 (5-10명)
- [ ] 피드백 수집

---

## ✅ Phase 7: 베타 테스트 (1-2주)

### 내부 테스트

- [ ] 테스터 그룹 생성 (친구, 지인)
- [ ] 테스트 계정 제공
- [ ] 버그 리포트 수집 (Google Forms)
- [ ] 긴급 버그 수정

### 피드백 반영

- [ ] UX 개선사항 정리
- [ ] 우선순위 분류
- [ ] P0 이슈 즉시 수정
- [ ] P1 이슈 다음 버전 반영

---

## ✅ Phase 8: 정식 출시 (1일)

### 최종 체크

- [ ] 모든 기능 테스트 통과
- [ ] 스토어 목록 최종 확인
- [ ] 개인정보처리방침 최종 확인
- [ ] 이용약관 확인
- [ ] 고객 지원 연락처 설정

### 출시

- [ ] Google Play Console > Production 트랙 출시
- [ ] 출시 노트 작성
- [ ] 출시 승인 대기 (보통 1-3일)
- [ ] 출시 완료 확인

### 모니터링

- [ ] Supabase Dashboard에서 API 사용량 확인
- [ ] Stripe Dashboard에서 결제 확인
- [ ] Google Play Console에서 다운로드/리뷰 확인
- [ ] 에러 로그 모니터링

---

## 📊 주요 지표 (KPI)

### 런칭 첫 주 목표

- [ ] 앱 다운로드: 100+
- [ ] 회원가입: 50+
- [ ] 첫 후원: 10+
- [ ] 평균 별점: 4.0+

### 첫 달 목표

- [ ] 월간 활성 사용자: 500+
- [ ] 총 후원 금액: ₩500,000+
- [ ] 구독자: 50+
- [ ] 리텐션: 30%+

---

## 💰 예산 계획

### 초기 비용 (1회)

| 항목 | 비용 |
|------|------|
| Google Play 개발자 등록 | $25 (₩33,000) |
| 도메인 (선택) | $12/년 |
| **총합** | **₩33,000-48,000** |

### 월간 운영 비용

| 항목 | Free Tier | 예상 비용 (100 DAU) |
|------|-----------|---------------------|
| Supabase | ✅ | $0-25 |
| Vercel | ✅ | $0 |
| Stripe 수수료 | - | 거래당 2.9% + $0.30 |
| **총합** | - | **₩50,000-100,000** |

---

## 🆘 트러블슈팅

### "Supabase connection failed"

1. `supabase_config.dart`에서 URL/Key 재확인
2. 네트워크 연결 확인
3. Supabase Dashboard > Health Check

### "Row Level Security policy violated"

1. 로그인 상태 확인
2. Table Editor > Policies에서 정책 재확인
3. SQL Editor에서 수동 쿼리 테스트

### "Payment failed"

1. Stripe Dashboard > Logs 확인
2. Webhook URL 정상 동작 확인
3. Vercel Function 로그 확인

### APK 빌드 실패

1. `flutter clean` 실행
2. `flutter pub get` 재실행
3. Gradle 버전 확인
4. ProGuard 규칙 확인

---

## 📞 지원 연락처

### Supabase Support
- Discord: https://discord.supabase.com
- Docs: https://supabase.com/docs

### Stripe Support
- Support: https://support.stripe.com
- Docs: https://stripe.com/docs

### Flutter Support
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- Discord: https://discord.gg/flutter

---

## 🎉 출시 후 로드맵

### v1.1 (1개월 후)

- [ ] iOS 버전 출시
- [ ] 라이브 방송 기능
- [ ] Bubble 메시징
- [ ] 포토카드 교환

### v1.2 (2개월 후)

- [ ] AI 추천 시스템
- [ ] 게임화 (레벨, 뱃지)
- [ ] 소셜 기능 강화
- [ ] 다국어 지원 (영어, 일본어)

### v2.0 (3개월 후)

- [ ] 라이브 커머스
- [ ] NFT 포토카드
- [ ] 메타버스 팬미팅
- [ ] 크리에이터 대시보드
