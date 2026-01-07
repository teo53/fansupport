import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/utils/responsive.dart';

/// Shimmer loading card for lists
class ShimmerCard extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.inputBackground,
      highlightColor: AppColors.border.withOpacity(0.3),
      child: Container(
        height: height ?? 200,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(PipoRadius.lg),
        ),
      ),
    );
  }
}

/// Shimmer loading for creator cards
class ShimmerCreatorCard extends StatelessWidget {
  const ShimmerCreatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: PipoSpacing.md),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(PipoRadius.lg),
        ),
        child: Shimmer.fromColors(
          baseColor: AppColors.inputBackground,
          highlightColor: AppColors.border.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(PipoRadius.lg),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(PipoSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(PipoRadius.sm),
                      ),
                    ),
                    const SizedBox(height: PipoSpacing.xs),
                    Container(
                      width: 120,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(PipoRadius.sm),
                      ),
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

/// Shimmer loading for list items
class ShimmerListTile extends StatelessWidget {
  final bool hasImage;

  const ShimmerListTile({super.key, this.hasImage = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PipoSpacing.xl,
        vertical: PipoSpacing.sm,
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.inputBackground,
        highlightColor: AppColors.border.withOpacity(0.3),
        child: Row(
          children: [
            if (hasImage)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(PipoRadius.md),
                ),
              ),
            if (hasImage) const SizedBox(width: PipoSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(PipoRadius.sm),
                    ),
                  ),
                  const SizedBox(height: PipoSpacing.sm),
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(PipoRadius.sm),
                    ),
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

/// Generic loading indicator
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              color: PipoColors.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: PipoSpacing.lg),
            Text(
              message!,
              style: TextStyle(
                color: PipoColors.textSecondary,
                fontSize: Responsive.sp(14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: LoadingIndicator(message: message),
    );
  }
}

/// Skeleton loader for grid items
class ShimmerGridItem extends StatelessWidget {
  const ShimmerGridItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.inputBackground,
      highlightColor: AppColors.border.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(PipoRadius.lg),
        ),
      ),
    );
  }
}
