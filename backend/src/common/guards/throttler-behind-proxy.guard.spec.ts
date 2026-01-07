import { ThrottlerBehindProxyGuard } from './throttler-behind-proxy.guard';

describe('ThrottlerBehindProxyGuard', () => {
  let guard: ThrottlerBehindProxyGuard;

  beforeEach(() => {
    guard = new ThrottlerBehindProxyGuard(
      { ttl: 60, limit: 10 } as any,
      {} as any,
      {} as any,
    );
  });

  it('should be defined', () => {
    expect(guard).toBeDefined();
  });

  describe('getTracker', () => {
    it('should get IP from X-Forwarded-For header', () => {
      const req = {
        headers: {
          'x-forwarded-for': '192.168.1.1, 10.0.0.1',
        },
      };

      const ip = (guard as any).getTracker(req);
      expect(ip).toBe('192.168.1.1');
    });

    it('should get IP from X-Real-IP header if X-Forwarded-For is not present', () => {
      const req = {
        headers: {
          'x-real-ip': '192.168.1.2',
        },
      };

      const ip = (guard as any).getTracker(req);
      expect(ip).toBe('192.168.1.2');
    });

    it('should fall back to req.ip if no proxy headers', () => {
      const req = {
        headers: {},
        ip: '192.168.1.3',
      };

      const ip = (guard as any).getTracker(req);
      expect(ip).toBe('192.168.1.3');
    });

    it('should return "unknown" if no IP can be determined', () => {
      const req = {
        headers: {},
      };

      const ip = (guard as any).getTracker(req);
      expect(ip).toBe('unknown');
    });

    it('should handle multiple IPs in X-Forwarded-For correctly', () => {
      const req = {
        headers: {
          'x-forwarded-for': '  192.168.1.1  , 10.0.0.1, 172.16.0.1',
        },
      };

      const ip = (guard as any).getTracker(req);
      expect(ip).toBe('192.168.1.1');
    });
  });
});
