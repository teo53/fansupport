import { IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SubscribeDto {
  @ApiProperty({ description: 'Creator user ID' })
  @IsUUID()
  creatorId: string;

  @ApiProperty({ description: 'Subscription tier ID' })
  @IsUUID()
  tierId: string;
}
