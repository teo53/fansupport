import { IsEmail, IsString, MinLength, MaxLength, Matches, IsDateString, IsBoolean } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({
    example: 'SecurePass123!',
    minLength: 8,
    description: 'Password must be 8-50 characters with at least 1 uppercase, 1 lowercase, 1 number, and 1 special character'
  })
  @IsString()
  @MinLength(8, { message: '비밀번호는 최소 8자 이상이어야 합니다' })
  @MaxLength(50, { message: '비밀번호는 최대 50자까지 가능합니다' })
  @Matches(
    /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
    { message: '비밀번호는 대문자, 소문자, 숫자, 특수문자(@$!%*?&)를 각각 1개 이상 포함해야 합니다' }
  )
  password: string;

  @ApiProperty({ example: 'NickName' })
  @IsString()
  @MinLength(2, { message: '닉네임은 최소 2자 이상이어야 합니다' })
  @MaxLength(30, { message: '닉네임은 최대 30자까지 가능합니다' })
  nickname: string;

  @ApiProperty({
    example: '2000-01-01',
    description: 'Date of birth (YYYY-MM-DD) for age verification'
  })
  @IsDateString()
  dateOfBirth: string;

  @ApiProperty({
    description: 'Consent to terms of service',
    example: true
  })
  @IsBoolean()
  termsConsent: boolean;

  @ApiProperty({
    description: 'Consent to privacy policy',
    example: true
  })
  @IsBoolean()
  privacyConsent: boolean;

  @ApiProperty({
    description: 'Consent to marketing (optional)',
    example: false,
    required: false
  })
  @IsBoolean()
  marketingConsent?: boolean;
}
