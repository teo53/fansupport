import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/design_system.dart';

/// Skeleton loader widgets for loading states
///
/// Provides various skeleton loaders for different components
class SkeletonLoader {
  /// Card skeleton
  static Widget card({
    double? width,
    double? height = 200,
    double? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: PipoColors.border,
      highlightColor: PipoColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius ?? PipoRadius.xl),
        ),
      ),
    );
  }

  /// List item skeleton
  static Widget listItem({
    bool showAvatar = true,
    int lines = 2,
  }) {
    return Shimmer.fromColors(
      baseColor: PipoColors.border,
      highlightColor: PipoColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PipoSpacing.xl,
          vertical: PipoSpacing.md,
        ),
        child: Row(
          children: [
            if (showAvatar)
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            if (showAvatar) const SizedBox(width: PipoSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  if (lines > 1) const SizedBox(height: 8),
                  if (lines > 1)
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
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

  /// Circle avatar skeleton
  static Widget avatar({double size = 64}) {
    return Shimmer.fromColors(
      baseColor: PipoColors.border,
      highlightColor: PipoColors.surface,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Text line skeleton
  static Widget text({
    double? width,
    double height = 16,
    double? borderRadius = 4,
  }) {
    return Shimmer.fromColors(
      baseColor: PipoColors.border,
      highlightColor: PipoColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius ?? 4),
        ),
      ),
    );
  }

  /// Creator card skeleton for home screen
  static Widget creatorCard() {
    return Shimmer.fromColors(
      baseColor: PipoColors.border,
      highlightColor: PipoColors.surface,
      child: Container(
        width: 180,
        height: 260,
        margin: const EdgeInsets.only(right: PipoSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PipoRadius.xl),
        ),
      ),
    );
  }

  /// Funding card skeleton
  static Widget fundingCard() {
    return Shimmer.fromColors(
      baseColor: PipoColors.border,
      highlightColor: PipoColors.surface,
      child: Container(
        width: 280,
        height: 180,
        margin: const EdgeInsets.only(right: PipoSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PipoRadius.xl),
        ),
      ),
    );
  }

  /// Grid of skeleton cards
  static Widget grid({
    required int itemCount,
    required Widget Function(int) itemBuilder,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(PipoSpacing.xl),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: PipoSpacing.md,
        mainAxisSpacing: PipoSpacing.md,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }

  /// Full page skeleton for home screen
  static Widget homeScreenSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: PipoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(width: 100, height: 24),
                Row(
                  children: [
                    avatar(size: 44),
                    const SizedBox(width: PipoSpacing.sm),
                    avatar(size: 44),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: PipoSpacing.xxl),

          // Hero card skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
            child: card(height: 180),
          ),
          const SizedBox(height: PipoSpacing.xxl),

          // Stories skeleton
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: PipoSpacing.md),
                child: avatar(size: 64),
              ),
            ),
          ),
          const SizedBox(height: PipoSpacing.xxl),

          // Creator cards skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
            child: text(width: 150, height: 20),
          ),
          const SizedBox(height: PipoSpacing.md),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
              itemCount: 3,
              itemBuilder: (context, index) => creatorCard(),
            ),
          ),
        ],
      ),
    );
  }
}
