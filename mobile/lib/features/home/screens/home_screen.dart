import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/idol_model.dart';
import '../../live/screens/incoming_call_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../widgets/hero_card.dart';
import '../widgets/story_item.dart';
import '../widgets/creator_card.dart';
import '../widgets/funding_card.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_title.dart';

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
                    SliverToBoxAdapter(child: _buildLiveStoriesSection(context)),
                    SliverToBoxAdapter(child: _buildQuickActionsGrid(context)),
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

  Widget _buildLiveStoriesSection(BuildContext context) {
    final idols = MockData.idolModels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PipoSpacing.xl, PipoSpacing.xxl, PipoSpacing.xl, PipoSpacing.md,
          ),
          child: Text(
            '스토리',
            style: PipoTypography.titleMedium.copyWith(
              color: PipoColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: idols.length,
            itemBuilder: (context, index) {
              final idol = idols[index];
              final isLive = index == 0;
              return StoryItem(
                idol: idol,
                isLive: isLive,
                onTap: () {
                  if (isLive) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => IncomingCallScreen(idol: idol),
                        fullscreenDialog: true,
                      ),
                    );
                  } else {
                    _showStoryView(context, idol);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showStoryView(BuildContext context, IdolModel idol) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black,
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.black,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: idol.profileImage,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.3, 0.8],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(PipoSpacing.lg),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                CachedNetworkImageProvider(idol.profileImage),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            idol.stageName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white, size: 28),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(PipoSpacing.xl),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go('/idols/${idol.id}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: PipoRadius.button,
                            ),
                          ),
                          child: const Text(
                            '프로필 방문하기',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.star_rounded,
        label: '멤버십',
        color: PipoColors.purple,
        onTap: () => context.go('/membership'),
      ),
      _QuickAction(
        icon: Icons.chat_bubble_rounded,
        label: 'Bubble',
        color: PipoColors.primary,
        onTap: () {
          final firstIdol = MockData.idolModels.first;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(idol: firstIdol),
            ),
          );
        },
      ),
      _QuickAction(
        icon: Icons.feed_rounded,
        label: '피드',
        color: PipoColors.teal,
        onTap: () => context.go('/community'),
      ),
      _QuickAction(
        icon: Icons.calendar_today_rounded,
        label: '스케줄',
        color: PipoColors.orange,
        onTap: () => context.go('/schedule'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PipoSpacing.xl, PipoSpacing.xxl, PipoSpacing.xl, 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              action.onTap();
            },
            child: SizedBox(
              width: 70,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(PipoRadius.lg),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: PipoSpacing.sm),
                  Text(
                    action.label,
                    style: PipoTypography.labelSmall.copyWith(
                      color: PipoColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCreatorCards(BuildContext context) {
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
  }

  Widget _buildFundingCards(BuildContext context) {
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
                              padding: EdgeInsets.only(left: 4),
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

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
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
