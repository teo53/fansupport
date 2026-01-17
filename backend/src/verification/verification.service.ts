import {
  Injectable,
  Logger,
  BadRequestException,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../database/prisma.service';
import { VerificationStatus, Gender } from '@prisma/client';
import { createHash, randomInt } from 'crypto';

/**
 * OTP 저장소 (Redis 사용 권장, 여기서는 메모리 사용)
 */
interface OtpData {
  code: string;
  phoneNumber: string;
  userId: string;
  expiresAt: number;
  attempts: number;
}

const otpStore = new Map<string, OtpData>();
const OTP_TTL = 3 * 60 * 1000; // 3분
const MAX_OTP_ATTEMPTS = 5;
const OTP_COOLDOWN = 60 * 1000; // 재전송 쿨다운 1분

// 쿨다운 추적
const cooldownStore = new Map<string, number>();

/**
 * SMS 발송 인터페이스 (실제 구현 시 NHN Cloud, AWS SNS 등 사용)
 */
interface SmsProvider {
  sendSms(phoneNumber: string, message: string): Promise<boolean>;
}

@Injectable()
export class VerificationService {
  private readonly logger = new Logger(VerificationService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * SMS OTP 발송 요청
   */
  async requestSmsOtp(userId: string, phoneNumber: string): Promise<{ success: boolean; expiresIn: number }> {
    // 전화번호 정규화
    const normalizedPhone = this.normalizePhoneNumber(phoneNumber);

    // 쿨다운 체크
    const lastRequest = cooldownStore.get(`${userId}:${normalizedPhone}`);
    if (lastRequest && Date.now() - lastRequest < OTP_COOLDOWN) {
      const remainingSeconds = Math.ceil((OTP_COOLDOWN - (Date.now() - lastRequest)) / 1000);
      throw new BadRequestException(`${remainingSeconds}초 후에 다시 시도해주세요.`);
    }

    // 이미 인증된 번호인지 확인
    const existingUser = await this.prisma.user.findFirst({
      where: {
        phoneNumber: normalizedPhone,
        identityVerifiedAt: { not: null },
        id: { not: userId },
      },
    });

    if (existingUser) {
      throw new ConflictException('이미 다른 계정에서 인증된 휴대폰 번호입니다.');
    }

    // OTP 생성 (6자리)
    const otpCode = this.generateOtp();
    const otpKey = `${userId}:${normalizedPhone}`;

    // OTP 저장
    otpStore.set(otpKey, {
      code: otpCode,
      phoneNumber: normalizedPhone,
      userId,
      expiresAt: Date.now() + OTP_TTL,
      attempts: 0,
    });

    // 쿨다운 설정
    cooldownStore.set(otpKey, Date.now());

    // SMS 발송 (실제 구현 필요)
    const smsMessage = `[PIPO] 인증번호는 [${otpCode}]입니다. 3분 내에 입력해주세요.`;
    await this.sendSms(normalizedPhone, smsMessage);

    // 인증 기록 생성
    await this.prisma.identityVerification.create({
      data: {
        userId,
        provider: 'KAKAO', // SMS로 변경 필요하면 enum 추가
        status: 'PENDING',
        phoneNumber: this.maskPhoneNumber(normalizedPhone),
        ipAddress: null, // 컨트롤러에서 전달받아 설정
      },
    });

    this.logger.log(`OTP sent to ${this.maskPhoneNumber(normalizedPhone)} for user ${userId}`);

    return {
      success: true,
      expiresIn: OTP_TTL / 1000,
    };
  }

  /**
   * SMS OTP 검증
   */
  async verifySmsOtp(
    userId: string,
    phoneNumber: string,
    otpCode: string,
  ): Promise<{ success: boolean; message: string }> {
    const normalizedPhone = this.normalizePhoneNumber(phoneNumber);
    const otpKey = `${userId}:${normalizedPhone}`;
    const otpData = otpStore.get(otpKey);

    if (!otpData) {
      throw new BadRequestException('인증번호를 먼저 요청해주세요.');
    }

    // 만료 체크
    if (Date.now() > otpData.expiresAt) {
      otpStore.delete(otpKey);
      throw new BadRequestException('인증번호가 만료되었습니다. 다시 요청해주세요.');
    }

    // 시도 횟수 체크
    if (otpData.attempts >= MAX_OTP_ATTEMPTS) {
      otpStore.delete(otpKey);
      throw new BadRequestException('인증 시도 횟수를 초과했습니다. 다시 요청해주세요.');
    }

    // OTP 검증
    if (otpData.code !== otpCode) {
      otpData.attempts++;
      const remaining = MAX_OTP_ATTEMPTS - otpData.attempts;
      throw new BadRequestException(`인증번호가 일치하지 않습니다. (남은 시도: ${remaining}회)`);
    }

    // 인증 성공 - OTP 삭제
    otpStore.delete(otpKey);

    // 사용자 정보 업데이트
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        phoneNumber: normalizedPhone,
        identityVerifiedAt: new Date(),
      },
    });

    // 인증 기록 업데이트
    await this.prisma.identityVerification.updateMany({
      where: {
        userId,
        status: 'PENDING',
      },
      data: {
        status: 'COMPLETED',
        completedAt: new Date(),
      },
    });

    this.logger.log(`Phone verified for user ${userId}: ${this.maskPhoneNumber(normalizedPhone)}`);

    return {
      success: true,
      message: '휴대폰 인증이 완료되었습니다.',
    };
  }

  /**
   * 인증 상태 조회
   */
  async getVerificationStatus(userId: string): Promise<{
    isVerified: boolean;
    maskedPhoneNumber: string | null;
    verifiedAt: Date | null;
  }> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        phoneNumber: true,
        identityVerifiedAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('사용자를 찾을 수 없습니다.');
    }

    return {
      isVerified: !!user.identityVerifiedAt,
      maskedPhoneNumber: user.phoneNumber ? this.maskPhoneNumber(user.phoneNumber) : null,
      verifiedAt: user.identityVerifiedAt,
    };
  }

  /**
   * 6자리 OTP 생성
   */
  private generateOtp(): string {
    return randomInt(100000, 999999).toString();
  }

  /**
   * 전화번호 정규화 (010-1234-5678 -> 01012345678)
   */
  private normalizePhoneNumber(phone: string): string {
    return phone.replace(/[^0-9]/g, '');
  }

  /**
   * 전화번호 마스킹 (01012345678 -> 010****5678)
   */
  private maskPhoneNumber(phone: string): string {
    if (phone.length < 8) return phone;
    return phone.slice(0, 3) + '****' + phone.slice(-4);
  }

  /**
   * 이름 마스킹 (홍길동 -> 홍*동)
   */
  private maskName(name: string): string {
    if (name.length <= 1) return name;
    if (name.length === 2) return name[0] + '*';
    return name[0] + '*'.repeat(name.length - 2) + name[name.length - 1];
  }

  /**
   * SMS 발송 - NHN Cloud Toast SMS / Twilio 지원
   * 환경변수에 따라 적절한 프로바이더 선택
   */
  private async sendSms(phoneNumber: string, message: string): Promise<boolean> {
    const nodeEnv = this.configService.get<string>('NODE_ENV') || this.configService.get<string>('app.nodeEnv');
    const isDevelopment = nodeEnv === 'development';

    // 개발 환경에서는 로그로 대체 (실제 발송 시뮬레이션)
    if (isDevelopment) {
      this.logger.warn(`[DEV MODE] SMS to ${phoneNumber}: ${message}`);
      return true;
    }

    // SMS 프로바이더 선택
    const smsProvider = this.configService.get<string>('SMS_PROVIDER') || 'nhn';

    try {
      if (smsProvider === 'twilio') {
        return await this.sendSmsTwilio(phoneNumber, message);
      } else {
        return await this.sendSmsNhn(phoneNumber, message);
      }
    } catch (error) {
      this.logger.error(`SMS 발송 실패: ${error instanceof Error ? error.message : 'Unknown error'}`, error instanceof Error ? error.stack : undefined);
      throw new BadRequestException('SMS 발송에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /**
   * NHN Cloud Toast SMS 발송
   */
  private async sendSmsNhn(phoneNumber: string, message: string): Promise<boolean> {
    const appKey = this.configService.get<string>('NHN_SMS_APP_KEY');
    const secretKey = this.configService.get<string>('NHN_SMS_SECRET_KEY');
    const sendNo = this.configService.get<string>('NHN_SMS_SENDER_NUMBER');

    if (!appKey || !secretKey || !sendNo) {
      this.logger.error('NHN Cloud SMS 설정이 누락되었습니다.');
      throw new Error('SMS 설정 오류');
    }

    // 국제번호 형식 변환 (010xxx -> +82010xxx)
    const internationalPhone = this.formatPhoneForKorea(phoneNumber);

    const response = await fetch(
      `https://api-sms.cloud.toast.com/sms/v3.0/appKeys/${appKey}/sender/sms`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
          'X-Secret-Key': secretKey,
        },
        body: JSON.stringify({
          body: message,
          sendNo: sendNo,
          recipientList: [
            {
              recipientNo: internationalPhone,
              countryCode: '82',
            },
          ],
        }),
      },
    );

    const result = await response.json();

    if (!response.ok || result.header?.isSuccessful === false) {
      this.logger.error(`NHN SMS 발송 실패: ${JSON.stringify(result)}`);
      return false;
    }

    this.logger.log(`SMS sent via NHN to ${this.maskPhoneNumber(phoneNumber)}`);
    return true;
  }

  /**
   * Twilio SMS 발송
   */
  private async sendSmsTwilio(phoneNumber: string, message: string): Promise<boolean> {
    const accountSid = this.configService.get<string>('TWILIO_ACCOUNT_SID');
    const authToken = this.configService.get<string>('TWILIO_AUTH_TOKEN');
    const fromNumber = this.configService.get<string>('TWILIO_PHONE_NUMBER');

    if (!accountSid || !authToken || !fromNumber) {
      this.logger.error('Twilio SMS 설정이 누락되었습니다.');
      throw new Error('SMS 설정 오류');
    }

    // 국제번호 형식 변환
    const internationalPhone = this.formatPhoneForKorea(phoneNumber);

    const auth = Buffer.from(`${accountSid}:${authToken}`).toString('base64');

    const response = await fetch(
      `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          Authorization: `Basic ${auth}`,
        },
        body: new URLSearchParams({
          To: internationalPhone,
          From: fromNumber,
          Body: message,
        }).toString(),
      },
    );

    const result = await response.json();

    if (!response.ok || result.error_code) {
      this.logger.error(`Twilio SMS 발송 실패: ${JSON.stringify(result)}`);
      return false;
    }

    this.logger.log(`SMS sent via Twilio to ${this.maskPhoneNumber(phoneNumber)}`);
    return true;
  }

  /**
   * 한국 전화번호를 국제 형식으로 변환
   * 01012345678 -> +821012345678
   */
  private formatPhoneForKorea(phone: string): string {
    const normalized = this.normalizePhoneNumber(phone);
    if (normalized.startsWith('0')) {
      return '+82' + normalized.substring(1);
    }
    if (normalized.startsWith('+82')) {
      return normalized;
    }
    return '+82' + normalized;
  }

  /**
   * 만료된 OTP 정리 (주기적 실행 권장)
   */
  cleanupExpiredOtps(): void {
    const now = Date.now();
    for (const [key, data] of otpStore.entries()) {
      if (now > data.expiresAt) {
        otpStore.delete(key);
      }
    }
  }
}
