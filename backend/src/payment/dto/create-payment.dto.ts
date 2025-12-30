import { IsNumber, IsEnum, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

enum PaymentType {
  WALLET_CHARGE = 'WALLET_CHARGE',
  SUBSCRIPTION = 'SUBSCRIPTION',
  CAMPAIGN = 'CAMPAIGN',
  DIRECT_SUPPORT = 'DIRECT_SUPPORT',
}

export class CreatePaymentDto {
  @ApiProperty({ description: 'Payment amount in KRW', minimum: 1000 })
  @IsNumber()
  @Min(1000)
  amount: number;

  @ApiProperty({ description: 'Payment type', enum: PaymentType })
  @IsEnum(PaymentType)
  type: PaymentType;
}
