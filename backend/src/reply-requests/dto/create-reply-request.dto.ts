import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsBoolean, IsOptional, IsNumber, Min, MaxLength } from 'class-validator';

export class CreateReplyRequestDto {
  @ApiProperty({ description: 'Creator (idol) user ID' })
  @IsString()
  creatorId: string;

  @ApiProperty({ description: 'Reply product ID' })
  @IsString()
  productId: string;

  @ApiProperty({ description: 'SLA option ID' })
  @IsString()
  slaId: string;

  @ApiProperty({ description: 'Request message from fan', maxLength: 1000 })
  @IsString()
  @MaxLength(1000)
  requestMessage: string;

  @ApiProperty({ description: 'Send request anonymously', default: false })
  @IsBoolean()
  @IsOptional()
  isAnonymous?: boolean;
}
