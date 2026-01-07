import { IsString, IsNumber, IsOptional, IsBoolean, Min, Max, MaxLength, IsUUID } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSupportDto {
  @ApiProperty({ description: 'ID of the idol/maid to support' })
  @IsUUID()
  receiverId: string;

  @ApiProperty({ description: 'Support amount in KRW', minimum: 100, maximum: 10000000 })
  @IsNumber()
  @Min(100, { message: 'Minimum support amount is 100 KRW' })
  @Max(10000000, { message: 'Maximum support amount is 10,000,000 KRW per transaction' })
  amount: number;

  @ApiPropertyOptional({ description: 'Support message' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  message?: string;

  @ApiPropertyOptional({ description: 'Send anonymously', default: false })
  @IsOptional()
  @IsBoolean()
  isAnonymous?: boolean = false;
}
