# API 엔드포인트 상세 문서

## Base URL
- Development: `http://localhost:3000/api`
- Production: `https://api.idol-support.com/api`

## 인증

모든 보호된 엔드포인트는 Bearer 토큰이 필요합니다:
```
Authorization: Bearer <access_token>
```

---

## Auth (인증)

### POST /auth/register
새 사용자 등록

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "nickname": "NickName"
}
```

**Response (201):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "nickname": "NickName",
    "role": "FAN"
  },
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token"
}
```

### POST /auth/login
로그인

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "nickname": "NickName",
    "role": "FAN",
    "profileImage": "url"
  },
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token"
}
```

### POST /auth/refresh
토큰 갱신

**Request Body:**
```json
{
  "refreshToken": "refresh_token"
}
```

**Response (200):**
```json
{
  "accessToken": "new_jwt_token",
  "refreshToken": "new_refresh_token"
}
```

---

## Users (사용자)

### GET /users/me
현재 사용자 정보 조회 (인증 필요)

**Response (200):**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "nickname": "NickName",
  "profileImage": "url",
  "role": "FAN",
  "isVerified": false,
  "wallet": {
    "balance": 10000,
    "currency": "KRW"
  }
}
```

### PUT /users/me
프로필 수정 (인증 필요)

**Request Body:**
```json
{
  "nickname": "NewNickName",
  "profileImage": "https://image.url"
}
```

### GET /users/idols
아이돌 목록 조회

**Query Parameters:**
- `category`: UNDERGROUND_IDOL | MAID_CAFE | COSPLAYER | VTuber | OTHER
- `page`: number (default: 1)
- `limit`: number (default: 20)
- `sortBy`: ranking | totalSupport | supporterCount

**Response (200):**
```json
{
  "data": [
    {
      "id": "uuid",
      "stageName": "아이돌 이름",
      "category": "UNDERGROUND_IDOL",
      "isVerified": true,
      "totalSupport": 1000000,
      "supporterCount": 100,
      "ranking": 1,
      "user": {
        "id": "uuid",
        "nickname": "NickName",
        "profileImage": "url"
      }
    }
  ],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "totalPages": 5
  }
}
```

---

## Wallet (지갑)

### GET /wallet
지갑 정보 조회 (인증 필요)

**Response (200):**
```json
{
  "id": "uuid",
  "balance": 50000,
  "currency": "KRW",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### GET /wallet/transactions
거래 내역 조회 (인증 필요)

**Query Parameters:**
- `page`: number
- `limit`: number

**Response (200):**
```json
{
  "data": [
    {
      "id": "uuid",
      "type": "DEPOSIT",
      "amount": 10000,
      "balanceBefore": 40000,
      "balanceAfter": 50000,
      "description": "코인 충전",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "total": 50,
    "page": 1,
    "limit": 20,
    "totalPages": 3
  }
}
```

---

## Support (후원)

### POST /support
후원하기 (인증 필요)

**Request Body:**
```json
{
  "receiverId": "uuid",
  "amount": 5000,
  "message": "응원합니다!",
  "isAnonymous": false
}
```

**Response (201):**
```json
{
  "id": "uuid",
  "supporterId": "uuid",
  "receiverId": "uuid",
  "amount": 5000,
  "message": "응원합니다!",
  "isAnonymous": false,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### GET /support/top-supporters/:receiverId
탑 서포터 조회

**Response (200):**
```json
[
  {
    "user": {
      "id": "uuid",
      "nickname": "TopFan",
      "profileImage": "url"
    },
    "totalAmount": 500000
  }
]
```

---

## Subscription (구독)

### POST /subscriptions/tiers
구독 티어 생성 (아이돌만)

**Request Body:**
```json
{
  "name": "골드",
  "price": 30000,
  "benefits": ["독점 콘텐츠", "팬미팅 우선권"],
  "maxSubscribers": 100
}
```

### POST /subscriptions
구독하기 (인증 필요)

**Request Body:**
```json
{
  "creatorId": "uuid",
  "tierId": "uuid"
}
```

---

## Campaign (펀딩)

### POST /campaigns
캠페인 생성 (인증 필요)

**Request Body:**
```json
{
  "title": "첫 앨범 발매",
  "description": "앨범 발매를 위한 펀딩입니다.",
  "coverImage": "https://image.url",
  "goalAmount": 10000000,
  "startDate": "2024-01-01",
  "endDate": "2024-02-01",
  "rewards": [
    {
      "amount": 10000,
      "title": "감사 메시지",
      "description": "감사 메시지를 보내드립니다."
    }
  ]
}
```

### POST /campaigns/:id/contribute
펀딩 참여 (인증 필요)

**Request Body:**
```json
{
  "amount": 30000,
  "rewardTier": "사인 앨범",
  "message": "응원합니다!",
  "isAnonymous": false
}
```

---

## Booking (예약)

### POST /bookings
예약 생성 (인증 필요)

**Request Body:**
```json
{
  "cafeName": "메이드카페 A",
  "cafeAddress": "도쿄 아키하바라",
  "date": "2024-01-15",
  "timeSlot": "14:00",
  "numberOfGuests": 2,
  "specialRequest": "창가 자리 희망"
}
```

### GET /bookings/available-slots
예약 가능 시간 조회

**Query Parameters:**
- `cafeName`: string
- `date`: YYYY-MM-DD

**Response (200):**
```json
[
  { "time": "11:00", "available": true },
  { "time": "11:30", "available": true },
  { "time": "12:00", "available": false }
]
```

---

## Community (커뮤니티)

### POST /community/posts
게시글 작성 (인증 필요)

**Request Body:**
```json
{
  "title": "오늘의 일기",
  "content": "오늘 연습 열심히 했어요!",
  "images": ["https://image1.url", "https://image2.url"],
  "visibility": "PUBLIC"
}
```

### GET /community/feed
피드 조회 (인증 필요)

**Query Parameters:**
- `page`: number
- `limit`: number

---

## Payment (결제)

### POST /payments/create-intent
결제 의도 생성 (인증 필요)

**Request Body:**
```json
{
  "amount": 50000,
  "type": "WALLET_CHARGE"
}
```

**Response (200):**
```json
{
  "paymentId": "uuid",
  "clientSecret": "stripe_client_secret"
}
```

### POST /payments/verify-iap
인앱 결제 검증 (인증 필요)

**Request Body:**
```json
{
  "provider": "GOOGLE_PLAY",
  "purchaseToken": "token",
  "productId": "coins_50000"
}
```

---

## 에러 응답

모든 에러는 다음 형식을 따릅니다:

```json
{
  "statusCode": 400,
  "message": "에러 메시지",
  "error": "Bad Request"
}
```

### 일반적인 HTTP 상태 코드
- `200`: 성공
- `201`: 생성됨
- `400`: 잘못된 요청
- `401`: 인증 필요
- `403`: 권한 없음
- `404`: 찾을 수 없음
- `409`: 충돌 (중복 등)
- `500`: 서버 에러
