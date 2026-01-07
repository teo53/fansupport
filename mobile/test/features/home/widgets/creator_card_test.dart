import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idol_support/features/home/widgets/creator_card.dart';
import 'package:idol_support/shared/models/idol_model.dart';

void main() {
  group('CreatorCard Widget', () {
    late IdolModel testIdol;

    setUp(() {
      testIdol = IdolModel(
        id: 'test-id',
        stageName: 'Test Idol',
        profileImage: 'https://example.com/image.jpg',
        category: IdolCategory.undergroundIdol,
        bio: 'Test bio',
        createdAt: DateTime(2024, 1, 1),
        totalSupport: 50000,
        supporterCount: 100,
        ranking: 1,
        isVerified: true,
        imageColor: '#FF5A5F',
      );
    });

    testWidgets('should render creator card with idol info',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreatorCard(
              idol: testIdol,
              rank: 1,
            ),
          ),
        ),
      );

      // Verify idol name is displayed
      expect(find.text('Test Idol'), findsOneWidget);

      // Verify rank badge is displayed
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('should display formatted support amount',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreatorCard(
              idol: testIdol,
              rank: 1,
            ),
          ),
        ),
      );

      // 50000 should be formatted as "50K"
      expect(find.text('50K'), findsOneWidget);
    });

    testWidgets('should display group name if available',
        (WidgetTester tester) async {
      final idolWithGroup = IdolModel(
        id: 'test-id',
        stageName: 'Test Idol',
        profileImage: 'https://example.com/image.jpg',
        category: IdolCategory.undergroundIdol,
        bio: 'Test bio',
        createdAt: DateTime(2024, 1, 1),
        totalSupport: 50000,
        supporterCount: 100,
        ranking: 1,
        isVerified: true,
        groupName: 'Test Group',
        imageColor: '#FF5A5F',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreatorCard(
              idol: idolWithGroup,
              rank: 1,
            ),
          ),
        ),
      );

      expect(find.text('Test Group'), findsOneWidget);
    });
  });
}
