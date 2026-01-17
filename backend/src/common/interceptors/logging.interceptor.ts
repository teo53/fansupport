import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

/**
 * Sensitive fields that should never be logged
 */
const SENSITIVE_FIELDS = [
  'password',
  'confirmPassword',
  'currentPassword',
  'newPassword',
  'token',
  'accessToken',
  'refreshToken',
  'apiKey',
  'secret',
  'authorization',
  'cookie',
  'creditCard',
  'cardNumber',
  'cvv',
  'ssn',
  'stripeToken',
];

/**
 * JSON 직렬화 가능한 값 타입
 */
type JsonValue = string | number | boolean | null | JsonValue[] | { [key: string]: JsonValue };

/**
 * Sanitize an object by masking sensitive fields
 */
function sanitizeObject(obj: unknown, depth = 0): JsonValue {
  if (depth > 5) return '[MAX_DEPTH]';
  if (obj === null || obj === undefined) return null;
  if (typeof obj !== 'object') return obj as JsonValue;

  if (Array.isArray(obj)) {
    return obj.map((item) => sanitizeObject(item, depth + 1));
  }

  const sanitized: Record<string, JsonValue> = {};

  for (const [key, value] of Object.entries(obj)) {
    const lowerKey = key.toLowerCase();

    // Check if key contains any sensitive field name
    const isSensitive = SENSITIVE_FIELDS.some(
      (field) => lowerKey.includes(field.toLowerCase()),
    );

    if (isSensitive) {
      sanitized[key] = '[REDACTED]';
    } else if (typeof value === 'object' && value !== null) {
      sanitized[key] = sanitizeObject(value, depth + 1);
    } else {
      sanitized[key] = value;
    }
  }

  return sanitized;
}

/**
 * Logging Interceptor
 *
 * Logs incoming requests and outgoing responses while
 * automatically redacting sensitive information.
 */
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest();
    const { method, url, body, ip } = request;
    const userAgent = request.get('user-agent') || '';
    const userId = request.user?.id || 'anonymous';

    const now = Date.now();

    // Log request (with sanitized body)
    const sanitizedBody = sanitizeObject(body);
    this.logger.log(
      `[${method}] ${url} - User: ${userId} - IP: ${ip} - Body: ${JSON.stringify(sanitizedBody)}`,
    );

    return next.handle().pipe(
      tap({
        next: (data) => {
          const responseTime = Date.now() - now;
          // Don't log response data for security, only log metadata
          this.logger.log(
            `[${method}] ${url} - ${responseTime}ms - User: ${userId}`,
          );
        },
        error: (error) => {
          const responseTime = Date.now() - now;
          this.logger.error(
            `[${method}] ${url} - ${responseTime}ms - User: ${userId} - Error: ${error.message}`,
          );
        },
      }),
    );
  }
}

/**
 * Export sanitize function for use in other parts of the application
 */
export { sanitizeObject, SENSITIVE_FIELDS };
