# PIPO Supabase 설정 가이드

## 🚀 빠른 시작 (15분)

### 1. Supabase 프로젝트 생성

1. https://app.supabase.com 접속 및 로그인 (GitHub 계정 사용 가능)
2. "New Project" 클릭
3. 프로젝트 정보 입력:
   - **Name**: `pipo` 또는 원하는 이름
   - **Database Password**: 강력한 비밀번호 (저장 필수!)
   - **Region**: `Northeast Asia (Seoul)` 선택 (한국 서비스용)
   - **Pricing Plan**: Free tier로 시작 (나중에 업그레이드 가능)

### 2. 데이터베이스 마이그레이션 실행

1. Supabase Dashboard > **SQL Editor** 클릭
2. `/home/user/fansupport/supabase_migration.sql` 파일 내용 전체 복사
3. SQL Editor에 붙여넣기
4. **RUN** 버튼 클릭
5. 성공 메시지 확인 ✅

### 3. Supabase 키 복사

1. Supabase Dashboard > **Project Settings** (왼쪽 하단 톱니바퀴 아이콘)
2. **API** 탭 선택
3. 다음 값 복사:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 4. Flutter 프로젝트 설정

#### 4.1 pubspec.yaml에 패키지 추가

```yaml
dependencies:
  flutter:
    sdk: flutter
  # 기존 패키지들...
  supabase_flutter: ^2.3.0  # Supabase SDK
  flutter_stripe: ^10.1.0    # Stripe 결제
```

```bash
flutter pub get
```

#### 4.2 main.dart 수정

```dart
// mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

#### 4.3 Supabase 키 설정

`mobile/lib/core/config/supabase_config.dart` 파일 수정:

```dart
class SupabaseConfig {
  static const String url = 'https://xxxxx.supabase.co'; // 3단계에서 복사한 URL
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // anon key
}
```

### 5. Storage Bucket 생성 (이미지 업로드용)

1. Supabase Dashboard > **Storage** 클릭
2. "Create a new bucket" 클릭
3. Bucket 정보 입력:
   - **Name**: `avatars`
   - **Public**: ✅ 체크
4. "Create bucket" 클릭

다음 버킷들도 생성:
- `idol-galleries` (아이돌 갤러리 이미지)
- `campaign-covers` (캠페인 커버 이미지)

### 6. 테스트 사용자 생성

SQL Editor에서 실행:

```sql
-- 테스트 계정 생성 (supabase.auth.signUp 대신 직접 생성)
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'test@pipo.com',
  crypt('password123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"nickname":"테스트유저"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);
```

로그인 테스트:
- **Email**: `test@pipo.com`
- **Password**: `password123`

---

## 📊 데이터베이스 확인

### Table Editor에서 확인

Supabase Dashboard > **Table Editor**에서 다음 테이블 확인:

- ✅ `users` - 사용자 프로필
- ✅ `wallets` - 지갑
- ✅ `idol_profiles` - 아이돌 프로필
- ✅ `supports` - 후원 기록
- ✅ `subscriptions` - 구독 정보
- ✅ `campaigns` - 캠페인
- ✅ `notifications` - 알림

### RLS (Row Level Security) 확인

각 테이블에서 **RLS** 활성화 여부 확인:
- Authentication > Policies에서 정책 확인

---

## 🔐 인증 설정

### 이메일 인증 활성화

1. Supabase Dashboard > **Authentication** > **Providers**
2. **Email** 확장
3. 설정:
   - ✅ Enable Email provider
   - ✅ Confirm email (이메일 인증 필요)

### 소셜 로그인 설정 (선택)

#### Google OAuth

1. **Providers** > **Google** 클릭
2. Google Cloud Console에서 OAuth Client ID 생성
3. 키 입력:
   - Client ID
   - Client Secret
4. Authorized redirect URIs에 추가:
   ```
   https://xxxxx.supabase.co/auth/v1/callback
   ```

#### Apple OAuth

1. **Providers** > **Apple** 클릭
2. Apple Developer에서 서비스 ID 생성
3. 키 입력

---

## 💰 Stripe 결제 연동

### 1. Stripe 계정 생성

1. https://dashboard.stripe.com 접속
2. 계정 생성 (테스트 모드로 시작)
3. **Developers** > **API keys** 에서 키 복사:
   - **Publishable key**: `pk_test_...`
   - **Secret key**: `sk_test_...`

### 2. Vercel 프로젝트 생성 (Webhook용)

1. https://vercel.com 접속 및 로그인
2. "New Project" 클릭
3. GitHub 레포지토리 연결 또는 새 프로젝트 생성

### 3. Vercel Edge Function 배포

`/vercel` 폴더 생성 및 파일 추가 (별도 가이드 참조)

---

## 🧪 로컬 테스트

### Supabase CLI로 로컬 개발

```bash
# Supabase CLI 설치
npm install -g supabase

# 프로젝트 링크
supabase link --project-ref xxxxx

# 로컬 Supabase 시작
supabase start

# 마이그레이션 적용
supabase db reset

# 로컬 URL 확인
# API URL: http://localhost:54321
# DB URL: postgresql://postgres:postgres@localhost:54322/postgres
```

`mobile/lib/core/config/supabase_config.dart` 에서 로컬 URL 사용:

```dart
static const String url = 'http://localhost:54321'; // 로컬 개발용
```

---

## 📝 다음 단계

### ✅ 완료 체크리스트

- [ ] Supabase 프로젝트 생성
- [ ] 데이터베이스 마이그레이션 실행
- [ ] Storage Bucket 생성
- [ ] Flutter 패키지 설치
- [ ] Supabase 키 설정
- [ ] 테스트 사용자로 로그인 테스트

### 🚀 다음 작업

1. **Auth 화면 연동**: 로그인/회원가입 화면에 Supabase Auth 적용
2. **후원 기능 구현**: `create_support` Function 호출
3. **Realtime 구독**: 알림 실시간 업데이트
4. **결제 연동**: Stripe Payment Intent 생성

---

## 🆘 문제 해결

### "Project URL is invalid"

- `supabase_config.dart`에서 URL 확인 (https:// 포함)
- Supabase Dashboard에서 URL 재확인

### "Invalid API key"

- anon key를 public key와 혼동하지 않았는지 확인
- Supabase Dashboard > API에서 재확인

### "Row Level Security policy violated"

- Table Editor > Policies에서 정책 확인
- 로그인 상태 확인 (`auth.uid()` 사용 정책)

### 마이그레이션 실패

- SQL Editor에서 에러 메시지 확인
- 기존 테이블 삭제 후 재실행:
  ```sql
  DROP SCHEMA public CASCADE;
  CREATE SCHEMA public;
  -- 마이그레이션 다시 실행
  ```

---

## 📚 참고 자료

- [Supabase 공식 문서](https://supabase.com/docs)
- [Flutter Supabase 가이드](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Stripe Flutter 가이드](https://stripe.com/docs/payments/accept-a-payment?platform=flutter)
