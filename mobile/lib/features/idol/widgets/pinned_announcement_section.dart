import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// 📌 고정 공지사항 모델
class PinnedAnnouncement {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isImportant;

  const PinnedAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isImportant = false,
  });
}

/// 📌 고정 공지사항 섹션
class PinnedAnnouncementSection extends StatelessWidget {
  final PinnedAnnouncement announcement;
  final VoidCallback? onTap;

  const PinnedAnnouncementSection({
    super.key,
    required this.announcement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: announcement.isImportant
                  ? [
                      const Color(0xFFFFEBEE),
                      const Color(0xFFFFF3E0),
                    ]
                  : [
                      const Color(0xFFE3F2FD),
                      const Color(0xFFE8F5E9),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: announcement.isImportant
                  ? const Color(0xFFFF6B6B)
                  : AppColors.primary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (announcement.isImportant
                        ? const Color(0xFFFF6B6B)
                        : AppColors.primary)
                    .withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: announcement.isImportant
                          ? const Color(0xFFFF6B6B)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          announcement.isImportant ? '⚠️' : '📌',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          announcement.isImportant ? '중요 공지' : '고정 공지',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(announcement.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 제목
              Text(
                announcement.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // 내용 (최대 2줄)
              Text(
                announcement.content,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 더보기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '자세히 보기',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: announcement.isImportant
                          ? const Color(0xFFFF6B6B)
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: announcement.isImportant
                        ? const Color(0xFFFF6B6B)
                        : AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}분 전';
      }
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('M월 d일').format(date);
    }
  }
}
