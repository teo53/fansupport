import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsArray, IsInt, Min, Max } from 'class-validator';

export class DeliverReplyDto {
  @ApiProperty({ description: 'Text content of the reply', required: false })
  @IsString()
  @IsOptional()
  textContent?: string;

  @ApiProperty({ description: 'Voice message URL', required: false })
  @IsString()
  @IsOptional()
  voiceUrl?: string;

  @ApiProperty({ description: 'Photo URLs', required: false, type: [String] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  photoUrls?: string[];

  @ApiProperty({ description: 'Video URL', required: false })
  @IsString()
  @IsOptional()
  videoUrl?: string;

  @ApiProperty({ description: 'Duration in seconds (for voice/video)', required: false })
  @IsInt()
  @Min(0)
  @IsOptional()
  duration?: number;

  @ApiProperty({ description: 'Creator note', required: false })
  @IsString()
  @IsOptional()
  creatorNote?: string;
}

export class RejectReplyDto {
  @ApiProperty({ description: 'Reason for rejection' })
  @IsString()
  reason: string;
}

export class FanFeedbackDto {
  @ApiProperty({ description: 'Rating 1-5' })
  @IsInt()
  @Min(1)
  @Max(5)
  rating: number;

  @ApiProperty({ description: 'Feedback message', required: false })
  @IsString()
  @IsOptional()
  feedback?: string;

  @ApiProperty({ description: 'Allow public display of this reply', default: false })
  @IsOptional()
  isPublicAllowed?: boolean;
}
