import { Injectable, BadRequestException, NotFoundException, Logger, ConflictException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../database/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { PaymentProvider, PaymentStatus, PaymentType } from '@prisma/client';
import Stripe from 'stripe';
import { Decimal } from '@prisma/client/runtime/library';
import { createSign, createVerify } from 'crypto';

/**
 * Google Play 영수증 검증 응답 타입
 */
interface GooglePlayPurchaseResponse {
  kind: string;
  purchaseTimeMillis: string;
  purchaseState: number;
  consumptionState: number;
  developerPayload: string;
  orderId: string;
  purchaseType?: number;
  acknowledgementState: number;
  regionCode: string;
}

/**
 * App Store 영수증 검증 응답 타입
 */
interface AppStoreReceiptResponse {
  status: number;
  receipt: {
    bundle_id: string;
    in_app: Array<{
      product_id: string;
      transaction_id: string;
      original_transaction_id: string;
      purchase_date_ms: string;
      quantity: string;
    }>;
  };
  environment: 'Production' | 'Sandbox';
}

@Injectable()
export class PaymentService {
  private readonly logger = new Logger(PaymentService.name);
  private stripe: Stripe;
  private googleAccessToken: string | null = null;
  private googleTokenExpiry: number = 0;

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

  /**
   * Google Play / App Store IAP 검증
   */
  async verifyInAppPurchase(
    userId: string,
    provider: 'GOOGLE_PLAY' | 'APP_STORE',
    purchaseToken: string,
    productId: string,
  ) {
    // 중복 검증 방지 (이미 처리된 영수증인지 확인)
    const existingPayment = await this.prisma.payment.findFirst({
      where: {
        providerPaymentId: purchaseToken,
        status: PaymentStatus.COMPLETED,
      },
    });

    if (existingPayment) {
      throw new ConflictException('이미 처리된 결제입니다.');
    }

    // 상품 금액 확인
    const amount = this.getProductAmount(productId);
    if (amount <= 0) {
      throw new BadRequestException('유효하지 않은 상품입니다.');
    }

    // 프로바이더별 검증
    let isValid = false;
    let transactionId = purchaseToken;

    try {
      if (provider === 'GOOGLE_PLAY') {
        const result = await this.verifyGooglePlayPurchase(productId, purchaseToken);
        isValid = result.isValid;
        transactionId = result.orderId || purchaseToken;
      } else {
        const result = await this.verifyAppStorePurchase(purchaseToken, productId);
        isValid = result.isValid;
        transactionId = result.transactionId || purchaseToken;
      }
    } catch (error) {
      this.logger.error(`IAP 검증 실패: ${error instanceof Error ? error.message : 'Unknown error'}`);
      throw new BadRequestException('결제 검증에 실패했습니다.');
    }

    if (!isValid) {
      throw new BadRequestException('유효하지 않은 결제입니다.');
    }

    // 결제 기록 생성 및 지갑 충전
    const payment = await this.prisma.$transaction(async (tx) => {
      const paymentRecord = await tx.payment.create({
        data: {
          userId,
          amount: new Decimal(amount),
          currency: 'KRW',
          provider: provider === 'GOOGLE_PLAY' ? PaymentProvider.GOOGLE_PLAY : PaymentProvider.APP_STORE,
          providerPaymentId: transactionId,
          type: PaymentType.WALLET_CHARGE,
          status: PaymentStatus.COMPLETED,
        },
      });

      // 지갑 충전
      await this.walletService.deposit(userId, amount, paymentRecord.id);

      return paymentRecord;
    });

    this.logger.log(`IAP verified and wallet charged: user=${userId}, amount=${amount}, provider=${provider}`);

    return { success: true, payment };
  }

  /**
   * Google Play 구매 검증
   */
  private async verifyGooglePlayPurchase(
    productId: string,
    purchaseToken: string,
  ): Promise<{ isValid: boolean; orderId?: string }> {
    const packageName = this.configService.get<string>('GOOGLE_PLAY_PACKAGE_NAME');

    if (!packageName) {
      this.logger.error('Google Play 패키지명 설정이 누락되었습니다.');
      throw new Error('Google Play 설정 오류');
    }

    // Google Play Developer API 액세스 토큰 획득
    const accessToken = await this.getGoogleAccessToken();

    const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/products/${productId}/tokens/${purchaseToken}`;

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      const error = await response.text();
      this.logger.error(`Google Play 검증 API 오류: ${error}`);
      return { isValid: false };
    }

    const data: GooglePlayPurchaseResponse = await response.json();

    // purchaseState: 0 = Purchased, 1 = Canceled
    // consumptionState: 0 = Not consumed, 1 = Consumed
    const isValid = data.purchaseState === 0;

    return {
      isValid,
      orderId: data.orderId,
    };
  }

  /**
   * Google OAuth 액세스 토큰 획득 (Service Account 사용)
   */
  private async getGoogleAccessToken(): Promise<string> {
    // 캐시된 토큰이 유효한 경우 재사용
    if (this.googleAccessToken && Date.now() < this.googleTokenExpiry - 60000) {
      return this.googleAccessToken;
    }

    const serviceAccountEmail = this.configService.get<string>('GOOGLE_SERVICE_ACCOUNT_EMAIL');
    const privateKey = this.configService.get<string>('GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY');

    if (!serviceAccountEmail || !privateKey) {
      throw new Error('Google Service Account 설정이 누락되었습니다.');
    }

    // JWT 생성
    const now = Math.floor(Date.now() / 1000);
    const header = Buffer.from(JSON.stringify({
      alg: 'RS256',
      typ: 'JWT',
    })).toString('base64url');

    const payload = Buffer.from(JSON.stringify({
      iss: serviceAccountEmail,
      scope: 'https://www.googleapis.com/auth/androidpublisher',
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: now + 3600,
    })).toString('base64url');

    const signInput = `${header}.${payload}`;
    const sign = createSign('RSA-SHA256');
    sign.update(signInput);
    const signature = sign.sign(privateKey.replace(/\\n/g, '\n'), 'base64url');

    const jwt = `${signInput}.${signature}`;

    // 토큰 교환
    const response = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }).toString(),
    });

    if (!response.ok) {
      const error = await response.text();
      this.logger.error(`Google OAuth 토큰 획득 실패: ${error}`);
      throw new Error('Google 인증 실패');
    }

    const tokenData = await response.json();
    this.googleAccessToken = tokenData.access_token;
    this.googleTokenExpiry = Date.now() + (tokenData.expires_in * 1000);

    return this.googleAccessToken!;
  }

  /**
   * App Store 영수증 검증
   */
  private async verifyAppStorePurchase(
    receiptData: string,
    expectedProductId: string,
  ): Promise<{ isValid: boolean; transactionId?: string }> {
    const sharedSecret = this.configService.get<string>('APPLE_SHARED_SECRET');

    if (!sharedSecret) {
      this.logger.error('Apple Shared Secret 설정이 누락되었습니다.');
      throw new Error('App Store 설정 오류');
    }

    // 프로덕션 URL로 먼저 시도
    let result = await this.callAppStoreVerifyEndpoint(
      'https://buy.itunes.apple.com/verifyReceipt',
      receiptData,
      sharedSecret,
    );

    // status 21007이면 샌드박스로 재시도
    if (result.status === 21007) {
      this.logger.log('샌드박스 환경으로 재검증 시도');
      result = await this.callAppStoreVerifyEndpoint(
        'https://sandbox.itunes.apple.com/verifyReceipt',
        receiptData,
        sharedSecret,
      );
    }

    // status 0이면 유효
    if (result.status !== 0) {
      this.logger.warn(`App Store 영수증 검증 실패: status=${result.status}`);
      return { isValid: false };
    }

    // 해당 상품 구매 내역 확인
    const inAppPurchases = result.receipt?.in_app || [];
    const purchase = inAppPurchases.find(
      (p) => p.product_id === expectedProductId,
    );

    if (!purchase) {
      this.logger.warn(`상품 ID ${expectedProductId}를 영수증에서 찾을 수 없습니다.`);
      return { isValid: false };
    }

    return {
      isValid: true,
      transactionId: purchase.transaction_id,
    };
  }

  /**
   * App Store 검증 엔드포인트 호출
   */
  private async callAppStoreVerifyEndpoint(
    url: string,
    receiptData: string,
    sharedSecret: string,
  ): Promise<AppStoreReceiptResponse> {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        'receipt-data': receiptData,
        password: sharedSecret,
        'exclude-old-transactions': true,
      }),
    });

    return response.json();
  }

  /**
   * 상품 ID에 해당하는 금액 반환
   */
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
