import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/activity_stats.dart';

/// 📊 활동 통계 섹션 (치지직 스타일)
class ActivityStatsSection extends StatelessWidget {
  final ActivityStats stats;
  final VoidCallback? onViewDetails;

  const ActivityStatsSection({
    super.key,
    required this.stats,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '📊',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '활동 통계',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (onViewDetails != null)
                TextButton(
                  onPressed: onViewDetails,
                  child: Text(
                    '상세보기',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '이번 주 활동 기준',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // 활동 레벨 배지
          _buildActivityLevelBadge(),
          const SizedBox(height: 20),

          // 주요 지표 그리드
          _buildStatsGrid(),
          const SizedBox(height: 16),

          // 연속 활동일 (스트릭)
          if (stats.consecutiveActiveDays > 0) ...[
            _buildStreakBanner(),
            const SizedBox(height: 16),
          ],

          // 획득 배지
          if (stats.badges.isNotEmpty) ...[
            _buildBadgesSection(),
          ],
        ],
      ),
    );
  }

  /// 활동 레벨 배지
  Widget _buildActivityLevelBadge() {
    final level = stats.level;
    final levelColor = Color(int.parse(level.color.replaceFirst('#', '0xFF')));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            levelColor.withOpacity(0.1),
            levelColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [levelColor, levelColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: levelColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                level.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: levelColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '활동 점수 ${stats.activityScore}점',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  /// 주요 지표 그리드
  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: '📝',
                label: '이번 주 게시글',
                value: '${stats.postsThisWeek}',
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: '💬',
                label: '이번 주 댓글',
                value: '${stats.commentsThisWeek}',
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: '🎥',
                label: '이번 주 라이브',
                value: '${stats.liveHoursThisWeek}시간',
                color: const Color(0xFFE91E63),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: '🎉',
                label: '예정 이벤트',
                value: '${stats.upcomingEvents}',
                color: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 통계 카드
  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 연속 활동일 배너
  Widget _buildStreakBanner() {
    final isActive = stats.hasActiveStreak;
    final days = stats.consecutiveActiveDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  const Color(0xFFFF6B6B),
                  const Color(0xFFFF8E53),
                ]
              : [
                  const Color(0xFFBDBDBD),
                  const Color(0xFF9E9E9E),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isActive ? '🔥' : '😴',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? '$days일 연속 활동 중!' : '$days일 기록 유지',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive
                      ? '매일 활동하고 있어요 👏'
                      : '오늘 활동하고 스트릭을 이어가세요!',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 배지 섹션
  Widget _buildBadgesSection() {
    final displayBadges = _getDisplayBadges();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '획득한 배지',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayBadges.map((badge) => _buildBadgeChip(badge)).toList(),
        ),
      ],
    );
  }

  /// 배지 칩
  Widget _buildBadgeChip(Badge badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            badge.icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            badge.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 표시할 배지 가져오기
  List<Badge> _getDisplayBadges() {
    final allBadges = [
      Badges.week1Streak,
      Badges.week4Streak,
      Badges.posts50,
      Badges.posts100,
      Badges.earlyBird,
      Badges.eventKing,
      Badges.fanFavorite,
    ];

    return allBadges
        .where((badge) => stats.badges.contains(badge.id))
        .toList();
  }
}
