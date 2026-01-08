import { Test, TestingModule } from '@nestjs/testing';
import { WalletService } from './wallet.service';
import { PrismaService } from '../database/prisma.service';
import { createMockPrismaService } from '../../test/helpers/test-database.helper';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { TransactionType } from '@prisma/client';

describe('WalletService', () => {
  let service: WalletService;
  let prisma: ReturnType<typeof createMockPrismaService>;

  const mockWallet = {
    id: 'wallet-123',
    userId: 'user-123',
    balance: 10000,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockTransaction = {
    id: 'tx-123',
    walletId: 'wallet-123',
    type: TransactionType.DEPOSIT,
    amount: 5000,
    description: 'Test deposit',
    createdAt: new Date(),
  };

  beforeEach(async () => {
    prisma = createMockPrismaService();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WalletService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<WalletService>(WalletService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getWalletByUserId', () => {
    it('should return wallet for user', async () => {
      prisma.wallet.findFirst.mockResolvedValue(mockWallet);

      const result = await service.getWalletByUserId('user-123');

      expect(result).toEqual(mockWallet);
      expect(prisma.wallet.findFirst).toHaveBeenCalledWith({
        where: { userId: 'user-123' },
        include: expect.any(Object),
      });
    });

    it('should throw NotFoundException when wallet not found', async () => {
      prisma.wallet.findFirst.mockResolvedValue(null);

      await expect(service.getWalletByUserId('nonexistent')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('deposit', () => {
    it('should add balance and create transaction', async () => {
      const depositAmount = 5000;
      const updatedWallet = { ...mockWallet, balance: mockWallet.balance + depositAmount };

      prisma.wallet.findFirst.mockResolvedValue(mockWallet);
      prisma.$transaction.mockImplementation(async (callback) => {
        prisma.wallet.update.mockResolvedValue(updatedWallet);
        prisma.transaction.create.mockResolvedValue(mockTransaction);
        return callback(prisma);
      });

      const result = await service.deposit('user-123', depositAmount, 'Test deposit');

      expect(result.balance).toBe(15000);
    });

    it('should throw BadRequestException for invalid amount', async () => {
      await expect(service.deposit('user-123', -100, 'Invalid')).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('withdraw', () => {
    it('should deduct balance and create transaction', async () => {
      const withdrawAmount = 3000;
      const updatedWallet = { ...mockWallet, balance: mockWallet.balance - withdrawAmount };

      prisma.wallet.findFirst.mockResolvedValue(mockWallet);
      prisma.$transaction.mockImplementation(async (callback) => {
        prisma.wallet.update.mockResolvedValue(updatedWallet);
        prisma.transaction.create.mockResolvedValue({
          ...mockTransaction,
          type: TransactionType.WITHDRAWAL,
          amount: -withdrawAmount,
        });
        return callback(prisma);
      });

      const result = await service.withdraw('user-123', withdrawAmount, 'Test withdrawal');

      expect(result.balance).toBe(7000);
    });

    it('should throw BadRequestException for insufficient balance', async () => {
      prisma.wallet.findFirst.mockResolvedValue(mockWallet);

      await expect(
        service.withdraw('user-123', 999999, 'Too much'),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('getTransactionHistory', () => {
    it('should return paginated transactions', async () => {
      const transactions = [mockTransaction];
      prisma.wallet.findFirst.mockResolvedValue(mockWallet);
      prisma.transaction.findMany.mockResolvedValue(transactions);

      const result = await service.getTransactionHistory('user-123', 1, 10);

      expect(result).toEqual(transactions);
      expect(prisma.transaction.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { walletId: mockWallet.id },
          take: 10,
          skip: 0,
        }),
      );
    });
  });
});
