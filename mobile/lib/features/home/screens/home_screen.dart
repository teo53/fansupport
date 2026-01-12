import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/idol_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../idol/providers/idol_provider.dart';
import '../../campaign/providers/campaign_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/creator_card.dart';
import '../widgets/funding_card.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_title.dart';
import '../widgets/live_stories_section.dart';
import '../widgets/quick_actions_grid.dart';
import '../../../shared/widgets/skeleton_loader.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _headerController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
    _fadeController = AnimationController(
      duration: PipoAnimations.medium,
      vsync: this,
    )..forward();
    _headerController = AnimationController(
      duration: PipoAnimations.slow,
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, you would:
    // - Refresh data from API
    // - Update state with new data
    // - Show success message if needed

    if (mounted) {
      // Optional: Show success message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('새로고침 완료')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: PipoColors.background,
        body: Stack(
          children: [
            _buildAmbientBackground(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: PipoColors.primary,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                    SliverToBoxAdapter(child: _buildHeader(context, user)),
                    const SliverToBoxAdapter(child: HeroCard()),
                    const SliverToBoxAdapter(child: LiveStoriesSection()),
                    const SliverToBoxAdapter(child: QuickActionsGrid()),
                    SliverToBoxAdapter(
                      child: SectionTitle(
                        title: '인기 크리에이터',
                        actionText: '전체보기',
                        onTap: () => context.go('/ranking'),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildCreatorCards(context)),
                    SliverToBoxAdapter(
                      child: SectionTitle(
                        title: '진행중인 펀딩',
                        actionText: '전체보기',
                        onTap: () => context.go('/campaigns'),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildFundingCards(context)),
                    SliverToBoxAdapter(
                      child: SectionTitle(title: '스페셜 이벤트'),
                    ),
                    SliverToBoxAdapter(child: _buildPremiumEvents(context)),
                    SliverToBoxAdapter(
                      child: SectionTitle(title: '카테고리'),
                    ),
                    SliverToBoxAdapter(child: _buildCategoryChips(context)),
                    SliverToBoxAdapter(
                      child: SectionTitle(
                        title: '최근 소식',
                        actionText: '더보기',
                        onTap: () => context.go('/community'),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildRecentActivity(context)),
                      SliverToBoxAdapter(
                        child: SizedBox(height: PipoSpacing.screen + 40),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    PipoColors.primary.withOpacity(0.12),
                    PipoColors.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 280,
            right: -100,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    PipoColors.purple.withOpacity(0.08),
                    PipoColors.purple.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _headerController,
        curve: PipoAnimations.standard,
      )),
      child: FadeTransition(
        opacity: _headerController,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            PipoSpacing.xl,
            MediaQuery.of(context).padding.top + PipoSpacing.lg,
            PipoSpacing.xl,
            PipoSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PIPO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: PipoColors.primary,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: PipoSpacing.xs),
                    RichText(
                      text: TextSpan(
                        style: PipoTypography.bodyMedium.copyWith(
                          color: PipoColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: user?.nickname ?? '팬',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: PipoColors.textPrimary,
                            ),
                          ),
                          const TextSpan(text: '님, 반가워요!'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildIconButton(
                    icon: Icons.search_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('검색 기능 준비중')),
                      );
                    },
                  ),
                  const SizedBox(width: PipoSpacing.sm),
                  _buildIconButton(
                    icon: Icons.notifications_none_rounded,
                    badge: 3,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('알림 센터 준비중')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    int? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: PipoColors.surface,
          borderRadius: BorderRadius.circular(PipoRadius.md),
          boxShadow: PipoShadows.sm,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: PipoColors.textPrimary),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: PipoColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorCards(BuildContext context) {
    final idolsAsync = ref.watch(popularIdolsProvider);

    return idolsAsync.when(
      data: (idols) {
        final displayIdols = idols.take(5).toList();
        return SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
            itemCount: displayIdols.length,
            itemBuilder: (context, index) {
              final idol = displayIdols[index];
              return CreatorCard(idol: idol, rank: index + 1);
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
          itemCount: 3,
          itemBuilder: (context, index) => SkeletonLoader.creatorCard(),
        ),
      ),
      error: (error, stack) {
        // Fallback to mock data on error
        final idols = MockData.idolModels.take(5).toList();
        return SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
            itemCount: idols.length,
            itemBuilder: (context, index) {
              final idol = idols[index];
              return CreatorCard(idol: idol, rank: index + 1);
            },
          ),
        );
      },
    );
  }

  Widget _buildFundingCards(BuildContext context) {
    final campaignsAsync = ref.watch(popularCampaignsProvider);

    return campaignsAsync.when(
      data: (campaigns) {
        final displayCampaigns = campaigns.take(3).toList();
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
            itemCount: displayCampaigns.length,
            itemBuilder: (context, index) {
              final campaign = displayCampaigns[index];
              return FundingCard(campaign: campaign.toJson());
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
          itemCount: 2,
          itemBuilder: (context, index) => SkeletonLoader.fundingCard(),
        ),
      ),
      error: (error, stack) {
        // Fallback to mock data on error
        final campaigns = MockData.campaigns.take(3).toList();
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              return FundingCard(campaign: campaign);
            },
          ),
        );
      },
    );
  }

  Widget _buildPremiumEvents(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: PremiumCard(
              icon: Icons.videocam_rounded,
              title: '1:1 영상통화',
              subtitle: '특별한 만남',
              gradient: PipoColors.primaryGradient,
              route: '/date-tickets',
            ),
          ),
          const SizedBox(width: PipoSpacing.md),
          Expanded(
            child: PremiumCard(
              icon: Icons.airplane_ticket_rounded,
              title: 'VIP 팬미팅',
              subtitle: '프리미엄 경험',
              gradient: PipoColors.premiumGradient,
              route: '/date-tickets',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final categories = [
      _Category(
        icon: Icons.mic,
        label: '아이돌',
        color: const Color(0xFFFF6B9D),
        value: 'UNDERGROUND_IDOL',
      ),
      _Category(
        icon: Icons.emoji_people,
        label: '메이드카페',
        color: const Color(0xFFFF9F43),
        value: 'MAID_CAFE',
      ),
      _Category(
        icon: Icons.camera_alt,
        label: '코스플레이어',
        color: const Color(0xFF54A0FF),
        value: 'COSPLAYER',
      ),
      _Category(
        icon: Icons.smart_display,
        label: 'VTuber',
        color: const Color(0xFF5F27CD),
        value: 'VTuber',
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => context.go('/idols?category=${cat.value}'),
            child: Container(
              margin: const EdgeInsets.only(right: PipoSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: PipoSpacing.lg,
                vertical: PipoSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(PipoRadius.full),
                border: Border.all(
                  color: cat.color.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, color: cat.color, size: 18),
                  const SizedBox(width: 6),
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
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final posts = MockData.posts.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
      child: Column(
        children: posts.map((post) {
          IdolModel? author;
          try {
            author = MockData.idolModels
                .firstWhere((i) => i.id == post['authorId']);
          } catch (e) {
            // Author not found - handle gracefully
            debugPrint('Author not found for post: ${post['id']}');
          }

          return Container(
            margin: const EdgeInsets.only(bottom: PipoSpacing.md),
            padding: const EdgeInsets.all(PipoSpacing.lg),
            decoration: BoxDecoration(
              color: PipoColors.surface,
              borderRadius: BorderRadius.circular(PipoRadius.lg),
              boxShadow: PipoShadows.sm,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: PipoColors.primarySoft,
                  backgroundImage: author?.profileImage != null
                      ? CachedNetworkImageProvider(author!.profileImage)
                      : null,
                  child: author?.profileImage == null
                      ? const Icon(Icons.person,
                          color: PipoColors.primary, size: 22)
                      : null,
                ),
                const SizedBox(width: PipoSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            author?.stageName ?? '익명',
                            style: PipoTypography.labelMedium.copyWith(
                              color: PipoColors.textPrimary,
                            ),
                          ),
                          if (author?.isVerified ?? false)
                            const Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.verified,
                                size: 14,
                                color: PipoColors.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post['content'] ?? '',
                        style: PipoTypography.bodySmall.copyWith(
                          color: PipoColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: PipoColors.textDisabled,
                  size: 20,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Category {
  final IconData icon;
  final String label;
  final Color color;
  final String value;

  _Category({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
  });
}
