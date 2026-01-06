import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Enhanced Empty State Widget
///
/// Provides rich, accessible empty state UI with optional actions
class EnhancedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIllustration;
  final Color? iconColor;

  const EnhancedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.customIllustration,
    this.iconColor,
  });

  // Factory methods for common empty states
  factory EnhancedEmptyState.noCreators({
    VoidCallback? onDiscover,
  }) {
    return EnhancedEmptyState(
      icon: Icons.favorite_border,
      iconColor: PipoColors.heart,
      title: '아직 서포트하는 크리에이터가 없어요',
      subtitle: '마음에 드는 크리에이터를 찾아보세요',
      actionLabel: '크리에이터 둘러보기',
      onAction: onDiscover,
    );
  }

  factory EnhancedEmptyState.noCampaigns({
    VoidCallback? onExplore,
  }) {
    return EnhancedEmptyState(
      icon: Icons.campaign_outlined,
      iconColor: PipoColors.primary,
      title: '진행중인 캠페인이 없습니다',
      subtitle: '다양한 크리에이터들의 꿈을 응원해보세요',
      actionLabel: '캠페인 둘러보기',
      onAction: onExplore,
    );
  }

  factory EnhancedEmptyState.noSubscriptions({
    VoidCallback? onSubscribe,
  }) {
    return EnhancedEmptyState(
      icon: Icons.subscriptions_outlined,
      iconColor: PipoColors.community,
      title: '구독 중인 크리에이터가 없어요',
      subtitle: '멤버십으로 독점 콘텐츠를 즐겨보세요',
      actionLabel: '크리에이터 찾기',
      onAction: onSubscribe,
    );
  }

  factory EnhancedEmptyState.noNotifications() {
    return const EnhancedEmptyState(
      icon: Icons.notifications_none,
      iconColor: PipoColors.textSecondary,
      title: '새로운 알림이 없습니다',
      subtitle: '크리에이터의 소식을 놓치지 마세요',
    );
  }

  factory EnhancedEmptyState.noMessages({
    VoidCallback? onStartChat,
  }) {
    return EnhancedEmptyState(
      icon: Icons.chat_bubble_outline,
      iconColor: PipoColors.warmth,
      title: '메시지가 없습니다',
      subtitle: '크리에이터에게 첫 메시지를 보내보세요',
      actionLabel: '메시지 보내기',
      onAction: onStartChat,
    );
  }

  factory EnhancedEmptyState.searchNoResults({
    String? query,
  }) {
    return EnhancedEmptyState(
      icon: Icons.search_off,
      iconColor: PipoColors.textSecondary,
      title: '검색 결과가 없습니다',
      subtitle: query != null ? '"$query"에 대한 결과를 찾을 수 없어요' : '다른 검색어로 시도해보세요',
    );
  }

  factory EnhancedEmptyState.networkError({
    VoidCallback? onRetry,
  }) {
    return EnhancedEmptyState(
      icon: Icons.wifi_off,
      iconColor: PipoColors.error,
      title: '인터넷 연결을 확인해주세요',
      subtitle: '네트워크 연결 상태를 확인하고 다시 시도해주세요',
      actionLabel: '다시 시도',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PipoSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon or Custom Illustration
            if (customIllustration != null)
              customIllustration!
            else
              Container(
                padding: const EdgeInsets.all(PipoSpacing.xxl),
                decoration: BoxDecoration(
                  color: (iconColor ?? PipoColors.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: iconColor ?? PipoColors.primary,
                  semanticLabel: title,
                ),
              ),
            const SizedBox(height: PipoSpacing.xxl),

            // Title
            Text(
              title,
              style: PipoTypography.titleLarge.copyWith(
                color: PipoColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: PipoSpacing.md),
              Text(
                subtitle!,
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: PipoSpacing.xxl),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor ?? PipoColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PipoSpacing.xxl,
                    vertical: PipoSpacing.lg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(PipoRadius.xl),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  actionLabel!,
                  style: PipoTypography.labelLarge.copyWith(
                    color: Colors.white,
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
}
