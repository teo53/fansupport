import { registerAs } from '@nestjs/config';

export default registerAs('kakao', () => ({
  // Kakao 본인인증 (Kakao Certification)
  certification: {
    // 카카오 개발자 콘솔에서 발급받은 앱 키
    restApiKey: process.env.KAKAO_REST_API_KEY,
    adminKey: process.env.KAKAO_ADMIN_KEY,
    // 본인인증 완료 후 리다이렉트 URL
    redirectUri: process.env.KAKAO_CERT_REDIRECT_URI || 'http://localhost:3000/api/verification/kakao/callback',
    // 모바일 앱용 딥링크
    mobileRedirectUri: process.env.KAKAO_CERT_MOBILE_REDIRECT_URI || 'pipo://verification/callback',
  },

  // Kakao OAuth (소셜 로그인용)
  oauth: {
    clientId: process.env.KAKAO_CLIENT_ID,
    clientSecret: process.env.KAKAO_CLIENT_SECRET,
    callbackUrl: process.env.KAKAO_OAUTH_CALLBACK_URL || 'http://localhost:3000/api/auth/kakao/callback',
  },
}));
