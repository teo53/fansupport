import { Injectable, BadRequestException, NotFoundException, InternalServerErrorException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { PaymentProvider, PaymentStatus, PaymentType } from '@prisma/client';
import Stripe from 'stripe';
import { Decimal } from '@prisma/client/runtime/library';

@Injectable()
export class PaymentService {
  private stripe: Stripe;
  private readonly logger = new Logger(PaymentService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
    private readonly walletService: WalletService,
  ) {
    const stripeSecretKey = this.configService.get<string>('STRIPE_SECRET_KEY');
    if (!stripeSecretKey) {
      this.logger.error('STRIPE_SECRET_KEY is not configured');
    }
    this.stripe = new Stripe(stripeSecretKey || '', {
      apiVersion: '2023-10-16',
    });
  }

  async createPaymentIntent(userId: string, amount: number, type: PaymentType) {
    if (!userId) {
      throw new BadRequestException('User ID is required');
    }

    if (!Number.isInteger(amount) || amount < 1000) {
      throw new BadRequestException('Amount must be an integer of at least 1000 KRW');
    }

    if (amount > 10000000) {
      throw new BadRequestException('Maximum single payment amount is 10,000,000 KRW');
    }

    // Verify user exists
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Create payment record
    const payment = await this.prisma.payment.create({
      data: {
        userId,
        amount: new Decimal(amount),
        currency: 'KRW',
        provider: PaymentProvider.STRIPE,
        type,
        status: PaymentStatus.PENDING,
      },
    });

    try {
      // Create Stripe PaymentIntent
      const paymentIntent = await this.stripe.paymentIntents.create({
        amount: amount, // Stripe uses smallest currency unit
        currency: 'krw',
        metadata: {
          paymentId: payment.id,
          userId,
          type,
        },
      });

      // Update payment with Stripe ID
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: { providerPaymentId: paymentIntent.id },
      });

      return {
        paymentId: payment.id,
        clientSecret: paymentIntent.client_secret,
      };
    } catch (error) {
      // Clean up the payment record if Stripe fails
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: { status: PaymentStatus.FAILED },
      });

      this.logger.error(`Stripe payment intent creation failed: ${error.message}`, error.stack);

      if (error instanceof Stripe.errors.StripeCardError) {
        throw new BadRequestException(`Card error: ${error.message}`);
      } else if (error instanceof Stripe.errors.StripeInvalidRequestError) {
        throw new BadRequestException(`Invalid payment request: ${error.message}`);
      } else if (error instanceof Stripe.errors.StripeAPIError) {
        throw new InternalServerErrorException('Payment service temporarily unavailable. Please try again later.');
      } else if (error instanceof Stripe.errors.StripeConnectionError) {
        throw new InternalServerErrorException('Unable to connect to payment service. Please try again later.');
      } else if (error instanceof Stripe.errors.StripeAuthenticationError) {
        throw new InternalServerErrorException('Payment service configuration error. Please contact support.');
      }

      throw new InternalServerErrorException('Payment processing failed. Please try again later.');
    }
  }

  async handleStripeWebhook(signature: string, payload: Buffer) {
    if (!signature) {
      throw new BadRequestException('Missing webhook signature');
    }

    if (!payload || payload.length === 0) {
      throw new BadRequestException('Empty webhook payload');
    }

    const webhookSecret = this.configService.get<string>('STRIPE_WEBHOOK_SECRET');
    if (!webhookSecret) {
      this.logger.error('STRIPE_WEBHOOK_SECRET is not configured');
      throw new InternalServerErrorException('Webhook configuration error');
    }

    let event: Stripe.Event;

    try {
      event = this.stripe.webhooks.constructEvent(payload, signature, webhookSecret);
    } catch (err) {
      this.logger.warn(`Webhook signature verification failed: ${err.message}`);
      throw new BadRequestException('Webhook signature verification failed');
    }

    try {
      switch (event.type) {
        case 'payment_intent.succeeded':
          await this.handlePaymentSuccess(event.data.object as Stripe.PaymentIntent);
          break;
        case 'payment_intent.payment_failed':
          await this.handlePaymentFailure(event.data.object as Stripe.PaymentIntent);
          break;
        default:
          this.logger.log(`Unhandled webhook event type: ${event.type}`);
      }
    } catch (error) {
      this.logger.error(`Error processing webhook event ${event.type}: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to process webhook event');
    }

    return { received: true };
  }

  private async handlePaymentSuccess(paymentIntent: Stripe.PaymentIntent) {
    const payment = await this.prisma.payment.findFirst({
      where: { providerPaymentId: paymentIntent.id },
    });

    if (!payment) {
      this.logger.warn(`Payment not found for Stripe payment intent: ${paymentIntent.id}`);
      throw new NotFoundException('Payment record not found for this transaction');
    }

    if (payment.status === PaymentStatus.COMPLETED) {
      this.logger.log(`Payment ${payment.id} already processed, skipping duplicate webhook`);
      return;
    }

    try {
      // Use transaction to ensure atomicity between payment status update and wallet deposit
      await this.prisma.$transaction(async (tx) => {
        // Update payment status
        await tx.payment.update({
          where: { id: payment.id },
          data: { status: PaymentStatus.COMPLETED },
        });

        // Process based on payment type
        if (payment.type === PaymentType.WALLET_CHARGE) {
          await this.walletService.deposit(
            payment.userId,
            Number(payment.amount),
            payment.id,
          );
        }
      });

      this.logger.log(`Successfully processed payment ${payment.id}`);
    } catch (error) {
      this.logger.error(`Failed to complete payment ${payment.id}: ${error.message}`, error.stack);

      // Mark payment as failed if processing fails
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: { status: PaymentStatus.FAILED },
      });

      throw new InternalServerErrorException('Failed to process payment completion');
    }
  }

  private async handlePaymentFailure(paymentIntent: Stripe.PaymentIntent) {
    const payment = await this.prisma.payment.findFirst({
      where: { providerPaymentId: paymentIntent.id },
    });

    if (!payment) {
      this.logger.warn(`Payment not found for failed Stripe payment intent: ${paymentIntent.id}`);
      return;
    }

    if (payment.status === PaymentStatus.FAILED) {
      this.logger.log(`Payment ${payment.id} already marked as failed, skipping duplicate webhook`);
      return;
    }

    try {
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: { status: PaymentStatus.FAILED },
      });
      this.logger.log(`Marked payment ${payment.id} as failed`);
    } catch (error) {
      this.logger.error(`Failed to update payment ${payment.id} status to failed: ${error.message}`);
    }
  }

  async getPaymentHistory(userId: string, options: { page?: number; limit?: number }) {
    const { page = 1, limit = 20 } = options;

    const [payments, total] = await Promise.all([
      this.prisma.payment.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.payment.count({ where: { userId } }),
    ]);

    return {
      data: payments,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getPaymentById(userId: string, paymentId: string) {
    const payment = await this.prisma.payment.findFirst({
      where: { id: paymentId, userId },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    return payment;
  }

  // Google Play / App Store IAP verification
  async verifyInAppPurchase(
    userId: string,
    provider: 'GOOGLE_PLAY' | 'APP_STORE',
    purchaseToken: string,
    productId: string,
  ) {
    if (!userId) {
      throw new BadRequestException('User ID is required');
    }

    if (!purchaseToken || purchaseToken.trim().length === 0) {
      throw new BadRequestException('Purchase token is required');
    }

    if (!productId || productId.trim().length === 0) {
      throw new BadRequestException('Product ID is required');
    }

    // Verify user exists
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check for duplicate purchase token to prevent double-spending
    const existingPayment = await this.prisma.payment.findFirst({
      where: { providerPaymentId: purchaseToken },
    });

    if (existingPayment) {
      throw new BadRequestException('This purchase has already been processed');
    }

    const amount = this.getProductAmount(productId);

    if (amount === 0) {
      throw new BadRequestException(`Invalid product ID: ${productId}`);
    }

    // TODO: Implement actual verification with Google Play / App Store APIs
    // This is a placeholder for the verification logic
    // In production, you should:
    // - For Google Play: Use the Google Play Developer API to verify the purchase
    // - For App Store: Use Apple's verifyReceipt endpoint to validate the receipt
    this.logger.warn(`IAP verification not yet implemented for ${provider}. Processing without validation.`);

    try {
      const payment = await this.prisma.payment.create({
        data: {
          userId,
          amount: new Decimal(amount),
          currency: 'KRW',
          provider: provider === 'GOOGLE_PLAY' ? PaymentProvider.GOOGLE_PLAY : PaymentProvider.APP_STORE,
          providerPaymentId: purchaseToken,
          type: PaymentType.WALLET_CHARGE,
          status: PaymentStatus.COMPLETED,
        },
      });

      await this.walletService.deposit(userId, amount, payment.id);

      this.logger.log(`Successfully processed IAP for user ${userId}, amount: ${amount}`);
      return { success: true, payment };
    } catch (error) {
      this.logger.error(`Failed to process IAP for user ${userId}: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to process in-app purchase. Please try again later.');
    }
  }

  private getProductAmount(productId: string): number {
    const products: Record<string, number> = {
      'coins_5000': 5000,
      'coins_10000': 10000,
      'coins_30000': 30000,
      'coins_50000': 50000,
      'coins_100000': 100000,
    };

    return products[productId] || 0;
  }
}
