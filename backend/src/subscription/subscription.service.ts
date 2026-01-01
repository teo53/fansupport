import { Injectable, NotFoundException, BadRequestException, ConflictException, InternalServerErrorException, Logger } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { CreateTierDto } from './dto/create-tier.dto';
import { SubscribeDto } from './dto/subscribe.dto';
import { TransactionType, SubscriptionStatus } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

const MIN_TIER_PRICE = 1000; // Minimum tier price in KRW
const MAX_TIER_PRICE = 1000000; // Maximum tier price in KRW
const MAX_TIER_NAME_LENGTH = 50;
const MAX_BENEFITS_LENGTH = 1000;

@Injectable()
export class SubscriptionService {
  private readonly logger = new Logger(SubscriptionService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly walletService: WalletService,
  ) {}

  async createTier(userId: string, createTierDto: CreateTierDto) {
    // Validate user ID
    if (!userId) {
      throw new BadRequestException('User ID is required');
    }

    // Validate tier name
    if (!createTierDto.name || createTierDto.name.trim().length === 0) {
      throw new BadRequestException('Tier name is required');
    }

    if (createTierDto.name.length > MAX_TIER_NAME_LENGTH) {
      throw new BadRequestException(`Tier name cannot exceed ${MAX_TIER_NAME_LENGTH} characters`);
    }

    // Validate price
    if (typeof createTierDto.price !== 'number' || isNaN(createTierDto.price)) {
      throw new BadRequestException('Price must be a valid number');
    }

    if (createTierDto.price < MIN_TIER_PRICE) {
      throw new BadRequestException(`Minimum tier price is ${MIN_TIER_PRICE.toLocaleString()} KRW`);
    }

    if (createTierDto.price > MAX_TIER_PRICE) {
      throw new BadRequestException(`Maximum tier price is ${MAX_TIER_PRICE.toLocaleString()} KRW`);
    }

    // Validate benefits
    if (!createTierDto.benefits || createTierDto.benefits.trim().length === 0) {
      throw new BadRequestException('Tier benefits description is required');
    }

    if (createTierDto.benefits.length > MAX_BENEFITS_LENGTH) {
      throw new BadRequestException(`Benefits description cannot exceed ${MAX_BENEFITS_LENGTH} characters`);
    }

    // Validate max subscribers if provided
    if (createTierDto.maxSubscribers !== undefined && createTierDto.maxSubscribers !== null) {
      if (createTierDto.maxSubscribers < 1) {
        throw new BadRequestException('Maximum subscribers must be at least 1');
      }
    }

    const idolProfile = await this.prisma.idolProfile.findUnique({
      where: { userId },
    });

    if (!idolProfile) {
      throw new NotFoundException('Idol profile not found. Only idol accounts can create subscription tiers.');
    }

    try {
      return this.prisma.subscriptionTier.create({
        data: {
          idolProfileId: idolProfile.id,
          name: createTierDto.name.trim(),
          price: new Decimal(createTierDto.price),
          benefits: createTierDto.benefits.trim(),
          maxSubscribers: createTierDto.maxSubscribers,
        },
      });
    } catch (error) {
      this.logger.error(`Failed to create subscription tier: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to create subscription tier. Please try again later.');
    }
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

    // Validate subscriber ID
    if (!subscriberId) {
      throw new BadRequestException('Subscriber ID is required');
    }

    // Validate creator ID
    if (!creatorId) {
      throw new BadRequestException('Creator ID is required');
    }

    // Validate tier ID
    if (!tierId) {
      throw new BadRequestException('Tier ID is required');
    }

    if (subscriberId === creatorId) {
      throw new BadRequestException('Cannot subscribe to yourself');
    }

    // Verify subscriber exists
    const subscriber = await this.prisma.user.findUnique({ where: { id: subscriberId } });
    if (!subscriber) {
      throw new NotFoundException('Subscriber account not found');
    }

    // Verify creator exists
    const creator = await this.prisma.user.findUnique({
      where: { id: creatorId },
      include: { idolProfile: true },
    });
    if (!creator) {
      throw new NotFoundException('Creator not found');
    }

    if (!creator.idolProfile) {
      throw new BadRequestException('Can only subscribe to idol accounts');
    }

    // Check if already subscribed
    const existingSubscription = await this.prisma.subscription.findUnique({
      where: {
        subscriberId_creatorId: { subscriberId, creatorId },
      },
    });

    if (existingSubscription && existingSubscription.status === SubscriptionStatus.ACTIVE) {
      throw new ConflictException('You are already subscribed to this creator. Please manage your existing subscription.');
    }

    // Get tier info
    const tier = await this.prisma.subscriptionTier.findUnique({
      where: { id: tierId },
      include: { idolProfile: true },
    });

    if (!tier) {
      throw new NotFoundException('Subscription tier not found');
    }

    if (!tier.isActive) {
      throw new BadRequestException('This subscription tier is no longer available');
    }

    // Verify the tier belongs to the correct creator
    if (tier.idolProfile.userId !== creatorId) {
      throw new BadRequestException('Selected tier does not belong to this creator');
    }

    // Check max subscribers limit
    if (tier.maxSubscribers) {
      const currentSubscribers = await this.prisma.subscription.count({
        where: { tierId, status: SubscriptionStatus.ACTIVE },
      });
      if (currentSubscribers >= tier.maxSubscribers) {
        throw new BadRequestException(`This tier has reached its maximum limit of ${tier.maxSubscribers} subscribers`);
      }
    }

    try {
      // Use transaction for atomicity
      const result = await this.prisma.$transaction(async (tx) => {
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

        let subscription;

        if (existingSubscription) {
          subscription = await tx.subscription.update({
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
        } else {
          subscription = await tx.subscription.create({
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
        }

        // Create notification for creator
        await tx.notification.create({
          data: {
            userId: creatorId,
            type: 'NEW_SUBSCRIBER',
            title: 'New Subscriber!',
            message: `${subscriber.nickname} has subscribed to your ${tier.name} tier!`,
            data: { subscriptionId: subscription.id, tierId },
          },
        });

        return subscription;
      });

      this.logger.log(`Subscription created: subscriber=${subscriberId}, creator=${creatorId}, tier=${tierId}`);
      return result;
    } catch (error) {
      // Re-throw known errors
      if (error instanceof BadRequestException || error instanceof NotFoundException || error instanceof ConflictException) {
        throw error;
      }

      this.logger.error(`Subscription failed: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to process subscription. Please try again later.');
    }
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
