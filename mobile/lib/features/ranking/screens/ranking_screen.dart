import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _getCategoryName(String? category) {
    final names = {
      'UNDERGROUND_IDOL': '지하 아이돌',
      'MAID_CAFE': '메이드카페',
      'COSPLAYER': '코스플레이어',
      'VTuber': 'VTuber',
    };
    return names[category] ?? '아이돌';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);

    // Sort idols by total received (support amount)
    final sortedIdols = List<Map<String, dynamic>>.from(MockData.idols)
      ..sort((a, b) => (b['totalReceived'] as int).compareTo(a['totalReceived'] as int));

    return Scaffold(
      appBar: AppBar(
        title: Text('랭킹', style: TextStyle(fontSize: Responsive.sp(18))),
      ),
      body: CustomScrollView(
        slivers: [
          // Top 3 Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(Responsive.wp(6)),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                children: [
                  Text(
                    '이번 달 TOP 3',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.sp(20),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(3)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (sortedIdols.length > 1)
                        _buildTopRanker(context, 2, 'Silver', sortedIdols[1]),
                      if (sortedIdols.isNotEmpty)
                        _buildTopRanker(context, 1, 'Gold', sortedIdols[0]),
                      if (sortedIdols.length > 2)
                        _buildTopRanker(context, 3, 'Bronze', sortedIdols[2]),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Rest of Rankings
          SliverPadding(
            padding: EdgeInsets.all(Responsive.wp(4)),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index + 3 >= sortedIdols.length) return null;
                  return _buildRankingItem(context, index + 4, sortedIdols[index + 3]);
                },
                childCount: sortedIdols.length > 3 ? sortedIdols.length - 3 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRanker(BuildContext context, int rank, String tier, Map<String, dynamic> idol) {
    final colors = {
      'Gold': AppColors.gold,
      'Silver': AppColors.silver,
      'Bronze': AppColors.bronze,
    };
    final sizes = {1: Responsive.wp(24), 2: Responsive.wp(20), 3: Responsive.wp(20)};
    final heights = {1: Responsive.hp(14), 2: Responsive.hp(10), 3: Responsive.hp(10)};

    return GestureDetector(
      onTap: () => context.go('/idols/${idol['id']}'),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors[tier]!,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[tier]!.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: (sizes[rank]! - 6) / 2,
              backgroundColor: Colors.white,
              backgroundImage: idol['profileImage'] != null
                  ? CachedNetworkImageProvider(idol['profileImage'])
                  : null,
              child: idol['profileImage'] == null
                  ? Icon(
                      Icons.person,
                      size: sizes[rank]! / 2,
                      color: colors[tier],
                    )
                  : null,
            ),
          ),
          SizedBox(height: Responsive.hp(1)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.wp(3),
              vertical: Responsive.hp(0.5),
            ),
            decoration: BoxDecoration(
              color: colors[tier],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: Responsive.sp(12),
              ),
            ),
          ),
          SizedBox(height: Responsive.hp(1)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                idol['stageName'] ?? '아이돌',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.sp(14),
                ),
              ),
              if (idol['isVerified'] ?? false) ...[
                SizedBox(width: Responsive.wp(1)),
                Icon(Icons.verified, color: Colors.white, size: Responsive.sp(14)),
              ],
            ],
          ),
          SizedBox(height: Responsive.hp(0.5)),
          Text(
            '￦${_formatNumber(idol['totalReceived'] ?? 0)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: Responsive.sp(12),
            ),
          ),
          SizedBox(height: heights[rank]! - Responsive.hp(10)),
        ],
      ),
    );
  }

  Widget _buildRankingItem(BuildContext context, int rank, Map<String, dynamic> idol) {
    // Simulate rank change
    final rankChange = (idol['id'].hashCode % 5) - 2;
    final isUp = rankChange > 0;
    final isDown = rankChange < 0;

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(1)),
      child: InkWell(
        onTap: () => context.go('/idols/${idol['id']}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(Responsive.wp(3)),
          child: Row(
            children: [
              SizedBox(
                width: Responsive.wp(10),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    fontSize: Responsive.sp(15),
                  ),
                ),
              ),
              CircleAvatar(
                radius: Responsive.wp(6),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: idol['profileImage'] != null
                    ? CachedNetworkImageProvider(idol['profileImage'])
                    : null,
                child: idol['profileImage'] == null
                    ? Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: Responsive.sp(24),
                      )
                    : null,
              ),
              SizedBox(width: Responsive.wp(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          idol['stageName'] ?? '아이돌',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: Responsive.sp(15),
                          ),
                        ),
                        if (idol['isVerified'] ?? false) ...[
                          SizedBox(width: Responsive.wp(1)),
                          Icon(
                            Icons.verified,
                            size: Responsive.sp(16),
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _getCategoryName(idol['category']),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: Responsive.sp(12),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '￦${_formatNumber(idol['totalReceived'] ?? 0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: Responsive.sp(15),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp
                            ? Icons.arrow_drop_up
                            : isDown
                                ? Icons.arrow_drop_down
                                : Icons.remove,
                        color: isUp
                            ? AppColors.success
                            : isDown
                                ? AppColors.error
                                : AppColors.textSecondary,
                        size: Responsive.sp(20),
                      ),
                      if (rankChange != 0)
                        Text(
                          '${rankChange.abs()}',
                          style: TextStyle(
                            color: isUp ? AppColors.success : AppColors.error,
                            fontSize: Responsive.sp(12),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
