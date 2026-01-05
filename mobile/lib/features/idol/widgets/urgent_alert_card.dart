/// 🚨 긴급 알림 카드
/// 미답글 정산에 대한 긴급 알림
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/creator_metrics.dart';

class UrgentAlertCard extends StatelessWidget {
  final CreatorMetrics metrics;
  final VoidCallback? onViewUnanswered;

  const UrgentAlertCard({
    super.key,
    required this.metrics,
    this.onViewUnanswered,
  });

  @override
  Widget build(BuildContext context) {
    final status = metrics.chekiStatus;

    // 긴급 상황이 아니면 표시하지 않음
    if (status == ChekiManagementStatus.good) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onViewUnanswered,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: Responsive.hp(1),
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: _getGradient(status),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.elevatedShadow(opacity: 0.15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(status),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(status),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    '미답글',
                    metrics.unansweredChekiCount,
                    Icons.chat_bubble_outline,
                  ),
                  if (metrics.urgentChekiCount > 0)
                    _buildStat(
                      '긴급',
                      metrics.urgentChekiCount,
                      Icons.warning_amber_rounded,
                    ),
                  if (metrics.overdueChekiCount > 0)
                    _buildStat(
                      '지연',
                      metrics.overdueChekiCount,
                      Icons.error_outline,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.8),
                fontFamily: 'Pretendard',
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getTitle(ChekiManagementStatus status) {
    switch (status) {
      case ChekiManagementStatus.needsAction:
        return '답글 필요';
      case ChekiManagementStatus.warning:
        return '⚠️ 긴급 확인 필요';
      case ChekiManagementStatus.critical:
        return '🚨 즉시 확인 필요';
      default:
        return '정산 관리';
    }
  }

  IconData _getIcon(ChekiManagementStatus status) {
    switch (status) {
      case ChekiManagementStatus.needsAction:
        return Icons.notifications_active_outlined;
      case ChekiManagementStatus.warning:
        return Icons.warning_amber_rounded;
      case ChekiManagementStatus.critical:
        return Icons.error_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  LinearGradient _getGradient(ChekiManagementStatus status) {
    switch (status) {
      case ChekiManagementStatus.needsAction:
        return const LinearGradient(
          colors: [Color(0xFF5B9FFF), Color(0xFF4A7FE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChekiManagementStatus.warning:
        return const LinearGradient(
          colors: [Color(0xFFFF9F0A), Color(0xFFFF8500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChekiManagementStatus.critical:
        return const LinearGradient(
          colors: [Color(0xFFFA3E3E), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppColors.primaryGradient;
    }
  }
}
