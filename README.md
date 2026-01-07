# 아이돌 서포트 (Idol Support Platform)

지하 아이돌과 메이드카페 팬덤을 위한 후원 플랫폼

## 프로젝트 구조

```
지하돌 후원 어플/
├── backend/          # NestJS Backend API
├── mobile/           # Flutter Mobile App
├── web/              # Next.js Landing Page
├── docs/             # Documentation
├── scripts/          # Utility scripts
└── .github/          # GitHub Actions CI/CD
```

## 주요 기능

### 팬 기능
- 아이돌/메이드 후원 (익명 가능)
- 구독 멤버십 (티어별 혜택)
- 크라우드 펀딩 참여
- 메이드카페 예약
- 커뮤니티 피드

### 아이돌/메이드 기능
- 프로필 관리
- 구독 티어 설정
- 펀딩 캠페인 생성
- 팬 메시지 확인
- 수익 정산

## 기술 스택

### Backend
- **Framework**: NestJS (Node.js)
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Authentication**: JWT + OAuth2 (Google, Apple, Kakao)
- **Payment**: Stripe, Google Play, App Store
- **Documentation**: Swagger/OpenAPI

### Mobile
- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: Go Router
- **HTTP Client**: Dio + Retrofit
- **Storage**: Secure Storage + Shared Preferences

### Web Landing
- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS
- **Animation**: Framer Motion
- **Icons**: Lucide React

## 최근 개선사항 (2025-01)

### 🔴 P0 - 프로덕션 준비성 향상
- **Backend 트랜잭션 처리**: 후원/구독/지갑 결제 시 데이터 일관성 보장 (Prisma $transaction)
- **Rate Limiting**: 전역 ThrottlerGuard 적용 (기본: 60초당 100회)
- **N+1 쿼리 최적화**: getTopSupporters 메서드 성능 개선
- **Flutter 에러 핸들링**: 타입별 예외 클래스 + 한국어 사용자 메시지

### 🟢 빌드 안정성
- **Kotlin 2.1.0 업그레이드**: Stripe Android SDK 호환성 해결
- **Gradle 8.12 + AGP 8.9.1**: 최신 빌드 도구 체인
- **compileSdk 36**: androidx 라이브러리 요구사항 충족
- **GitHub Actions 디스크 공간 최적화**: APK 빌드 성공

### 📚 문서화
- Backend/Mobile README 업데이트
- 환경 변수 설명 보강 (.env.example)
- 트러블슈팅 가이드 추가

## 시작하기

### 요구사항
- Node.js 20+
- Flutter 3.16+
- PostgreSQL 15+
- Docker (선택사항)

### Backend 설정

```bash
cd backend

# 의존성 설치
npm install

# 환경변수 설정
cp .env.example .env
# .env 파일을 수정하여 DB 연결 정보 등 입력

# Prisma 클라이언트 생성
npx prisma generate

# 데이터베이스 마이그레이션
npx prisma db push

# 개발 서버 실행
npm run start:dev
```

API 문서: http://localhost:3000/docs

### Mobile 설정

```bash
cd mobile

# 의존성 설치
flutter pub get

# iOS 설정 (macOS만 해당)
cd ios && pod install && cd ..

# 앱 실행
flutter run
```

### Web 설정

```bash
cd web

# 의존성 설치
npm install

# 개발 서버 실행
npm run dev
```

웹사이트: http://localhost:3001

## API 엔드포인트

### 인증 (Auth)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | 회원가입 |
| POST | /api/auth/login | 로그인 |
| POST | /api/auth/refresh | 토큰 갱신 |
| POST | /api/auth/logout | 로그아웃 |
| GET | /api/auth/google | Google OAuth |

### 사용자 (Users)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/users/me | 내 프로필 조회 |
| PUT | /api/users/me | 프로필 수정 |
| GET | /api/users/idols | 아이돌 목록 |
| GET | /api/users/idols/ranking | 랭킹 조회 |
| POST | /api/users/idol-profile | 아이돌 프로필 생성 |

