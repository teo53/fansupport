import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/idol_model.dart';

class StoryItem extends StatelessWidget {
  final IdolModel idol;
  final bool isLive;
  final VoidCallback onTap;

  const StoryItem({
    super.key,
    required this.idol,
    required this.isLive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: PipoSpacing.md),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isLive
                    ? const LinearGradient(
                        colors: [Color(0xFFFF5A5F), Color(0xFFFF8A8E)],
                      )
                    : LinearGradient(
                        colors: [
                          PipoColors.border,
                          PipoColors.border.withOpacity(0.5),
                        ],
                      ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: idol.profileImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.fromHex(idol.imageColor),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.fromHex(idol.imageColor),
                      child: const Icon(Icons.person, color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: PipoSpacing.xs),
            if (isLive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: PipoColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Text(
                idol.stageName,
                style: PipoTypography.caption.copyWith(
                  color: PipoColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
