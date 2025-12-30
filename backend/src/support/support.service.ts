import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { CreateSupportDto } from './dto/create-support.dto';
import { TransactionType } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

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

    // Transfer funds from supporter to receiver
    await this.walletService.transfer(
      supporterId,
      receiverId,
      amount,
      TransactionType.SUPPORT_SENT,
      `Support to ${receiver.nickname}`,
    );

    // Create support record
    const support = await this.prisma.support.create({
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
      await this.prisma.idolProfile.update({
        where: { id: receiver.idolProfile.id },
        data: {
          totalSupport: { increment: amount },
          supporterCount: {
            increment: await this.isFirstSupport(supporterId, receiverId) ? 1 : 0,
          },
        },
      });
    }

    // Create notification
    await this.prisma.notification.create({
      data: {
        userId: receiverId,
        type: 'SUPPORT_RECEIVED',
        title: 'New Support Received!',
        message: isAnonymous
          ? `Anonymous fan sent you ${amount} KRW!`
          : `${(await this.prisma.user.findUnique({ where: { id: supporterId } }))?.nickname} sent you ${amount} KRW!`,
        data: { supportId: support.id, amount, isAnonymous },
      },
    });

    return support;
  }

  private async isFirstSupport(supporterId: string, receiverId: string): Promise<boolean> {
    const count = await this.prisma.support.count({
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

    const supporters = await Promise.all(
      supports.map(async (s) => {
        const user = await this.prisma.user.findUnique({
          where: { id: s.supporterId },
          select: { id: true, nickname: true, profileImage: true },
        });
        return {
          user,
          totalAmount: s._sum.amount,
        };
      }),
    );

    return supporters;
  }
}
