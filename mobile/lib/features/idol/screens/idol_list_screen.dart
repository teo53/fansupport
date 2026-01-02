import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_components.dart';

class IdolListScreen extends ConsumerStatefulWidget {
  const IdolListScreen({super.key});

  @override
  ConsumerState<IdolListScreen> createState() => _IdolListScreenState();
}

class _IdolListScreenState extends ConsumerState<IdolListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final categories = [
    ('전체', null),
    ('지하 아이돌', 'UNDERGROUND_IDOL'),
    ('메이드카페', 'MAID_CAFE'),
    ('코스플레이어', 'COSPLAYER'),
    ('VTuber', 'VTuber'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterIdols(String? category) {
    var filtered = MockData.idols.where((idol) {
      final matchesCategory = category == null || idol['category'] == category;
      final matchesSearch = _searchQuery.isEmpty ||
          idol['stageName'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '아이돌',
          style: TextStyle(fontSize: Responsive.sp(18)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard_outlined, size: Responsive.sp(24)),
            onPressed: () => context.go('/ranking'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: TextStyle(fontSize: Responsive.sp(13)),
          tabs: categories.map((c) => Tab(text: c.$1)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Spacing.base),
            child: SearchInput(
              controller: _searchController,
              hint: '아이돌 검색...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((c) => _buildIdolGrid(c.$2)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdolGrid(String? category) {
    final idols = _filterIdols(category);

    if (idols.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: '검색 결과가 없습니다',
        description: '다른 검색어로 시도해보세요',
      );
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: Spacing.base),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: Spacing.md,
        mainAxisSpacing: Spacing.md,
      ),
      itemCount: idols.length,
      itemBuilder: (context, index) => _buildIdolCard(idols[index]),
    );
  }

  Widget _buildIdolCard(Map<String, dynamic> idol) {
    final categoryColors = {
      'UNDERGROUND_IDOL': AppColors.idolCategory,
      'MAID_CAFE': AppColors.maidCategory,
      'COSPLAYER': AppColors.cosplayerCategory,
      'VTuber': AppColors.vtuberCategory,
    };

    final categoryNames = {
      'UNDERGROUND_IDOL': '지하 아이돌',
      'MAID_CAFE': '메이드카페',
      'COSPLAYER': '코스플레이어',
      'VTuber': 'VTuber',
    };

    final color = categoryColors[idol['category']] ?? AppColors.primary;

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: Radii.lg,
      onTap: () => context.go('/idols/${idol['id']}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
                  child: CachedNetworkImage(
                    imageUrl: idol['profileImage'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: color.withOpacity(0.2),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: color.withOpacity(0.2),
                      child: Icon(Icons.person, size: 50, color: color),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                if (idol['ranking'] <= 3)
                  Positioned(
                    top: Spacing.sm,
                    left: Spacing.sm,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getRankingColor(idol['ranking']),
                        borderRadius: BorderRadius.circular(Radii.xs),
                      ),
                      child: Text(
                        '#${idol['ranking']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          fontFamily: TypographyTokens.fontFamily,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: Spacing.sm,
                  right: Spacing.sm,
                  child: Container(
                    padding: EdgeInsets.all(Spacing.xs + 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: Shadows.soft,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: IconSizes.sm,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          idol['stageName'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: TypographyTokens.fontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (idol['isVerified'])
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                  SizedBox(height: Spacing.xs),
                  Text(
                    categoryNames[idol['category']] ?? '기타',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontFamily: TypographyTokens.fontFamily,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: Spacing.xs),
                      Text(
                        '${idol['supporterCount']}명',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: TypographyTokens.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
