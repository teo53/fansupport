import { Injectable, NotFoundException, BadRequestException, InternalServerErrorException, Logger } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { TransactionType, TransactionStatus } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

// Maximum balance limit to prevent overflow and fraud
const MAX_WALLET_BALANCE = 100000000; // 100 million KRW
const MAX_SINGLE_TRANSACTION = 10000000; // 10 million KRW

@Injectable()
export class WalletService {
  private readonly logger = new Logger(WalletService.name);

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
    if (!userId) {
      throw new BadRequestException('User ID is required');
    }

    if (typeof amount !== 'number' || isNaN(amount)) {
      throw new BadRequestException('Amount must be a valid number');
    }

    if (amount <= 0) {
      throw new BadRequestException('Amount must be positive');
    }

    if (amount > MAX_SINGLE_TRANSACTION) {
      throw new BadRequestException(`Maximum single deposit amount is ${MAX_SINGLE_TRANSACTION.toLocaleString()} KRW`);
    }

    const wallet = await this.getOrCreateWallet(userId);
    const balanceBefore = wallet.balance;
    const balanceAfter = new Decimal(wallet.balance).plus(amount);

    // Check if new balance would exceed maximum limit
    if (balanceAfter.greaterThan(MAX_WALLET_BALANCE)) {
      throw new BadRequestException(`Deposit would exceed maximum wallet balance of ${MAX_WALLET_BALANCE.toLocaleString()} KRW`);
    }

    try {
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

      this.logger.log(`Deposit completed: user=${userId}, amount=${amount}, newBalance=${balanceAfter}`);

      return {
        wallet: updatedWallet,
        transaction,
      };
    } catch (error) {
      this.logger.error(`Deposit failed for user ${userId}: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to process deposit. Please try again later.');
    }
  }

  async transfer(
    fromUserId: string,
    toUserId: string,
    amount: number,
    type: TransactionType,
    description?: string,
    referenceId?: string,
  ) {
    if (!fromUserId) {
      throw new BadRequestException('Sender user ID is required');
    }

    if (!toUserId) {
      throw new BadRequestException('Recipient user ID is required');
    }

    if (fromUserId === toUserId) {
      throw new BadRequestException('Cannot transfer to yourself');
    }

    if (typeof amount !== 'number' || isNaN(amount)) {
      throw new BadRequestException('Amount must be a valid number');
    }

    if (amount <= 0) {
      throw new BadRequestException('Amount must be positive');
    }

    if (amount > MAX_SINGLE_TRANSACTION) {
      throw new BadRequestException(`Maximum single transfer amount is ${MAX_SINGLE_TRANSACTION.toLocaleString()} KRW`);
    }

    // Verify both users exist
    const [fromUser, toUser] = await Promise.all([
      this.prisma.user.findUnique({ where: { id: fromUserId } }),
      this.prisma.user.findUnique({ where: { id: toUserId } }),
    ]);

    if (!fromUser) {
      throw new NotFoundException('Sender user not found');
    }

    if (!toUser) {
      throw new NotFoundException('Recipient user not found');
    }

    const fromWallet = await this.getOrCreateWallet(fromUserId);
    const toWallet = await this.getOrCreateWallet(toUserId);

    if (new Decimal(fromWallet.balance).lessThan(amount)) {
      throw new BadRequestException(`Insufficient balance. Current balance: ${fromWallet.balance} KRW, required: ${amount} KRW`);
    }

    const fromBalanceBefore = fromWallet.balance;
    const fromBalanceAfter = new Decimal(fromWallet.balance).minus(amount);
    const toBalanceBefore = toWallet.balance;
    const toBalanceAfter = new Decimal(toWallet.balance).plus(amount);

    // Check if recipient's new balance would exceed maximum limit
    if (toBalanceAfter.greaterThan(MAX_WALLET_BALANCE)) {
      throw new BadRequestException('Transfer would exceed recipient\'s maximum wallet balance');
    }

    try {
      const result = await this.prisma.$transaction([
        this.prisma.wallet.update({
          where: { id: fromWallet.id },
          data: { balance: fromBalanceAfter },
        }),
        this.prisma.wallet.update({
          where: { id: toWallet.id },
          data: { balance: toBalanceAfter },
        }),
        this.prisma.transaction.create({
          data: {
            walletId: fromWallet.id,
            type: type === TransactionType.SUPPORT_SENT ? TransactionType.SUPPORT_SENT : TransactionType.SUBSCRIPTION_PAYMENT,
            amount: new Decimal(-amount),
            balanceBefore: fromBalanceBefore,
            balanceAfter: fromBalanceAfter,
            description,
            referenceId,
            status: TransactionStatus.COMPLETED,
          },
        }),
        this.prisma.transaction.create({
          data: {
            walletId: toWallet.id,
            type: type === TransactionType.SUPPORT_SENT ? TransactionType.SUPPORT_RECEIVED : TransactionType.SUPPORT_RECEIVED,
            amount: new Decimal(amount),
            balanceBefore: toBalanceBefore,
            balanceAfter: toBalanceAfter,
            description,
            referenceId,
            status: TransactionStatus.COMPLETED,
          },
        }),
      ]);

      this.logger.log(`Transfer completed: from=${fromUserId}, to=${toUserId}, amount=${amount}, type=${type}`);

      return {
        fromWallet: result[0],
        toWallet: result[1],
      };
    } catch (error) {
      this.logger.error(`Transfer failed: from=${fromUserId}, to=${toUserId}, amount=${amount}: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to process transfer. Please try again later.');
    }
  }
}
