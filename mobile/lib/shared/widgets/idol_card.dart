import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/idol_entity.dart';

/// 아이돌 카드 위젯 (그리드용)
class IdolCard extends StatelessWidget {
  final IdolSummary idol;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;

  const IdolCard({
    super.key,
    required this.idol,
    this.onTap,
    this.onFollow,
  });

  Color get _categoryColor {
    switch (idol.category) {
      case IdolCategory.undergroundIdol:
        return AppColors.primary;
      case IdolCategory.maidCafe:
        return AppColors.maidCategory;
      case IdolCategory.cosplayer:
        return AppColors.cosplayerCategory;
      case IdolCategory.vtuber:
        return AppColors.vtuberCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: _buildImage(),
            ),
            Expanded(
              flex: 2,
              child: _buildInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: idol.profileImage,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: _categoryColor.withValues(alpha: 0.2),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _categoryColor,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: _categoryColor.withValues(alpha: 0.2),
            child: Icon(
              Icons.person,
              size: Responsive.sp(40),
              color: _categoryColor,
            ),
          ),
        ),
        // 카테고리 뱃지
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _categoryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              idol.category.displayName,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.sp(10),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // 팔로우 버튼
        if (onFollow != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFollow,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: idol.isFollowing
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  idol.isFollowing ? Icons.favorite : Icons.favorite_border,
                  size: Responsive.sp(16),
                  color: idol.isFollowing ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: EdgeInsets.all(Responsive.wp(3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  idol.stageName,
                  style: TextStyle(
                    fontSize: Responsive.sp(14),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (idol.isVerified)
                Icon(
                  Icons.verified,
                  size: Responsive.sp(14),
                  color: AppColors.primary,
                ),
            ],
          ),
          SizedBox(height: Responsive.hp(0.5)),
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: Responsive.sp(12),
                color: AppColors.textSecondary,
              ),
              SizedBox(width: Responsive.wp(1)),
              Text(
                NumberFormatter.formatKorean(idol.followerCount),
                style: TextStyle(
                  fontSize: Responsive.sp(12),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 아이돌 리스트 아이템 위젯 (리스트용)
class IdolListTile extends StatelessWidget {
  final IdolSummary idol;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;
  final int? rank;

  const IdolListTile({
    super.key,
    required this.idol,
    this.onTap,
    this.onFollow,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _buildLeading(),
      title: Row(
        children: [
          Text(
            idol.stageName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.sp(15),
            ),
          ),
          if (idol.isVerified) ...[
            SizedBox(width: Responsive.wp(1)),
            Icon(
              Icons.verified,
              size: Responsive.sp(14),
              color: AppColors.primary,
            ),
          ],
        ],
      ),
      subtitle: Text(
        '${idol.category.displayName} · 팔로워 ${NumberFormatter.formatKorean(idol.followerCount)}',
        style: TextStyle(
          fontSize: Responsive.sp(12),
          color: AppColors.textSecondary,
        ),
      ),
      trailing: onFollow != null
          ? _buildFollowButton()
          : Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }

  Widget _buildLeading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rank != null) ...[
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.bold,
                color: rank! <= 3 ? _getRankColor(rank!) : AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: Responsive.wp(2)),
        ],
        CircleAvatar(
          radius: 24,
          backgroundImage: CachedNetworkImageProvider(idol.profileImage),
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    return TextButton(
      onPressed: onFollow,
      style: TextButton.styleFrom(
        backgroundColor: idol.isFollowing
            ? AppColors.backgroundAlt
            : AppColors.primary,
        foregroundColor: idol.isFollowing
            ? AppColors.textPrimary
            : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
      ),
      child: Text(
        idol.isFollowing ? '팔로잉' : '팔로우',
        style: TextStyle(fontSize: Responsive.sp(12)),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.gold;
      case 2:
        return AppColors.silver;
      case 3:
        return AppColors.bronze;
      default:
        return AppColors.textSecondary;
    }
  }
}
