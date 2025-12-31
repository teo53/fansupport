import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// 데모 모드용 피드백 유틸리티
/// 시연 시 자연스러운 사용자 경험을 제공합니다
class DemoFeedback {
  /// 성공 액션 피드백 (데모에서 실제로 수행된 것처럼)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    IconData icon = Icons.check_circle_outline,
  }) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  /// 정보성 피드백 (기능 안내)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    IconData icon = Icons.info_outline,
  }) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  /// 데모 기능 알림 (곧 지원 예정)
  static void showComingSoon(
    BuildContext context,
    String featureName, {
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text('$featureName 기능이 곧 출시됩니다!')),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  /// 데모에서 액션이 완료된 것처럼 표시
  static void showActionComplete(
    BuildContext context, {
    required String action,
    String? detail,
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  action,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (detail != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  /// 소셜 로그인 데모 피드백
  static void showSocialLoginDemo(BuildContext context, String provider) {
    showInfo(
      context,
      '$provider 계정으로 로그인됩니다 (데모)',
      icon: Icons.login,
    );
  }

  /// 결제/후원 데모 피드백
  static void showPaymentDemo(BuildContext context, int amount) {
    final formattedAmount = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    showActionComplete(
      context,
      action: '${formattedAmount}원 결제 완료!',
      detail: '데모 모드에서는 실제 결제가 진행되지 않습니다',
    );
  }

  /// 공유 기능 데모 피드백
  static void showShareDemo(BuildContext context, String itemName) {
    showSuccess(
      context,
      '$itemName 공유 링크가 복사되었습니다',
      icon: Icons.share,
    );
  }

  /// 검색 기능 데모 피드백
  static void showSearchDemo(BuildContext context) {
    showInfo(
      context,
      '아이돌 이름이나 콘텐츠를 검색해보세요',
      icon: Icons.search,
    );
  }

  /// 알림 기능 데모 피드백
  static void showNotificationDemo(BuildContext context, String action) {
    showSuccess(
      context,
      '$action 알림이 설정되었습니다',
      icon: Icons.notifications_active,
    );
  }

  /// 팔로우/언팔로우 피드백
  static void showFollowDemo(BuildContext context, String name, bool isFollowing) {
    if (isFollowing) {
      showSuccess(
        context,
        '$name님을 팔로우합니다',
        icon: Icons.person_add,
      );
    } else {
      showInfo(
        context,
        '$name님 팔로우를 해제했습니다',
        icon: Icons.person_remove,
      );
    }
  }

  /// 좋아요 피드백
  static void showLikeDemo(BuildContext context, bool isLiked) {
    if (isLiked) {
      HapticFeedback.lightImpact();
      // 좋아요는 snackbar 없이 햅틱만
    } else {
      HapticFeedback.selectionClick();
    }
  }

  /// 북마크 피드백
  static void showBookmarkDemo(BuildContext context, bool isBookmarked) {
    if (isBookmarked) {
      showSuccess(context, '북마크에 저장되었습니다', icon: Icons.bookmark);
    } else {
      showInfo(context, '북마크에서 제거되었습니다', icon: Icons.bookmark_border);
    }
  }

  /// 신고/차단 데모 피드백
  static void showReportDemo(BuildContext context, String action) {
    showSuccess(
      context,
      '$action 처리되었습니다',
      icon: Icons.flag,
    );
  }

  /// 설정 변경 데모 피드백
  static void showSettingChanged(BuildContext context, String setting, bool enabled) {
    showSuccess(
      context,
      '$setting ${enabled ? '활성화' : '비활성화'}',
      icon: enabled ? Icons.toggle_on : Icons.toggle_off,
    );
  }

  /// 구독/후원 완료 데모 피드백
  static void showSubscriptionDemo(BuildContext context, String tierName) {
    showActionComplete(
      context,
      action: '$tierName 구독 완료!',
      detail: '이제 전용 콘텐츠를 이용할 수 있습니다',
    );
  }

  /// 펀딩 참여 완료 데모 피드백
  static void showFundingDemo(BuildContext context, String campaignName) {
    showActionComplete(
      context,
      action: '펀딩 참여 완료!',
      detail: campaignName,
    );
  }
}

/// 데모 모드용 성공적인 액션 메시지들
class DemoMessages {
  // 소셜 기능
  static const String postCreated = '게시물이 작성되었습니다';
  static const String commentAdded = '댓글이 등록되었습니다';
  static const String reposted = '리트윗되었습니다';
  static const String shared = '공유 링크가 복사되었습니다';
  static const String bookmarkAdded = '북마크에 저장되었습니다';
  static const String bookmarkRemoved = '북마크에서 제거되었습니다';

  // 팔로우
  static const String followed = '팔로우합니다';
  static const String unfollowed = '팔로우를 해제했습니다';

  // 구독/결제
  static const String subscribed = '구독이 완료되었습니다';
  static const String paymentComplete = '결제가 완료되었습니다';
  static const String fundingJoined = '펀딩에 참여했습니다';

  // 설정
  static const String settingSaved = '설정이 저장되었습니다';
  static const String notificationSet = '알림이 설정되었습니다';

  // 리포트
  static const String reportSubmitted = '신고가 접수되었습니다';
  static const String userBlocked = '사용자를 차단했습니다';

  // 프로필
  static const String profileUpdated = '프로필이 수정되었습니다';
  static const String passwordChanged = '비밀번호가 변경되었습니다';
}
