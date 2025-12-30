import { IsString, IsNumber, IsOptional, IsBoolean, Min, MaxLength, IsUUID } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSupportDto {
  @ApiProperty({ description: 'ID of the idol/maid to support' })
  @IsUUID()
  receiverId: string;

  @ApiProperty({ description: 'Support amount in KRW', minimum: 100 })
  @IsNumber()
  @Min(100)
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
