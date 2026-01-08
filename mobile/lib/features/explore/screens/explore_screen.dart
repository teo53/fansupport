import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../shared/widgets/glass_card.dart';

/// Explore Screen - Browse and discover creators
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selectedCategory = 'all';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PipoColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryChips(),
            _buildCreatorGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(PipoSpacing.md),
        child: Row(
          children: [
            Text(
              '탐색',
              style: PipoTypography.heading1.copyWith(
                color: PipoColors.textPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => context.push('/ranking'),
              icon: const Icon(Icons.leaderboard_rounded),
              color: PipoColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.md),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '크리에이터 검색',
            hintStyle: PipoTypography.bodyMedium.copyWith(
              color: PipoColors.textTertiary,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: PipoColors.textTertiary,
            ),
            filled: true,
            fillColor: PipoColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PipoRadius.lg),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: PipoSpacing.md,
              vertical: PipoSpacing.md,
            ),
          ),
          onChanged: (value) {
            // TODO: Implement search
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      {'id': 'all', 'label': '전체', 'icon': Icons.grid_view_rounded},
      {'id': 'UNDERGROUND_IDOL', 'label': '아이돌', 'icon': Icons.star_rounded},
      {'id': 'MAID_CAFE', 'label': '메이드카페', 'icon': Icons.local_cafe_rounded},
      {'id': 'COSPLAYER', 'label': '코스플레이어', 'icon': Icons.face_rounded},
      {'id': 'VTuber', 'label': '스트리머', 'icon': Icons.videocam_rounded},
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 48,
        margin: const EdgeInsets.only(top: PipoSpacing.md),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.md),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategory == category['id'];

            return Padding(
              padding: const EdgeInsets.only(right: PipoSpacing.sm),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : PipoColors.textSecondary,
                    ),
                    const SizedBox(width: PipoSpacing.xs),
                    Text(category['label'] as String),
                  ],
                ),
                labelStyle: PipoTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.white : PipoColors.textSecondary,
                ),
                backgroundColor: PipoColors.surfaceVariant,
                selectedColor: PipoColors.primary,
                checkmarkColor: Colors.white,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PipoRadius.full),
                ),
                side: BorderSide.none,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category['id'] as String;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCreatorGrid() {
    // TODO: Replace with actual data from provider
    final creators = _getMockCreators();

    return SliverPadding(
      padding: const EdgeInsets.all(PipoSpacing.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: PipoSpacing.md,
          mainAxisSpacing: PipoSpacing.md,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildCreatorCard(creators[index]),
          childCount: creators.length,
        ),
      ),
    );
  }

  Widget _buildCreatorCard(Map<String, dynamic> creator) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/idols/${creator['id']}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: PipoColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(PipoRadius.lg),
                ),
                image: creator['image'] != null
                    ? DecorationImage(
                        image: NetworkImage(creator['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: creator['image'] == null
                  ? const Center(
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: PipoColors.textTertiary,
                      ),
                    )
                  : null,
            ),
          ),
          // Info section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(PipoSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          creator['name'] ?? '',
                          style: PipoTypography.titleSmall.copyWith(
                            color: PipoColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (creator['isVerified'] == true)
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: PipoColors.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: PipoSpacing.xs),
                  Text(
                    creator['category'] ?? '',
                    style: PipoTypography.labelSmall.copyWith(
                      color: PipoColors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      // Slots indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PipoSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (creator['remainingSlots'] ?? 0) > 0
                              ? PipoColors.success.withOpacity(0.1)
                              : PipoColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(PipoRadius.sm),
                        ),
                        child: Text(
                          (creator['remainingSlots'] ?? 0) > 0
                              ? '${creator['remainingSlots']}슬롯'
                              : '마감',
                          style: PipoTypography.labelSmall.copyWith(
                            color: (creator['remainingSlots'] ?? 0) > 0
                                ? PipoColors.success
                                : PipoColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${creator['startPrice']}원~',
                        style: PipoTypography.labelSmall.copyWith(
                          color: PipoColors.primary,
                          fontWeight: FontWeight.w600,
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

  List<Map<String, dynamic>> _getMockCreators() {
    return [
      {
        'id': '1',
        'name': 'Sakura',
        'image': null,
        'category': '아이돌',
        'isVerified': true,
        'remainingSlots': 5,
        'startPrice': '3,000',
      },
      {
        'id': '2',
        'name': 'Yuki',
        'image': null,
        'category': '메이드카페',
        'isVerified': true,
        'remainingSlots': 2,
        'startPrice': '5,000',
      },
      {
        'id': '3',
        'name': 'Mina',
        'image': null,
        'category': '코스플레이어',
        'isVerified': false,
        'remainingSlots': 0,
        'startPrice': '8,000',
      },
      {
        'id': '4',
        'name': 'Hana',
        'image': null,
        'category': '스트리머',
        'isVerified': true,
        'remainingSlots': 10,
        'startPrice': '2,000',
      },
      {
        'id': '5',
        'name': 'Luna',
        'image': null,
        'category': '아이돌',
        'isVerified': false,
        'remainingSlots': 3,
        'startPrice': '4,000',
      },
      {
        'id': '6',
        'name': 'Sora',
        'image': null,
        'category': '메이드카페',
        'isVerified': true,
        'remainingSlots': 8,
        'startPrice': '3,500',
      },
    ];
  }
}
