import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { ReplyRequestsService } from './reply-requests.service';

@Injectable()
export class ReplyRequestsSchedulerService {
  private readonly logger = new Logger(ReplyRequestsSchedulerService.name);

  constructor(private readonly replyRequestsService: ReplyRequestsService) {}

  /**
   * Process expired SLA requests every 5 minutes
   * - Finds requests past their deadline
   * - Automatically refunds the fan
   * - Updates status to EXPIRED
   */
  @Cron(CronExpression.EVERY_5_MINUTES)
  async handleExpiredRequests() {
    this.logger.log('Starting expired requests processing...');

    try {
      const result = await this.replyRequestsService.processExpiredRequests();

      if (result.processed > 0) {
        this.logger.log(`Processed ${result.processed} expired requests`);

        // Log any errors
        const errors = result.results.filter(r => r.status === 'error');
        if (errors.length > 0) {
          this.logger.warn(`${errors.length} requests failed to process:`, errors);
        }
      }
    } catch (error) {
      this.logger.error('Failed to process expired requests:', error);
    }
  }

  /**
   * Daily summary report at midnight
   */
  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async handleDailySummary() {
    this.logger.log('Generating daily summary...');
    // TODO: Implement daily stats aggregation
    // - Total requests created
    // - Total requests delivered
    // - Total requests expired
    // - Revenue generated
  }
}
