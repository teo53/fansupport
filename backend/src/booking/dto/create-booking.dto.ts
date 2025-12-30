import { IsString, IsNumber, IsOptional, IsDateString, Min, Max, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateBookingDto {
  @ApiProperty({ description: 'Cafe name' })
  @IsString()
  @MaxLength(100)
  cafeName: string;

  @ApiPropertyOptional({ description: 'Cafe address' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  cafeAddress?: string;

  @ApiProperty({ description: 'Booking date (YYYY-MM-DD)' })
  @IsDateString()
  date: string;

  @ApiProperty({ description: 'Time slot (e.g., "14:00")' })
  @IsString()
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
