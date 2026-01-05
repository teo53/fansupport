/// 📋 게시글 타입별 통계
/// 정산, 메시, --시 등 게시글 분류 통계
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/post_type.dart';

class PostTypeBreakdown extends StatelessWidget {
  final int chekiCount;
  final int hiddenChekiCount;
  final int mealDateCount;
  final int birthdayTimeCount;
  final int generalCount;
  final int unansweredChekiCount;

  const PostTypeBreakdown({
    super.key,
    required this.chekiCount,
    this.hiddenChekiCount = 0,
    required this.mealDateCount,
    required this.birthdayTimeCount,
    required this.generalCount,
    this.unansweredChekiCount = 0,
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
                  color: AppColors.infoSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '게시글 분류',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPostTypeItem(
            context,
            type: PostType.cheki,
            count: chekiCount,
            hasAlert: unansweredChekiCount > 0,
            alertCount: unansweredChekiCount,
          ),
          const SizedBox(height: 12.0),
          if (hiddenChekiCount > 0) ...[
            _buildPostTypeItem(
              context,
              type: PostType.hiddenCheki,
              count: hiddenChekiCount,
            ),
            const SizedBox(height: 12.0),
          ],
          _buildPostTypeItem(
            context,
            type: PostType.mealDate,
            count: mealDateCount,
          ),
          const SizedBox(height: 12.0),
          _buildPostTypeItem(
            context,
            type: PostType.birthdayTime,
            count: birthdayTimeCount,
          ),
          const SizedBox(height: 12.0),
          _buildPostTypeItem(
            context,
            type: PostType.general,
            count: generalCount,
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeItem(
    BuildContext context, {
    required PostType type,
    required int count,
    bool hasAlert = false,
    int alertCount = 0,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to filtered post list
        // context.push('/community/filter/${type.name}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: type.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: type.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                type.icon,
                color: type.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),
            if (hasAlert && alertCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '미답글 $alertCount',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: type.color,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: type.color.withValues(alpha: 0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
