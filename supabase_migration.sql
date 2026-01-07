-- PIPO Supabase Migration
-- 이 파일을 Supabase Dashboard > SQL Editor에 붙여넣고 실행하세요

-- ==================== ENUMS ====================
CREATE TYPE user_role AS ENUM ('FAN', 'IDOL', 'MAID', 'ADMIN');
CREATE TYPE auth_provider AS ENUM ('LOCAL', 'GOOGLE', 'APPLE', 'KAKAO');
CREATE TYPE idol_category AS ENUM ('UNDERGROUND_IDOL', 'MAID_CAFE', 'COSPLAYER', 'VTuber', 'OTHER');
CREATE TYPE transaction_type AS ENUM (
  'DEPOSIT', 'WITHDRAWAL',
  'SUPPORT_SENT', 'SUPPORT_RECEIVED',
  'SUBSCRIPTION_PAYMENT', 'CAMPAIGN_CONTRIBUTION', 'REFUND'
);
CREATE TYPE transaction_status AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED');
CREATE TYPE subscription_status AS ENUM ('ACTIVE', 'PAUSED', 'CANCELLED', 'EXPIRED');
CREATE TYPE campaign_status AS ENUM ('DRAFT', 'ACTIVE', 'COMPLETED', 'FAILED', 'CANCELLED');
CREATE TYPE notification_type AS ENUM (
  'SUPPORT_RECEIVED', 'NEW_SUBSCRIBER', 'SUBSCRIPTION_RENEWED',
  'CAMPAIGN_UPDATE', 'CAMPAIGN_GOAL_REACHED',
  'BOOKING_CONFIRMED', 'BOOKING_REMINDER',
  'NEW_POST', 'NEW_COMMENT', 'SYSTEM'
);

-- ==================== TABLES ====================

-- Users (프로필 확장)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  nickname TEXT NOT NULL,
  profile_image TEXT,
  role user_role DEFAULT 'FAN',
  provider auth_provider DEFAULT 'LOCAL',
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Wallets
CREATE TABLE public.wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  balance DECIMAL(15, 2) DEFAULT 0 CHECK (balance >= 0),
  currency TEXT DEFAULT 'KRW',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transactions
CREATE TABLE public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  type transaction_type NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  balance_before DECIMAL(15, 2) NOT NULL,
  balance_after DECIMAL(15, 2) NOT NULL,
  description TEXT,
  reference_id TEXT,
  reference_type TEXT,
  status transaction_status DEFAULT 'COMPLETED',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Idol Profiles
CREATE TABLE public.idol_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  stage_name TEXT NOT NULL,
  introduction TEXT,
  category idol_category NOT NULL,
  cafe_name TEXT,
  cafe_address TEXT,
  header_image TEXT,
  gallery_images TEXT[],
  social_links JSONB,
  is_verified BOOLEAN DEFAULT false,
  total_support DECIMAL(15, 2) DEFAULT 0,
  supporter_count INTEGER DEFAULT 0,
  ranking INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Supports
CREATE TABLE public.supports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supporter_id UUID NOT NULL REFERENCES public.users(id),
  receiver_id UUID NOT NULL REFERENCES public.users(id),
  amount DECIMAL(15, 2) NOT NULL CHECK (amount >= 100 AND amount <= 10000000),
  message TEXT,
  is_anonymous BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscription Tiers
CREATE TABLE public.subscription_tiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  idol_profile_id UUID NOT NULL REFERENCES public.idol_profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  price DECIMAL(15, 2) NOT NULL CHECK (price >= 1000 AND price <= 1000000),
  benefits TEXT[] NOT NULL,
  max_subscribers INTEGER CHECK (max_subscribers > 0 AND max_subscribers <= 10000),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscriptions
