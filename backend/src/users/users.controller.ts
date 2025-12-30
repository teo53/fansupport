import {
  Controller,
  Get,
  Put,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UpdateUserDto } from './dto/update-user.dto';
import { CreateIdolProfileDto } from './dto/create-idol-profile.dto';

@ApiTags('users')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  async getMe(@CurrentUser('id') userId: string) {
    return this.usersService.findById(userId);
  }

  @Put('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update current user profile' })
  async updateMe(
    @CurrentUser('id') userId: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.usersService.updateProfile(userId, updateUserDto);
  }

  @Get('idols')
  @ApiOperation({ summary: 'Get list of idols' })
  @ApiQuery({ name: 'category', required: false })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'sortBy', required: false, enum: ['ranking', 'totalSupport', 'supporterCount'] })
  async getIdols(
    @Query('category') category?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('sortBy') sortBy?: 'ranking' | 'totalSupport' | 'supporterCount',
  ) {
    return this.usersService.getIdolsList({ category, page, limit, sortBy });
  }

  @Get('idols/ranking')
  @ApiOperation({ summary: 'Get idol ranking' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getIdolRanking(@Query('limit') limit?: number) {
    return this.usersService.getRanking(limit);
  }

  @Get('idols/:userId')
  @ApiOperation({ summary: 'Get idol profile by user ID' })
  async getIdolProfile(@Param('userId') userId: string) {
    return this.usersService.getIdolProfile(userId);
  }

  @Post('idol-profile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create idol profile for current user' })
  async createIdolProfile(
    @CurrentUser('id') userId: string,
    @Body() createIdolProfileDto: CreateIdolProfileDto,
  ) {
    return this.usersService.createIdolProfile(userId, createIdolProfileDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  async getUser(@Param('id') id: string) {
    return this.usersService.findById(id);
  }
}
