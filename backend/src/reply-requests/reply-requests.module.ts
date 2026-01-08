import { Module } from '@nestjs/common';
import { ReplyRequestsService } from './reply-requests.service';
import { ReplyRequestsController, CreatorProductsController } from './reply-requests.controller';
import { ReplyRequestsSchedulerService } from './reply-requests-scheduler.service';
import { DatabaseModule } from '../database/database.module';
import { WalletModule } from '../wallet/wallet.module';

@Module({
  imports: [DatabaseModule, WalletModule],
  controllers: [ReplyRequestsController, CreatorProductsController],
  providers: [ReplyRequestsService, ReplyRequestsSchedulerService],
  exports: [ReplyRequestsService],
})
export class ReplyRequestsModule {}
