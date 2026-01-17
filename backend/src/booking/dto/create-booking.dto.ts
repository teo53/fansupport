import { IsString, IsNumber, IsOptional, IsDateString, Min, Max, MaxLength, Matches, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateBookingDto {
  @ApiProperty({ description: 'Cafe name' })
  @IsString()
  @MinLength(1, { message: '카페 이름을 입력해주세요.' })
  @MaxLength(100, { message: '카페 이름은 100자를 초과할 수 없습니다.' })
  cafeName: string;

  @ApiPropertyOptional({ description: 'Cafe address' })
  @IsOptional()
  @IsString()
  @MaxLength(200, { message: '주소는 200자를 초과할 수 없습니다.' })
  cafeAddress?: string;

  @ApiProperty({ description: 'Booking date (YYYY-MM-DD)' })
  @IsDateString({}, { message: '유효한 날짜 형식을 입력해주세요. (YYYY-MM-DD)' })
  date: string;

  @ApiProperty({ description: 'Time slot (e.g., "14:00")' })
  @IsString()
  @Matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, {
    message: '유효한 시간 형식을 입력해주세요. (HH:MM)',
  })
  timeSlot: string;

  @ApiProperty({ description: 'Number of guests', minimum: 1, maximum: 10 })
  @IsNumber()
  @Min(1)
  @Max(10)
  numberOfGuests: number;

  @ApiPropertyOptional({ description: 'Special requests' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  specialRequest?: string;
}
