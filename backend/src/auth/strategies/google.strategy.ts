import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, VerifyCallback, Profile } from 'passport-google-oauth20';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';
import { AuthProvider } from '@prisma/client';
import { Request } from 'express';
import { randomBytes, createHash } from 'crypto';

/**
 * OAuth State Store for CSRF Protection
 * In production, consider using Redis for distributed state storage
 */
const stateStore = new Map<string, { timestamp: number; nonce: string }>();
const STATE_TTL = 10 * 60 * 1000; // 10 minutes

/**
 * Clean up expired states periodically
 */
function cleanupExpiredStates(): void {
  const now = Date.now();
  for (const [state, data] of stateStore.entries()) {
    if (now - data.timestamp > STATE_TTL) {
      stateStore.delete(state);
    }
  }
}

// Run cleanup every 5 minutes
setInterval(cleanupExpiredStates, 5 * 60 * 1000);

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  private readonly logger = new Logger(GoogleStrategy.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly authService: AuthService,
  ) {
    super({
      clientID: configService.get<string>('GOOGLE_CLIENT_ID'),
      clientSecret: configService.get<string>('GOOGLE_CLIENT_SECRET'),
      callbackURL: configService.get<string>('GOOGLE_CALLBACK_URL'),
      scope: ['email', 'profile'],
      // Enable state parameter for CSRF protection
      state: true,
      // Pass request to validate callback for state verification
      passReqToCallback: true,
    });
  }

  /**
   * Generate a secure state parameter
   */
  generateState(): string {
    const nonce = randomBytes(32).toString('hex');
    const timestamp = Date.now();
    const state = createHash('sha256')
      .update(`${nonce}:${timestamp}`)
      .digest('hex');

    stateStore.set(state, { timestamp, nonce });
    return state;
  }

  /**
   * Verify the state parameter to prevent CSRF attacks
   */
  private verifyState(state: string | undefined): boolean {
    if (!state) {
      this.logger.warn('OAuth callback received without state parameter');
      return false;
    }

    const storedData = stateStore.get(state);
    if (!storedData) {
      this.logger.warn('OAuth callback received with invalid state parameter');
      return false;
    }

    // Check if state has expired
    if (Date.now() - storedData.timestamp > STATE_TTL) {
      this.logger.warn('OAuth callback received with expired state parameter');
      stateStore.delete(state);
      return false;
    }

    // State is valid, remove it (one-time use)
    stateStore.delete(state);
    return true;
  }

  async validate(
    req: Request,
    accessToken: string,
    refreshToken: string,
    profile: Profile,
    done: VerifyCallback,
  ): Promise<void> {
    try {
      // Verify state parameter for CSRF protection
      const state = req.query.state as string | undefined;
      if (!this.verifyState(state)) {
        return done(new UnauthorizedException('Invalid OAuth state. Please try again.'), false);
      }

      const { id, emails, displayName, photos } = profile;

      // Validate required fields
      if (!emails || emails.length === 0 || !emails[0].value) {
        this.logger.warn(`OAuth user without email: ${id}`);
        return done(new UnauthorizedException('Email is required for authentication'), false);
      }

      const result = await this.authService.validateOAuthUser({
        email: emails[0].value,
        name: displayName || 'Unknown',
        picture: photos?.[0]?.value,
        provider: AuthProvider.GOOGLE,
        providerId: id,
      });

      done(null, result);
    } catch (error) {
      this.logger.error(`OAuth validation failed: ${error.message}`);
      done(error, false);
    }
  }
}
