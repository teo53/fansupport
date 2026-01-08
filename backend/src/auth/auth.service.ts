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

  // 계정 잠금 설정
  private readonly MAX_FAILED_ATTEMPTS = 5;
  private readonly LOCKOUT_DURATION_MINUTES = 30;

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
      throw new UnauthorizedException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }

    // 계정 잠금 확인
    if (user.lockedUntil && user.lockedUntil > new Date()) {
      const remainingMinutes = Math.ceil(
        (user.lockedUntil.getTime() - Date.now()) / (1000 * 60),
      );
      throw new UnauthorizedException(
        `계정이 잠겼습니다. ${remainingMinutes}분 후에 다시 시도해주세요.`,
      );
    }

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);

    if (!isPasswordValid) {
      // 로그인 실패 처리
      await this.handleFailedLogin(user.id, user.failedLoginAttempts);
      throw new UnauthorizedException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }

    // 로그인 성공 - 실패 카운트 초기화
    await this.resetFailedLoginAttempts(user.id);

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

  /**
   * 로그인 실패 처리 (계정 잠금 로직)
   */
  private async handleFailedLogin(
    userId: string,
    currentAttempts: number,
  ): Promise<void> {
    const newAttempts = currentAttempts + 1;

    if (newAttempts >= this.MAX_FAILED_ATTEMPTS) {
      // 계정 잠금
      const lockedUntil = new Date();
      lockedUntil.setMinutes(lockedUntil.getMinutes() + this.LOCKOUT_DURATION_MINUTES);

      await this.prisma.user.update({
        where: { id: userId },
        data: {
          failedLoginAttempts: newAttempts,
          lastFailedLoginAt: new Date(),
          lockedUntil,
        },
      });

      this.logger.warn(`Account locked for user ${userId} due to ${newAttempts} failed attempts`);
    } else {
      // 실패 횟수 증가
      await this.prisma.user.update({
        where: { id: userId },
        data: {
          failedLoginAttempts: newAttempts,
          lastFailedLoginAt: new Date(),
        },
      });

      this.logger.debug(`Failed login attempt ${newAttempts}/${this.MAX_FAILED_ATTEMPTS} for user ${userId}`);
    }
  }

  /**
   * 로그인 성공 시 실패 카운트 초기화
   */
  private async resetFailedLoginAttempts(userId: string): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        failedLoginAttempts: 0,
        lastFailedLoginAt: null,
        lockedUntil: null,
      },
    });
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

  /**
   * 비밀번호 변경
   */
  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string,
  ): Promise<{ message: string }> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('사용자를 찾을 수 없습니다.');
    }

    // OAuth 사용자는 비밀번호 변경 불가
    if (!user.password) {
      throw new UnauthorizedException(
        '소셜 로그인 사용자는 비밀번호를 변경할 수 없습니다.',
      );
    }

    // 현재 비밀번호 확인
    const isCurrentPasswordValid = await bcrypt.compare(
      currentPassword,
      user.password,
    );
    if (!isCurrentPasswordValid) {
      throw new UnauthorizedException('현재 비밀번호가 일치하지 않습니다.');
    }

    // 새 비밀번호 유효성 검사
    if (newPassword.length < 8) {
      throw new UnauthorizedException('새 비밀번호는 8자 이상이어야 합니다.');
    }

    // 새 비밀번호 해싱 및 저장
    const hashedNewPassword = await bcrypt.hash(newPassword, 10);

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        password: hashedNewPassword,
        tokenVersion: { increment: 1 }, // 모든 기존 토큰 무효화
      },
    });

    // 모든 refresh token 삭제
    await this.revokeAllUserTokens(userId);

    this.logger.log(`Password changed for user ${userId}`);

    return { message: '비밀번호가 변경되었습니다. 다시 로그인해주세요.' };
  }

  /**
   * 사용자 프로필 조회
   */
  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        nickname: true,
        profileImage: true,
        role: true,
        provider: true,
        isVerified: true,
        phoneNumber: true,
        identityVerifiedAt: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('사용자를 찾을 수 없습니다.');
    }

    return {
      ...user,
      hasPassword: await this.hasPassword(userId),
      isPhoneVerified: !!user.identityVerifiedAt,
      maskedPhoneNumber: user.phoneNumber
        ? this.maskPhoneNumber(user.phoneNumber)
        : null,
    };
  }

  /**
   * 비밀번호 설정 여부 확인
   */
  private async hasPassword(userId: string): Promise<boolean> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { password: true },
    });
    return !!user?.password;
  }

  /**
   * 전화번호 마스킹
   */
  private maskPhoneNumber(phone: string): string {
    if (phone.length < 8) return phone;
    return phone.slice(0, 3) + '****' + phone.slice(-4);
  }
}
