import { IsString, IsNumber, IsOptional, IsDateString, Min, Max, MaxLength, IsUrl, ValidateNested, IsArray, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

/**
 * 캠페인 리워드 티어 DTO
 */
export class CampaignRewardDto {
  @ApiProperty({ description: '최소 후원 금액', minimum: 1000 })
  @IsNumber()
  @Min(1000, { message: '리워드 최소 금액은 1,000원 이상이어야 합니다.' })
  @Max(10000000, { message: '리워드 최소 금액은 10,000,000원을 초과할 수 없습니다.' })
  amount: number;

  @ApiProperty({ description: '리워드 제목' })
  @IsString()
  @MinLength(1, { message: '리워드 제목을 입력해주세요.' })
  @MaxLength(100, { message: '리워드 제목은 100자를 초과할 수 없습니다.' })
  title: string;

  @ApiProperty({ description: '리워드 설명' })
  @IsString()
  @MinLength(1, { message: '리워드 설명을 입력해주세요.' })
  @MaxLength(1000, { message: '리워드 설명은 1,000자를 초과할 수 없습니다.' })
  description: string;
}

export class CreateCampaignDto {
  @ApiProperty({ description: 'Campaign title' })
  @IsString()
  @MinLength(5, { message: '캠페인 제목은 최소 5자 이상이어야 합니다.' })
  @MaxLength(100, { message: 'Campaign title cannot exceed 100 characters' })
  title: string;

  @ApiProperty({ description: 'Campaign description' })
  @IsString()
  @MinLength(20, { message: '캠페인 설명은 최소 20자 이상이어야 합니다.' })
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
  @IsDateString({}, { message: '유효한 시작 날짜 형식을 입력해주세요. (YYYY-MM-DD)' })
  startDate: string;

  @ApiProperty({ description: 'Campaign end date' })
  @IsDateString({}, { message: '유효한 종료 날짜 형식을 입력해주세요. (YYYY-MM-DD)' })
  endDate: string;

  @ApiPropertyOptional({ description: 'Reward tiers', type: [CampaignRewardDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CampaignRewardDto)
  rewards?: CampaignRewardDto[];
}
