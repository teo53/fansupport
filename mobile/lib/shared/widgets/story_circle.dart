import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/idol_model.dart';
import '../../core/utils/responsive.dart';
import 'idol_avatar.dart';

class StoryCircle extends StatelessWidget {
  final IdolModel idol;
  final bool isLive;
  final VoidCallback onTap;

  const StoryCircle({
    super.key,
    required this.idol,
    this.isLive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Parse color for gradient ring
    final ringColor =
        AppColors.fromHex(idol.imageColor, defaultColor: AppColors.primary);

    // Live gradient colors
    final gradientColors = isLive
        ? [
            const Color(0xFFFF0055),
            const Color(0xFFFF00CC)
          ] // Neon Pink/Red for Live
        : [ringColor, AppColors.secondary];

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: isLive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF0055).withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IdolAvatar(
                    imageUrl: idol.profileImage,
                    category: idol.category,
                    size: Responsive.wp(16).clamp(48.0, 72.0),
                  ),
                ),
              ),
              if (isLive)
                Positioned(
                  bottom: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF9500), // Orange
                          const Color(0xFFFFCC00), // Yellow-Orange
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9500).withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'SOON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            idol.stageName,
            style: TextStyle(
              fontSize: Responsive.sp(12),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
