import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { ContributeDto } from './dto/contribute.dto';
import { CampaignStatus, TransactionType } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

@Injectable()
export class CampaignService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly walletService: WalletService,
  ) {}

  async createCampaign(creatorId: string, createCampaignDto: CreateCampaignDto) {
    const { title, description, coverImage, goalAmount, startDate, endDate, rewards } = createCampaignDto;

    if (new Date(startDate) >= new Date(endDate)) {
      throw new BadRequestException('End date must be after start date');
    }

    return this.prisma.campaign.create({
      data: {
        creatorId,
        title,
        description,
        coverImage,
        goalAmount: new Decimal(goalAmount),
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        rewards,
        status: new Date(startDate) <= new Date() ? CampaignStatus.ACTIVE : CampaignStatus.DRAFT,
      },
      include: {
        creator: {
          select: { id: true, nickname: true, profileImage: true },
        },
      },
    });
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

    const campaign = await this.prisma.campaign.findUnique({
      where: { id: campaignId },
    });

    if (!campaign) {
      throw new NotFoundException('Campaign not found');
    }

    if (campaign.status !== CampaignStatus.ACTIVE) {
      throw new BadRequestException('Campaign is not active');
    }

    if (new Date() > campaign.endDate) {
      throw new BadRequestException('Campaign has ended');
    }

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
    const contribution = await this.prisma.campaignContribution.create({
      data: {
        campaignId,
        userId,
        amount: new Decimal(amount),
        rewardTier,
        message,
        isAnonymous,
      },
      include: {
        user: {
          select: { id: true, nickname: true, profileImage: true },
        },
      },
    });

    // Update campaign current amount
    const updatedCampaign = await this.prisma.campaign.update({
      where: { id: campaignId },
      data: {
        currentAmount: { increment: amount },
      },
    });

    // Check if goal reached
    if (Number(updatedCampaign.currentAmount) >= Number(updatedCampaign.goalAmount)) {
      await this.prisma.notification.create({
        data: {
          userId: campaign.creatorId,
          type: 'CAMPAIGN_GOAL_REACHED',
          title: 'Campaign Goal Reached!',
          message: `Your campaign "${campaign.title}" has reached its goal!`,
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
