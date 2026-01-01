import { Injectable, UnauthorizedException, ConflictException, BadRequestException, InternalServerErrorException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { PrismaService } from '../database/prisma.service';
import { UsersService } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { AuthProvider } from '@prisma/client';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {
    // Validate required configuration on startup
    const jwtSecret = this.configService.get<string>('JWT_SECRET');
    const jwtRefreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET');

    if (!jwtSecret) {
      this.logger.error('JWT_SECRET is not configured');
    }
    if (!jwtRefreshSecret) {
      this.logger.error('JWT_REFRESH_SECRET is not configured');
    }
  }

  async register(registerDto: RegisterDto) {
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!registerDto.email || !emailRegex.test(registerDto.email)) {
      throw new BadRequestException('Invalid email format');
    }

    // Validate password strength
    if (!registerDto.password || registerDto.password.length < 8) {
      throw new BadRequestException('Password must be at least 8 characters long');
    }

    // Validate nickname
    if (!registerDto.nickname || registerDto.nickname.trim().length < 2) {
      throw new BadRequestException('Nickname must be at least 2 characters long');
    }

    if (registerDto.nickname.length > 50) {
      throw new BadRequestException('Nickname cannot exceed 50 characters');
    }

    const existingUser = await this.prisma.user.findUnique({
      where: { email: registerDto.email.toLowerCase() },
    });

    if (existingUser) {
      throw new ConflictException('An account with this email already exists');
    }

    try {
      const hashedPassword = await bcrypt.hash(registerDto.password, 10);

      const user = await this.prisma.user.create({
        data: {
          email: registerDto.email.toLowerCase(),
          password: hashedPassword,
          nickname: registerDto.nickname.trim(),
          provider: AuthProvider.LOCAL,
        },
      });

      const tokens = await this.generateTokens(user.id, user.email, user.role);
      await this.saveRefreshToken(user.id, tokens.refreshToken);

      this.logger.log(`New user registered: ${user.email}`);

      return {
        user: {
          id: user.id,
          email: user.email,
          nickname: user.nickname,
          role: user.role,
        },
        ...tokens,
      };
    } catch (error) {
      this.logger.error(`Registration failed for ${registerDto.email}: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to create account. Please try again later.');
    }
  }

  async login(loginDto: LoginDto) {
    if (!loginDto.email) {
      throw new BadRequestException('Email is required');
    }

    if (!loginDto.password) {
      throw new BadRequestException('Password is required');
    }

    const user = await this.prisma.user.findUnique({
      where: { email: loginDto.email.toLowerCase() },
    });

    if (!user) {
      // Use same error message to prevent user enumeration
      throw new UnauthorizedException('Invalid email or password');
    }

    if (!user.password) {
      // User registered via OAuth, no password set
      throw new UnauthorizedException('Please use your social login provider to sign in');
    }

    try {
      const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);
      if (!isPasswordValid) {
        this.logger.warn(`Failed login attempt for user: ${user.email}`);
        throw new UnauthorizedException('Invalid email or password');
      }

      const tokens = await this.generateTokens(user.id, user.email, user.role);
      await this.saveRefreshToken(user.id, tokens.refreshToken);

      this.logger.log(`User logged in: ${user.email}`);

      return {
        user: {
          id: user.id,
          email: user.email,
          nickname: user.nickname,
          role: user.role,
          profileImage: user.profileImage,
        },
        ...tokens,
      };
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      this.logger.error(`Login failed for ${loginDto.email}: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Login failed. Please try again later.');
    }
  }

  async refreshTokens(userId: string, refreshToken: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    const storedToken = await this.prisma.refreshToken.findFirst({
      where: {
        userId,
        token: refreshToken,
        expiresAt: { gt: new Date() },
      },
    });

    if (!storedToken) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    await this.prisma.refreshToken.delete({ where: { id: storedToken.id } });

    const tokens = await this.generateTokens(user.id, user.email, user.role);
    await this.saveRefreshToken(user.id, tokens.refreshToken);

    return tokens;
  }

  async logout(userId: string, refreshToken?: string) {
    if (refreshToken) {
      await this.prisma.refreshToken.deleteMany({
        where: { userId, token: refreshToken },
      });
    } else {
      await this.prisma.refreshToken.deleteMany({
        where: { userId },
      });
    }

    return { message: 'Logged out successfully' };
  }

  async validateOAuthUser(profile: {
    email: string;
    name: string;
    picture?: string;
    provider: AuthProvider;
    providerId: string;
  }) {
    // Validate required OAuth profile fields
    if (!profile.email) {
      throw new BadRequestException('Email is required from OAuth provider');
    }

    if (!profile.providerId) {
      throw new BadRequestException('Provider ID is required from OAuth provider');
    }

    if (!profile.provider) {
      throw new BadRequestException('Provider type is required');
    }

    if (!profile.name || profile.name.trim().length === 0) {
      throw new BadRequestException('Name is required from OAuth provider');
    }

    const normalizedEmail = profile.email.toLowerCase();

    try {
      // First, try to find by provider ID (most reliable)
      let user = await this.prisma.user.findFirst({
        where: {
          providerId: profile.providerId,
          provider: profile.provider,
        },
      });

      // If not found by provider ID, check by email
      if (!user) {
        const existingUserByEmail = await this.prisma.user.findUnique({
          where: { email: normalizedEmail },
        });

        if (existingUserByEmail) {
          // Email exists but with different provider
          if (existingUserByEmail.provider !== profile.provider) {
            const providerName = existingUserByEmail.provider === AuthProvider.LOCAL
              ? 'email and password'
              : existingUserByEmail.provider.toLowerCase();
            throw new ConflictException(
              `An account with this email already exists. Please sign in using ${providerName}.`
            );
          }
          user = existingUserByEmail;
        }
      }

      if (!user) {
        // Create new user
        user = await this.prisma.user.create({
          data: {
            email: normalizedEmail,
            nickname: profile.name.trim(),
            profileImage: profile.picture,
            provider: profile.provider,
            providerId: profile.providerId,
            isVerified: true,
          },
        });
        this.logger.log(`New OAuth user created: ${user.email} via ${profile.provider}`);
      }

      const tokens = await this.generateTokens(user.id, user.email, user.role);
      await this.saveRefreshToken(user.id, tokens.refreshToken);

      this.logger.log(`OAuth user authenticated: ${user.email} via ${profile.provider}`);

      return {
        user: {
          id: user.id,
          email: user.email,
          nickname: user.nickname,
          role: user.role,
          profileImage: user.profileImage,
        },
        ...tokens,
      };
    } catch (error) {
      if (error instanceof ConflictException || error instanceof BadRequestException) {
        throw error;
      }
      this.logger.error(`OAuth validation failed for ${profile.email}: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to authenticate with OAuth provider. Please try again later.');
    }
  }

  private async generateTokens(userId: string, email: string, role: string) {
    const jwtRefreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET');

    if (!jwtRefreshSecret) {
      this.logger.error('JWT_REFRESH_SECRET is not configured - cannot generate refresh tokens');
      throw new InternalServerErrorException('Authentication service configuration error');
    }

    const payload = { sub: userId, email, role };

    try {
      const [accessToken, refreshToken] = await Promise.all([
        this.jwtService.signAsync(payload),
        this.jwtService.signAsync(payload, {
          secret: jwtRefreshSecret,
          expiresIn: this.configService.get<string>('JWT_REFRESH_EXPIRES_IN') || '7d',
        }),
      ]);

      return { accessToken, refreshToken };
    } catch (error) {
      this.logger.error(`Token generation failed: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to generate authentication tokens');
    }
  }

  private async saveRefreshToken(userId: string, token: string) {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    await this.prisma.refreshToken.create({
      data: {
        userId,
        token,
        expiresAt,
      },
    });
  }
}
