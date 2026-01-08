import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import helmet from 'helmet';
import * as basicAuth from 'express-basic-auth';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log', 'debug'],
  });

  const configService = app.get(ConfigService);
  const logger = new Logger('Bootstrap');

  // Global prefix
  const apiPrefix = configService.get<string>('app.apiPrefix', 'api');
  app.setGlobalPrefix(apiPrefix);

  // Security headers
  app.use(helmet());

  // CORS - Enhanced security (using ConfigService)
  const allowedOrigins = configService.get<string[]>('app.allowedOrigins', [
    'http://localhost:3001',
    'http://localhost:3000',
  ]);

  app.enableCors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, curl, etc.)
      if (!origin) return callback(null, true);

      if (allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        logger.warn(`CORS blocked origin: ${origin}`);
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    exposedHeaders: ['X-Total-Count', 'X-Page-Number'],
    maxAge: 3600,
  });

  // Validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Swagger API Documentation with Production Auth Protection
  const nodeEnv = configService.get<string>('app.nodeEnv', 'development');
  const swaggerEnabled = configService.get<boolean>('swagger.enabled', true);

  if (swaggerEnabled) {
    // Production 환경에서는 Basic Auth로 Swagger 보호
    if (nodeEnv === 'production') {
      const swaggerUser = configService.get<string>('swagger.username', 'admin');
      const swaggerPass = configService.get<string>('swagger.password');

      if (!swaggerPass || swaggerPass === 'changeme') {
        logger.warn('⚠️  Swagger password not set or using default. Please set SWAGGER_PASSWORD in production!');
      }

      app.use(
        '/docs',
        basicAuth({
          users: { [swaggerUser]: swaggerPass || 'changeme' },
          challenge: true,
          realm: 'Idol Support API Docs',
        }),
      );
      logger.log('🔐 Swagger protected with Basic Auth in production');
    }

    const config = new DocumentBuilder()
      .setTitle('Idol Support Platform API')
      .setDescription('API documentation for Underground Idol & Maid Cafe Fan Support Platform')
      .setVersion('1.0')
      .addBearerAuth()
      .addTag('auth', 'Authentication endpoints')
      .addTag('users', 'User management')
      .addTag('wallet', 'Wallet & transactions')
      .addTag('support', 'Support/donation endpoints')
      .addTag('subscription', 'Subscription management')
      .addTag('campaign', 'Crowdfunding campaigns')
      .addTag('booking', 'Maid cafe booking')
      .addTag('community', 'Community posts & comments')
      .addTag('payment', 'Payment processing')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('docs', app, document);
    logger.log(`📚 Swagger docs available at /docs`);
  } else {
    logger.log('📚 Swagger documentation is disabled');
  }

  const port = configService.get<number>('app.port', 3000);
  await app.listen(port);
  logger.log(`🚀 Application running on: http://localhost:${port}`);
  logger.log(`🌍 Environment: ${nodeEnv}`);
}
bootstrap();
