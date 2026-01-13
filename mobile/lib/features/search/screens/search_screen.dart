import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/idol_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';
  List<IdolModel> _searchResults = [];
  bool _isSearching = false;

  final List<String> _recentSearches = [
    '메이드카페',
    'VTuber',
    '생일 서포트',
    '포토카드',
  ];

  final List<String> _trendingKeywords = [
    '🔥 핫한 아이돌',
    '✨ 신규 크리에이터',
    '🎂 생일 이벤트',
    '🎁 한정판 굿즈',
    '💕 구독 이벤트',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // Simulate search with delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || _searchQuery != query) return;

      final allIdols = MockData.idolModels;
      final results = allIdols.where((idol) {
        final queryLower = query.toLowerCase();
        return idol.stageName.toLowerCase().contains(queryLower) ||
            idol.category.toLowerCase().contains(queryLower) ||
            idol.bio.toLowerCase().contains(queryLower);
      }).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  void _addToRecentSearches(String query) {
    if (query.isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PipoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildDiscoveryContent()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        PipoSpacing.md,
        PipoSpacing.md,
        PipoSpacing.xl,
        PipoSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: PipoColors.textPrimary,
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: PipoColors.surface,
                borderRadius: BorderRadius.circular(PipoRadius.lg),
                boxShadow: PipoShadows.sm,
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearch,
                onSubmitted: (query) {
                  _addToRecentSearches(query);
                },
                style: PipoTypography.bodyMedium.copyWith(
                  color: PipoColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '아이돌, 캠페인, 키워드 검색',
                  hintStyle: PipoTypography.bodyMedium.copyWith(
                    color: PipoColors.textDisabled,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: PipoColors.textTertiary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          color: PipoColors.textTertiary,
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: PipoSpacing.lg,
                    vertical: PipoSpacing.md,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader('최근 검색', onClear: () {
              setState(() => _recentSearches.clear());
            }),
            const SizedBox(height: PipoSpacing.md),
            Wrap(
              spacing: PipoSpacing.sm,
              runSpacing: PipoSpacing.sm,
              children: _recentSearches.map((keyword) {
                return _SearchChip(
                  label: keyword,
                  onTap: () {
                    _searchController.text = keyword;
                    _onSearch(keyword);
                  },
                  onDelete: () {
                    setState(() => _recentSearches.remove(keyword));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: PipoSpacing.xxl),
          ],
          _buildSectionHeader('인기 검색어'),
          const SizedBox(height: PipoSpacing.md),
          ...List.generate(_trendingKeywords.length, (index) {
            final keyword = _trendingKeywords[index];
            return _TrendingItem(
              rank: index + 1,
              keyword: keyword,
              onTap: () {
                final cleanKeyword = keyword.replaceAll(RegExp(r'[^\w\s가-힣]'), '').trim();
                _searchController.text = cleanKeyword;
                _onSearch(cleanKeyword);
              },
            );
          }),
          const SizedBox(height: PipoSpacing.xxl),
          _buildSectionHeader('추천 크리에이터'),
          const SizedBox(height: PipoSpacing.md),
          _buildRecommendedCreators(),
          const SizedBox(height: PipoSpacing.xxl),
          _buildSectionHeader('카테고리로 찾기'),
          const SizedBox(height: PipoSpacing.md),
          _buildCategoryGrid(),
          const SizedBox(height: PipoSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onClear}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: PipoTypography.titleSmall.copyWith(
            color: PipoColors.textPrimary,
          ),
        ),
        if (onClear != null)
          GestureDetector(
            onTap: onClear,
            child: Text(
              '전체 삭제',
              style: PipoTypography.bodySmall.copyWith(
                color: PipoColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedCreators() {
    final idols = MockData.idolModels.take(4).toList();
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: idols.length,
        separatorBuilder: (_, __) => const SizedBox(width: PipoSpacing.md),
        itemBuilder: (context, index) {
          final idol = idols[index];
          return GestureDetector(
            onTap: () => context.push('/idols/${idol.id}'),
            child: SizedBox(
              width: 80,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: PipoColors.primaryGradient,
                      boxShadow: PipoShadows.sm,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(idol.profileImage),
                    ),
                  ),
                  const SizedBox(height: PipoSpacing.sm),
                  Text(
                    idol.stageName,
                    style: PipoTypography.labelSmall.copyWith(
                      color: PipoColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    idol.category,
                    style: PipoTypography.bodySmall.copyWith(
                      color: PipoColors.textTertiary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      _CategoryItem(
        icon: Icons.mic,
        label: '아이돌',
        color: const Color(0xFFFF6B9D),
        value: 'UNDERGROUND_IDOL',
      ),
      _CategoryItem(
        icon: Icons.emoji_people,
        label: '메이드카페',
        color: const Color(0xFFFF9F43),
        value: 'MAID_CAFE',
      ),
      _CategoryItem(
        icon: Icons.camera_alt,
        label: '코스플레이어',
        color: const Color(0xFF54A0FF),
        value: 'COSPLAYER',
      ),
      _CategoryItem(
        icon: Icons.smart_display,
        label: 'VTuber',
        color: const Color(0xFF5F27CD),
        value: 'VTuber',
      ),
      _CategoryItem(
        icon: Icons.live_tv,
        label: '스트리머',
        color: const Color(0xFF00D2D3),
        value: 'STREAMER',
      ),
      _CategoryItem(
        icon: Icons.campaign,
        label: '펀딩',
        color: const Color(0xFFFF6B6B),
        value: 'CAMPAIGN',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: PipoSpacing.md,
        crossAxisSpacing: PipoSpacing.md,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/idols?category=${cat.value}');
          },
          child: Container(
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(PipoRadius.lg),
              border: Border.all(color: cat.color.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 22),
                ),
                const SizedBox(height: PipoSpacing.sm),
                Text(
                  cat.label,
                  style: PipoTypography.labelSmall.copyWith(
                    color: cat.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: PipoColors.primary),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: PipoColors.textDisabled,
            ),
            const SizedBox(height: PipoSpacing.lg),
            Text(
              "'$_searchQuery' 검색 결과가 없어요',",
              style: PipoTypography.bodyLarge.copyWith(
                color: PipoColors.textTertiary,
              ),
            ),
            const SizedBox(height: PipoSpacing.sm),
            Text(
              '다른 키워드로 검색해보세요',
              style: PipoTypography.bodySmall.copyWith(
                color: PipoColors.textDisabled,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: PipoSpacing.xl,
        vertical: PipoSpacing.md,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final idol = _searchResults[index];
        return _SearchResultTile(
          idol: idol,
          onTap: () {
            _addToRecentSearches(_searchQuery);
            context.push('/idols/${idol.id}');
          },
        );
      },
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SearchChip({
    required this.label,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PipoSpacing.md,
          vertical: PipoSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: PipoColors.surface,
          borderRadius: BorderRadius.circular(PipoRadius.full),
          border: Border.all(color: PipoColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: PipoTypography.bodySmall.copyWith(
                color: PipoColors.textSecondary,
              ),
            ),
            const SizedBox(width: PipoSpacing.xs),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: PipoColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingItem extends StatelessWidget {
  final int rank;
  final String keyword;
  final VoidCallback onTap;

  const _TrendingItem({
    required this.rank,
    required this.keyword,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PipoSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                style: PipoTypography.titleSmall.copyWith(
                  color: rank <= 3 ? PipoColors.primary : PipoColors.textTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: PipoSpacing.md),
            Text(
              keyword,
              style: PipoTypography.bodyMedium.copyWith(
                color: PipoColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final IdolModel idol;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.idol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: PipoSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: CachedNetworkImageProvider(idol.profileImage),
            ),
            const SizedBox(width: PipoSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        idol.stageName,
                        style: PipoTypography.labelMedium.copyWith(
                          color: PipoColors.textPrimary,
                        ),
                      ),
                      if (idol.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            size: 16,
                            color: PipoColors.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    idol.category,
                    style: PipoTypography.bodySmall.copyWith(
                      color: PipoColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PipoSpacing.md,
                vertical: PipoSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: PipoColors.primarySoft,
                borderRadius: BorderRadius.circular(PipoRadius.full),
              ),
              child: Text(
                '프로필',
                style: PipoTypography.labelSmall.copyWith(
                  color: PipoColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  final String value;

  _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
  });
}
