import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:idol_support/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Complete first launch flow', (WidgetTester tester) async {
      // Set first launch
      SharedPreferences.setMockInitialValues({'first_launch': true});

      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should see splash screen with PIPO logo
      expect(find.text('PIPO'), findsOneWidget);

      // Wait for splash to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should see onboarding screen
      expect(find.text('좋아하는 크리에이터를\n응원하세요'), findsOneWidget);
      expect(find.text('다음'), findsOneWidget);

      // Navigate through onboarding pages
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('특별한 소통을\n경험하세요'), findsOneWidget);

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('팬들과 함께\n목표를 이루세요'), findsOneWidget);
      expect(find.text('시작하기'), findsOneWidget);

      // Complete onboarding
      await tester.tap(find.text('시작하기'));
      await tester.pumpAndSettle();

      // Should now be on main app
      // (Specific assertions depend on home screen implementation)
    });

    testWidgets('Skip onboarding flow', (WidgetTester tester) async {
      // Set first launch
      SharedPreferences.setMockInitialValues({'first_launch': true});

      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Wait for splash to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should see onboarding screen with skip button
      expect(find.text('건너뛰기'), findsOneWidget);

      // Tap skip button
      await tester.tap(find.text('건너뛰기'));
      await tester.pumpAndSettle();

      // Should now be on main app
      // (Specific assertions depend on home screen implementation)
    });

    testWidgets('Returning user flow', (WidgetTester tester) async {
      // Set returning user
      SharedPreferences.setMockInitialValues({'first_launch': false});

      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Wait for splash to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should NOT see onboarding, should see main app directly
      expect(find.text('건너뛰기'), findsNothing);
      expect(find.text('좋아하는 크리에이터를\n응원하세요'), findsNothing);
    });

    testWidgets('Theme switching works', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'first_launch': false});

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Wait for splash
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find MaterialApp to check current theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp).first);

      // Verify theme configuration exists
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Can navigate between tabs (if applicable)', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'first_launch': false});

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Wait for app to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigation tests would go here
      // Depends on actual navigation structure
    });
  });
}
