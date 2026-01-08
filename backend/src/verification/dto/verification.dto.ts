import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum VerificationPurpose {
  IDENTITY = 'identity',      // 본인인증
  PAYMENT = 'payment',        // 결제 인증
  WITHDRAWAL = 'withdrawal',  // 출금 인증
}

export class InitiateVerificationDto {
  @ApiPropertyOptional({
    description: '인증 목적',
    enum: VerificationPurpose,
    default: VerificationPurpose.IDENTITY,
  })
  @IsEnum(VerificationPurpose)
  @IsOptional()
  purpose?: VerificationPurpose = VerificationPurpose.IDENTITY;

  @ApiPropertyOptional({ description: '모바일 여부 (딥링크 리다이렉트용)' })
  @IsOptional()
  isMobile?: boolean;

  @ApiPropertyOptional({ description: '인증 완료 후 리다이렉트 URL (웹용)' })
  @IsString()
  @IsOptional()
  returnUrl?: string;
}

export class VerificationCallbackDto {
  @ApiProperty({ description: '카카오 본인인증 트랜잭션 ID' })
  @IsString()
  txId: string;

  @ApiPropertyOptional({ description: '인증 결과 코드' })
  @IsString()
  @IsOptional()
  code?: string;

  @ApiPropertyOptional({ description: '에러 코드 (실패 시)' })
  @IsString()
  @IsOptional()
  error?: string;

  @ApiPropertyOptional({ description: '에러 설명 (실패 시)' })
  @IsString()
  @IsOptional()
  errorDescription?: string;
}

export class VerificationStatusDto {
  @ApiProperty({ description: '인증 기록 ID' })
  @IsUUID()
  verificationId: string;
}

// Response DTOs
export class InitiateVerificationResponseDto {
  @ApiProperty({ description: '인증 요청 ID' })
  verificationId: string;

  @ApiProperty({ description: '카카오 본인인증 URL' })
  certificationUrl: string;

  @ApiProperty({ description: '트랜잭션 ID' })
  txId: string;

  @ApiProperty({ description: '만료 시간 (Unix timestamp)' })
  expiresAt: number;
}

export class VerificationResultDto {
  @ApiProperty({ description: '인증 성공 여부' })
  success: boolean;

  @ApiPropertyOptional({ description: '인증 상태' })
  status?: string;

  @ApiPropertyOptional({ description: '마스킹된 휴대폰 번호' })
  maskedPhoneNumber?: string;

  @ApiPropertyOptional({ description: '마스킹된 이름' })
  maskedName?: string;

  @ApiPropertyOptional({ description: '성인 여부' })
  isAdult?: boolean;

  @ApiPropertyOptional({ description: '에러 메시지' })
  errorMessage?: string;
}

export class VerificationStatusResponseDto {
  @ApiProperty({ description: '인증 ID' })
  id: string;

  @ApiProperty({ description: '인증 상태' })
  status: string;

  @ApiProperty({ description: '인증 완료 여부' })
  isCompleted: boolean;

  @ApiPropertyOptional({ description: '마스킹된 휴대폰 번호' })
  maskedPhoneNumber?: string;

  @ApiPropertyOptional({ description: '마스킹된 이름' })
  maskedName?: string;

  @ApiProperty({ description: '인증 요청 시각' })
  requestedAt: Date;

  @ApiPropertyOptional({ description: '인증 완료 시각' })
  completedAt?: Date;
}
