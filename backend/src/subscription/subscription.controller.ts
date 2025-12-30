import { Controller, Post, Get, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SubscriptionService } from './subscription.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateTierDto } from './dto/create-tier.dto';
import { SubscribeDto } from './dto/subscribe.dto';

@ApiTags('subscription')
@Controller('subscriptions')
export class SubscriptionController {
  constructor(private readonly subscriptionService: SubscriptionService) {}

  @Post('tiers')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create subscription tier (for idols/maids)' })
  async createTier(
    @CurrentUser('id') userId: string,
    @Body() createTierDto: CreateTierDto,
  ) {
    return this.subscriptionService.createTier(userId, createTierDto);
  }

  @Get('tiers/:idolUserId')
  @ApiOperation({ summary: 'Get subscription tiers for an idol' })
  async getTiers(@Param('idolUserId') idolUserId: string) {
    return this.subscriptionService.getTiers(idolUserId);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Subscribe to a creator' })
  async subscribe(
    @CurrentUser('id') userId: string,
    @Body() subscribeDto: SubscribeDto,
  ) {
    return this.subscriptionService.subscribe(userId, subscribeDto);
  }

  @Delete(':creatorId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Cancel subscription' })
  async cancelSubscription(
    @CurrentUser('id') userId: string,
    @Param('creatorId') creatorId: string,
  ) {
    return this.subscriptionService.cancelSubscription(userId, creatorId);
  }

  @Get('my-subscriptions')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get my active subscriptions' })
  async getMySubscriptions(@CurrentUser('id') userId: string) {
    return this.subscriptionService.getMySubscriptions(userId);
  }

  @Get('my-subscribers')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get my subscribers (for creators)' })
  async getMySubscribers(@CurrentUser('id') userId: string) {
    return this.subscriptionService.getMySubscribers(userId);
  }

  @Get('check/:creatorId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Check if subscribed to a creator' })
  async checkSubscription(
    @CurrentUser('id') userId: string,
    @Param('creatorId') creatorId: string,
  ) {
    return this.subscriptionService.checkSubscription(userId, creatorId);
  }
}
