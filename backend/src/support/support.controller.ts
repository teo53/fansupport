import { Controller, Post, Get, Body, Query, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { SupportService } from './support.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateSupportDto } from './dto/create-support.dto';

@ApiTags('support')
@Controller('support')
export class SupportController {
  constructor(private readonly supportService: SupportService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Send support to an idol/maid' })
  async createSupport(
    @CurrentUser('id') userId: string,
    @Body() createSupportDto: CreateSupportDto,
  ) {
    return this.supportService.createSupport(userId, createSupportDto);
  }

  @Get('sent')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get sent support history' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getSentHistory(
    @CurrentUser('id') userId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.supportService.getSupportHistory(userId, 'sent', { page, limit });
  }

  @Get('received')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get received support history' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getReceivedHistory(
    @CurrentUser('id') userId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.supportService.getSupportHistory(userId, 'received', { page, limit });
  }

  @Get('top-supporters/:receiverId')
  @ApiOperation({ summary: 'Get top supporters for an idol/maid' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getTopSupporters(
    @Param('receiverId') receiverId: string,
    @Query('limit') limit?: number,
  ) {
    return this.supportService.getTopSupporters(receiverId, limit);
  }
}
