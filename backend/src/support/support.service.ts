import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { CreateSupportDto } from './dto/create-support.dto';
import { TransactionType, Prisma } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

/**
 * Prisma 트랜잭션 클라이언트 타입
 */
type PrismaTransactionClient = Omit<
  PrismaService,
  '$connect' | '$disconnect' | '$on' | '$transaction' | '$use' | '$extends'
>;

@Injectable()
export class SupportService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly walletService: WalletService,
  ) {}

  async createSupport(supporterId: string, createSupportDto: CreateSupportDto) {
    const { receiverId, amount, message, isAnonymous } = createSupportDto;

    if (supporterId === receiverId) {
      throw new BadRequestException('Cannot support yourself');
    }

    const receiver = await this.prisma.user.findUnique({
      where: { id: receiverId },
      include: { idolProfile: true },
    });

    if (!receiver) {
      throw new NotFoundException('Receiver not found');
    }

    // Use transaction to ensure data consistency
    const support = await this.prisma.$transaction(async (tx) => {
      // Transfer funds from supporter to receiver
      await this.walletService.transfer(
        supporterId,
        receiverId,
        amount,
        TransactionType.SUPPORT_SENT,
        `Support to ${receiver.nickname}`,
        tx,
      );

      // Create support record
      const supportRecord = await tx.support.create({
        data: {
          supporterId,
          receiverId,
          amount: new Decimal(amount),
          message,
          isAnonymous,
        },
        include: {
          supporter: {
            select: { id: true, nickname: true, profileImage: true },
          },
          receiver: {
            select: { id: true, nickname: true, profileImage: true },
          },
        },
      });

      // Update idol profile stats
      if (receiver.idolProfile) {
        const isFirst = await this.isFirstSupportInTransaction(supporterId, receiverId, tx);
        await tx.idolProfile.update({
          where: { id: receiver.idolProfile.id },
          data: {
            totalSupport: { increment: amount },
            supporterCount: {
              increment: isFirst ? 1 : 0,
            },
          },
        });
      }

      // Create notification
      const supporter = await tx.user.findUnique({ where: { id: supporterId } });
      await tx.notification.create({
        data: {
          userId: receiverId,
          type: 'SUPPORT_RECEIVED',
          title: 'New Support Received!',
          message: isAnonymous
            ? `Anonymous fan sent you ${amount} KRW!`
            : `${supporter?.nickname} sent you ${amount} KRW!`,
          data: { supportId: supportRecord.id, amount, isAnonymous },
        },
      });

      return supportRecord;
    });

    return support;
  }

  private async isFirstSupport(supporterId: string, receiverId: string): Promise<boolean> {
    const count = await this.prisma.support.count({
      where: { supporterId, receiverId },
    });
    return count === 1;
  }

  private async isFirstSupportInTransaction(supporterId: string, receiverId: string, tx: PrismaTransactionClient): Promise<boolean> {
    const count = await tx.support.count({
      where: { supporterId, receiverId },
    });
    return count === 1;
  }

  async getSupportHistory(userId: string, type: 'sent' | 'received', options: { page?: number; limit?: number }) {
    const { page = 1, limit = 20 } = options;
    const where = type === 'sent' ? { supporterId: userId } : { receiverId: userId };

    const [supports, total] = await Promise.all([
      this.prisma.support.findMany({
        where,
        include: {
          supporter: {
            select: { id: true, nickname: true, profileImage: true },
          },
          receiver: {
            select: { id: true, nickname: true, profileImage: true },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.support.count({ where }),
    ]);

    // Hide supporter info for anonymous supports when viewing received
    const processedSupports = supports.map((support) => {
      if (type === 'received' && support.isAnonymous) {
        return {
          ...support,
          supporter: { id: 'anonymous', nickname: 'Anonymous', profileImage: null },
        };
      }
      return support;
    });

    return {
      data: processedSupports,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getTopSupporters(receiverId: string, limit: number = 10) {
    const supports = await this.prisma.support.groupBy({
      by: ['supporterId'],
      where: { receiverId, isAnonymous: false },
      _sum: { amount: true },
      orderBy: { _sum: { amount: 'desc' } },
      take: limit,
    });

    // Fix N+1 query: fetch all users in a single query
    const userIds = supports.map((s) => s.supporterId);
    const users = await this.prisma.user.findMany({
      where: { id: { in: userIds } },
      select: { id: true, nickname: true, profileImage: true },
    });

    // Create a map for O(1) lookup
    const userMap = new Map(users.map((u) => [u.id, u]));

    const supporters = supports.map((s) => ({
      user: userMap.get(s.supporterId),
      totalAmount: s._sum.amount,
    }));

    return supporters;
  }
}
