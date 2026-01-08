import { registerAs } from '@nestjs/config';

export default registerAs('app', () => {
  const nodeEnv = process.env.NODE_ENV || 'development';
  const isDevelopment = nodeEnv === 'development';

  // Only include localhost origins in development
  const localOrigins = isDevelopment
    ? ['http://localhost:3001', 'http://localhost:3000']
    : [];

  return {
    nodeEnv,
    port: parseInt(process.env.PORT, 10) || 3000,
    apiPrefix: process.env.API_PREFIX || 'api',

    // CORS - localhost only in development
    allowedOrigins: (process.env.ALLOWED_ORIGINS || '')
      .split(',')
      .filter(Boolean)
      .concat(localOrigins),
    frontendUrl: process.env.FRONTEND_URL || 'http://localhost:3001',

    // Rate Limiting
    throttle: {
      ttl: parseInt(process.env.THROTTLE_TTL, 10) || 60,
      limit: parseInt(process.env.THROTTLE_LIMIT, 10) || 100,
    },

    // Logging - less verbose in production
    logLevel: process.env.LOG_LEVEL || (isDevelopment ? 'debug' : 'warn'),
  };
});
