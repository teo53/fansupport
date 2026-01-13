---
name: nestjs-dev
description: |
  NestJS backend development skill for Idol Support API.
  Use when working on backend/ directory: creating modules, services, controllers, or fixing backend issues.
  Includes Prisma ORM, JWT auth, and Stripe payment patterns.
---

# NestJS Development Skill

## Project Structure

```
backend/
├── src/
│   ├── auth/           # Authentication module
│   ├── users/          # Users module
│   ├── wallet/         # Wallet & transactions
│   ├── support/        # Donations
│   ├── subscriptions/  # Subscription tiers
│   ├── campaigns/      # Crowdfunding
│   ├── bookings/       # Reservations
│   ├── community/      # Posts, comments
│   ├── payments/       # Stripe, IAP
│   ├── common/         # Shared (guards, pipes, filters)
│   ├── prisma/         # Prisma service
│   └── main.ts
├── prisma/
│   └── schema.prisma   # Database schema
└── test/               # E2E tests
```

## Module Pattern

```typescript
// users.module.ts
@Module({
  imports: [PrismaModule],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
```

## Controller Pattern

```typescript
@Controller('api/users')
@UseGuards(JwtAuthGuard)
@ApiTags('Users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get current user profile' })
  async getProfile(@CurrentUser() user: User) {
    return this.usersService.findById(user.id);
  }

  @Put('me')
  async updateProfile(
    @CurrentUser() user: User,
    @Body() dto: UpdateUserDto,
  ) {
    return this.usersService.update(user.id, dto);
  }
}
```

## Service Pattern

```typescript
@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findById(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      include: { idolProfile: true },
    });
  }
}
```

## DTOs with Validation

```typescript
export class CreateSupportDto {
  @IsUUID()
  @ApiProperty({ description: 'Recipient idol ID' })
  idolId: string;

  @IsNumber()
  @Min(100)
  @ApiProperty({ description: 'Amount in KRW', minimum: 100 })
  amount: number;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  message?: string;

  @IsOptional()
  @IsBoolean()
  isAnonymous?: boolean;
}
```

## Prisma Transactions

```typescript
// For financial operations, always use transactions
async createSupport(userId: string, dto: CreateSupportDto) {
  return this.prisma.$transaction(async (tx) => {
    // 1. Deduct from sender wallet
    await tx.wallet.update({
      where: { userId },
      data: { balance: { decrement: dto.amount } },
    });

    // 2. Add to recipient wallet
    await tx.wallet.update({
      where: { userId: dto.idolId },
      data: { balance: { increment: dto.amount } },
    });

    // 3. Create support record
    return tx.support.create({
      data: {
        senderId: userId,
        recipientId: dto.idolId,
        amount: dto.amount,
        message: dto.message,
        isAnonymous: dto.isAnonymous ?? false,
      },
    });
  });
}
```

## Auth Guards

```typescript
// JWT Guard (most endpoints)
@UseGuards(JwtAuthGuard)

// Role-based access
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.IDOL)

// Public endpoint
@Public()
```

## Rate Limiting

```typescript
// Global throttler configured in app.module.ts
// Default: 100 requests per 60 seconds

// Custom limit for specific endpoint
@Throttle({ default: { limit: 5, ttl: 60000 } })
@Post('support')
async createSupport() {}
```

## Commands

```bash
npm run start:dev           # Dev server with watch
npm run test                # Unit tests
npm run test:e2e            # E2E tests
npx prisma generate         # Generate Prisma client
npx prisma db push          # Push schema to DB
npx prisma studio           # DB GUI
npx prisma migrate dev      # Create migration
```

## API Documentation

Swagger UI available at `http://localhost:3000/docs`

Use decorators:
- `@ApiTags('Module')` - Group endpoints
- `@ApiOperation({ summary: '' })` - Describe endpoint
- `@ApiProperty()` - Document DTO fields
- `@ApiBearerAuth()` - Require JWT
