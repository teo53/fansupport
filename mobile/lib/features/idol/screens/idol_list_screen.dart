import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';

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
            padding: EdgeInsets.all(Responsive.wp(4)),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '아이돌 검색',
                hintStyle: TextStyle(fontSize: Responsive.sp(14)),
                prefixIcon: Icon(Icons.search, size: Responsive.sp(22)),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Responsive.wp(4),
                  vertical: Responsive.hp(1.5),
                ),
              ),
              style: TextStyle(fontSize: Responsive.sp(14)),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: Responsive.sp(48),
              color: AppColors.textSecondary,
            ),
            SizedBox(height: Responsive.hp(2)),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: Responsive.sp(16),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: Responsive.wp(3),
        mainAxisSpacing: Responsive.wp(3),
      ),
      itemCount: idols.length,
      itemBuilder: (context, index) => _buildIdolCard(idols[index]),
    );
  }

  Widget _buildIdolCard(Map<String, dynamic> idol) {
    final categoryColors = {
      'UNDERGROUND_IDOL': AppColors.primary,
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

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.go('/idols/${idol['id']}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: idol['profileImage'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: color.withValues(alpha: 0.2),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: color.withValues(alpha: 0.2),
                      child: Icon(Icons.person, size: 50, color: color),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                  if (idol['ranking'] <= 3)
                    Positioned(
                      top: Responsive.wp(2),
                      left: Responsive.wp(2),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.wp(2),
                          vertical: Responsive.hp(0.5),
                        ),
                        decoration: BoxDecoration(
                          color: [
                            AppColors.gold,
                            AppColors.silver,
                            AppColors.bronze
                          ][idol['ranking'] - 1],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${idol['ranking']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.sp(11),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: Responsive.wp(2),
                    right: Responsive.wp(2),
                    child: Container(
                      padding: EdgeInsets.all(Responsive.wp(1.5)),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: Responsive.sp(18),
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
                padding: EdgeInsets.all(Responsive.wp(3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            idol['stageName'],
                            style: TextStyle(
                              fontSize: Responsive.sp(14),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (idol['isVerified'])
                          Icon(
                            Icons.verified,
                            size: Responsive.sp(14),
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                    SizedBox(height: Responsive.hp(0.5)),
                    Text(
                      categoryNames[idol['category']] ?? '기타',
                      style: TextStyle(
                        fontSize: Responsive.sp(12),
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: Responsive.sp(14),
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: Responsive.wp(1)),
                        Text(
                          '${idol['supporterCount']}명',
                          style: TextStyle(
                            fontSize: Responsive.sp(12),
                            color: AppColors.textSecondary,
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
      ),
    );
  }
}
