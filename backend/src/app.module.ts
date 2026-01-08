import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD, APP_INTERCEPTOR, APP_FILTER } from '@nestjs/core';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { WalletModule } from './wallet/wallet.module';
import { SupportModule } from './support/support.module';
import { SubscriptionModule } from './subscription/subscription.module';
import { CampaignModule } from './campaign/campaign.module';
import { BookingModule } from './booking/booking.module';
import { CommunityModule } from './community/community.module';
import { PaymentModule } from './payment/payment.module';
import { DatabaseModule } from './database/database.module';
import { VerificationModule } from './verification/verification.module';
import {
  appConfig,
  databaseConfig,
  jwtConfig,
  stripeConfig,
  googleConfig,
  swaggerConfig,
  kakaoConfig,
} from './config';
import { ResponseTransformInterceptor } from './common/interceptors';
import { GlobalExceptionFilter } from './common/filters';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
      load: [
        appConfig,
        databaseConfig,
        jwtConfig,
        stripeConfig,
        googleConfig,
        swaggerConfig,
        kakaoConfig,
      ],
    }),
    ThrottlerModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => [{
        ttl: config.get<number>('app.throttle.ttl', 60) * 1000,
        limit: config.get<number>('app.throttle.limit', 100),
      }],
    }),
    DatabaseModule,
    AuthModule,
    UsersModule,
    WalletModule,
    SupportModule,
    SubscriptionModule,
    CampaignModule,
    BookingModule,
    CommunityModule,
    PaymentModule,
    VerificationModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: ResponseTransformInterceptor,
    },
    {
      provide: APP_FILTER,
      useClass: GlobalExceptionFilter,
    },
  ],
})
export class AppModule {}
