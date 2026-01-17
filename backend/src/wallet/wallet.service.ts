import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { TransactionType, TransactionStatus, Prisma } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

/**
 * Prisma 트랜잭션 클라이언트 타입
 */
type PrismaTransactionClient = Omit<
  PrismaService,
  '$connect' | '$disconnect' | '$on' | '$transaction' | '$use' | '$extends'
>;

@Injectable()
export class WalletService {
  constructor(private readonly prisma: PrismaService) {}

  async getOrCreateWallet(userId: string) {
    let wallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      wallet = await this.prisma.wallet.create({
        data: { userId },
      });
    }

    return wallet;
  }

  async getWallet(userId: string) {
    const wallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      throw new NotFoundException('Wallet not found');
    }

    return wallet;
  }

  async getBalance(userId: string) {
    const wallet = await this.getOrCreateWallet(userId);
    return {
      balance: wallet.balance,
      currency: wallet.currency,
    };
  }

  async getTransactions(userId: string, options: { page?: number; limit?: number }) {
    const { page = 1, limit = 20 } = options;
    const wallet = await this.getOrCreateWallet(userId);

    const [transactions, total] = await Promise.all([
      this.prisma.transaction.findMany({
        where: { walletId: wallet.id },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.transaction.count({ where: { walletId: wallet.id } }),
    ]);

    return {
      data: transactions,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async deposit(userId: string, amount: number, referenceId?: string) {
    if (amount <= 0) {
      throw new BadRequestException('Amount must be positive');
    }

    const wallet = await this.getOrCreateWallet(userId);
    const balanceBefore = wallet.balance;
    const balanceAfter = new Decimal(wallet.balance).plus(amount);

    const [updatedWallet, transaction] = await this.prisma.$transaction([
      this.prisma.wallet.update({
        where: { id: wallet.id },
        data: { balance: balanceAfter },
      }),
      this.prisma.transaction.create({
        data: {
          walletId: wallet.id,
          type: TransactionType.DEPOSIT,
          amount: new Decimal(amount),
          balanceBefore,
          balanceAfter,
          referenceId,
          referenceType: 'PAYMENT',
          status: TransactionStatus.COMPLETED,
        },
      }),
    ]);

    return {
      wallet: updatedWallet,
      transaction,
    };
  }

  async transfer(
    fromUserId: string,
    toUserId: string,
    amount: number,
    type: TransactionType,
    description?: string,
    tx?: PrismaTransactionClient,
  ) {
    if (amount <= 0) {
      throw new BadRequestException('Amount must be positive');
    }

    const prismaClient = tx || this.prisma;

    const fromWallet = await this.getOrCreateWallet(fromUserId);
    const toWallet = await this.getOrCreateWallet(toUserId);

    if (new Decimal(fromWallet.balance).lessThan(amount)) {
      throw new BadRequestException('Insufficient balance');
    }

    const fromBalanceBefore = fromWallet.balance;
    const fromBalanceAfter = new Decimal(fromWallet.balance).minus(amount);
    const toBalanceBefore = toWallet.balance;
    const toBalanceAfter = new Decimal(toWallet.balance).plus(amount);

    const executeTransfer = async (client: PrismaTransactionClient) => {
      const result = await Promise.all([
        client.wallet.update({
          where: { id: fromWallet.id },
          data: { balance: fromBalanceAfter },
        }),
        client.wallet.update({
          where: { id: toWallet.id },
          data: { balance: toBalanceAfter },
        }),
        client.transaction.create({
          data: {
            walletId: fromWallet.id,
            type: type === TransactionType.SUPPORT_SENT ? TransactionType.SUPPORT_SENT : TransactionType.SUBSCRIPTION_PAYMENT,
            amount: new Decimal(-amount),
            balanceBefore: fromBalanceBefore,
            balanceAfter: fromBalanceAfter,
            description,
            status: TransactionStatus.COMPLETED,
          },
        }),
        client.transaction.create({
          data: {
            walletId: toWallet.id,
            type: type === TransactionType.SUPPORT_SENT ? TransactionType.SUPPORT_RECEIVED : TransactionType.SUPPORT_RECEIVED,
            amount: new Decimal(amount),
            balanceBefore: toBalanceBefore,
            balanceAfter: toBalanceAfter,
            description,
            status: TransactionStatus.COMPLETED,
          },
        }),
      ]);

      return {
        fromWallet: result[0],
        toWallet: result[1],
      };
    };

    // If tx is provided, use it; otherwise create a new transaction
    if (tx) {
      return executeTransfer(tx);
    } else {
      return this.prisma.$transaction(async (newTx) => {
        return executeTransfer(newTx);
      });
    }
  }
}
