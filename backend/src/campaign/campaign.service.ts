import { Injectable, NotFoundException, BadRequestException, ForbiddenException, InternalServerErrorException, Logger } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { ContributeDto } from './dto/contribute.dto';
import { CampaignStatus, TransactionType } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

const MIN_GOAL_AMOUNT = 10000; // Minimum goal amount in KRW
const MAX_GOAL_AMOUNT = 1000000000; // Maximum goal amount (1 billion KRW)
const MIN_CONTRIBUTION_AMOUNT = 1000; // Minimum contribution in KRW
const MAX_CAMPAIGN_DURATION_DAYS = 365; // Maximum campaign duration

@Injectable()
export class CampaignService {
  private readonly logger = new Logger(CampaignService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly walletService: WalletService,
  ) {}

  async createCampaign(creatorId: string, createCampaignDto: CreateCampaignDto) {
    const { title, description, coverImage, goalAmount, startDate, endDate, rewards } = createCampaignDto;

    // Validate creator ID
    if (!creatorId) {
      throw new BadRequestException('Creator ID is required');
    }

    // Validate title
    if (!title || title.trim().length === 0) {
      throw new BadRequestException('Campaign title is required');
    }

    if (title.length > 100) {
      throw new BadRequestException('Campaign title cannot exceed 100 characters');
    }

    // Validate description
    if (!description || description.trim().length === 0) {
      throw new BadRequestException('Campaign description is required');
    }

    if (description.length > 5000) {
      throw new BadRequestException('Campaign description cannot exceed 5000 characters');
    }

    // Validate goal amount
    if (typeof goalAmount !== 'number' || isNaN(goalAmount)) {
      throw new BadRequestException('Goal amount must be a valid number');
    }

    if (goalAmount < MIN_GOAL_AMOUNT) {
      throw new BadRequestException(`Minimum goal amount is ${MIN_GOAL_AMOUNT.toLocaleString()} KRW`);
    }

    if (goalAmount > MAX_GOAL_AMOUNT) {
      throw new BadRequestException(`Maximum goal amount is ${MAX_GOAL_AMOUNT.toLocaleString()} KRW`);
    }

    // Parse and validate dates
    let parsedStartDate: Date;
    let parsedEndDate: Date;

    try {
      parsedStartDate = new Date(startDate);
      if (isNaN(parsedStartDate.getTime())) {
        throw new Error('Invalid start date');
      }
    } catch {
      throw new BadRequestException('Invalid start date format');
    }

    try {
      parsedEndDate = new Date(endDate);
      if (isNaN(parsedEndDate.getTime())) {
        throw new Error('Invalid end date');
      }
    } catch {
      throw new BadRequestException('Invalid end date format');
    }

    if (parsedStartDate >= parsedEndDate) {
      throw new BadRequestException('End date must be after start date');
    }

    // Validate campaign duration
    const durationDays = Math.ceil((parsedEndDate.getTime() - parsedStartDate.getTime()) / (1000 * 60 * 60 * 24));
    if (durationDays > MAX_CAMPAIGN_DURATION_DAYS) {
      throw new BadRequestException(`Campaign duration cannot exceed ${MAX_CAMPAIGN_DURATION_DAYS} days`);
    }

    // Verify creator exists and is an idol
    const creator = await this.prisma.user.findUnique({
      where: { id: creatorId },
      include: { idolProfile: true },
    });

    if (!creator) {
      throw new NotFoundException('Creator not found');
    }

    if (!creator.idolProfile) {
      throw new ForbiddenException('Only idol accounts can create campaigns');
    }

    try {
      return this.prisma.campaign.create({
        data: {
          creatorId,
          title: title.trim(),
          description: description.trim(),
          coverImage,
          goalAmount: new Decimal(goalAmount),
          startDate: parsedStartDate,
          endDate: parsedEndDate,
          rewards,
          status: parsedStartDate <= new Date() ? CampaignStatus.ACTIVE : CampaignStatus.DRAFT,
        },
        include: {
          creator: {
            select: { id: true, nickname: true, profileImage: true },
          },
        },
      });
    } catch (error) {
      this.logger.error(`Failed to create campaign: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to create campaign. Please try again later.');
    }
  }

  async getCampaigns(options: {
    status?: CampaignStatus;
    creatorId?: string;
    page?: number;
    limit?: number;
  }) {
    const { status, creatorId, page = 1, limit = 20 } = options;

    const where: any = {};
    if (status) where.status = status;
    if (creatorId) where.creatorId = creatorId;

    const [campaigns, total] = await Promise.all([
      this.prisma.campaign.findMany({
        where,
        include: {
          creator: {
            select: { id: true, nickname: true, profileImage: true },
          },
          _count: { select: { contributions: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.campaign.count({ where }),
    ]);

    const campaignsWithProgress = campaigns.map((campaign) => ({
      ...campaign,
      progressPercentage: Number(campaign.currentAmount) / Number(campaign.goalAmount) * 100,
      daysLeft: Math.max(0, Math.ceil((new Date(campaign.endDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24))),
    }));

    return {
      data: campaignsWithProgress,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getCampaignById(id: string) {
    const campaign = await this.prisma.campaign.findUnique({
      where: { id },
      include: {
        creator: {
          select: { id: true, nickname: true, profileImage: true },
          include: {
            idolProfile: {
              select: { stageName: true, category: true },
            },
          },
        },
        contributions: {
          include: {
            user: {
              select: { id: true, nickname: true, profileImage: true },
            },
          },
          orderBy: { createdAt: 'desc' },
          take: 10,
        },
        _count: { select: { contributions: true } },
      },
    });

    if (!campaign) {
      throw new NotFoundException('Campaign not found');
    }

    // Process anonymous contributions
    const processedContributions = campaign.contributions.map((c) => ({
      ...c,
      user: c.isAnonymous ? { id: 'anonymous', nickname: 'Anonymous', profileImage: null } : c.user,
    }));

    return {
      ...campaign,
      contributions: processedContributions,
      progressPercentage: Number(campaign.currentAmount) / Number(campaign.goalAmount) * 100,
      daysLeft: Math.max(0, Math.ceil((new Date(campaign.endDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24))),
    };
  }

  async contribute(userId: string, campaignId: string, contributeDto: ContributeDto) {
    const { amount, rewardTier, message, isAnonymous } = contributeDto;

    // Validate user ID
    if (!userId) {
      throw new BadRequestException('User ID is required');
    }

    // Validate campaign ID
    if (!campaignId) {
      throw new BadRequestException('Campaign ID is required');
    }

    // Validate amount
    if (typeof amount !== 'number' || isNaN(amount)) {
      throw new BadRequestException('Amount must be a valid number');
    }

    if (amount < MIN_CONTRIBUTION_AMOUNT) {
      throw new BadRequestException(`Minimum contribution amount is ${MIN_CONTRIBUTION_AMOUNT.toLocaleString()} KRW`);
    }

    // Validate message length
    if (message && message.length > 500) {
      throw new BadRequestException('Contribution message cannot exceed 500 characters');
    }

    // Verify user exists
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const campaign = await this.prisma.campaign.findUnique({
      where: { id: campaignId },
    });

    if (!campaign) {
      throw new NotFoundException('Campaign not found');
    }

    // Check if contributing to own campaign
    if (campaign.creatorId === userId) {
      throw new BadRequestException('Cannot contribute to your own campaign');
    }

    if (campaign.status !== CampaignStatus.ACTIVE) {
      throw new BadRequestException('Campaign is not active. Only active campaigns accept contributions.');
    }

    if (new Date() > campaign.endDate) {
      throw new BadRequestException('Campaign has ended and is no longer accepting contributions');
    }

    try {
      // Use transaction for atomicity
      const result = await this.prisma.$transaction(async (tx) => {
        // Transfer funds
        await this.walletService.transfer(
          userId,
          campaign.creatorId,
          amount,
          TransactionType.CAMPAIGN_CONTRIBUTION,
          `Contribution to ${campaign.title}`,
          campaignId,
        );

        // Create contribution record
        const contribution = await tx.campaignContribution.create({
          data: {
            campaignId,
            userId,
            amount: new Decimal(amount),
            rewardTier,
            message: message?.trim(),
            isAnonymous,
          },
          include: {
            user: {
              select: { id: true, nickname: true, profileImage: true },
            },
          },
        });

        // Update campaign current amount
        const updatedCampaign = await tx.campaign.update({
          where: { id: campaignId },
          data: {
            currentAmount: { increment: amount },
          },
        });

        // Check if goal reached for the first time
        const wasGoalReached = Number(campaign.currentAmount) >= Number(campaign.goalAmount);
        const isGoalReached = Number(updatedCampaign.currentAmount) >= Number(updatedCampaign.goalAmount);

        if (isGoalReached && !wasGoalReached) {
          await tx.notification.create({
            data: {
              userId: campaign.creatorId,
              type: 'CAMPAIGN_GOAL_REACHED',
              title: 'Campaign Goal Reached!',
              message: `Congratulations! Your campaign "${campaign.title}" has reached its goal of ${Number(campaign.goalAmount).toLocaleString()} KRW!`,
              data: { campaignId },
            },
          });
        }

        return {
          contribution,
          campaign: {
            ...updatedCampaign,
            progressPercentage: Number(updatedCampaign.currentAmount) / Number(updatedCampaign.goalAmount) * 100,
          },
        };
      });

      this.logger.log(`Contribution made: user=${userId}, campaign=${campaignId}, amount=${amount}`);
      return result;
    } catch (error) {
      // Re-throw known errors
      if (error instanceof BadRequestException || error instanceof NotFoundException) {
        throw error;
      }

      this.logger.error(`Contribution failed: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to process contribution. Please try again later.');
    }
  }

  async updateCampaignStatus(creatorId: string, campaignId: string, status: CampaignStatus) {
    const campaign = await this.prisma.campaign.findUnique({
      where: { id: campaignId },
    });

    if (!campaign) {
      throw new NotFoundException('Campaign not found');
    }

    if (campaign.creatorId !== creatorId) {
      throw new ForbiddenException('Not authorized to update this campaign');
    }

    return this.prisma.campaign.update({
      where: { id: campaignId },
      data: { status },
    });
  }

  async getMyCampaigns(userId: string) {
    return this.prisma.campaign.findMany({
      where: { creatorId: userId },
      include: {
        _count: { select: { contributions: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getMyContributions(userId: string) {
    return this.prisma.campaignContribution.findMany({
      where: { userId },
      include: {
        campaign: {
          include: {
            creator: {
              select: { id: true, nickname: true, profileImage: true },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }
}
