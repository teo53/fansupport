import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/idol_model.dart';
import '../../live/screens/incoming_call_screen.dart';
import '../../chat/screens/chat_screen.dart';

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

  String _formatCompact(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
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
            // Ambient background
            _buildAmbientBackground(),

            // Main Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _buildHeader(context, user),
                    ),

                    // Hero Card
                    SliverToBoxAdapter(
                      child: _buildHeroCard(context),
                    ),

                    // Live Stories
                    SliverToBoxAdapter(
                      child: _buildLiveStoriesSection(context),
                    ),

                    // Quick Actions Grid
                    SliverToBoxAdapter(
                      child: _buildQuickActionsGrid(context),
                    ),

                    // Trending Creators
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('인기 크리에이터', '전체보기',
                        onTap: () => context.go('/ranking')),
                    ),
                    SliverToBoxAdapter(
                      child: _buildCreatorCards(context),
                    ),

                    // Active Funding
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('진행중인 펀딩', '전체보기',
                        onTap: () => context.go('/campaigns')),
                    ),
                    SliverToBoxAdapter(
                      child: _buildFundingCards(context),
                    ),

                    // Premium Events
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('스페셜 이벤트', null),
                    ),
                    SliverToBoxAdapter(
                      child: _buildPremiumEvents(context),
                    ),

                    // Categories
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('카테고리', null),
                    ),
                    SliverToBoxAdapter(
                      child: _buildCategoryChips(context),
                    ),

                    // Recent Activity
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('최근 소식', '더보기',
                        onTap: () => context.go('/community')),
                    ),
                    SliverToBoxAdapter(
                      child: _buildRecentActivity(context),
                    ),

                    // Bottom spacing
                    SliverToBoxAdapter(
                      child: SizedBox(height: PipoSpacing.screen + 40),
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

  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top gradient blob
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
          // Right gradient blob
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
              // Left: Logo + Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PIPO Logo
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
                            text: user?.nickname ?? '오타',
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
              // Right: Action buttons
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

  Widget _buildHeroCard(BuildContext context) {
    return Padding(
      padding: PipoSpacing.screenPadding,
      child: GestureDetector(
        onTap: () => context.go('/campaigns'),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PipoRadius.xxl),
            gradient: PipoColors.primaryGradient,
            boxShadow: PipoShadows.primaryGlow,
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(PipoSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(PipoRadius.sm),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: PipoSpacing.md),
                    Text(
                      '좋아하는 크리에이터를\n응원해보세요',
                      style: PipoTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: PipoSpacing.sm),
                    Row(
                      children: [
                        Text(
                          '지금 참여하기',
                          style: PipoTypography.labelMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              return _buildStoryItem(context, idol, isLive);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(BuildContext context, IdolModel idol, bool isLive) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
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
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: PipoSpacing.md),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isLive
                    ? const LinearGradient(
                        colors: [Color(0xFFFF5A5F), Color(0xFFFF8A8E)],
                      )
                    : LinearGradient(
                        colors: [
                          PipoColors.border,
                          PipoColors.border.withOpacity(0.5),
                        ],
                      ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: idol.profileImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.fromHex(idol.imageColor),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.fromHex(idol.imageColor),
                      child: const Icon(Icons.person, color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: PipoSpacing.xs),
            if (isLive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: PipoColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Text(
                idol.stageName,
                style: PipoTypography.caption.copyWith(
                  color: PipoColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
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

  Widget _buildSectionTitle(String title, String? actionText, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PipoSpacing.xl, PipoSpacing.xxxl, PipoSpacing.xl, PipoSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: PipoTypography.titleLarge.copyWith(
              color: PipoColors.textPrimary,
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    actionText,
                    style: PipoTypography.labelSmall.copyWith(
                      color: PipoColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: PipoColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCreatorCards(BuildContext context) {
    final idols = MockData.idolModels.take(5).toList();

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
        itemCount: idols.length,
        itemBuilder: (context, index) {
          final idol = idols[index];
          return _buildCreatorCard(context, idol, index + 1);
        },
      ),
    );
  }

  Widget _buildCreatorCard(BuildContext context, IdolModel idol, int rank) {
    final imageColor =
        AppColors.fromHex(idol.imageColor, defaultColor: PipoColors.primary);

    // Rank colors
    final rankColors = [
      [const Color(0xFFFFD700), const Color(0xFFFFA500)], // Gold
      [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)], // Silver
      [const Color(0xFFCD7F32), const Color(0xFF8B4513)], // Bronze
      [PipoColors.primary, PipoColors.primary.withOpacity(0.7)],
      [PipoColors.purple, PipoColors.purple.withOpacity(0.7)],
    ];
    final rankGradient = rank <= 5 ? rankColors[rank - 1] : rankColors[3];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/idols/${idol.id}');
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: PipoSpacing.md),
        child: Stack(
          children: [
            // Main card
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.fromLTRB(12, 50, 12, 14),
              decoration: BoxDecoration(
                color: PipoColors.surface,
                borderRadius: BorderRadius.circular(PipoRadius.xl),
                boxShadow: PipoShadows.md,
              ),
              child: Column(
                children: [
                  // Name
                  Text(
                    idol.stageName,
                    style: PipoTypography.titleMedium.copyWith(
                      color: PipoColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Group name or category
                  Text(
                    idol.groupName ?? idol.category ?? '',
                    style: PipoTypography.caption.copyWith(
                      color: PipoColors.textTertiary,
                    ),
                    maxLines: 1,
                  ),
                  const Spacer(),
                  // Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: PipoColors.backgroundAlt,
                      borderRadius: BorderRadius.circular(PipoRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_rounded,
                            color: PipoColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _formatCompact(idol.totalSupport),
                          style: PipoTypography.labelSmall.copyWith(
                            color: PipoColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.people_rounded,
                            color: PipoColors.textSecondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _formatCompact(idol.fanCount),
                          style: PipoTypography.labelSmall.copyWith(
                            color: PipoColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Profile image (floating)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: rankGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: rankGradient[0].withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: idol.profileImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: imageColor,
                          child: const Icon(Icons.person,
                              color: Colors.white54, size: 28),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: imageColor,
                          child: const Icon(Icons.person,
                              color: Colors.white54, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Rank badge
            Positioned(
              top: 48,
              right: 20,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: rankGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: rankGradient[0].withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
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
          return _buildFundingCard(context, campaign);
        },
      ),
    );
  }

  Widget _buildFundingCard(BuildContext context, Map<String, dynamic> campaign) {
    final progress =
        (campaign['currentAmount'] as int) / (campaign['goalAmount'] as int);
    final daysLeft =
        DateTime.parse(campaign['endDate']).difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () => context.go('/campaigns/${campaign['id']}'),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: PipoSpacing.md),
        padding: const EdgeInsets.all(PipoSpacing.lg),
        decoration: BoxDecoration(
          color: PipoColors.surface,
          borderRadius: BorderRadius.circular(PipoRadius.xl),
          boxShadow: PipoShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: daysLeft <= 7
                        ? PipoColors.errorLight
                        : PipoColors.primarySoft,
                    borderRadius: BorderRadius.circular(PipoRadius.xs),
                  ),
                  child: Text(
                    daysLeft > 0 ? 'D-$daysLeft' : '마감',
                    style: TextStyle(
                      color: daysLeft <= 7
                          ? PipoColors.error
                          : PipoColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: PipoTypography.titleMedium.copyWith(
                    color: PipoColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PipoSpacing.md),
            // Title
            Text(
              campaign['title'] ?? '',
              style: PipoTypography.titleMedium.copyWith(
                color: PipoColors.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: PipoColors.border,
                valueColor:
                    const AlwaysStoppedAnimation(PipoColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: PipoSpacing.sm),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatCurrency(campaign['currentAmount'])}원',
                  style: PipoTypography.labelMedium.copyWith(
                    color: PipoColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${campaign['supporters']}명 참여',
                  style: PipoTypography.caption.copyWith(
                    color: PipoColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumEvents(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: _buildPremiumCard(
              context,
              icon: Icons.local_cafe_rounded,
              title: '오프회',
              subtitle: '프리미엄 경험',
              gradient: PipoColors.primaryGradient,
              route: '/date-tickets',
            ),
          ),
          const SizedBox(width: PipoSpacing.md),
          Expanded(
            child: _buildPremiumCard(
              context,
              icon: Icons.airplane_ticket_rounded,
              title: 'VIP 오프회',
              subtitle: '프리미엄 경험',
              gradient: PipoColors.premiumGradient,
              route: '/date-tickets',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go(route);
      },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(PipoSpacing.lg),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(PipoRadius.xl),
          boxShadow: PipoShadows.primaryGlow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(PipoRadius.md),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: PipoTypography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: PipoTypography.caption.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
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
          } catch (_) {}

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
