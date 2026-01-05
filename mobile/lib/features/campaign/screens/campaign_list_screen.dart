import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';

class CampaignListScreen extends ConsumerStatefulWidget {
  const CampaignListScreen({super.key});

  @override
  ConsumerState<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends ConsumerState<CampaignListScreen> {
  String _selectedFilter = 'all';

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  int _calculateDaysLeft(String endDateStr) {
    final endDate = DateTime.parse(endDateStr);
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  List<Map<String, dynamic>> get _filteredCampaigns {
    final campaigns = MockData.campaigns;
    switch (_selectedFilter) {
      case 'ending':
        return campaigns.where((c) => _calculateDaysLeft(c['endDate']) <= 7).toList();
      case 'popular':
        return campaigns.where((c) => (c['supporters'] as int) >= 100).toList();
      case 'new':
        return campaigns.toList()..sort((a, b) {
          final aDate = DateTime.parse(a['startDate']);
          final bDate = DateTime.parse(b['startDate']);
          return bDate.compareTo(aDate);
        });
      default:
        return campaigns;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final campaigns = _filteredCampaigns;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '펀딩',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: campaigns.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(Responsive.wp(6)),
              itemCount: campaigns.length,
              itemBuilder: (context, index) => _buildCampaignCard(context, campaigns[index]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '진행 중인 펀딩이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '필터',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption('all', '전체', Icons.list),
            _buildFilterOption('ending', '마감 임박', Icons.timer),
            _buildFilterOption('popular', '인기 펀딩', Icons.favorite),
            _buildFilterOption('new', '최신순', Icons.new_releases),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = value);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, Map<String, dynamic> campaign) {
    final currentAmount = campaign['currentAmount'] as int;
    final goalAmount = campaign['goalAmount'] as int;
    final progress = currentAmount / goalAmount;
    final daysLeft = _calculateDaysLeft(campaign['endDate']);
    final supporters = campaign['supporters'] as int;

    // Get creator info
    Map<String, dynamic>? creator;
    try {
      creator = MockData.idols.firstWhere((i) => i['id'] == campaign['creatorId']);
    } catch (e) {
      creator = MockData.idols.isNotEmpty ? MockData.idols.first : null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/campaigns/${campaign['id']}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: campaign['coverImage'] != null
                      ? CachedNetworkImage(
                          imageUrl: campaign['coverImage'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.backgroundAlt,
                            child: Center(
                              child: Icon(
                                Icons.campaign,
                                size: 48,
                                color: AppColors.textSecondary.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.backgroundAlt,
                            child: Center(
                              child: Icon(
                                Icons.campaign,
                                size: 48,
                                color: AppColors.textSecondary.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.backgroundAlt,
                          child: Center(
                            child: Icon(
                              Icons.campaign,
                              size: 48,
                              color: AppColors.textSecondary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                ),
                if (daysLeft <= 7 && daysLeft > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'D-$daysLeft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                if (daysLeft <= 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '마감',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Creator Info
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundAlt,
                          shape: BoxShape.circle,
                        ),
                        child: creator?['profileImage'] != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: creator!['profileImage'],
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        creator?['stageName'] ?? '아이돌',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (creator?['isVerified'] ?? false) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    campaign['title'] ?? '캠페인',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    campaign['description'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '￦${_formatNumber(currentAmount)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '목표 ￦${_formatNumber(goalAmount)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '$supporters명',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: daysLeft <= 7 ? AppColors.error : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            daysLeft > 0 ? 'D-$daysLeft' : '마감',
                            style: TextStyle(
                              fontSize: 13,
                              color: daysLeft <= 7 ? AppColors.error : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
