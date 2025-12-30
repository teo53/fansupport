import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { PaymentProvider, PaymentStatus, PaymentType } from '@prisma/client';
import Stripe from 'stripe';
import { Decimal } from '@prisma/client/runtime/library';

@Injectable()
export class PaymentService {
  private stripe: Stripe;

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
    private readonly walletService: WalletService,
  ) {
    this.stripe = new Stripe(this.configService.get<string>('STRIPE_SECRET_KEY') || '', {
      apiVersion: '2023-10-16',
    });
  }

  async createPaymentIntent(userId: string, amount: number, type: PaymentType) {
    if (amount < 1000) {
      throw new BadRequestException('Minimum amount is 1000 KRW');
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
  }

  async handleStripeWebhook(signature: string, payload: Buffer) {
    const webhookSecret = this.configService.get<string>('STRIPE_WEBHOOK_SECRET');

    let event: Stripe.Event;

    try {
      event = this.stripe.webhooks.constructEvent(payload, signature, webhookSecret || '');
    } catch (err) {
      throw new BadRequestException(`Webhook signature verification failed`);
    }

    switch (event.type) {
      case 'payment_intent.succeeded':
        await this.handlePaymentSuccess(event.data.object as Stripe.PaymentIntent);
        break;
      case 'payment_intent.payment_failed':
        await this.handlePaymentFailure(event.data.object as Stripe.PaymentIntent);
        break;
    }

    return { received: true };
  }

  private async handlePaymentSuccess(paymentIntent: Stripe.PaymentIntent) {
    const payment = await this.prisma.payment.findFirst({
      where: { providerPaymentId: paymentIntent.id },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    // Update payment status
    await this.prisma.payment.update({
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
  }

  private async handlePaymentFailure(paymentIntent: Stripe.PaymentIntent) {
    const payment = await this.prisma.payment.findFirst({
      where: { providerPaymentId: paymentIntent.id },
    });

    if (payment) {
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: { status: PaymentStatus.FAILED },
      });
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
    // TODO: Implement actual verification with Google Play / App Store APIs
    // This is a placeholder for the verification logic

    const amount = this.getProductAmount(productId);

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

    return { success: true, payment };
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
