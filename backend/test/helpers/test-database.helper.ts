import { PrismaClient } from '@prisma/client';

/**
 * Test Database Helper
 *
 * Prisma는 자체적인 in-memory DB를 제공하지 않으므로,
 * 테스트용 SQLite나 별도의 PostgreSQL 테스트 DB를 사용합니다.
 *
 * 권장 방법:
 * 1. 테스트 전용 PostgreSQL DB 사용 (docker-compose.test.yml)
 * 2. 각 테스트 전후로 데이터 초기화
 */

export class TestDatabaseHelper {
  private static prisma: PrismaClient;

  static async connect(): Promise<PrismaClient> {
    if (!this.prisma) {
      this.prisma = new PrismaClient({
        datasources: {
          db: {
            url: process.env.TEST_DATABASE_URL || process.env.DATABASE_URL,
          },
        },
      });
      await this.prisma.$connect();
    }
    return this.prisma;
  }

  static async disconnect(): Promise<void> {
    if (this.prisma) {
      await this.prisma.$disconnect();
    }
  }

  static async cleanDatabase(): Promise<void> {
    const prisma = await this.connect();

    // 외래 키 제약 조건 순서대로 삭제
    const deleteOrder = [
      'like',
      'comment',
      'post',
      'campaignContribution',
      'campaign',
      'booking',
      'subscription',
      'subscriptionTier',
      'support',
      'payment',
      'transaction',
      'wallet',
      'schedule',
      'idolProfile',
      'refreshToken',
      'notification',
      'user',
    ];

    for (const tableName of deleteOrder) {
      try {
        await prisma[tableName]?.deleteMany?.();
      } catch (e) {
        // Table might not exist, ignore
      }
    }
  }

  static getPrisma(): PrismaClient {
    return this.prisma;
  }
}

/**
 * Mock Prisma Service for Unit Tests
 * 서비스 레벨 테스트에서 DB 접근 없이 테스트할 때 사용
 */
export const createMockPrismaService = () => ({
  user: {
    findUnique: jest.fn(),
    findMany: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
  wallet: {
    findUnique: jest.fn(),
    findFirst: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
  transaction: {
    findMany: jest.fn(),
    create: jest.fn(),
  },
  support: {
    findMany: jest.fn(),
    create: jest.fn(),
  },
  subscription: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
  campaign: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
  booking: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
  post: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
  comment: {
    findMany: jest.fn(),
    create: jest.fn(),
    delete: jest.fn(),
  },
  like: {
    findUnique: jest.fn(),
    create: jest.fn(),
    delete: jest.fn(),
    count: jest.fn(),
  },
  refreshToken: {
    findFirst: jest.fn(),
    create: jest.fn(),
    delete: jest.fn(),
    deleteMany: jest.fn(),
  },
  $transaction: jest.fn((callback) => callback(createMockPrismaService())),
});
