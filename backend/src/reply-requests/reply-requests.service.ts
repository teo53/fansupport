import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { CreateReplyRequestDto, DeliverReplyDto, RejectReplyDto, FanFeedbackDto } from './dto';
import {
  ReplyRequestStatus,
  TransactionType,
  TransactionStatus,
  ReplyRefundReason,
} from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

@Injectable()
export class ReplyRequestsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly walletService: WalletService,
  ) {}

  /**
   * Create a new reply request with escrow payment
   */
  async createRequest(requesterId: string, dto: CreateReplyRequestDto) {
    const { creatorId, productId, slaId, requestMessage, isAnonymous } = dto;

    if (requesterId === creatorId) {
      throw new BadRequestException('Cannot request a reply from yourself');
    }

    // Validate product and SLA exist and are active
    const product = await this.prisma.replyProduct.findUnique({
      where: { id: productId },
      include: { idolProfile: true },
    });

    if (!product || !product.isActive) {
      throw new NotFoundException('Product not found or inactive');
    }

    if (product.idolProfile.userId !== creatorId) {
      throw new BadRequestException('Product does not belong to this creator');
    }

    const sla = await this.prisma.replySLA.findUnique({
      where: { id: slaId },
    });

    if (!sla || !sla.isActive || sla.replyProductId !== productId) {
      throw new NotFoundException('SLA option not found or invalid');
    }

    // Check slot availability
    const slotPolicy = await this.prisma.replySlotPolicy.findUnique({
      where: { idolProfileId: product.idolProfileId },
    });

    if (slotPolicy) {
      const todayStart = new Date();
      todayStart.setHours(0, 0, 0, 0);
      const todayEnd = new Date();
      todayEnd.setHours(23, 59, 59, 999);

      const todayRequestCount = await this.prisma.replyRequest.count({
        where: {
          creatorId,
          createdAt: { gte: todayStart, lte: todayEnd },
          status: { in: ['QUEUED', 'IN_PROGRESS', 'DELIVERED'] },
        },
      });

      if (todayRequestCount >= slotPolicy.dailySlotLimit) {
        throw new BadRequestException('Creator has reached daily slot limit');
      }
    }

    // Calculate price
    const basePrice = new Decimal(product.basePrice);
    const slaMultiplier = new Decimal(sla.priceMultiplier);
    const totalPrice = basePrice.mul(slaMultiplier);

    // Check requester's balance
    const wallet = await this.walletService.getOrCreateWallet(requesterId);
    if (new Decimal(wallet.balance).lessThan(totalPrice)) {
      throw new BadRequestException('Insufficient balance');
    }

    // Create request with escrow in transaction
    const request = await this.prisma.$transaction(async (tx) => {
      // Deduct from requester wallet (escrow)
      const balanceBefore = wallet.balance;
      const balanceAfter = new Decimal(wallet.balance).minus(totalPrice);

      await tx.wallet.update({
        where: { id: wallet.id },
        data: { balance: balanceAfter },
      });

      await tx.transaction.create({
        data: {
          walletId: wallet.id,
          type: TransactionType.REPLY_REQUEST_ESCROW,
          amount: totalPrice.negated(),
          balanceBefore,
          balanceAfter,
          description: `Reply request escrow`,
          status: TransactionStatus.COMPLETED,
        },
      });

      // Calculate queue position
      const queuePosition = await tx.replyRequest.count({
        where: {
          creatorId,
          status: { in: ['QUEUED', 'IN_PROGRESS'] },
        },
      });

      // Calculate deadline
      const now = new Date();
      const deadlineAt = new Date(now.getTime() + sla.deadlineHours * 60 * 60 * 1000);

      // Create the request
      const newRequest = await tx.replyRequest.create({
        data: {
          requesterId,
          creatorId,
          productId,
          slaId,
          requestMessage,
          isAnonymous: isAnonymous ?? false,
          basePrice: basePrice,
          slaPrice: totalPrice.minus(basePrice),
          totalPrice: totalPrice,
          escrowAmount: totalPrice,
          status: ReplyRequestStatus.QUEUED,
          queuePosition: queuePosition + 1,
          paidAt: now,
          queuedAt: now,
          deadlineAt,
        },
        include: {
          requester: { select: { id: true, nickname: true, profileImage: true } },
          creator: { select: { id: true, nickname: true, profileImage: true } },
          product: true,
          sla: true,
        },
      });

      // Create notification for creator
      const requester = await tx.user.findUnique({ where: { id: requesterId } });
      await tx.notification.create({
        data: {
          userId: creatorId,
          type: 'REPLY_REQUEST_RECEIVED',
          title: 'New Reply Request!',
          message: isAnonymous
            ? `Anonymous fan requested a ${product.name}!`
            : `${requester?.nickname} requested a ${product.name}!`,
          data: { requestId: newRequest.id, productName: product.name },
        },
      });

      return newRequest;
    });

    return request;
  }

  /**
   * Get reply requests for a fan (requester)
   */
  async getMyRequests(
    requesterId: string,
    options: { status?: ReplyRequestStatus; page?: number; limit?: number },
  ) {
    const { status, page = 1, limit = 20 } = options;
    const where: any = { requesterId };
    if (status) where.status = status;

    const [requests, total] = await Promise.all([
      this.prisma.replyRequest.findMany({
        where,
        include: {
          creator: { select: { id: true, nickname: true, profileImage: true } },
          product: true,
          sla: true,
          delivery: true,
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.replyRequest.count({ where }),
    ]);

    return {
      data: requests,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  /**
   * Get single request detail
   */
  async getRequestById(requestId: string, userId: string) {
    const request = await this.prisma.replyRequest.findUnique({
      where: { id: requestId },
      include: {
        requester: { select: { id: true, nickname: true, profileImage: true } },
        creator: { select: { id: true, nickname: true, profileImage: true } },
        product: true,
        sla: true,
        delivery: true,
        refund: true,
      },
    });

    if (!request) {
      throw new NotFoundException('Request not found');
    }

    // Only requester or creator can view
    if (request.requesterId !== userId && request.creatorId !== userId) {
      throw new ForbiddenException('Not authorized to view this request');
    }

    // Hide requester info if anonymous (for creator view)
    if (request.isAnonymous && request.creatorId === userId) {
      return {
        ...request,
        requester: { id: 'anonymous', nickname: 'Anonymous', profileImage: null },
      };
    }

    return request;
  }

  /**
   * Get creator's queue (pending requests to fulfill)
   */
  async getCreatorQueue(
    creatorId: string,
    options: { page?: number; limit?: number },
  ) {
    const { page = 1, limit = 20 } = options;

    const [requests, total] = await Promise.all([
      this.prisma.replyRequest.findMany({
        where: {
          creatorId,
          status: { in: ['QUEUED', 'IN_PROGRESS'] },
        },
        include: {
          requester: { select: { id: true, nickname: true, profileImage: true } },
          product: true,
          sla: true,
        },
        orderBy: [
          { deadlineAt: 'asc' }, // Urgent first
          { queuePosition: 'asc' },
        ],
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.replyRequest.count({
        where: {
          creatorId,
          status: { in: ['QUEUED', 'IN_PROGRESS'] },
        },
      }),
    ]);

    // Hide requester info for anonymous requests
    const processedRequests = requests.map((req) => {
      if (req.isAnonymous) {
        return {
          ...req,
          requester: { id: 'anonymous', nickname: 'Anonymous', profileImage: null },
        };
      }
      return req;
    });

    // Get today's stats
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const [todayDelivered, totalDelivered, slotPolicy] = await Promise.all([
      this.prisma.replyRequest.count({
        where: {
          creatorId,
          status: 'DELIVERED',
          deliveredAt: { gte: todayStart },
        },
      }),
      this.prisma.replyRequest.count({
        where: { creatorId, status: 'DELIVERED' },
      }),
      this.prisma.replySlotPolicy.findFirst({
        where: { idolProfile: { userId: creatorId } },
      }),
    ]);

    return {
      data: processedRequests,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
      stats: {
        queueCount: total,
        todayDelivered,
        totalDelivered,
        dailySlotLimit: slotPolicy?.dailySlotLimit ?? 10,
        remainingSlots: Math.max(0, (slotPolicy?.dailySlotLimit ?? 10) - todayDelivered),
      },
    };
  }

  /**
   * Creator delivers a reply
   */
  async deliverReply(requestId: string, creatorId: string, dto: DeliverReplyDto) {
    const request = await this.prisma.replyRequest.findUnique({
      where: { id: requestId },
      include: { product: true },
    });

    if (!request) {
      throw new NotFoundException('Request not found');
    }

    if (request.creatorId !== creatorId) {
      throw new ForbiddenException('Not authorized to deliver this request');
    }

    if (!['QUEUED', 'IN_PROGRESS'].includes(request.status)) {
      throw new BadRequestException(`Cannot deliver request with status: ${request.status}`);
    }

    // Validate content based on product type
    const contentType = request.product.contentType;
    if (contentType === 'TEXT' && !dto.textContent) {
      throw new BadRequestException('Text content is required for this product');
    }
    if (contentType === 'VOICE' && !dto.voiceUrl) {
      throw new BadRequestException('Voice URL is required for this product');
    }
    if (contentType === 'PHOTO' && (!dto.photoUrls || dto.photoUrls.length === 0)) {
      throw new BadRequestException('Photo URLs are required for this product');
    }
    if (contentType === 'VIDEO' && !dto.videoUrl) {
      throw new BadRequestException('Video URL is required for this product');
    }

    const result = await this.prisma.$transaction(async (tx) => {
      const now = new Date();

      // Create delivery
      const delivery = await tx.replyDelivery.create({
        data: {
          replyRequestId: requestId,
          textContent: dto.textContent,
          voiceUrl: dto.voiceUrl,
          photoUrls: dto.photoUrls ?? [],
          videoUrl: dto.videoUrl,
          duration: dto.duration,
          creatorNote: dto.creatorNote,
        },
      });

      // Update request status
      const updatedRequest = await tx.replyRequest.update({
        where: { id: requestId },
        data: {
          status: ReplyRequestStatus.DELIVERED,
          deliveredAt: now,
        },
        include: {
          requester: { select: { id: true, nickname: true, profileImage: true } },
          creator: { select: { id: true, nickname: true, profileImage: true } },
          product: true,
          sla: true,
          delivery: true,
        },
      });

      // Release escrow to creator
      const creatorWallet = await this.walletService.getOrCreateWallet(creatorId);
      const balanceBefore = creatorWallet.balance;
      const balanceAfter = new Decimal(creatorWallet.balance).plus(request.escrowAmount);

      await tx.wallet.update({
        where: { id: creatorWallet.id },
        data: { balance: balanceAfter },
      });

      await tx.transaction.create({
        data: {
          walletId: creatorWallet.id,
          type: TransactionType.REPLY_REQUEST_RELEASE,
          amount: request.escrowAmount,
          balanceBefore,
          balanceAfter,
          description: `Reply delivery payment`,
          referenceId: requestId,
          referenceType: 'REPLY_REQUEST',
          status: TransactionStatus.COMPLETED,
        },
      });

      // Notify requester
      await tx.notification.create({
        data: {
          userId: request.requesterId,
          type: 'REPLY_REQUEST_DELIVERED',
          title: 'Your reply is ready!',
          message: `Your ${request.product.name} request has been delivered!`,
          data: { requestId: request.id },
        },
      });

      return updatedRequest;
    });

    return result;
  }

  /**
   * Creator rejects a request (with refund)
   */
  async rejectRequest(requestId: string, creatorId: string, dto: RejectReplyDto) {
    const request = await this.prisma.replyRequest.findUnique({
      where: { id: requestId },
    });

    if (!request) {
      throw new NotFoundException('Request not found');
    }

    if (request.creatorId !== creatorId) {
      throw new ForbiddenException('Not authorized to reject this request');
    }

    if (!['QUEUED', 'IN_PROGRESS'].includes(request.status)) {
      throw new BadRequestException(`Cannot reject request with status: ${request.status}`);
    }

    const result = await this.prisma.$transaction(async (tx) => {
      const now = new Date();

      // Update request status
      const updatedRequest = await tx.replyRequest.update({
        where: { id: requestId },
        data: {
          status: ReplyRequestStatus.REJECTED,
          refundedAt: now,
        },
      });

      // Refund to requester
      const requesterWallet = await this.walletService.getOrCreateWallet(request.requesterId);
      const balanceBefore = requesterWallet.balance;
      const balanceAfter = new Decimal(requesterWallet.balance).plus(request.escrowAmount);

      await tx.wallet.update({
        where: { id: requesterWallet.id },
        data: { balance: balanceAfter },
      });

      await tx.transaction.create({
        data: {
          walletId: requesterWallet.id,
          type: TransactionType.REPLY_REQUEST_REFUND,
          amount: request.escrowAmount,
          balanceBefore,
          balanceAfter,
          description: `Reply request rejected - refund`,
          referenceId: requestId,
          referenceType: 'REPLY_REQUEST',
          status: TransactionStatus.COMPLETED,
        },
      });

      // Create refund record
      await tx.replyRefund.create({
        data: {
          replyRequestId: requestId,
          reason: ReplyRefundReason.CREATOR_REJECTED,
          amount: request.escrowAmount,
          description: dto.reason,
        },
      });

      // Notify requester
      await tx.notification.create({
        data: {
          userId: request.requesterId,
          type: 'REPLY_REQUEST_REFUNDED',
          title: 'Request Rejected',
          message: `Your reply request was rejected. Full refund has been processed.`,
          data: { requestId: request.id, reason: dto.reason },
        },
      });

      return updatedRequest;
    });

    return result;
  }

  /**
   * Process expired requests (called by cron)
   */
  async processExpiredRequests() {
    const now = new Date();

    const expiredRequests = await this.prisma.replyRequest.findMany({
      where: {
        status: { in: ['QUEUED', 'IN_PROGRESS'] },
        deadlineAt: { lt: now },
      },
    });

    const results = [];

    for (const request of expiredRequests) {
      try {
        const result = await this.prisma.$transaction(async (tx) => {
          // Update request status
          const updatedRequest = await tx.replyRequest.update({
            where: { id: request.id },
            data: {
              status: ReplyRequestStatus.EXPIRED,
              expiredAt: now,
              refundedAt: now,
            },
          });

          // Refund to requester
          const requesterWallet = await this.walletService.getOrCreateWallet(request.requesterId);
          const balanceBefore = requesterWallet.balance;
          const balanceAfter = new Decimal(requesterWallet.balance).plus(request.escrowAmount);

          await tx.wallet.update({
            where: { id: requesterWallet.id },
            data: { balance: balanceAfter },
          });

          await tx.transaction.create({
            data: {
              walletId: requesterWallet.id,
              type: TransactionType.REPLY_REQUEST_REFUND,
              amount: request.escrowAmount,
              balanceBefore,
              balanceAfter,
              description: `Reply request expired - auto refund`,
              referenceId: request.id,
              referenceType: 'REPLY_REQUEST',
              status: TransactionStatus.COMPLETED,
            },
          });

          // Create refund record
          await tx.replyRefund.create({
            data: {
              replyRequestId: request.id,
              reason: ReplyRefundReason.SLA_EXPIRED,
              amount: request.escrowAmount,
              description: 'Automatic refund due to SLA expiry',
              processedBy: 'SYSTEM',
            },
          });

          // Notify requester
          await tx.notification.create({
            data: {
              userId: request.requesterId,
              type: 'REPLY_REQUEST_EXPIRED',
              title: 'Request Expired',
              message: `Your reply request has expired. Full refund has been processed.`,
              data: { requestId: request.id },
            },
          });

          return updatedRequest;
        });

        results.push({ id: request.id, status: 'refunded' });
      } catch (error) {
        results.push({ id: request.id, status: 'error', error: error.message });
      }
    }

    return {
      processed: results.length,
      results,
    };
  }

  /**
   * Fan submits feedback for a delivered reply
   */
  async submitFeedback(requestId: string, requesterId: string, dto: FanFeedbackDto) {
    const request = await this.prisma.replyRequest.findUnique({
      where: { id: requestId },
      include: { delivery: true },
    });

    if (!request) {
      throw new NotFoundException('Request not found');
    }

    if (request.requesterId !== requesterId) {
      throw new ForbiddenException('Not authorized to submit feedback');
    }

    if (request.status !== 'DELIVERED' || !request.delivery) {
      throw new BadRequestException('Can only submit feedback for delivered requests');
    }

    const delivery = await this.prisma.replyDelivery.update({
      where: { id: request.delivery.id },
      data: {
        fanRating: dto.rating,
        fanFeedback: dto.feedback,
        isPublicAllowed: dto.isPublicAllowed ?? false,
      },
    });

    return delivery;
  }

  /**
   * Get creator's products and SLA options
   */
  async getCreatorProducts(creatorId: string) {
    const profile = await this.prisma.idolProfile.findFirst({
      where: { userId: creatorId },
    });

    if (!profile) {
      throw new NotFoundException('Creator profile not found');
    }

    const products = await this.prisma.replyProduct.findMany({
      where: { idolProfileId: profile.id, isActive: true },
      include: {
        slaOptions: {
          where: { isActive: true },
          orderBy: { sortOrder: 'asc' },
        },
      },
      orderBy: { sortOrder: 'asc' },
    });

    const slotPolicy = await this.prisma.replySlotPolicy.findUnique({
      where: { idolProfileId: profile.id },
    });

    // Get today's remaining slots
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const todayRequestCount = await this.prisma.replyRequest.count({
      where: {
        creatorId,
        createdAt: { gte: todayStart },
        status: { in: ['QUEUED', 'IN_PROGRESS', 'DELIVERED'] },
      },
    });

    return {
      products,
      slotPolicy: slotPolicy ?? { dailySlotLimit: 10, isAutoClose: true },
      todayStats: {
        requestCount: todayRequestCount,
        remainingSlots: Math.max(0, (slotPolicy?.dailySlotLimit ?? 10) - todayRequestCount),
      },
    };
  }

  /**
   * Start working on a request (set IN_PROGRESS)
   */
  async startRequest(requestId: string, creatorId: string) {
    const request = await this.prisma.replyRequest.findUnique({
      where: { id: requestId },
    });

    if (!request) {
      throw new NotFoundException('Request not found');
    }

    if (request.creatorId !== creatorId) {
      throw new ForbiddenException('Not authorized');
    }

    if (request.status !== 'QUEUED') {
      throw new BadRequestException(`Cannot start request with status: ${request.status}`);
    }

    return this.prisma.replyRequest.update({
      where: { id: requestId },
      data: {
        status: ReplyRequestStatus.IN_PROGRESS,
        startedAt: new Date(),
      },
    });
  }
}
