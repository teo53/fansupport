import { IsString, IsNumber, IsOptional, IsDateString, Min, MaxLength, IsUrl } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCampaignDto {
  @ApiProperty({ description: 'Campaign title' })
  @IsString()
  @MaxLength(100)
  title: string;

  @ApiProperty({ description: 'Campaign description' })
  @IsString()
  @MaxLength(5000)
  description: string;

  @ApiPropertyOptional({ description: 'Cover image URL' })
  @IsOptional()
  @IsUrl()
  coverImage?: string;

  @ApiProperty({ description: 'Goal amount in KRW', minimum: 10000 })
  @IsNumber()
  @Min(10000)
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
