import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiQuery,
  ApiParam,
} from '@nestjs/swagger';
import { ReplyRequestsService } from './reply-requests.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import {
  CreateReplyRequestDto,
  DeliverReplyDto,
  RejectReplyDto,
  FanFeedbackDto,
} from './dto';
import { ReplyRequestStatus } from '@prisma/client';

@ApiTags('reply-requests')
@Controller('reply-requests')
export class ReplyRequestsController {
  constructor(private readonly replyRequestsService: ReplyRequestsService) {}

  // ==================== FAN ENDPOINTS ====================

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new reply request (fan)' })
  async createRequest(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateReplyRequestDto,
  ) {
    return this.replyRequestsService.createRequest(userId, dto);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get my reply requests (fan inbox)' })
  @ApiQuery({ name: 'status', required: false, enum: ReplyRequestStatus })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getMyRequests(
    @CurrentUser('id') userId: string,
    @Query('status') status?: ReplyRequestStatus,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.replyRequestsService.getMyRequests(userId, { status, page, limit });
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get reply request detail' })
  @ApiParam({ name: 'id', description: 'Reply request ID' })
  async getRequestById(
    @CurrentUser('id') userId: string,
    @Param('id') requestId: string,
  ) {
    return this.replyRequestsService.getRequestById(requestId, userId);
  }

  @Post(':id/feedback')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Submit feedback for delivered reply (fan)' })
  @ApiParam({ name: 'id', description: 'Reply request ID' })
  async submitFeedback(
    @CurrentUser('id') userId: string,
    @Param('id') requestId: string,
    @Body() dto: FanFeedbackDto,
  ) {
    return this.replyRequestsService.submitFeedback(requestId, userId, dto);
  }

  // ==================== CREATOR ENDPOINTS ====================

  @Get('creator/queue')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get creator queue (pending requests)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getCreatorQueue(
    @CurrentUser('id') userId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.replyRequestsService.getCreatorQueue(userId, { page, limit });
  }

  @Get('creator/products')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get creator products and SLA options' })
  async getCreatorProducts(@CurrentUser('id') userId: string) {
    return this.replyRequestsService.getCreatorProducts(userId);
  }

  @Patch(':id/start')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Start working on a request (creator)' })
  @ApiParam({ name: 'id', description: 'Reply request ID' })
  async startRequest(
    @CurrentUser('id') userId: string,
    @Param('id') requestId: string,
  ) {
    return this.replyRequestsService.startRequest(requestId, userId);
  }

  @Post(':id/deliver')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Deliver reply (creator)' })
  @ApiParam({ name: 'id', description: 'Reply request ID' })
  async deliverReply(
    @CurrentUser('id') userId: string,
    @Param('id') requestId: string,
    @Body() dto: DeliverReplyDto,
  ) {
    return this.replyRequestsService.deliverReply(requestId, userId, dto);
  }

  @Post(':id/reject')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Reject request with refund (creator)' })
  @ApiParam({ name: 'id', description: 'Reply request ID' })
  async rejectRequest(
    @CurrentUser('id') userId: string,
    @Param('id') requestId: string,
    @Body() dto: RejectReplyDto,
  ) {
    return this.replyRequestsService.rejectRequest(requestId, userId, dto);
  }

  // ==================== SYSTEM ENDPOINTS ====================

  @Post('system/process-expired')
  @ApiOperation({ summary: 'Process expired requests (system/cron)' })
  async processExpiredRequests() {
    // TODO: Add API key or admin auth guard
    return this.replyRequestsService.processExpiredRequests();
  }
}

// Additional controller for public product info
@ApiTags('creators')
@Controller('creators')
export class CreatorProductsController {
  constructor(private readonly replyRequestsService: ReplyRequestsService) {}

  @Get(':creatorId/products')
  @ApiOperation({ summary: 'Get creator products (public)' })
  @ApiParam({ name: 'creatorId', description: 'Creator user ID' })
  async getCreatorProducts(@Param('creatorId') creatorId: string) {
    return this.replyRequestsService.getCreatorProducts(creatorId);
  }
}
