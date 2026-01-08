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
      appBar: AppBar(
        title: Text('펀딩', style: TextStyle(fontSize: Responsive.sp(18))),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, size: Responsive.sp(24)),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: campaigns.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: Responsive.sp(60),
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: Responsive.hp(2)),
                  Text(
                    '진행 중인 펀딩이 없습니다',
                    style: TextStyle(
                      fontSize: Responsive.sp(16),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(Responsive.wp(4)),
              itemCount: campaigns.length,
              itemBuilder: (context, index) => _buildCampaignCard(context, campaigns[index]),
            ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(Responsive.wp(4)),
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
                width: Responsive.wp(10),
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: Responsive.hp(3)),
            Text(
              '필터',
              style: TextStyle(
                fontSize: Responsive.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.hp(2)),
            _buildFilterOption('all', '전체', Icons.list),
            _buildFilterOption('ending', '마감 임박', Icons.timer),
            _buildFilterOption('popular', '인기 펀딩', Icons.favorite),
            _buildFilterOption('new', '최신순', Icons.new_releases),
            SizedBox(height: Responsive.hp(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        size: Responsive.sp(24),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: Responsive.sp(15),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.primary, size: Responsive.sp(24))
          : null,
      onTap: () {
        setState(() => _selectedFilter = value);
        Navigator.pop(context);
      },
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
      final creatorId = campaign['creatorId'];
      if (creatorId != null) {
        creator = MockData.idols.firstWhere(
          (i) => i['id'] == creatorId,
          orElse: () => <String, dynamic>{},
        );
        if (creator?.isEmpty ?? true) creator = null;
      }
    } catch (e) {
      creator = null;
    }

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(2)),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.go('/campaigns/${campaign['id']}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Container(
              height: Responsive.hp(18),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (campaign['coverImage'] != null)
                    CachedNetworkImage(
                      imageUrl: campaign['coverImage'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: Icon(
                          Icons.campaign,
                          size: Responsive.sp(50),
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.campaign,
                          size: Responsive.sp(50),
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.campaign,
                        size: Responsive.sp(50),
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  if (daysLeft <= 7 && daysLeft > 0)
                    Positioned(
                      top: Responsive.hp(1.5),
                      right: Responsive.wp(3),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.wp(3),
                          vertical: Responsive.hp(0.8),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'D-$daysLeft',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.sp(12),
                          ),
                        ),
                      ),
                    ),
                  if (daysLeft <= 0)
                    Positioned(
                      top: Responsive.hp(1.5),
                      right: Responsive.wp(3),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.wp(3),
                          vertical: Responsive.hp(0.8),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '마감',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.sp(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.wp(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Creator Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: Responsive.wp(3.5),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: creator?['profileImage'] != null
                            ? CachedNetworkImageProvider(creator!['profileImage'])
                            : null,
                        child: creator?['profileImage'] == null
                            ? Icon(
                                Icons.person,
                                size: Responsive.sp(14),
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      SizedBox(width: Responsive.wp(2)),
                      Text(
                        creator?['stageName'] ?? '아이돌',
                        style: TextStyle(
                          fontSize: Responsive.sp(13),
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: Responsive.wp(1)),
                      if (creator?['isVerified'] ?? false)
                        Icon(
                          Icons.verified,
                          size: Responsive.sp(14),
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                  SizedBox(height: Responsive.hp(1.5)),

                  // Title
                  Text(
                    campaign['title'] ?? '캠페인',
                    style: TextStyle(
                      fontSize: Responsive.sp(17),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.hp(1)),

                  // Description
                  Text(
                    campaign['description'] ?? '',
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.hp(2)),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: Responsive.hp(1),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(1.5)),

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
                              fontSize: Responsive.sp(16),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '목표 ￦${_formatNumber(goalAmount)}',
                            style: TextStyle(
                              fontSize: Responsive.sp(12),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildStatChip(
                            context,
                            icon: Icons.people,
                            value: '$supporters명',
                          ),
                          SizedBox(width: Responsive.wp(3)),
                          _buildStatChip(
                            context,
                            icon: Icons.timer,
                            value: daysLeft > 0 ? 'D-$daysLeft' : '마감',
                            color: daysLeft <= 7 ? AppColors.error : null,
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

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: Responsive.sp(16), color: color ?? AppColors.textSecondary),
        SizedBox(width: Responsive.wp(1)),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(12),
            color: color ?? AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
