import { ThrottlerGuard } from '@nestjs/throttler';
import { Injectable } from '@nestjs/common';

/**
 * Throttler guard that works behind a proxy
 *
 * This guard extends the default ThrottlerGuard to correctly identify
 * client IPs when the application is behind a reverse proxy (nginx, etc.)
 */
@Injectable()
export class ThrottlerBehindProxyGuard extends ThrottlerGuard {
  protected getTracker(req: Record<string, any>): string {
    // Get IP from X-Forwarded-For header (set by reverse proxy)
    const forwardedFor = req.headers['x-forwarded-for'];
    if (forwardedFor) {
      // X-Forwarded-For can contain multiple IPs, use the first one
      return forwardedFor.split(',')[0].trim();
    }

    // Fallback to X-Real-IP header
    if (req.headers['x-real-ip']) {
      return req.headers['x-real-ip'];
    }

    // Fallback to direct connection IP
    return req.ip || req.connection.remoteAddress || 'unknown';
  }
}
