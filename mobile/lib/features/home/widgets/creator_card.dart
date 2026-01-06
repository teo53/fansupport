import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/idol_model.dart';

class CreatorCard extends StatelessWidget {
  final IdolModel idol;
  final int rank;

  const CreatorCard({
    super.key,
    required this.idol,
    required this.rank,
  });

  String _formatCompact(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    final imageColor =
        AppColors.fromHex(idol.imageColor, defaultColor: PipoColors.primary);

    return GestureDetector(
      onTap: () => context.go('/idols/${idol.id}'),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: PipoSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PipoRadius.xl),
          boxShadow: PipoShadows.md,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PipoRadius.xl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with Hero animation
              Hero(
                tag: 'idol_profile_${idol.id}',
                child: CachedNetworkImage(
                  imageUrl: idol.profileImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: imageColor),
                  errorWidget: (context, url, error) => Container(
                    color: imageColor,
                    child: const Icon(Icons.person, color: Colors.white54, size: 40),
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              // Rank badge
              Positioned(
                top: PipoSpacing.md,
                left: PipoSpacing.md,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(PipoRadius.sm),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(PipoRadius.sm),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Info
              Positioned(
                bottom: PipoSpacing.lg,
                left: PipoSpacing.lg,
                right: PipoSpacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (idol.groupName != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: imageColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          idol.groupName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Text(
                      idol.stageName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.favorite,
                            color: PipoColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _formatCompact(idol.totalSupport),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
