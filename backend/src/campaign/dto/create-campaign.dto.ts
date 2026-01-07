import { IsString, IsNumber, IsOptional, IsDateString, Min, Max, MaxLength, IsUrl } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCampaignDto {
  @ApiProperty({ description: 'Campaign title' })
  @IsString()
  @MaxLength(100, { message: 'Campaign title cannot exceed 100 characters' })
  title: string;

  @ApiProperty({ description: 'Campaign description' })
  @IsString()
  @MaxLength(5000, { message: 'Campaign description cannot exceed 5,000 characters' })
  description: string;

  @ApiPropertyOptional({ description: 'Cover image URL' })
  @IsOptional()
  @IsUrl({}, { message: 'Cover image must be a valid URL' })
  coverImage?: string;

  @ApiProperty({ description: 'Goal amount in KRW', minimum: 10000, maximum: 100000000 })
  @IsNumber()
  @Min(10000, { message: 'Minimum campaign goal is 10,000 KRW' })
  @Max(100000000, { message: 'Maximum campaign goal is 100,000,000 KRW' })
  goalAmount: number;

  @ApiProperty({ description: 'Campaign start date' })
  @IsDateString()
  startDate: string;

  @ApiProperty({ description: 'Campaign end date' })
  @IsDateString()
  endDate: string;

  @ApiPropertyOptional({ description: 'Reward tiers' })
  @IsOptional()
  rewards?: Array<{
    amount: number;
    title: string;
    description: string;
  }>;
}
