import { registerAs } from '@nestjs/config';

export default registerAs('swagger', () => ({
  // Swagger 인증 설정 (프로덕션용)
  enabled: process.env.SWAGGER_ENABLED !== 'false',
  username: process.env.SWAGGER_USERNAME || 'admin',
  password: process.env.SWAGGER_PASSWORD || 'changeme',
}));
