import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { VerificationService } from './verification.service';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Request } from 'express';

// DTOs
class RequestOtpDto {
  phoneNumber: string;
}

class VerifyOtpDto {
  phoneNumber: string;
  otpCode: string;
}

@ApiTags('Verification (본인인증)')
@Controller('verification')
export class VerificationController {
  constructor(private readonly verificationService: VerificationService) {}

  /**
   * SMS OTP 발송 요청
   */
  @Post('sms/request')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'SMS 인증번호 요청',
    description: '휴대폰 번호로 6자리 인증번호를 발송합니다.',
  })
  @ApiResponse({ status: 200, description: '인증번호 발송 성공' })
  @ApiResponse({ status: 400, description: '잘못된 요청 또는 쿨다운' })
  @ApiResponse({ status: 409, description: '이미 인증된 번호' })
  async requestSmsOtp(
    @CurrentUser() user: { id: string },
    @Body() dto: RequestOtpDto,
    @Req() req: Request,
  ) {
    return this.verificationService.requestSmsOtp(user.id, dto.phoneNumber);
  }

  /**
   * SMS OTP 검증
   */
  @Post('sms/verify')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'SMS 인증번호 확인',
    description: '발송된 인증번호를 검증합니다.',
  })
  @ApiResponse({ status: 200, description: '인증 성공' })
  @ApiResponse({ status: 400, description: '인증 실패 또는 만료' })
  async verifySmsOtp(
    @CurrentUser() user: { id: string },
    @Body() dto: VerifyOtpDto,
  ) {
    return this.verificationService.verifySmsOtp(
      user.id,
      dto.phoneNumber,
      dto.otpCode,
    );
  }

  /**
   * 인증 상태 조회
   */
  @Get('status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({
    summary: '본인인증 상태 조회',
    description: '현재 사용자의 본인인증 상태를 조회합니다.',
  })
  @ApiResponse({ status: 200, description: '조회 성공' })
  async getVerificationStatus(@CurrentUser() user: { id: string }) {
    return this.verificationService.getVerificationStatus(user.id);
  }
}
