import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/campaign_entity.dart';

/// 캠페인 카드 위젯
class CampaignCard extends StatelessWidget {
  final CampaignSummary campaign;
  final VoidCallback? onTap;
  final bool showProgress;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onTap,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(),
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          if (campaign.thumbnailImage != null)
            CachedNetworkImage(
              imageUrl: campaign.thumbnailImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.backgroundAlt,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.backgroundAlt,
                child: Icon(
                  Icons.campaign,
                  size: Responsive.sp(40),
                  color: AppColors.textHint,
                ),
              ),
            )
          else
            Container(
              color: AppColors.primarySoft,
              child: Center(
                child: Icon(
                  Icons.campaign,
                  size: Responsive.sp(40),
                  color: AppColors.primary,
                ),
              ),
            ),
          // 타입 뱃지
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor(campaign.type),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                campaign.type.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.sp(10),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // D-Day
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                campaign.daysLeft > 0 ? 'D-${campaign.daysLeft}' : 'D-DAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.sp(10),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: EdgeInsets.all(Responsive.wp(3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campaign.title,
            style: TextStyle(
              fontSize: Responsive.sp(14),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Responsive.hp(1)),
          if (showProgress) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberFormatter.formatCurrency(campaign.currentAmount),
                  style: TextStyle(
                    fontSize: Responsive.sp(14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${(campaign.progressPercent * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: Responsive.sp(12),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.hp(0.5)),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: campaign.progressPercent,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 4,
              ),
            ),
            SizedBox(height: Responsive.hp(0.5)),
            Text(
              '목표 ${NumberFormatter.formatCurrency(campaign.targetAmount)}',
              style: TextStyle(
                fontSize: Responsive.sp(11),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTypeColor(CampaignType type) {
    switch (type) {
      case CampaignType.birthday:
        return AppColors.primary;
      case CampaignType.debut:
        return AppColors.secondary;
      case CampaignType.album:
        return AppColors.info;
      case CampaignType.concert:
        return AppColors.success;
      case CampaignType.event:
        return AppColors.warning;
      case CampaignType.support:
        return AppColors.neonPurple;
      case CampaignType.other:
        return AppColors.textSecondary;
    }
  }
}

/// 캠페인 리스트 아이템 위젯
class CampaignListTile extends StatelessWidget {
  final CampaignSummary campaign;
  final VoidCallback? onTap;

  const CampaignListTile({
    super.key,
    required this.campaign,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(1),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: campaign.thumbnailImage != null
            ? CachedNetworkImage(
                imageUrl: campaign.thumbnailImage!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : Container(
                width: 60,
                height: 60,
                color: AppColors.primarySoft,
                child: Icon(
                  Icons.campaign,
                  color: AppColors.primary,
                ),
              ),
      ),
      title: Text(
        campaign.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: Responsive.sp(14),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Responsive.hp(0.5)),
          Row(
            children: [
              Text(
                '${(campaign.progressPercent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: Responsive.sp(12),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: Responsive.wp(2)),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: campaign.progressPercent,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.hp(0.5)),
          Text(
            '${campaign.daysLeft > 0 ? "D-${campaign.daysLeft}" : "마감"} · ${campaign.type.displayName}',
            style: TextStyle(
              fontSize: Responsive.sp(11),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
    );
  }
}
