import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/features/splash/screens/splash_screen.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('should display PIPO logo text', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Check if PIPO text is displayed
      expect(find.text('PIPO'), findsOneWidget);
    });

    testWidgets('should display tagline text', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Wait for animations to start
      await tester.pump(const Duration(milliseconds: 800));

      // Check if tagline texts are displayed
      expect(find.text('좋아하는 크리에이터를'), findsOneWidget);
      expect(find.text('응원하세요'), findsOneWidget);
    });

    testWidgets('should show loading indicator', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Wait for animations to start
      await tester.pump(const Duration(milliseconds: 800));

      // Check if CircularProgressIndicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should call onComplete after delay', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Initially not completed
      expect(completed, isFalse);

      // Wait for animation sequence to complete (200ms + 600ms + 1800ms = 2600ms)
      await tester.pump(const Duration(milliseconds: 2700));

      // Should be completed now
      expect(completed, isTrue);
    });

    testWidgets('should have gradient background', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Find Container with gradient
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Container),
        ).first,
      );

      // Check if decoration has gradient
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('should create all animation controllers', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Pump to allow animations to initialize
      await tester.pump();

      // If no errors, all controllers were created successfully
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('should dispose animation controllers properly', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      await tester.pump();

      // Remove the widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // If no errors during disposal, test passes
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}
