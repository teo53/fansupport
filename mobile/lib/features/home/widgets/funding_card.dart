import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';

class FundingCard extends StatelessWidget {
  final Map<String, dynamic> campaign;

  const FundingCard({
    super.key,
    required this.campaign,
  });

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (campaign['currentAmount'] as int) / (campaign['goalAmount'] as int);
    final daysLeft =
        DateTime.parse(campaign['endDate']).difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () => context.go('/campaigns/${campaign['id']}'),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: PipoSpacing.md),
        padding: const EdgeInsets.all(PipoSpacing.lg),
        decoration: BoxDecoration(
          color: PipoColors.surface,
          borderRadius: BorderRadius.circular(PipoRadius.xl),
          boxShadow: PipoShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: daysLeft <= 7
                        ? PipoColors.errorLight
                        : PipoColors.primarySoft,
                    borderRadius: BorderRadius.circular(PipoRadius.xs),
                  ),
                  child: Text(
                    daysLeft > 0 ? 'D-$daysLeft' : '마감',
                    style: TextStyle(
                      color: daysLeft <= 7
                          ? PipoColors.error
                          : PipoColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: PipoTypography.titleMedium.copyWith(
                    color: PipoColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PipoSpacing.md),
            // Title
            Text(
              campaign['title'] ?? '',
              style: PipoTypography.titleMedium.copyWith(
                color: PipoColors.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: PipoColors.border,
                valueColor:
                    const AlwaysStoppedAnimation(PipoColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: PipoSpacing.sm),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatCurrency(campaign['currentAmount'])}원',
                  style: PipoTypography.labelMedium.copyWith(
                    color: PipoColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${campaign['supporters']}명 참여',
                  style: PipoTypography.caption.copyWith(
                    color: PipoColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
