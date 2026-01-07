import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:idol_support/main.dart';
import 'package:idol_support/features/splash/screens/splash_screen.dart';
import 'package:idol_support/features/onboarding/screens/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IdolSupportApp Main Tests', () {
    setUp(() {
      // Initialize SharedPreferences with empty values before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should show loading indicator while initializing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: IdolSupportApp(),
        ),
      );

      // Should show loading indicator immediately
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show splash screen after initialization on first launch', (WidgetTester tester) async {
      // Set first launch to true
      SharedPreferences.setMockInitialValues({'first_launch': true});

      await tester.pumpWidget(
        const ProviderScope(
          child: IdolSupportApp(),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show splash screen
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('should transition from splash to onboarding on first launch', (WidgetTester tester) async {
      // Set first launch to true
      SharedPreferences.setMockInitialValues({'first_launch': true});

      await tester.pumpWidget(
        const ProviderScope(
          child: IdolSupportApp(),
        ),
      );

      // Wait for initialization and splash screen
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for splash to complete (2 seconds splash delay)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show onboarding screen
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('should show splash then main app on returning launch', (WidgetTester tester) async {
      // Set first launch to false (returning user)
      SharedPreferences.setMockInitialValues({'first_launch': false});

      await tester.pumpWidget(
        const ProviderScope(
          child: IdolSupportApp(),
        ),
      );

      // Wait for initialization and splash screen
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for splash to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should NOT show onboarding, should show main app (MaterialApp.router)
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('should handle initialization error gracefully', (WidgetTester tester) async {
      // Don't set any SharedPreferences to simulate error

      await tester.pumpWidget(
        const ProviderScope(
          child: IdolSupportApp(),
        ),
      );

      // Wait for initialization attempt
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should still show splash screen (defaults to main app on error)
      // The app should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('should have correct app title', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'first_launch': false});

      await tester.pumpWidget(
        const ProviderScope(
          child: IdolSupportApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Wait for splash
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp).first,
      );

      expect(materialApp.title, 'PIPO');
    });

    testWidgets('should not show debug banner', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'first_launch': false});

      await tester.pumpWidget(
        const ProviderScope(
          child: IdolSupportApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Wait for splash
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp).first,
      );

      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('should support Korean locale', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'first_launch': false});

      await tester.pumpWidget(
        const ProviderScope(
          child: IdolSupportApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Wait for splash
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp).first,
      );

      expect(materialApp.supportedLocales, contains(const Locale('ko', 'KR')));
      expect(materialApp.locale, const Locale('ko', 'KR'));
    });
  });

  group('AppState Enum Tests', () {
    test('should have three states', () {
      expect(AppState.values.length, 3);
      expect(AppState.values, contains(AppState.splash));
      expect(AppState.values, contains(AppState.onboarding));
      expect(AppState.values, contains(AppState.main));
    });
  });
}
