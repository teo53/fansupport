/// 🧭 Navigation Extensions
/// 화면 이동 헬퍼 함수들
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/post_model.dart';

/// Navigation Helper Extensions
extension NavigationExtensions on BuildContext {
  // Community
  void goToPostCreate() => go('/community/post/create');

  void goToPostDetail(Post post) => go('/community/post/${post.id}', extra: post);

  void goToUnansweredCheki() => go('/community/cheki/unanswered');

  // Bubble
  void goToBubbleCompose() => go('/bubble/compose');

  // Search
  void goToSearch() => go('/search');

  // Notifications
  void goToNotifications() => go('/notifications');

  // Payment
  void goToSubscriptionPayment({
    required String idolId,
    required String idolName,
    String? idolProfileImage,
  }) {
    go(
      '/subscription/payment/$idolId',
      extra: {
        'idolName': idolName,
        'idolProfileImage': idolProfileImage,
      },
    );
  }

  // Utility
  void goBack() => pop();
}

/// Router Helper Functions
class AppNavigation {
  /// Navigate to Post Create Screen
  static void toPostCreate(BuildContext context) {
    context.go('/community/post/create');
  }

  /// Navigate to Post Detail Screen
  static void toPostDetail(BuildContext context, Post post) {
    context.go('/community/post/${post.id}', extra: post);
  }

  /// Navigate to Unanswered Cheki List
  static void toUnansweredCheki(BuildContext context) {
    context.go('/community/cheki/unanswered');
  }

  /// Navigate to Bubble Compose
  static void toBubbleCompose(BuildContext context) {
    context.go('/bubble/compose');
  }

  /// Navigate to Search
  static void toSearch(BuildContext context) {
    context.go('/search');
  }

  /// Navigate to Notifications
  static void toNotifications(BuildContext context) {
    context.go('/notifications');
  }

  /// Navigate to Subscription Payment
  static void toSubscriptionPayment(
    BuildContext context, {
    required String idolId,
    required String idolName,
    String? idolProfileImage,
  }) {
    context.go(
      '/subscription/payment/$idolId',
      extra: {
        'idolName': idolName,
        'idolProfileImage': idolProfileImage,
      },
    );
  }
}
