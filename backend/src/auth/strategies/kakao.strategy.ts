import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, Profile } from 'passport-kakao';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';
import { AuthProvider } from '@prisma/client';

@Injectable()
export class KakaoStrategy extends PassportStrategy(Strategy, 'kakao') {
  private readonly logger = new Logger(KakaoStrategy.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly authService: AuthService,
  ) {
    super({
      clientID: configService.get<string>('kakao.oauth.clientId') ||
                configService.get<string>('KAKAO_CLIENT_ID'),
      clientSecret: configService.get<string>('kakao.oauth.clientSecret') ||
                    configService.get<string>('KAKAO_CLIENT_SECRET'),
      callbackURL: configService.get<string>('kakao.oauth.callbackUrl') ||
                   configService.get<string>('KAKAO_OAUTH_CALLBACK_URL') ||
                   'http://localhost:3000/api/auth/kakao/callback',
    });
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    profile: Profile,
    done: (error: any, user?: any, info?: any) => void,
  ): Promise<void> {
    try {
      this.logger.debug(`Kakao OAuth profile received: ${profile.id}`);

      const { id, username, displayName, _json } = profile;

      // 카카오 프로필에서 정보 추출
      const kakaoAccount = _json?.kakao_account || {};
      const kakaoProfile = kakaoAccount.profile || {};

      const email = kakaoAccount.email;
      const nickname = kakaoProfile.nickname || displayName || username || `kakao_${id}`;
      const profileImage = kakaoProfile.profile_image_url || kakaoProfile.thumbnail_image_url;

      // 이메일이 없는 경우 처리 (카카오는 이메일 선택 동의)
      if (!email) {
        this.logger.warn(`Kakao user without email: ${id}`);
        // 이메일 없이도 가입 허용 (카카오 ID로 구분)
      }

      const result = await this.authService.validateOAuthUser({
        email: email || `kakao_${id}@kakao.local`, // 이메일 없으면 임시 생성
        name: nickname,
        picture: profileImage,
        provider: AuthProvider.KAKAO,
        providerId: id.toString(),
      });

      done(null, result);
    } catch (error) {
      this.logger.error(`Kakao OAuth validation failed: ${error.message}`);
      done(error, false);
    }
  }
}
