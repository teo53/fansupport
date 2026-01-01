import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/idol_model.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);

    // Sort idols by total support amount
    final sortedIdols = List<IdolModel>.from(MockData.idolModels)
      ..sort((a, b) => b.totalSupport.compareTo(a.totalSupport));

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
                  return _buildRankingItem(
                      context, index + 4, sortedIdols[index + 3]);
                },
                childCount: sortedIdols.length > 3 ? sortedIdols.length - 3 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRanker(
      BuildContext context, int rank, String tier, IdolModel idol) {
    final colors = {
      'Gold': AppColors.gold,
      'Silver': AppColors.silver,
      'Bronze': AppColors.bronze,
    };
    final sizes = {
      1: Responsive.wp(24),
      2: Responsive.wp(20),
      3: Responsive.wp(20)
    };
    final heights = {
      1: Responsive.hp(14),
      2: Responsive.hp(10),
      3: Responsive.hp(10)
    };

    return GestureDetector(
      onTap: () => context.go('/idols/${idol.id}'),
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
              backgroundImage: CachedNetworkImageProvider(idol.profileImage),
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
                idol.stageName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.sp(14),
                ),
              ),
              if (idol.isVerified) ...[
                SizedBox(width: Responsive.wp(1)),
                Icon(Icons.verified,
                    color: Colors.white, size: Responsive.sp(14)),
              ],
            ],
          ),
          SizedBox(height: Responsive.hp(0.5)),
          Text(
            '${_formatNumber(idol.totalSupport)} P',
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

  Widget _buildRankingItem(BuildContext context, int rank, IdolModel idol) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.hp(1.5)),
      padding: EdgeInsets.all(Responsive.wp(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow(opacity: 0.05),
      ),
      child: InkWell(
        onTap: () => context.go('/idols/${idol.id}'),
        child: Row(
          children: [
            SizedBox(
              width: Responsive.wp(10),
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: Responsive.sp(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: Responsive.wp(3)),
            CircleAvatar(
              radius: Responsive.wp(6),
              backgroundImage: CachedNetworkImageProvider(idol.profileImage),
            ),
            SizedBox(width: Responsive.wp(4)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        idol.stageName,
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (idol.isVerified) ...[
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
                    idol.agencyName ?? '개인',
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatNumber(idol.totalSupport),
                  style: TextStyle(
                    fontSize: Responsive.sp(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Point',
                  style: TextStyle(
                    fontSize: Responsive.sp(10),
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
