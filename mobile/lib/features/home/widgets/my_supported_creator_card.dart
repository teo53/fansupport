import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/models/idol_model.dart';

/// My Supported Creator Card
///
/// Shows creators that the user actively supports with relationship indicators
class MySupportedCreatorCard extends StatelessWidget {
  final IdolModel creator;
  final int supportLevel; // 1-5
  final int daysSupporting;
  final String lastInteraction;

  const MySupportedCreatorCard({
    super.key,
    required this.creator,
    required this.supportLevel,
    required this.daysSupporting,
    required this.lastInteraction,
  });

  Color _getSupportLevelColor() {
    switch (supportLevel) {
      case 5:
        return PipoColors.gold;
      case 4:
        return PipoColors.silver;
      case 3:
        return PipoColors.bronze;
      default:
        return PipoColors.primary;
    }
  }

  String _getSupportLevelName() {
    switch (supportLevel) {
      case 5:
        return 'VIP 서포터';
      case 4:
        return '골드 팬';
      case 3:
        return '실버 팬';
      case 2:
        return '브론즈 팬';
      default:
        return '팬';
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getSupportLevelColor();

    return GestureDetector(
      onTap: () => context.go('/idols/${creator.id}'),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: PipoSpacing.md),
        decoration: BoxDecoration(
          color: PipoColors.surface,
          borderRadius: BorderRadius.circular(PipoRadius.xl),
          border: Border.all(
            color: levelColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: levelColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Creator Image with Level Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(PipoRadius.xl),
                    topRight: Radius.circular(PipoRadius.xl),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: creator.profileImage,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: PipoColors.border,
                    ),
                  ),
                ),
                // Level Badge
                Positioned(
                  top: PipoSpacing.sm,
                  right: PipoSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PipoSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: BorderRadius.circular(PipoRadius.sm),
                      boxShadow: PipoShadows.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Lv.$supportLevel',
                          style: PipoTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Creator Info
            Padding(
              padding: const EdgeInsets.all(PipoSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          creator.stageName,
                          style: PipoTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: PipoColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (creator.isVerified)
                        const Icon(
                          Icons.verified,
                          color: PipoColors.primary,
                          size: 14,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSupportLevelName(),
                    style: PipoTypography.caption.copyWith(
                      color: levelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PipoSpacing.sm),
                  // Support Stats
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: PipoColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${daysSupporting}일째',
                        style: PipoTypography.caption.copyWith(
                          color: PipoColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 12,
                        color: PipoColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lastInteraction,
                          style: PipoTypography.caption.copyWith(
                            color: PipoColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
