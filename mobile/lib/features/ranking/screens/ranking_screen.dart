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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '랭킹',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Top 3 Section
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(Responsive.wp(6)),
              margin: EdgeInsets.only(bottom: Responsive.wp(4)),
              child: Column(
                children: [
                  Text(
                    '이번 달 TOP 3',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (sortedIdols.length > 1)
                        _buildTopRanker(context, 2, sortedIdols[1]),
                      if (sortedIdols.isNotEmpty)
                        _buildTopRanker(context, 1, sortedIdols[0]),
                      if (sortedIdols.length > 2)
                        _buildTopRanker(context, 3, sortedIdols[2]),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Rest of Rankings
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
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
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildTopRanker(BuildContext context, int rank, IdolModel idol) {
    final colors = {
      1: AppColors.gold,
      2: AppColors.silver,
      3: AppColors.bronze,
    };
    final sizes = {
      1: 90.0,
      2: 70.0,
      3: 70.0,
    };

    return GestureDetector(
      onTap: () => context.go('/idols/${idol.id}'),
      child: Column(
        children: [
          Container(
            width: sizes[rank],
            height: sizes[rank],
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors[rank]!,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: idol.profileImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Color(int.parse(idol.imageColor ?? "0xFF000000")),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Color(int.parse(idol.imageColor ?? "0xFF000000")),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colors[rank],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                idol.stageName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              if (idol.isVerified) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.verified,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            '${_formatNumber(idol.totalSupport)} P',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (rank == 1) const SizedBox(height: 20),
          if (rank != 1) const SizedBox(height: 12.0),
        ],
      ),
    );
  }

  Widget _buildRankingItem(BuildContext context, int rank, IdolModel idol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => context.go('/idols/${idol.id}'),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: idol.profileImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Color(int.parse(idol.imageColor ?? "0xFF000000")),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Color(int.parse(idol.imageColor ?? "0xFF000000")),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          idol.stageName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (idol.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    idol.agencyName ?? '개인',
                    style: TextStyle(
                      fontSize: 13,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Point',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
