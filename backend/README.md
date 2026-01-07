# PIPO Backend API

NestJS-based backend for the PIPO platform (Underground Idol & Maid Cafe Fan Support Platform)

## Prerequisites

- Node.js 20+
- PostgreSQL 15+
- npm or yarn

## Installation

```bash
# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your configuration

# Generate Prisma client
npm run prisma:generate

# Run database migrations
npm run prisma:migrate
# OR push schema without migrations
npm run db:push
```

## Running the app

```bash
# Development
npm run start:dev

# Production
npm run build
npm run start:prod

# Debug mode
npm run start:debug
```

## Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## Environment Variables

See `.env.example` for all available environment variables.

Key variables:
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Secret for JWT token signing
- `ALLOWED_ORIGINS`: Comma-separated list of allowed CORS origins
- `STRIPE_SECRET_KEY`: Stripe API key

## API Documentation

Swagger documentation is available at: `http://localhost:3000/docs`

## Security Features

- **Helmet**: Security headers protection
- **CORS**: Configurable origin whitelist
- **Rate Limiting**: Global throttling guard (100 req/60sec default, configurable via `THROTTLE_TTL` and `THROTTLE_LIMIT`)
- **Input Validation**: Automatic DTO validation with class-validator
- **JWT Authentication**: Secure token-based auth with refresh tokens
- **Transaction Safety**: Database transactions for payment operations (support, subscription, wallet)

## Database

Uses Prisma ORM with PostgreSQL.

```bash
# Open Prisma Studio (database GUI)
npm run prisma:studio

# Generate migration
npm run prisma:migrate

# Reset database (⚠️ destructive)
npx prisma migrate reset
```

## Project Structure

```
src/
├── auth/           # Authentication module
├── users/          # User management
├── wallet/         # Wallet & transactions
├── support/        # Support/donations
├── subscription/   # Subscription management
├── campaign/       # Crowdfunding campaigns
├── booking/        # Maid cafe bookings
├── community/      # Posts & comments
├── payment/        # Payment processing
├── common/         # Shared utilities
│   ├── dto/       # Data transfer objects
│   └── guards/    # Auth & throttle guards
└── database/       # Database module

prisma/
└── schema.prisma   # Database schema
```

## License

MIT
