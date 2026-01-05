/// 📊 월별 활동 요약
/// 이번 달 크리에이터 활동 통계
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/models/creator_metrics.dart';

class MonthlyActivitySummary extends StatelessWidget {
  final CreatorMetrics metrics;

  const MonthlyActivitySummary({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '이번 달 활동',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
              _buildResponseRateBadge(),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.mail_outline,
                  label: 'Bubble 메시지',
                  value: '${metrics.thisMonthBubbleMessages}회',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.camera_alt_outlined,
                  label: '정산',
                  value: '${metrics.thisMonthChekiCount}개',
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.article_outlined,
                  label: '전체 게시글',
                  value: '${metrics.thisMonthPosts}개',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.people_outline,
                  label: '신규 구독자',
                  value: '+${metrics.thisMonthNewSubscribers}',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          if (metrics.chekiResponseRate > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.speed_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '평균 답글 시간',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatResponseTime(metrics.averageResponseTime),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
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

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseRateBadge() {
    final grade = metrics.responseGrade;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: grade.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: grade.color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: grade.color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${(metrics.chekiResponseRate * 100).toStringAsFixed(0)}% ${grade.displayName}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: grade.color,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }

  String _formatResponseTime(double hours) {
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '$minutes분';
    } else if (hours < 24) {
      return '${hours.toStringAsFixed(1)}시간';
    } else {
      final days = (hours / 24).toStringAsFixed(1);
      return '$days일';
    }
  }
}
