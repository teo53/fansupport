import { IsNumber, IsOptional, IsBoolean, IsString, Min, Max, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ContributeDto {
  @ApiProperty({ description: 'Contribution amount in KRW', minimum: 1000, maximum: 10000000 })
  @IsNumber()
  @Min(1000, { message: 'Minimum contribution amount is 1,000 KRW' })
  @Max(10000000, { message: 'Maximum contribution amount is 10,000,000 KRW per transaction' })
  amount: number;

  @ApiPropertyOptional({ description: 'Selected reward tier' })
  @IsOptional()
  @IsString()
  @MaxLength(100, { message: 'Reward tier ID cannot exceed 100 characters' })
  rewardTier?: string;

  @ApiPropertyOptional({ description: 'Contribution message' })
  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'Contribution message cannot exceed 500 characters' })
  message?: string;

  @ApiPropertyOptional({ description: 'Contribute anonymously', default: false })
  @IsOptional()
  @IsBoolean()
  isAnonymous?: boolean = false;
}
