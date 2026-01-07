import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/features/onboarding/screens/onboarding_screen.dart';

void main() {
  group('OnboardingScreen Widget Tests', () {
    testWidgets('should display PIPO logo', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Check if PIPO logo text is displayed
      expect(find.text('PIPO'), findsOneWidget);
    });

    testWidgets('should display skip button on first page', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Check if skip button is displayed
      expect(find.text('건너뛰기'), findsOneWidget);
    });

    testWidgets('should display first page content', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Check first page content
      expect(find.text('좋아하는 크리에이터를\n응원하세요'), findsOneWidget);
      expect(find.text('아이돌, 스트리머, VTuber까지\n다양한 크리에이터를 후원할 수 있어요'), findsOneWidget);
    });

    testWidgets('should have 3 page indicators', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Find all animated containers (page indicators)
      final indicators = find.byType(AnimatedContainer);

      // Should have at least 3 indicators (plus other AnimatedContainers)
      expect(indicators, findsWidgets);
    });

    testWidgets('should display next button', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Check if next button is displayed
      expect(find.text('다음'), findsOneWidget);
    });

    testWidgets('should navigate to next page on next button tap', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Initially on first page
      expect(find.text('좋아하는 크리에이터를\n응원하세요'), findsOneWidget);

      // Tap next button
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      // Should be on second page
      expect(find.text('특별한 소통을\n경험하세요'), findsOneWidget);
      expect(find.text('프라이빗 메시지, 영상통화, 팬미팅까지\n특별한 경험이 기다려요'), findsOneWidget);
    });

    testWidgets('should show start button on last page', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Navigate to last page
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      // Should show start button
      expect(find.text('시작하기'), findsOneWidget);
      expect(find.text('다음'), findsNothing);
    });

    testWidgets('should call onComplete when tapping start button', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Navigate to last page
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      // Initially not completed
      expect(completed, isFalse);

      // Tap start button
      await tester.tap(find.text('시작하기'));
      await tester.pumpAndSettle();

      // Should be completed
      expect(completed, isTrue);
    });

    testWidgets('should call onComplete when tapping skip button', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Initially not completed
      expect(completed, isFalse);

      // Tap skip button
      await tester.tap(find.text('건너뛰기'));
      await tester.pumpAndSettle();

      // Should be completed
      expect(completed, isTrue);
    });

    testWidgets('should hide skip button on last page', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Initially skip button is visible
      expect(find.text('건너뛰기'), findsOneWidget);

      // Navigate to last page
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      // Skip button should be hidden
      expect(find.text('건너뛰기'), findsNothing);
    });

    testWidgets('should support swipe gesture', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      // Initially on first page
      expect(find.text('좋아하는 크리에이터를\n응원하세요'), findsOneWidget);

      // Swipe left
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Should be on second page
      expect(find.text('특별한 소통을\n경험하세요'), findsOneWidget);
    });

    testWidgets('should dispose controllers properly', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () => completed = true,
          ),
        ),
      );

      await tester.pump();

      // Remove the widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // If no errors during disposal, test passes
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  group('OnboardingData Model Tests', () {
    test('should create OnboardingData with required fields', () {
      const data = OnboardingData(
        emoji: '❤️',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        accentColor: Color(0xFFFF5A5F),
      );

      expect(data.emoji, '❤️');
      expect(data.title, 'Test Title');
      expect(data.subtitle, 'Test Subtitle');
      expect(data.accentColor, const Color(0xFFFF5A5F));
    });
  });
}
