import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

enum EmptyStateType {
  noData,
  noSearch,
  noNotification,
  noMessage,
  noFollower,
  noPost,
  noEvent,
  noCampaign,
  noWallet,
  offline,
  error,
  maintenance,
}

class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customIcon;

  const EmptyState({
    super.key,
    this.type = EmptyStateType.noData,
    this.title,
    this.message,
    this.buttonText,
    this.onButtonPressed,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final config = _getConfig(type);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            customIcon ?? _buildIcon(config),
            SizedBox(height: Responsive.hp(3)),

            // Title
            Text(
              title ?? config.title,
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.hp(1)),

            // Message
            Text(
              message ?? config.message,
              style: TextStyle(
                fontSize: Responsive.sp(14),
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Button
            if (buttonText != null || config.buttonText != null) ...[
              SizedBox(height: Responsive.hp(3)),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.wp(8),
                    vertical: Responsive.hp(1.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText ?? config.buttonText ?? '',
                  style: TextStyle(
                    fontSize: Responsive.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(_EmptyStateConfig config) {
    if (config.isError) {
      return Container(
        width: Responsive.wp(28),
        height: Responsive.wp(28),
        decoration: BoxDecoration(
          color: config.color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          config.icon,
          size: Responsive.sp(60),
          color: config.color,
        ),
      );
    }

    return Container(
      width: Responsive.wp(32),
      height: Responsive.wp(32),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            config.icon,
            size: Responsive.sp(64),
            color: AppColors.textHint,
          ),
          if (config.overlayIcon != null)
            Positioned(
              bottom: Responsive.wp(5),
              right: Responsive.wp(5),
              child: Container(
                width: Responsive.wp(8),
                height: Responsive.wp(8),
                decoration: BoxDecoration(
                  color: config.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.overlayIcon,
                  size: Responsive.sp(14),
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  _EmptyStateConfig _getConfig(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.noData:
        return _EmptyStateConfig(
          icon: Icons.inbox_outlined,
          title: '데이터가 없습니다',
          message: '표시할 내용이 없습니다.',
          color: AppColors.textHint,
        );
      case EmptyStateType.noSearch:
        return _EmptyStateConfig(
          icon: Icons.search_off_rounded,
          title: '검색 결과가 없습니다',
          message: '다른 검색어로 다시 시도해보세요.',
          color: AppColors.textHint,
        );
      case EmptyStateType.noNotification:
        return _EmptyStateConfig(
          icon: Icons.notifications_off_outlined,
          title: '알림이 없습니다',
          message: '새로운 알림이 오면 여기에 표시됩니다.',
          color: AppColors.textHint,
        );
      case EmptyStateType.noMessage:
        return _EmptyStateConfig(
          icon: Icons.chat_bubble_outline_rounded,
          title: '메시지가 없습니다',
          message: '아직 받은 메시지가 없습니다.',
          color: AppColors.textHint,
        );
      case EmptyStateType.noFollower:
        return _EmptyStateConfig(
          icon: Icons.people_outline_rounded,
          title: '팔로워가 없습니다',
          message: '아직 팔로워가 없습니다.',
          color: AppColors.textHint,
        );
      case EmptyStateType.noPost:
        return _EmptyStateConfig(
          icon: Icons.article_outlined,
          overlayIcon: Icons.add,
          title: '게시물이 없습니다',
          message: '첫 번째 게시물을 작성해보세요!',
          buttonText: '게시물 작성',
          color: AppColors.primary,
        );
      case EmptyStateType.noEvent:
        return _EmptyStateConfig(
          icon: Icons.event_busy_outlined,
          title: '예정된 일정이 없습니다',
          message: '새로운 공연 일정을 확인해보세요.',
          color: AppColors.textHint,
        );
      case EmptyStateType.noCampaign:
        return _EmptyStateConfig(
          icon: Icons.rocket_outlined,
          title: '진행 중인 펀딩이 없습니다',
          message: '새로운 펀딩 캠페인을 기다려주세요.',
          color: AppColors.textHint,
        );
      case EmptyStateType.noWallet:
        return _EmptyStateConfig(
          icon: Icons.account_balance_wallet_outlined,
          overlayIcon: Icons.add,
          title: '거래 내역이 없습니다',
          message: '충전 후 아이돌을 후원해보세요!',
          buttonText: '충전하기',
          color: AppColors.primary,
        );
      case EmptyStateType.offline:
        return _EmptyStateConfig(
          icon: Icons.wifi_off_rounded,
          title: '인터넷에 연결되지 않았습니다',
          message: '네트워크 연결을 확인하고 다시 시도해주세요.',
          buttonText: '다시 시도',
          color: AppColors.warning,
          isError: true,
        );
      case EmptyStateType.error:
        return _EmptyStateConfig(
          icon: Icons.error_outline_rounded,
          title: '오류가 발생했습니다',
          message: '잠시 후 다시 시도해주세요.\n문제가 지속되면 고객센터에 문의해주세요.',
          buttonText: '다시 시도',
          color: AppColors.error,
          isError: true,
        );
      case EmptyStateType.maintenance:
        return _EmptyStateConfig(
          icon: Icons.construction_rounded,
          title: '점검 중입니다',
          message: '서비스 개선을 위해 점검 중입니다.\n잠시 후 다시 방문해주세요.',
          color: AppColors.warning,
          isError: true,
        );
    }
  }
}

class _EmptyStateConfig {
  final IconData icon;
  final IconData? overlayIcon;
  final String title;
  final String message;
  final String? buttonText;
  final Color color;
  final bool isError;

  _EmptyStateConfig({
    required this.icon,
    this.overlayIcon,
    required this.title,
    required this.message,
    this.buttonText,
    required this.color,
    this.isError = false,
  });
}

// Error Screen Widget
class ErrorScreen extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.title,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: EmptyState(
        type: EmptyStateType.error,
        title: title,
        message: message,
        buttonText: '다시 시도',
        onButtonPressed: onRetry,
      ),
    );
  }
}

// Offline Screen Widget
class OfflineScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineScreen({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: EmptyState(
        type: EmptyStateType.offline,
        onButtonPressed: onRetry,
      ),
    );
  }
}
