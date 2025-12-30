import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { CreateTierDto } from './dto/create-tier.dto';
import { SubscribeDto } from './dto/subscribe.dto';
import { TransactionType, SubscriptionStatus } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

@Injectable()
export class SubscriptionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly walletService: WalletService,
  ) {}

  async createTier(userId: string, createTierDto: CreateTierDto) {
    const idolProfile = await this.prisma.idolProfile.findUnique({
      where: { userId },
    });

    if (!idolProfile) {
      throw new NotFoundException('Idol profile not found');
    }

    return this.prisma.subscriptionTier.create({
      data: {
        idolProfileId: idolProfile.id,
        name: createTierDto.name,
        price: new Decimal(createTierDto.price),
        benefits: createTierDto.benefits,
        maxSubscribers: createTierDto.maxSubscribers,
      },
    });
  }

  async getTiers(idolUserId: string) {
    const idolProfile = await this.prisma.idolProfile.findUnique({
      where: { userId: idolUserId },
    });

    if (!idolProfile) {
      throw new NotFoundException('Idol profile not found');
    }

    return this.prisma.subscriptionTier.findMany({
      where: { idolProfileId: idolProfile.id, isActive: true },
      orderBy: { price: 'asc' },
    });
  }

  async subscribe(subscriberId: string, subscribeDto: SubscribeDto) {
    const { creatorId, tierId } = subscribeDto;

    if (subscriberId === creatorId) {
      throw new BadRequestException('Cannot subscribe to yourself');
    }

    // Check if already subscribed
    const existingSubscription = await this.prisma.subscription.findUnique({
      where: {
        subscriberId_creatorId: { subscriberId, creatorId },
      },
    });

    if (existingSubscription && existingSubscription.status === SubscriptionStatus.ACTIVE) {
      throw new ConflictException('Already subscribed to this creator');
    }

    // Get tier info
    const tier = await this.prisma.subscriptionTier.findUnique({
      where: { id: tierId },
      include: { idolProfile: true },
    });

    if (!tier || !tier.isActive) {
      throw new NotFoundException('Subscription tier not found');
    }

    // Check max subscribers limit
    if (tier.maxSubscribers) {
      const currentSubscribers = await this.prisma.subscription.count({
        where: { tierId, status: SubscriptionStatus.ACTIVE },
      });
      if (currentSubscribers >= tier.maxSubscribers) {
        throw new BadRequestException('This tier has reached maximum subscribers');
      }
    }

    // Process payment
    await this.walletService.transfer(
      subscriberId,
      creatorId,
      Number(tier.price),
      TransactionType.SUBSCRIPTION_PAYMENT,
      `Subscription to ${tier.name}`,
      tierId,
    );

    // Create or update subscription
    const renewalDate = new Date();
    renewalDate.setMonth(renewalDate.getMonth() + 1);

    if (existingSubscription) {
      return this.prisma.subscription.update({
        where: { id: existingSubscription.id },
        data: {
          tierId,
          status: SubscriptionStatus.ACTIVE,
          startDate: new Date(),
          renewalDate,
        },
        include: {
          tier: true,
          creator: {
            select: { id: true, nickname: true, profileImage: true },
          },
        },
      });
    }

    const subscription = await this.prisma.subscription.create({
      data: {
        subscriberId,
        creatorId,
        tierId,
        renewalDate,
      },
      include: {
        tier: true,
        creator: {
          select: { id: true, nickname: true, profileImage: true },
        },
      },
    });

    // Create notification for creator
    await this.prisma.notification.create({
      data: {
        userId: creatorId,
        type: 'NEW_SUBSCRIBER',
        title: 'New Subscriber!',
        message: `You have a new subscriber for ${tier.name}!`,
        data: { subscriptionId: subscription.id, tierId },
      },
    });

    return subscription;
  }

  async cancelSubscription(subscriberId: string, creatorId: string) {
    const subscription = await this.prisma.subscription.findUnique({
      where: {
        subscriberId_creatorId: { subscriberId, creatorId },
      },
    });

    if (!subscription) {
      throw new NotFoundException('Subscription not found');
    }

    return this.prisma.subscription.update({
      where: { id: subscription.id },
      data: {
        status: SubscriptionStatus.CANCELLED,
        endDate: new Date(),
      },
    });
  }

  async getMySubscriptions(userId: string) {
    return this.prisma.subscription.findMany({
      where: {
        subscriberId: userId,
        status: SubscriptionStatus.ACTIVE,
      },
      include: {
        tier: true,
        creator: {
          select: { id: true, nickname: true, profileImage: true },
          include: {
            idolProfile: {
              select: { stageName: true, category: true },
            },
          },
        },
      },
      orderBy: { startDate: 'desc' },
    });
  }

  async getMySubscribers(userId: string) {
    return this.prisma.subscription.findMany({
      where: {
        creatorId: userId,
        status: SubscriptionStatus.ACTIVE,
      },
      include: {
        tier: true,
        subscriber: {
          select: { id: true, nickname: true, profileImage: true },
        },
      },
      orderBy: { startDate: 'desc' },
    });
  }

  async checkSubscription(subscriberId: string, creatorId: string) {
    const subscription = await this.prisma.subscription.findUnique({
      where: {
        subscriberId_creatorId: { subscriberId, creatorId },
      },
      include: { tier: true },
    });

    return {
      isSubscribed: subscription?.status === SubscriptionStatus.ACTIVE,
      subscription,
    };
  }
}
