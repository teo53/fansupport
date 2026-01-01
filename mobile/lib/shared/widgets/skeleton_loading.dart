import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

/// 기본 스켈레톤 박스
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// 원형 스켈레톤
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.border,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Shimmer 효과를 적용하는 래퍼
class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWrapper({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppColors.border,
      highlightColor: highlightColor ?? AppColors.backgroundAlt,
      child: child,
    );
  }
}

/// 포스트 카드 스켈레톤
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return ShimmerWrapper(
      child: Container(
        padding: EdgeInsets.all(Responsive.wp(4)),
        margin: EdgeInsets.only(bottom: Responsive.hp(1)),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                SkeletonCircle(size: Responsive.wp(12)),
                SizedBox(width: Responsive.wp(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: Responsive.wp(30),
                        height: Responsive.hp(2),
                      ),
                      SizedBox(height: Responsive.hp(0.5)),
                      SkeletonBox(
                        width: Responsive.wp(20),
                        height: Responsive.hp(1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.hp(2)),

            // Content
            SkeletonBox(
              width: double.infinity,
              height: Responsive.hp(2),
            ),
            SizedBox(height: Responsive.hp(1)),
            SkeletonBox(
              width: Responsive.wp(70),
              height: Responsive.hp(2),
            ),
            SizedBox(height: Responsive.hp(2)),

            // Image placeholder
            SkeletonBox(
              width: double.infinity,
              height: Responsive.hp(25),
              borderRadius: 12,
            ),
            SizedBox(height: Responsive.hp(2)),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (_) => SkeletonBox(
                width: Responsive.wp(15),
                height: Responsive.hp(2.5),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

/// 아이돌 카드 스켈레톤
class IdolCardSkeleton extends StatelessWidget {
  const IdolCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return ShimmerWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SkeletonBox(
              width: double.infinity,
              height: Responsive.hp(18),
              borderRadius: 16,
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.wp(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: Responsive.wp(20),
                    height: Responsive.hp(2),
                  ),
                  SizedBox(height: Responsive.hp(0.5)),
                  SkeletonBox(
                    width: Responsive.wp(30),
                    height: Responsive.hp(1.5),
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

/// 리스트 아이템 스켈레톤
class ListItemSkeleton extends StatelessWidget {
  final bool hasImage;
  final bool hasSubtitle;

  const ListItemSkeleton({
    super.key,
    this.hasImage = true,
    this.hasSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return ShimmerWrapper(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: Responsive.hp(1.5),
        ),
        child: Row(
          children: [
            if (hasImage) ...[
              SkeletonCircle(size: Responsive.wp(12)),
              SizedBox(width: Responsive.wp(3)),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: Responsive.wp(40),
                    height: Responsive.hp(2),
                  ),
                  if (hasSubtitle) ...[
                    SizedBox(height: Responsive.hp(0.8)),
                    SkeletonBox(
                      width: Responsive.wp(60),
                      height: Responsive.hp(1.5),
                    ),
                  ],
                ],
              ),
            ),
            SkeletonBox(
              width: Responsive.wp(15),
              height: Responsive.hp(2),
            ),
          ],
        ),
      ),
    );
  }
}

/// 캘린더 이벤트 스켈레톤
class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return ShimmerWrapper(
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.hp(1.5)),
        padding: EdgeInsets.all(Responsive.wp(4)),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(
                  width: Responsive.wp(15),
                  height: Responsive.hp(2.5),
                  borderRadius: 6,
                ),
                const Spacer(),
                SkeletonBox(
                  width: Responsive.wp(12),
                  height: Responsive.hp(2),
                ),
              ],
            ),
            SizedBox(height: Responsive.hp(1)),
            SkeletonBox(
              width: Responsive.wp(60),
              height: Responsive.hp(2.5),
            ),
            SizedBox(height: Responsive.hp(0.8)),
            SkeletonBox(
              width: Responsive.wp(45),
              height: Responsive.hp(1.8),
            ),
            SizedBox(height: Responsive.hp(1.5)),
            Row(
              children: [
                SkeletonCircle(size: Responsive.wp(6)),
                SizedBox(width: Responsive.wp(1)),
                SkeletonCircle(size: Responsive.wp(6)),
                const Spacer(),
                SkeletonBox(
                  width: Responsive.wp(20),
                  height: Responsive.hp(3),
                  borderRadius: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 프로필 헤더 스켈레톤
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return ShimmerWrapper(
      child: Column(
        children: [
          SizedBox(height: Responsive.hp(2)),
          SkeletonCircle(size: Responsive.wp(25)),
          SizedBox(height: Responsive.hp(2)),
          SkeletonBox(
            width: Responsive.wp(30),
            height: Responsive.hp(2.5),
          ),
          SizedBox(height: Responsive.hp(1)),
          SkeletonBox(
            width: Responsive.wp(50),
            height: Responsive.hp(1.8),
          ),
          SizedBox(height: Responsive.hp(3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                child: Column(
                  children: [
                    SkeletonBox(
                      width: Responsive.wp(12),
                      height: Responsive.hp(2.5),
                    ),
                    SizedBox(height: Responsive.hp(0.5)),
                    SkeletonBox(
                      width: Responsive.wp(10),
                      height: Responsive.hp(1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 스켈레톤 리스트 생성 헬퍼
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: padding,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: itemBuilder,
    );
  }

  /// 포스트 리스트 스켈레톤
  static Widget posts({int count = 3}) {
    return SkeletonList(
      itemCount: count,
      itemBuilder: (_, __) => const PostCardSkeleton(),
    );
  }

  /// 리스트 아이템 스켈레톤
  static Widget listItems({int count = 5, bool hasImage = true}) {
    return SkeletonList(
      itemCount: count,
      itemBuilder: (_, __) => ListItemSkeleton(hasImage: hasImage),
    );
  }

  /// 이벤트 리스트 스켈레톤
  static Widget events({int count = 3}) {
    return SkeletonList(
      itemCount: count,
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
      itemBuilder: (_, __) => const EventCardSkeleton(),
    );
  }
}

/// 스켈레톤 그리드 생성 헬퍼
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets? padding;
  final double? childAspectRatio;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    required this.itemBuilder,
    this.padding,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      padding: padding ?? EdgeInsets.all(Responsive.wp(4)),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: Responsive.hp(2),
        crossAxisSpacing: Responsive.wp(3),
        childAspectRatio: childAspectRatio ?? 0.75,
      ),
      itemBuilder: itemBuilder,
    );
  }

  /// 아이돌 그리드 스켈레톤
  static Widget idols({int count = 6}) {
    return SkeletonGrid(
      itemCount: count,
      itemBuilder: (_, __) => const IdolCardSkeleton(),
    );
  }
}
