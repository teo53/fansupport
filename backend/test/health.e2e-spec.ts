import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Health Check (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('/ (GET) should return 200', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200);
  });

  it('/api (GET) should be accessible', () => {
    return request(app.getHttpServer())
      .get('/api')
      .expect((res) => {
        expect(res.status).toBeLessThan(500);
      });
  });
});
