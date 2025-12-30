import { IsNumber, IsOptional, IsBoolean, IsString, Min, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ContributeDto {
  @ApiProperty({ description: 'Contribution amount in KRW', minimum: 1000 })
  @IsNumber()
  @Min(1000)
  amount: number;

  @ApiPropertyOptional({ description: 'Selected reward tier' })
  @IsOptional()
  @IsString()
  rewardTier?: string;

  @ApiPropertyOptional({ description: 'Contribution message' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  message?: string;

  @ApiPropertyOptional({ description: 'Contribute anonymously', default: false })
  @IsOptional()
  @IsBoolean()
  isAnonymous?: boolean = false;
}
