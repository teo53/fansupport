import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
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

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    ThrottlerModule.forRoot([{
      ttl: parseInt(process.env.THROTTLE_TTL || '60') * 1000,
      limit: parseInt(process.env.THROTTLE_LIMIT || '100'),
    }]),
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
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
