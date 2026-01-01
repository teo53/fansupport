import { Injectable, NotFoundException, BadRequestException, InternalServerErrorException, Logger } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { CreateSupportDto } from './dto/create-support.dto';
import { TransactionType } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

const MIN_SUPPORT_AMOUNT = 1000; // Minimum support amount in KRW
const MAX_SUPPORT_AMOUNT = 10000000; // Maximum support amount in KRW

@Injectable()
export class SupportService {
  private readonly logger = new Logger(SupportService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly walletService: WalletService,
  ) {}

  async createSupport(supporterId: string, createSupportDto: CreateSupportDto) {
    const { receiverId, amount, message, isAnonymous } = createSupportDto;

    // Validate supporter ID
    if (!supporterId) {
      throw new BadRequestException('Supporter ID is required');
    }

    // Validate receiver ID
    if (!receiverId) {
      throw new BadRequestException('Receiver ID is required');
    }

    if (supporterId === receiverId) {
      throw new BadRequestException('Cannot support yourself');
    }

    // Validate amount
    if (typeof amount !== 'number' || isNaN(amount)) {
      throw new BadRequestException('Amount must be a valid number');
    }

    if (amount < MIN_SUPPORT_AMOUNT) {
      throw new BadRequestException(`Minimum support amount is ${MIN_SUPPORT_AMOUNT.toLocaleString()} KRW`);
    }

    if (amount > MAX_SUPPORT_AMOUNT) {
      throw new BadRequestException(`Maximum support amount is ${MAX_SUPPORT_AMOUNT.toLocaleString()} KRW`);
    }

    // Validate message length if provided
    if (message && message.length > 500) {
      throw new BadRequestException('Support message cannot exceed 500 characters');
    }

    // Verify receiver exists
    const receiver = await this.prisma.user.findUnique({
      where: { id: receiverId },
      include: { idolProfile: true },
    });

    if (!receiver) {
      throw new NotFoundException('Receiver not found');
    }

    // Verify supporter exists
    const supporter = await this.prisma.user.findUnique({
      where: { id: supporterId },
    });

    if (!supporter) {
      throw new NotFoundException('Supporter account not found');
    }

    try {
      // Use transaction to ensure atomicity of transfer, support record, stats update, and notification
      const result = await this.prisma.$transaction(async (tx) => {
        // Transfer funds from supporter to receiver
        await this.walletService.transfer(
          supporterId,
          receiverId,
          amount,
          TransactionType.SUPPORT_SENT,
          `Support to ${receiver.nickname}`,
        );

        // Check if this is the first support from this supporter
        const existingSupportCount = await tx.support.count({
          where: { supporterId, receiverId },
        });
        const isFirstSupport = existingSupportCount === 0;

        // Create support record
        const support = await tx.support.create({
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
          await tx.idolProfile.update({
            where: { id: receiver.idolProfile.id },
            data: {
              totalSupport: { increment: amount },
              supporterCount: {
                increment: isFirstSupport ? 1 : 0,
              },
            },
          });
        }

        // Create notification
        await tx.notification.create({
          data: {
            userId: receiverId,
            type: 'SUPPORT_RECEIVED',
            title: 'New Support Received!',
            message: isAnonymous
              ? `Anonymous fan sent you ${amount.toLocaleString()} KRW!`
              : `${supporter.nickname} sent you ${amount.toLocaleString()} KRW!`,
            data: { supportId: support.id, amount, isAnonymous },
          },
        });

        return support;
      });

      this.logger.log(`Support created: supporter=${supporterId}, receiver=${receiverId}, amount=${amount}`);
      return result;
    } catch (error) {
      // Re-throw known errors
      if (error instanceof BadRequestException || error instanceof NotFoundException) {
        throw error;
      }

      this.logger.error(`Failed to create support: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to process support. Please try again later.');
    }
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
    if (!receiverId) {
      throw new BadRequestException('Receiver ID is required');
    }

    if (limit < 1 || limit > 100) {
      throw new BadRequestException('Limit must be between 1 and 100');
    }

    // Verify receiver exists
    const receiver = await this.prisma.user.findUnique({
      where: { id: receiverId },
    });

    if (!receiver) {
      throw new NotFoundException('Receiver not found');
    }

    try {
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
          // Handle case where user might have been deleted
          return {
            user: user || { id: s.supporterId, nickname: 'Deleted User', profileImage: null },
            totalAmount: s._sum.amount,
          };
        }),
      );

      return supporters;
    } catch (error) {
      this.logger.error(`Failed to get top supporters for ${receiverId}: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to retrieve top supporters. Please try again later.');
    }
  }
}