### 지갑 (Wallet)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/wallet | 지갑 조회 |
| GET | /api/wallet/balance | 잔액 조회 |
| GET | /api/wallet/transactions | 거래 내역 |

### 후원 (Support)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/support | 후원하기 |
| GET | /api/support/sent | 보낸 후원 내역 |
| GET | /api/support/received | 받은 후원 내역 |
| GET | /api/support/top-supporters/:id | 탑 서포터 |

### 구독 (Subscription)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/subscriptions/tiers | 티어 생성 |
| GET | /api/subscriptions/tiers/:id | 티어 조회 |
| POST | /api/subscriptions | 구독하기 |
| DELETE | /api/subscriptions/:id | 구독 취소 |
| GET | /api/subscriptions/my-subscriptions | 내 구독 목록 |

### 캠페인 (Campaign)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/campaigns | 캠페인 생성 |
| GET | /api/campaigns | 캠페인 목록 |
| GET | /api/campaigns/:id | 캠페인 상세 |
| POST | /api/campaigns/:id/contribute | 펀딩 참여 |

### 예약 (Booking)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/bookings | 예약 생성 |
| GET | /api/bookings | 내 예약 목록 |
| GET | /api/bookings/available-slots | 예약 가능 시간 |
| DELETE | /api/bookings/:id | 예약 취소 |

### 커뮤니티 (Community)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/community/posts | 게시글 작성 |
| GET | /api/community/posts | 게시글 목록 |
| GET | /api/community/feed | 피드 조회 |
| POST | /api/community/posts/:id/like | 좋아요 |
| POST | /api/community/posts/:id/comments | 댓글 작성 |

### 결제 (Payment)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/payments/create-intent | 결제 의도 생성 |
| POST | /api/payments/webhook/stripe | Stripe 웹훅 |
| POST | /api/payments/verify-iap | IAP 검증 |

## 데이터베이스 스키마

주요 테이블:
- `User` - 사용자 정보
- `IdolProfile` - 아이돌/메이드 프로필
- `Wallet` - 지갑
- `Transaction` - 거래 내역
- `Support` - 후원 내역
- `Subscription` - 구독 정보
- `SubscriptionTier` - 구독 티어
- `Campaign` - 펀딩 캠페인
- `CampaignContribution` - 펀딩 참여
- `Booking` - 예약 정보
- `Post` - 커뮤니티 게시글
- `Comment` - 댓글
- `Like` - 좋아요
- `Notification` - 알림
- `Payment` - 결제 정보

## 테스트

### Backend 테스트
```bash
cd backend

# 단위 테스트
npm run test

# E2E 테스트
npm run test:e2e

# 커버리지
npm run test:cov
```

### Mobile 테스트
```bash
cd mobile

# 단위 테스트
flutter test

# 통합 테스트
flutter test integration_test
```

## 배포

### Docker
```bash
# Backend
cd backend
docker build -t idol-support-backend .
docker run -p 3000:3000 idol-support-backend
```

### CI/CD
GitHub Actions를 통해 자동 배포 설정됨:
- `main` 브랜치 푸시 시 자동 배포
- PR 생성 시 테스트 자동 실행

## 환경 변수

### Backend (.env)
```
DATABASE_URL=postgresql://...
JWT_SECRET=your-secret
JWT_REFRESH_SECRET=your-refresh-secret
STRIPE_SECRET_KEY=sk_...
STRIPE_WEBHOOK_SECRET=whsec_...
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
```

## 라이선스

MIT License

## 기여하기

1. Fork 하기
2. Feature 브랜치 생성 (`git checkout -b feature/AmazingFeature`)
3. 변경사항 커밋 (`git commit -m 'Add AmazingFeature'`)
4. 브랜치 푸시 (`git push origin feature/AmazingFeature`)
5. Pull Request 생성

## 문의

- Email: support@idol-support.com
- Website: https://idol-support.com
