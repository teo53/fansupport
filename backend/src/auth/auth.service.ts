import { Injectable, UnauthorizedException, ConflictException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { createHash } from 'crypto';
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
  ) {}

  async register(registerDto: RegisterDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { email: registerDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(registerDto.password, 10);

    const user = await this.prisma.user.create({
      data: {
        email: registerDto.email,
        password: hashedPassword,
        nickname: registerDto.nickname,
        provider: AuthProvider.LOCAL,
      },
    });

    const tokens = await this.generateTokens(user.id, user.email, user.role);
    await this.saveRefreshToken(user.id, tokens.refreshToken);

    return {
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        role: user.role,
      },
      ...tokens,
    };
  }

  async login(loginDto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: loginDto.email },
    });

    if (!user || !user.password) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const tokens = await this.generateTokens(user.id, user.email, user.role);
    await this.saveRefreshToken(user.id, tokens.refreshToken);

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
  }

  async refreshTokens(userId: string, refreshToken: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    // Hash the incoming token and find matching stored token
    const tokenHash = this.hashToken(refreshToken);

    const storedToken = await this.prisma.refreshToken.findFirst({
      where: {
        userId,
        token: tokenHash,
        expiresAt: { gt: new Date() },
      },
    });

    if (!storedToken) {
      // Token Reuse Detection:
      // If token is not found but user claims to have a valid JWT,
      // this might indicate token theft. Invalidate ALL user tokens.
      this.logger.warn(
        `Potential token reuse detected for user ${userId}. Invalidating all tokens.`,
      );
      await this.prisma.refreshToken.deleteMany({ where: { userId } });
      throw new UnauthorizedException('Invalid refresh token. Please login again.');
    }

    // Token Rotation: Delete the used token
    await this.prisma.refreshToken.delete({ where: { id: storedToken.id } });

    // Generate new tokens
    const tokens = await this.generateTokens(user.id, user.email, user.role);
    await this.saveRefreshToken(user.id, tokens.refreshToken);

    return tokens;
  }

  async logout(userId: string, refreshToken?: string) {
    if (refreshToken) {
      const tokenHash = this.hashToken(refreshToken);
      await this.prisma.refreshToken.deleteMany({
        where: { userId, token: tokenHash },
      });
    } else {
      // Logout from all devices
      await this.prisma.refreshToken.deleteMany({
        where: { userId },
      });
    }

    return { message: 'Logged out successfully' };
  }

  /**
   * Revoke all refresh tokens for a user (e.g., on password change)
   */
  async revokeAllUserTokens(userId: string): Promise<void> {
    await this.prisma.refreshToken.deleteMany({ where: { userId } });
    this.logger.log(`All refresh tokens revoked for user ${userId}`);
  }

  async validateOAuthUser(profile: {
    email: string;
    name: string;
    picture?: string;
    provider: AuthProvider;
    providerId: string;
  }) {
    let user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: profile.email },
          { providerId: profile.providerId, provider: profile.provider },
        ],
      },
    });

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          email: profile.email,
          nickname: profile.name,
          profileImage: profile.picture,
          provider: profile.provider,
          providerId: profile.providerId,
          isVerified: true,
        },
      });
    }

    const tokens = await this.generateTokens(user.id, user.email, user.role);
    await this.saveRefreshToken(user.id, tokens.refreshToken);

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
  }

  private async generateTokens(userId: string, email: string, role: string) {
    const payload = { sub: userId, email, role };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get<string>('JWT_REFRESH_EXPIRES_IN') || '7d',
      }),
    ]);

    return { accessToken, refreshToken };
  }

  private async saveRefreshToken(userId: string, token: string) {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    // Hash the token before storing
    const tokenHash = this.hashToken(token);

    await this.prisma.refreshToken.create({
      data: {
        userId,
        token: tokenHash,
        expiresAt,
      },
    });
  }

  /**
   * Hash a token using SHA-256
   * Using SHA-256 for refresh tokens as bcrypt is too slow for token verification
   * and refresh tokens are already cryptographically random JWTs
   */
  private hashToken(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }

  /**
   * Clean up expired refresh tokens (should be called by a scheduled job)
   */
  async cleanupExpiredTokens(): Promise<number> {
    const result = await this.prisma.refreshToken.deleteMany({
      where: {
        expiresAt: { lt: new Date() },
      },
    });
    this.logger.log(`Cleaned up ${result.count} expired refresh tokens`);
    return result.count;
  }
}