CREATE TABLE public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscriber_id UUID NOT NULL REFERENCES public.users(id),
  creator_id UUID NOT NULL REFERENCES public.users(id),
  tier_id UUID NOT NULL REFERENCES public.subscription_tiers(id),
  status subscription_status DEFAULT 'ACTIVE',
  start_date TIMESTAMPTZ DEFAULT NOW(),
  end_date TIMESTAMPTZ,
  renewal_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(subscriber_id, creator_id)
);

-- Campaigns
CREATE TABLE public.campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL REFERENCES public.users(id),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  cover_image TEXT,
  goal_amount DECIMAL(15, 2) NOT NULL CHECK (goal_amount >= 10000 AND goal_amount <= 100000000),
  current_amount DECIMAL(15, 2) DEFAULT 0,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  status campaign_status DEFAULT 'DRAFT',
  rewards JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Campaign Contributions
CREATE TABLE public.campaign_contributions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES public.campaigns(id),
  user_id UUID NOT NULL REFERENCES public.users(id),
  amount DECIMAL(15, 2) NOT NULL CHECK (amount >= 1000 AND amount <= 10000000),
  reward_tier TEXT,
  message TEXT,
  is_anonymous BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type notification_type NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== INDEXES ====================
CREATE INDEX idx_transactions_wallet_id ON public.transactions(wallet_id);
CREATE INDEX idx_transactions_created_at ON public.transactions(created_at DESC);
CREATE INDEX idx_supports_supporter ON public.supports(supporter_id);
CREATE INDEX idx_supports_receiver ON public.supports(receiver_id);
CREATE INDEX idx_supports_created_at ON public.supports(created_at DESC);
CREATE INDEX idx_idol_profiles_category ON public.idol_profiles(category);
CREATE INDEX idx_idol_profiles_ranking ON public.idol_profiles(ranking);
CREATE INDEX idx_idol_profiles_total_support ON public.idol_profiles(total_support DESC);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);

-- ==================== ROW LEVEL SECURITY ====================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.idol_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users Policies
CREATE POLICY "Anyone can view profiles" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Wallets Policies
CREATE POLICY "Users can view own wallet" ON public.wallets FOR SELECT USING (auth.uid() = user_id);

-- Transactions Policies
CREATE POLICY "Users can view own transactions" ON public.transactions FOR SELECT
USING (wallet_id IN (SELECT id FROM public.wallets WHERE user_id = auth.uid()));

-- Idol Profiles Policies
CREATE POLICY "Anyone can view verified profiles" ON public.idol_profiles FOR SELECT
USING (is_verified = true OR auth.uid() = user_id);
CREATE POLICY "Idols can update own profile" ON public.idol_profiles FOR UPDATE
USING (auth.uid() = user_id);

-- Supports Policies
CREATE POLICY "Users can view related supports" ON public.supports FOR SELECT
USING (auth.uid() = receiver_id OR auth.uid() = supporter_id);
CREATE POLICY "Users can create supports" ON public.supports FOR INSERT
WITH CHECK (auth.uid() = supporter_id);

-- Subscriptions Policies
CREATE POLICY "Users can view own subscriptions" ON public.subscriptions FOR SELECT
USING (auth.uid() = subscriber_id OR auth.uid() = creator_id);

-- Campaigns Policies
CREATE POLICY "Anyone can view active campaigns" ON public.campaigns FOR SELECT
USING (status = 'ACTIVE' OR auth.uid() = creator_id);

-- Notifications Policies
CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT
USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE
USING (auth.uid() = user_id);

-- ==================== FUNCTIONS ====================

