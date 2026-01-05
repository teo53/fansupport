/// 📢 이벤트 공지 배지
/// 공연 공지사항 알림 배지
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EventNoticeBadge extends StatelessWidget {
  final int unreadCount;
  final bool isUrgent;

  const EventNoticeBadge({
    super.key,
    required this.unreadCount,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    if (unreadCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.error : AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? AppColors.error : AppColors.primary)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUrgent) ...[
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            '$unreadCount',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }
}
