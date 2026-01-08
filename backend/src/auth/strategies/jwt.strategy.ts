import { Injectable, UnauthorizedException, Logger } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../database/prisma.service';

/**
 * JWT Payload interface with standard claims
 */
interface JwtPayload {
  sub: string; // Subject (user ID)
  email: string;
  role: string;
  iat: number; // Issued at (Unix timestamp)
  exp: number; // Expiration time (Unix timestamp)
  jti?: string; // JWT ID (optional, for token revocation)
}

/**
 * Maximum allowed clock skew in seconds
 * Accounts for minor time differences between servers
 */
const MAX_CLOCK_SKEW_SECONDS = 60;

/**
 * Maximum token age in seconds (24 hours)
 * Prevents tokens from being valid indefinitely even if exp is far in future
 */
const MAX_TOKEN_AGE_SECONDS = 24 * 60 * 60;

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  private readonly logger = new Logger(JwtStrategy.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET'),
      // Additional security: validate issuer and audience if configured
      issuer: configService.get<string>('JWT_ISSUER'),
      audience: configService.get<string>('JWT_AUDIENCE'),
    });
  }

  /**
   * Validate JWT payload with enhanced security checks
   */
  async validate(payload: JwtPayload) {
    const now = Math.floor(Date.now() / 1000);

    // Validate iat (issued at) claim
    if (!payload.iat) {
      this.logger.warn(`JWT missing iat claim for user: ${payload.sub}`);
      throw new UnauthorizedException('Invalid token: missing issued time');
    }

    // Check if token was issued in the future (with clock skew tolerance)
    if (payload.iat > now + MAX_CLOCK_SKEW_SECONDS) {
      this.logger.warn(`JWT iat in future for user: ${payload.sub}, iat: ${payload.iat}, now: ${now}`);
      throw new UnauthorizedException('Invalid token: issued in the future');
    }

    // Check token age - prevent very old tokens even if not expired
    const tokenAge = now - payload.iat;
    if (tokenAge > MAX_TOKEN_AGE_SECONDS) {
      this.logger.warn(`JWT too old for user: ${payload.sub}, age: ${tokenAge}s`);
      throw new UnauthorizedException('Token expired: please refresh your token');
    }

    // Validate exp (expiration) claim
    if (!payload.exp) {
      this.logger.warn(`JWT missing exp claim for user: ${payload.sub}`);
      throw new UnauthorizedException('Invalid token: missing expiration');
    }

    // Check if token has expired (with clock skew tolerance)
    if (payload.exp < now - MAX_CLOCK_SKEW_SECONDS) {
      this.logger.warn(`JWT expired for user: ${payload.sub}, exp: ${payload.exp}, now: ${now}`);
      throw new UnauthorizedException('Token expired');
    }

    // Validate sub (subject) claim
    if (!payload.sub) {
      this.logger.warn('JWT missing sub claim');
      throw new UnauthorizedException('Invalid token: missing subject');
    }

    // Fetch user and perform additional validation
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: {
        id: true,
        email: true,
        role: true,
        deletedAt: true,
        updatedAt: true,
        tokenVersion: true, // For token invalidation on password change
      },
    });

    if (!user) {
      this.logger.warn(`JWT for non-existent user: ${payload.sub}`);
      throw new UnauthorizedException('User not found');
    }

    if (user.deletedAt) {
      this.logger.warn(`JWT for deleted user: ${payload.sub}`);
      throw new UnauthorizedException('User account has been deleted');
    }

    // Validate email hasn't changed since token was issued
    if (user.email !== payload.email) {
      this.logger.warn(`JWT email mismatch for user: ${payload.sub}`);
      throw new UnauthorizedException('Token invalid: please login again');
    }

    // Validate role hasn't changed since token was issued
    if (user.role !== payload.role) {
      this.logger.warn(`JWT role mismatch for user: ${payload.sub}`);
      throw new UnauthorizedException('Token invalid: permissions changed');
    }

    // Check if token was issued before last security update
    // This allows invalidating all tokens when user changes password
    if (user.tokenVersion !== undefined) {
      const userUpdatedAt = Math.floor(user.updatedAt.getTime() / 1000);
      if (payload.iat < userUpdatedAt) {
        this.logger.warn(`JWT issued before user update for: ${payload.sub}`);
        throw new UnauthorizedException('Token invalid: please login again');
      }
    }

    return {
      id: payload.sub,
      email: payload.email,
      role: payload.role,
    };
  }
}
