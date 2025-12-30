import { IsString, IsNumber, IsArray, IsOptional, Min, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateTierDto {
  @ApiProperty({ description: 'Tier name' })
  @IsString()
  @MaxLength(50)
  name: string;

  @ApiProperty({ description: 'Monthly subscription price in KRW', minimum: 1000 })
  @IsNumber()
  @Min(1000)
  price: number;

  @ApiProperty({ description: 'List of benefits', type: [String] })
  @IsArray()
  @IsString({ each: true })
  benefits: string[];

  @ApiPropertyOptional({ description: 'Maximum number of subscribers' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  maxSubscribers?: number;
}
