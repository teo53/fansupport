import { IsEmail, IsString, MinLength, MaxLength, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email: string;

  @ApiProperty({ example: 'password123', minLength: 8, maxLength: 50 })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  @MaxLength(50, { message: 'Password cannot exceed 50 characters' })
  @Matches(/^(?=.*[a-zA-Z])(?=.*[0-9])/, {
    message: 'Password must contain at least one letter and one number'
  })
  password: string;

  @ApiProperty({ example: 'NickName', minLength: 2, maxLength: 30 })
  @IsString()
  @MinLength(2, { message: 'Nickname must be at least 2 characters long' })
  @MaxLength(30, { message: 'Nickname cannot exceed 30 characters' })
  @Matches(/^[a-zA-Z0-9가-힣_]+$/, {
    message: 'Nickname can only contain letters, numbers, Korean characters, and underscores'
  })
  nickname: string;
}
