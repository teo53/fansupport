/// 🔍 게시글 필터 바
/// 아이돌 계정 전용 - 정산/메시/--시 필터링
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/post_type.dart';

class PostFilterBar extends StatelessWidget {
  final PostType? selectedType;
  final bool showUnansweredOnly;
  final int unansweredCount;
  final Function(PostType?) onTypeSelected;
  final Function(bool) onUnansweredToggle;

  const PostFilterBar({
    super.key,
    this.selectedType,
    this.showUnansweredOnly = false,
    this.unansweredCount = 0,
    required this.onTypeSelected,
    required this.onUnansweredToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타입 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: '전체',
                  isSelected: selectedType == null,
                  onTap: () => onTypeSelected(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: PostType.cheki.displayName,
                  icon: PostType.cheki.icon,
                  color: PostType.cheki.color,
                  isSelected: selectedType == PostType.cheki,
                  badgeCount: showUnansweredOnly ? null : unansweredCount,
                  onTap: () => onTypeSelected(PostType.cheki),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: PostType.hiddenCheki.displayName,
                  icon: PostType.hiddenCheki.icon,
                  color: PostType.hiddenCheki.color,
                  isSelected: selectedType == PostType.hiddenCheki,
                  onTap: () => onTypeSelected(PostType.hiddenCheki),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: PostType.mealDate.displayName,
                  icon: PostType.mealDate.icon,
                  color: PostType.mealDate.color,
                  isSelected: selectedType == PostType.mealDate,
                  onTap: () => onTypeSelected(PostType.mealDate),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: PostType.birthdayTime.displayName,
                  icon: PostType.birthdayTime.icon,
                  color: PostType.birthdayTime.color,
                  isSelected: selectedType == PostType.birthdayTime,
                  onTap: () => onTypeSelected(PostType.birthdayTime),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: PostType.announcement.displayName,
                  icon: PostType.announcement.icon,
                  color: PostType.announcement.color,
                  isSelected: selectedType == PostType.announcement,
                  onTap: () => onTypeSelected(PostType.announcement),
                ),
              ],
            ),
          ),

          // 미답글 필터 (정산 관련 타입일 때만)
          if (selectedType == null ||
              selectedType == PostType.cheki ||
              selectedType == PostType.hiddenCheki) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => onUnansweredToggle(!showUnansweredOnly),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: showUnansweredOnly
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: showUnansweredOnly
                        ? AppColors.error
                        : AppColors.border,
                    width: showUnansweredOnly ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      showUnansweredOnly
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color:
                          showUnansweredOnly ? AppColors.error : AppColors.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '답글 안 단 정산만 보기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: showUnansweredOnly
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: showUnansweredOnly
                              ? AppColors.error
                              : AppColors.textSecondary,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                    if (unansweredCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$unansweredCount',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? chipColor : AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? chipColor : AppColors.textSecondary,
                fontFamily: 'Pretendard',
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Pretendard',
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
