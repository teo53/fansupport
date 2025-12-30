import { IsString, IsOptional, IsEnum, IsArray, MaxLength, IsUrl } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

enum IdolCategory {
  UNDERGROUND_IDOL = 'UNDERGROUND_IDOL',
  MAID_CAFE = 'MAID_CAFE',
  COSPLAYER = 'COSPLAYER',
  VTuber = 'VTuber',
  OTHER = 'OTHER',
}

export class CreateIdolProfileDto {
  @ApiProperty()
  @IsString()
  @MaxLength(50)
  stageName: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  introduction?: string;

  @ApiProperty({ enum: IdolCategory })
  @IsEnum(IdolCategory)
  category: IdolCategory;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(100)
  cafeName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(200)
  cafeAddress?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUrl()
  headerImage?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsArray()
  @IsUrl({}, { each: true })
  galleryImages?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  socialLinks?: Record<string, string>;
}
