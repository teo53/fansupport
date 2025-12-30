import { IsString, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

enum IAPProvider {
  GOOGLE_PLAY = 'GOOGLE_PLAY',
  APP_STORE = 'APP_STORE',
}

export class VerifyIAPDto {
  @ApiProperty({ description: 'IAP provider', enum: IAPProvider })
  @IsEnum(IAPProvider)
  provider: 'GOOGLE_PLAY' | 'APP_STORE';

  @ApiProperty({ description: 'Purchase token from store' })
  @IsString()
  purchaseToken: string;

  @ApiProperty({ description: 'Product ID' })
  @IsString()
  productId: string;
}
