import {
  Controller,
  Post,
  Body,
  UseGuards,
  Get,
  Req,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiBody, ApiResponse } from '@nestjs/swagger';
import { SkipThrottle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { JwtRefreshGuard } from './guards/jwt-refresh.guard';
import {
  LoginRateLimitGuard,
  RegisterRateLimitGuard,
  RefreshRateLimitGuard,
} from './guards/auth-rate-limit.guard';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @UseGuards(RegisterRateLimitGuard)
  @SkipThrottle()
  @ApiOperation({ summary: 'Register a new user' })
  @ApiResponse({ status: 429, description: 'Too many registration attempts' })
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @UseGuards(LoginRateLimitGuard)
  @SkipThrottle()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login with email and password' })
  @ApiResponse({ status: 429, description: 'Too many login attempts' })
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Post('refresh')
  @UseGuards(RefreshRateLimitGuard, JwtRefreshGuard)
  @SkipThrottle()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refresh access token' })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({ status: 429, description: 'Too many refresh attempts' })
  async refresh(
    @CurrentUser('id') userId: string,
    @Body() refreshTokenDto: RefreshTokenDto,
  ) {
    return this.authService.refreshTokens(userId, refreshTokenDto.refreshToken);
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Logout current user' })
  async logout(
    @CurrentUser('id') userId: string,
    @Body('refreshToken') refreshToken?: string,
  ) {
    return this.authService.logout(userId, refreshToken);
  }

  @Get('google')
  @UseGuards(AuthGuard('google'))
  @ApiOperation({ summary: 'Login with Google OAuth' })
  async googleAuth() {
    // Initiates Google OAuth flow
  }

  @Get('google/callback')
  @UseGuards(AuthGuard('google'))
  @ApiOperation({ summary: 'Google OAuth callback' })
  async googleAuthCallback(@Req() req: any) {
    return req.user;
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  async getMe(@CurrentUser('id') userId: string) {
    return { userId };
  }
}
