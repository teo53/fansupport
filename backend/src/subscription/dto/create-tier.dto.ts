import { IsString, IsNumber, IsArray, IsOptional, Min, Max, MaxLength, ArrayMaxSize } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateTierDto {
  @ApiProperty({ description: 'Tier name' })
  @IsString()
  @MaxLength(50, { message: 'Tier name cannot exceed 50 characters' })
  name: string;

  @ApiProperty({ description: 'Monthly subscription price in KRW', minimum: 1000, maximum: 1000000 })
  @IsNumber()
  @Min(1000, { message: 'Minimum subscription price is 1,000 KRW' })
  @Max(1000000, { message: 'Maximum subscription price is 1,000,000 KRW per month' })
  price: number;

  @ApiProperty({ description: 'List of benefits (max 20 items)', type: [String] })
  @IsArray()
  @ArrayMaxSize(20, { message: 'Maximum 20 benefits allowed' })
  @IsString({ each: true })
  @MaxLength(200, { each: true, message: 'Each benefit cannot exceed 200 characters' })
  benefits: string[];

  @ApiPropertyOptional({ description: 'Maximum number of subscribers' })
  @IsOptional()
  @IsNumber()
  @Min(1, { message: 'Minimum subscriber limit is 1' })
  @Max(10000, { message: 'Maximum subscriber limit is 10,000' })
  maxSubscribers?: number;
}
