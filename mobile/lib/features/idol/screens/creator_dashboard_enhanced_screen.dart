/// 📊 크리에이터 대시보드 (Enhanced)
/// 정산 관리 중심의 아이돌 전용 대시보드
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/creator_metrics.dart';
import '../widgets/urgent_alert_card.dart';
import '../widgets/monthly_activity_summary.dart';
import '../widgets/post_type_breakdown.dart';

class CreatorDashboardEnhancedScreen extends ConsumerStatefulWidget {
  const CreatorDashboardEnhancedScreen({super.key});

  @override
  ConsumerState<CreatorDashboardEnhancedScreen> createState() =>
      _CreatorDashboardEnhancedScreenState();
}

class _CreatorDashboardEnhancedScreenState
    extends ConsumerState<CreatorDashboardEnhancedScreen> {
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    // TODO: Replace with actual provider
    final metrics = _getMockMetrics();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '크리에이터 대시보드',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Pretendard',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh metrics
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          padding: EdgeInsets.only(
            top: Responsive.hp(2),
            bottom: Responsive.hp(4),
          ),
          children: [
            // 1. 긴급 알림 카드
            UrgentAlertCard(
              metrics: metrics,
              onViewUnanswered: () {
                // TODO: Navigate to unanswered cheki list
                _showUnansweredChekiBottomSheet(context);
              },
            ),

            // 2. 월별 활동 요약
            MonthlyActivitySummary(metrics: metrics),

            // 3. 게시글 타입별 통계
            PostTypeBreakdown(
              chekiCount: metrics.totalChekiCount,
              hiddenChekiCount: metrics.hiddenChekiCount,
              mealDateCount: metrics.mealDatePosts,
              birthdayTimeCount: metrics.birthdayTimePosts,
              generalCount: metrics.generalPosts,
              unansweredChekiCount: metrics.unansweredChekiCount,
            ),

            // 4. 빠른 액션
            _buildQuickActions(context),

            // 5. 구독자 현황
            _buildSubscriberStatus(metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(1),
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '빠른 액션',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.mail_outline,
                  label: 'Bubble 보내기',
                  color: AppColors.primary,
                  onTap: () {
                    // TODO: Navigate to bubble compose
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: '정산 올리기',
                  color: AppColors.info,
                  onTap: () {
                    // TODO: Navigate to cheki compose
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.event_outlined,
                  label: '공연 공지',
                  color: AppColors.warning,
                  onTap: () {
                    // TODO: Navigate to event announcement
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.analytics_outlined,
                  label: '통계 보기',
                  color: AppColors.success,
                  onTap: () {
                    // TODO: Navigate to analytics
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriberStatus(CreatorMetrics metrics) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(1),
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.elevatedShadow(opacity: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                '구독자 현황',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSubscriberStat(
                  '전체',
                  '${metrics.totalSubscribers}명',
                  Icons.people_outline,
                ),
              ),
              Expanded(
                child: _buildSubscriberStat(
                  '일반',
                  '${metrics.standardSubscribers}명',
                  Icons.favorite_outline,
                ),
              ),
              Expanded(
                child: _buildSubscriberStat(
                  '프리미엄',
                  '${metrics.premiumSubscribers}명',
                  Icons.star,
                ),
              ),
            ],
          ),
          if (metrics.thisMonthNewSubscribers > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '이번 달 +${metrics.thisMonthNewSubscribers}명 증가',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriberStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
            fontFamily: 'Pretendard',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  void _showUnansweredChekiBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '답글 필요한 정산',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  '미답글 정산 목록이 여기에 표시됩니다',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mock data - TODO: Replace with actual provider
  CreatorMetrics _getMockMetrics() {
    return const CreatorMetrics(
      unansweredChekiCount: 12,
      urgentChekiCount: 3,
      overdueChekiCount: 1,
      totalChekiCount: 145,
      thisMonthChekiCount: 24,
      hiddenChekiCount: 8,
      totalPosts: 342,
      thisMonthPosts: 45,
      generalPosts: 102,
      mealDatePosts: 67,
      birthdayTimePosts: 20,
      thisWeekBubbleMessages: 14,
      thisMonthBubbleMessages: 38,
      totalBubbleMessages: 412,
      totalSubscribers: 1247,
      standardSubscribers: 823,
      premiumSubscribers: 424,
      thisMonthNewSubscribers: 87,
      chekiResponseRate: 0.92,
      averageResponseTime: 4.5,
      totalLikes: 15420,
      totalComments: 3847,
      totalViews: 98234,
    );
  }
}
