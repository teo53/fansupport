---
name: prisma-schema
description: |
  Prisma schema and database operations skill.
  Use when modifying database schema, creating migrations, or working with Prisma queries.
  Includes best practices for relations, indexes, and transactions.
---

# Prisma Schema Skill

## Schema Location

`backend/prisma/schema.prisma`

## Model Patterns

### Basic Model
```prisma
model User {
  id          String   @id @default(uuid())
  email       String   @unique
  displayName String
  avatarUrl   String?
  role        UserRole @default(FAN)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  // Relations
  wallet      Wallet?
  idolProfile IdolProfile?
  supports    Support[]    @relation("SupportSender")

  @@map("users")
}
```

### Enum
```prisma
enum UserRole {
  FAN
  IDOL
  ADMIN
}

enum TransactionType {
  DEPOSIT
  WITHDRAWAL
  SUPPORT_SENT
  SUPPORT_RECEIVED
  SUBSCRIPTION
}
```

### Relations

```prisma
// One-to-One
model User {
  wallet Wallet?
}
model Wallet {
  userId String @unique
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
}

// One-to-Many
model User {
  posts Post[]
}
model Post {
  authorId String
  author   User   @relation(fields: [authorId], references: [id])
}

// Many-to-Many (explicit)
model Post {
  likes Like[]
}
model User {
  likes Like[]
}
model Like {
  userId String
  postId String
  user   User @relation(fields: [userId], references: [id])
  post   Post @relation(fields: [postId], references: [id])
  @@id([userId, postId])
}
```

### Indexes
```prisma
model Support {
  id          String   @id @default(uuid())
  senderId    String
  recipientId String
  amount      Int
  createdAt   DateTime @default(now())

  @@index([senderId])
  @@index([recipientId])
  @@index([createdAt])
}
```

## Commands

```bash
# Generate Prisma Client (after schema changes)
npx prisma generate

# Push schema to database (dev only)
npx prisma db push

# Create migration
npx prisma migrate dev --name <migration-name>

# Apply migrations (production)
npx prisma migrate deploy

# Open Prisma Studio (DB GUI)
npx prisma studio

# Reset database
npx prisma migrate reset
```

## Query Patterns

### Include Relations
```typescript
const user = await prisma.user.findUnique({
  where: { id },
  include: {
    wallet: true,
    idolProfile: {
      include: { subscriptionTiers: true }
    }
  }
});
```

### Select Specific Fields
```typescript
const users = await prisma.user.findMany({
  select: {
    id: true,
    displayName: true,
    avatarUrl: true,
  }
});
```

### Transactions
```typescript
// For operations that must succeed together
const result = await prisma.$transaction(async (tx) => {
  const wallet = await tx.wallet.update({
    where: { userId },
    data: { balance: { decrement: amount } }
  });

  const support = await tx.support.create({
    data: { senderId, recipientId, amount }
  });

  return { wallet, support };
});
```

### Aggregations
```typescript
const stats = await prisma.support.aggregate({
  where: { recipientId: idolId },
  _sum: { amount: true },
  _count: true,
});
```
