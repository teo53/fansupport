import { Controller, Post, Get, Patch, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { CampaignService } from './campaign.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { ContributeDto } from './dto/contribute.dto';
import { CampaignStatus } from '@prisma/client';

@ApiTags('campaign')
@Controller('campaigns')
export class CampaignController {
  constructor(private readonly campaignService: CampaignService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new campaign' })
  async createCampaign(
    @CurrentUser('id') userId: string,
    @Body() createCampaignDto: CreateCampaignDto,
  ) {
    return this.campaignService.createCampaign(userId, createCampaignDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all campaigns' })
  @ApiQuery({ name: 'status', required: false, enum: CampaignStatus })
  @ApiQuery({ name: 'creatorId', required: false })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getCampaigns(
    @Query('status') status?: CampaignStatus,
    @Query('creatorId') creatorId?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.campaignService.getCampaigns({ status, creatorId, page, limit });
  }

  @Get('my-campaigns')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get my campaigns' })
  async getMyCampaigns(@CurrentUser('id') userId: string) {
    return this.campaignService.getMyCampaigns(userId);
  }

  @Get('my-contributions')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get my contributions' })
  async getMyContributions(@CurrentUser('id') userId: string) {
    return this.campaignService.getMyContributions(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get campaign by ID' })
  async getCampaign(@Param('id') id: string) {
    return this.campaignService.getCampaignById(id);
  }

  @Post(':id/contribute')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Contribute to a campaign' })
  async contribute(
    @CurrentUser('id') userId: string,
    @Param('id') campaignId: string,
    @Body() contributeDto: ContributeDto,
  ) {
    return this.campaignService.contribute(userId, campaignId, contributeDto);
  }

  @Patch(':id/status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update campaign status' })
  async updateStatus(
    @CurrentUser('id') userId: string,
    @Param('id') campaignId: string,
    @Body('status') status: CampaignStatus,
  ) {
    return this.campaignService.updateCampaignStatus(userId, campaignId, status);
  }
}
