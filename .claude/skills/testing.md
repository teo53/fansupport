---
name: testing
description: |
  Testing skill for writing unit tests, integration tests, and E2E tests.
  Use when creating tests for NestJS backend, Flutter mobile, or Next.js web.
  Includes Jest, Flutter test, and testing best practices.
---

# Testing Skill

## Backend (NestJS + Jest)

### Unit Test Structure
```typescript
// users.service.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from '../prisma/prisma.service';

describe('UsersService', () => {
  let service: UsersService;
  let prisma: PrismaService;

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findById', () => {
    it('should return user when found', async () => {
      const mockUser = { id: '1', email: 'test@test.com' };
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);

      const result = await service.findById('1');

      expect(result).toEqual(mockUser);
      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { id: '1' },
      });
    });

    it('should throw NotFoundException when user not found', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(service.findById('1')).rejects.toThrow(NotFoundException);
    });
  });
});
```

### E2E Test
```typescript
// test/users.e2e-spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('UsersController (e2e)', () => {
  let app: INestApplication;
  let authToken: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    // Get auth token
    const loginRes = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: 'test@test.com', password: 'password' });
    authToken = loginRes.body.accessToken;
  });

  afterAll(async () => {
    await app.close();
  });

  it('/api/users/me (GET)', () => {
    return request(app.getHttpServer())
      .get('/api/users/me')
      .set('Authorization', `Bearer ${authToken}`)
      .expect(200)
      .expect((res) => {
        expect(res.body).toHaveProperty('id');
        expect(res.body).toHaveProperty('email');
      });
  });
});
```

### Commands
```bash
npm run test              # Run unit tests
npm run test:watch        # Watch mode
npm run test:cov          # Coverage report
npm run test:e2e          # E2E tests
```

## Mobile (Flutter)

### Unit Test
```dart
// test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ApiClient])
import 'auth_service_test.mocks.dart';

void main() {
  late AuthService authService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    authService = AuthService(mockApiClient);
  });

  group('AuthService', () {
    test('login returns user on success', () async {
      final mockUser = User(id: '1', email: 'test@test.com');
      when(mockApiClient.login(any)).thenAnswer((_) async => mockUser);

      final result = await authService.login('test@test.com', 'password');

      expect(result, equals(mockUser));
      verify(mockApiClient.login(any)).called(1);
    });

    test('login throws AuthException on failure', () async {
      when(mockApiClient.login(any)).thenThrow(DioException(...));

      expect(
        () => authService.login('test@test.com', 'wrong'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
```

### Widget Test
```dart
// test/widgets/idol_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/presentation/widgets/idol_card.dart';

void main() {
  testWidgets('IdolCard displays idol name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: IdolCard(
          idol: Idol(id: '1', name: 'Test Idol'),
        ),
      ),
    );

    expect(find.text('Test Idol'), findsOneWidget);
  });

  testWidgets('IdolCard navigates on tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: IdolCard(idol: testIdol),
        routes: {'/idol/1': (_) => IdolDetailScreen()},
      ),
    );

    await tester.tap(find.byType(IdolCard));
    await tester.pumpAndSettle();

    expect(find.byType(IdolDetailScreen), findsOneWidget);
  });
}
```

### Integration Test
```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:idol_support/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full app test', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Test login flow
    await tester.enterText(find.byKey(Key('email')), 'test@test.com');
    await tester.enterText(find.byKey(Key('password')), 'password');
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
```

### Commands
```bash
flutter test                        # Unit & widget tests
flutter test integration_test       # Integration tests
flutter test --coverage             # Coverage report
```

## Test Patterns

### AAA Pattern
```
Arrange - Set up test data and mocks
Act - Execute the code being tested
Assert - Verify the results
```

### Test Naming
```
should_[expected behavior]_when_[condition]
returns_[value]_given_[input]
throws_[exception]_when_[condition]
```