-- 후원 생성 함수 (트랜잭션 보장)
CREATE OR REPLACE FUNCTION create_support(
  p_receiver_id UUID,
  p_amount DECIMAL,
  p_message TEXT DEFAULT NULL,
  p_is_anonymous BOOLEAN DEFAULT false
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_supporter_id UUID;
  v_supporter_wallet_id UUID;
  v_receiver_wallet_id UUID;
  v_support_id UUID;
  v_balance_before DECIMAL;
  v_balance_after DECIMAL;
BEGIN
  v_supporter_id := auth.uid();

  IF v_supporter_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT id, balance INTO v_supporter_wallet_id, v_balance_before
  FROM public.wallets WHERE user_id = v_supporter_id FOR UPDATE;

  SELECT id INTO v_receiver_wallet_id
  FROM public.wallets WHERE user_id = p_receiver_id FOR UPDATE;

  IF v_balance_before < p_amount THEN
    RAISE EXCEPTION 'Insufficient balance';
  END IF;

  -- 1. 후원자 지갑 차감
  UPDATE public.wallets SET balance = balance - p_amount, updated_at = NOW()
  WHERE id = v_supporter_wallet_id;

  v_balance_after := v_balance_before - p_amount;

  -- 2. 후원자 거래 기록
  INSERT INTO public.transactions (wallet_id, type, amount, balance_before, balance_after, description)
  VALUES (v_supporter_wallet_id, 'SUPPORT_SENT', p_amount, v_balance_before, v_balance_after,
          '후원 전송: ' || COALESCE(p_message, ''));

  -- 3. 받는 사람 지갑 증가
  UPDATE public.wallets SET balance = balance + p_amount, updated_at = NOW()
  WHERE id = v_receiver_wallet_id;

  -- 4. 받는 사람 거래 기록
  INSERT INTO public.transactions (wallet_id, type, amount, balance_before, balance_after, description)
  SELECT id, 'SUPPORT_RECEIVED', p_amount, balance - p_amount, balance,
         '후원 받음: ' || COALESCE(p_message, '')
  FROM public.wallets WHERE id = v_receiver_wallet_id;

  -- 5. Support 레코드 생성
  INSERT INTO public.supports (supporter_id, receiver_id, amount, message, is_anonymous)
  VALUES (v_supporter_id, p_receiver_id, p_amount, p_message, p_is_anonymous)
  RETURNING id INTO v_support_id;

  -- 6. Idol Profile 통계 업데이트
  UPDATE public.idol_profiles
  SET total_support = total_support + p_amount,
      supporter_count = supporter_count + 1,
      updated_at = NOW()
  WHERE user_id = p_receiver_id;

  -- 7. 알림 생성
  IF NOT p_is_anonymous THEN
    INSERT INTO public.notifications (user_id, type, title, message, data)
    SELECT p_receiver_id, 'SUPPORT_RECEIVED', '새로운 후원',
           u.nickname || '님이 ' || p_amount || '원을 후원하셨습니다',
           jsonb_build_object('support_id', v_support_id, 'amount', p_amount)
    FROM public.users u WHERE u.id = v_supporter_id;
  END IF;

  RETURN v_support_id;
END;
$$;

-- 지갑 충전 함수
CREATE OR REPLACE FUNCTION charge_wallet(
  p_amount DECIMAL,
  p_payment_id TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_wallet_id UUID;
  v_balance_before DECIMAL;
BEGIN
  v_user_id := auth.uid();

  SELECT id, balance INTO v_wallet_id, v_balance_before
  FROM public.wallets WHERE user_id = v_user_id FOR UPDATE;

  UPDATE public.wallets SET balance = balance + p_amount, updated_at = NOW()
  WHERE id = v_wallet_id;

  INSERT INTO public.transactions (wallet_id, type, amount, balance_before, balance_after, reference_id, reference_type)
  VALUES (v_wallet_id, 'DEPOSIT', p_amount, v_balance_before, v_balance_before + p_amount,
          p_payment_id, 'PAYMENT');

  RETURN true;
END;
$$;

-- ==================== TRIGGERS ====================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_idol_profiles_updated_at BEFORE UPDATE ON public.idol_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ==================== REALTIME ====================
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.supports;
ALTER PUBLICATION supabase_realtime ADD TABLE public.subscriptions;

-- ==================== 초기 데이터 (회원가입 후 지갑 자동 생성) ====================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, nickname, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nickname', SPLIT_PART(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'FAN')
  );

  INSERT INTO public.wallets (user_id, balance)
  VALUES (NEW.id, 0);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
