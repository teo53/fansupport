# Idol Support Platform - Claude Code Context

## Project Overview

지하 아이돌과 메이드카페 팬덤을 위한 후원 플랫폼 (Underground Idol & Maid Cafe Fan Support Platform)

## Architecture

```
fansupport/
├── backend/     # NestJS API Server
├── mobile/      # Flutter Mobile App
├── web/         # Next.js Landing Page
└── docs/        # Documentation
```

## Tech Stack

### Backend (NestJS)
- **Framework**: NestJS 10 with TypeScript
- **Database**: PostgreSQL + Prisma ORM
- **Auth**: JWT + Passport (Google, Kakao OAuth)
- **Payment**: Stripe
- **API Docs**: Swagger/OpenAPI at `/docs`

### Mobile (Flutter)
- **Framework**: Flutter 3.16+ (Dart SDK >=3.6.0)
- **State**: Riverpod + freezed
- **Navigation**: GoRouter
- **Network**: Dio + Retrofit + Supabase
- **Storage**: flutter_secure_storage, shared_preferences

### Web (Next.js)
- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS 3.4
- **Animation**: Framer Motion
- **Icons**: Lucide React

## Key Commands

### Backend
```bash
cd backend
npm run start:dev      # Dev server
npm run test           # Unit tests
npm run test:e2e       # E2E tests
npx prisma studio      # DB GUI
```

### Mobile
```bash
cd mobile
flutter pub get        # Install deps
flutter run            # Run app
flutter test           # Run tests
flutter build apk      # Build Android
```

### Web
```bash
cd web
npm run dev            # Dev server (port 3001)
npm run build          # Production build
```

## Database Schema (Prisma)

Key models: `User`, `IdolProfile`, `Wallet`, `Transaction`, `Support`, `Subscription`, `SubscriptionTier`, `Campaign`, `Booking`, `Post`, `Comment`, `Like`, `Payment`

## API Endpoints

- Auth: `/api/auth/*` (register, login, OAuth)
- Users: `/api/users/*` (profiles, idol listing)
- Wallet: `/api/wallet/*` (balance, transactions)
- Support: `/api/support/*` (donations)
- Subscriptions: `/api/subscriptions/*` (tiers, subscribe)
- Campaigns: `/api/campaigns/*` (crowdfunding)
- Bookings: `/api/bookings/*` (reservations)
- Community: `/api/community/*` (posts, comments)
- Payments: `/api/payments/*` (Stripe, IAP)

## Code Style

### TypeScript/NestJS
- Use class-validator for DTOs
- Use Prisma transactions for financial operations
- Rate limiting via @nestjs/throttler

### Flutter/Dart
- Follow flutter_lints rules
- Use Riverpod for state management
- Freezed for immutable data classes
- Korean error messages for user-facing errors

### React/Next.js
- Tailwind CSS for styling
- Framer Motion for animations
- App Router conventions

## Environment Variables

Backend: `backend/.env` (see `.env.example`)
Mobile: `mobile/.env.*` (development, staging, production)

## CI/CD

GitHub Actions workflows in `.github/workflows/`
- APK build on push
- Tests on PR
