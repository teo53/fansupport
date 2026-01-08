import { Injectable, ExecutionContext, HttpException, HttpStatus } from '@nestjs/common';
import { ThrottlerGuard, ThrottlerException } from '@nestjs/throttler';

/**
 * Login Rate Limit Guard
 *
 * Provides stricter rate limiting for authentication endpoints
 * to prevent brute force attacks.
 *
 * Default: 5 attempts per 15 minutes per IP
 */
@Injectable()
export class LoginRateLimitGuard extends ThrottlerGuard {
  // Override default throttle settings for login
  protected readonly errorMessage = 'Too many login attempts. Please try again later.';

  // Generate key based on IP and endpoint
  protected async getTracker(req: Record<string, any>): Promise<string> {
    // Use IP + email combination for more precise rate limiting
    const ip = req.ip || req.connection?.remoteAddress || 'unknown';
    const email = req.body?.email || 'unknown';
    return `login:${ip}:${email}`;
  }

  // Stricter limits for login: 5 attempts per 15 minutes
  protected getLimit(): number {
    return 5;
  }

  protected getTtl(): number {
    return 15 * 60 * 1000; // 15 minutes in milliseconds
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    try {
      return await super.canActivate(context);
    } catch (error) {
      if (error instanceof ThrottlerException) {
        throw new HttpException(
          {
            statusCode: HttpStatus.TOO_MANY_REQUESTS,
            message: this.errorMessage,
            retryAfter: Math.ceil(this.getTtl() / 1000),
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
      throw error;
    }
  }
}

/**
 * Register Rate Limit Guard
 *
 * Rate limiting for registration to prevent spam accounts.
 * Default: 3 registrations per hour per IP
 */
@Injectable()
export class RegisterRateLimitGuard extends ThrottlerGuard {
  protected readonly errorMessage = 'Too many registration attempts. Please try again later.';

  protected async getTracker(req: Record<string, any>): Promise<string> {
    const ip = req.ip || req.connection?.remoteAddress || 'unknown';
    return `register:${ip}`;
  }

  protected getLimit(): number {
    return 3;
  }

  protected getTtl(): number {
    return 60 * 60 * 1000; // 1 hour in milliseconds
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    try {
      return await super.canActivate(context);
    } catch (error) {
      if (error instanceof ThrottlerException) {
        throw new HttpException(
          {
            statusCode: HttpStatus.TOO_MANY_REQUESTS,
            message: this.errorMessage,
            retryAfter: Math.ceil(this.getTtl() / 1000),
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
      throw error;
    }
  }
}

/**
 * Refresh Token Rate Limit Guard
 *
 * Prevents token refresh abuse.
 * Default: 10 refresh attempts per minute
 */
@Injectable()
export class RefreshRateLimitGuard extends ThrottlerGuard {
  protected readonly errorMessage = 'Too many token refresh attempts.';

  protected async getTracker(req: Record<string, any>): Promise<string> {
    const ip = req.ip || req.connection?.remoteAddress || 'unknown';
    return `refresh:${ip}`;
  }

  protected getLimit(): number {
    return 10;
  }

  protected getTtl(): number {
    return 60 * 1000; // 1 minute in milliseconds
  }
}
