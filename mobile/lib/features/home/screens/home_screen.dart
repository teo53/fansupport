import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/idol_model.dart';
import '../../../shared/widgets/story_circle.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatCompact(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Background Gradient
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 200,
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Custom App Bar
                    SliverToBoxAdapter(
                      child: _buildHeader(context, user),
                    ),

                    // Hero Banner
                    SliverToBoxAdapter(
                      child: _buildHeroBanner(context),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(height: Responsive.hp(1.5)),
                    ),

                    // Story Section
                    SliverToBoxAdapter(
                      child: _buildStorySection(context),
                    ),

                    // Quick Actions
                    SliverToBoxAdapter(
                      child: _buildQuickActions(context),
                    ),

                    // Hot Idols Section (Rising Star)
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        context,
                        'Rising Star',
                        '랭킹 보기',
                        onTap: () => context.go('/ranking'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildHotIdolsList(context),
                    ),

                    // Trending Campaigns
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        context,
                        '인기 펀딩',
                        '전체보기',
                        onTap: () => context.go('/campaigns'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildCampaignsList(context),
                    ),

                    // Special Events
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(context, '스페셜 이벤트', null),
                    ),
                    SliverToBoxAdapter(
                      child: _buildPremiumServices(context),
                    ),

                    // Categories
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(context, '카테고리', null),
                    ),
                    SliverToBoxAdapter(
                      child: _buildCategories(context),
                    ),

                    // Recent Posts
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        context,
                        '최근 소식',
                        '더보기',
                        onTap: () => context.go('/community'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildRecentPosts(context),
                    ),

                    // Bottom Spacing
                    SliverToBoxAdapter(
                      child: SizedBox(height: Responsive.hp(12)),
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

  Widget _buildHeader(BuildContext context, user) {
    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Responsive.wp(5),
          Responsive.hp(6),
          Responsive.wp(5),
          Responsive.hp(2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '안녕하세요,',
                  style: TextStyle(
                    fontSize: Responsive.sp(14),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Responsive.hp(0.5)),
                Row(
                  children: [
                    Text(
                      user?.nickname ?? '팬',
                      style: TextStyle(
                        fontSize: Responsive.sp(24),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '님',
                      style: TextStyle(
                        fontSize: Responsive.sp(24),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                _buildHeaderButton(
                  icon: Icons.notifications_none_rounded,
                  badge: 3,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('알림 센터는 준비 중입니다')),
                    );
                  },
                ),
                SizedBox(width: Responsive.wp(2)),
                _buildHeaderButton(
                  icon: Icons.search_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('검색 기능은 준비 중입니다')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
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
        width: Responsive.wp(11),
        height: Responsive.wp(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.cardShadow(opacity: 0.06),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: Responsive.sp(22), color: AppColors.textPrimary),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.sp(9),
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

  Widget _buildHeroBanner(BuildContext context) {
    // Mock Banner Data
    final banners = [
      {
        'title': 'Angel Number 999',
        'subtitle': 'Live Concert Coming Soon',
        'image':
            'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?q=80&w=2070&auto=format&fit=crop',
        'color': const Color(0xFF6B4DFF),
      },
      {
        'title': 'New Generation',
        'subtitle': 'Find Your Favorite Idol',
        'image':
            'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=2070&auto=format&fit=crop',
        'color': const Color(0xFFFF4D8D),
      },
    ];

    return SizedBox(
      height: Responsive.hp(22),
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        physics: const BouncingScrollPhysics(),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: Responsive.wp(1.5)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: NetworkImage(banner['image'] as String),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: (banner['color'] as Color).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Responsive.wp(5)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (banner['color'] as Color),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Featured',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.sp(10),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.hp(1)),
                      Text(
                        banner['title'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.sp(22),
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        banner['subtitle'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: Responsive.sp(13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStorySection(BuildContext context) {
    final idols = MockData.idolModels;

    return SizedBox(
      height: Responsive.hp(14),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: Responsive.wp(5)),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: idols.length,
        separatorBuilder: (context, index) => SizedBox(width: Responsive.wp(4)),
        itemBuilder: (context, index) {
          final idol = idols[index];
          // Mocking the first idol as 'Live'
          final isLive = index == 0;

          return StoryCircle(
            idol: idol,
            isLive: isLive,
            onTap: () {
              if (isLive) {
                _showLiveScreen(context, idol);
              } else {
                _showStoryView(context, idol);
              }
            },
          );
        },
      ),
    );
  }

  void _showLiveScreen(BuildContext context, IdolModel idol) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IncomingCallScreen(idol: idol),
        fullscreenDialog: true,
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
              // Story Image
              Container(
                color: Colors.black,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: idol.profileImage,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: AppColors.fromHex(idol.imageColor),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.fromHex(idol.imageColor),
                      child: const Center(
                        child:
                            Icon(Icons.person, color: Colors.white54, size: 80),
                      ),
                    ),
                  ),
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.2, 0.8],
                    ),
                  ),
                ),
              ),
              // UI Layer
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                          const SizedBox(width: 8),
                          Text(
                            '1시간 전',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
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
                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(20.0),
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
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
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

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.star_rounded,
        'label': '멤버십',
        'color': const Color(0xFF6B4DFF),
        'onTap': () => context.go('/membership'),
      },
      {
        'icon': Icons.chat_bubble_rounded, // Bubble Icon
        'label': 'Bubble',
        'color': const Color(0xFFFF4D8D), // Bubble Pink
        'onTap': () {
          // Mock navigation to first idol's chat
          final firstIdol = MockData.idolModels.first;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(idol: firstIdol),
            ),
          );
        },
      },
      {
        'icon': Icons.feed_rounded,
        'label': '피드',
        'color': AppColors.primary,
        'onTap': () => context.go('/community'),
      },
      {
        'icon': Icons.calendar_today_rounded,
        'label': '스케줄',
        'color': const Color(0xFF00C853),
        'onTap': () => context.go('/schedule'),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              (action['onTap'] as VoidCallback)();
            },
            child: Column(
              children: [
                Container(
                  width: Responsive.wp(16),
                  height: Responsive.wp(16),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color)
                        .withAlpha(25), // 0.1 opacity approx
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: action['color'] as Color,
                    size: Responsive.sp(26),
                  ),
                ),
                SizedBox(height: Responsive.hp(1)),
                Text(
                  action['label'] as String,
                  style: TextStyle(
                    fontSize: Responsive.sp(12),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String? actionText, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.wp(5),
        Responsive.hp(2),
        Responsive.wp(5),
        Responsive.hp(1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.sp(20),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    actionText,
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: Responsive.sp(18),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHotIdolsList(BuildContext context) {
    // Use idolModels instead of idols
    final idols = MockData.idolModels.take(5).toList();

    return SizedBox(
      height: Responsive.hp(38), // Taller for Photocard style
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding:
            EdgeInsets.symmetric(horizontal: Responsive.wp(5), vertical: 10),
        itemCount: idols.length,
        itemBuilder: (context, index) {
          final idol = idols[index];
          return _buildIdolPhotocard(context, idol, index + 1);
        },
      ),
    );
  }

  Widget _buildIdolPhotocard(BuildContext context, IdolModel idol, int rank) {
    final imageColor =
        AppColors.fromHex(idol.imageColor, defaultColor: AppColors.primary);

    return GestureDetector(
      onTap: () => context.go('/idols/${idol.id}'),
      child: Container(
        width: Responsive.wp(55), // Wider card
        margin: EdgeInsets.only(right: Responsive.wp(4)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.elevatedShadow(opacity: 0.15),
          image: DecorationImage(
            image: NetworkImage(idol.profileImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 0.8, 1.0],
                ),
              ),
            ),

            // Rank Badge (Glassmorphism)
            Positioned(
              top: 12,
              left: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#$rank',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.sp(14),
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Idol Info
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (idol.groupName != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: imageColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        idol.groupName!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.sp(10),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Text(
                    idol.stageName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.sp(22),
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.favorite, color: AppColors.error, size: 14),
                      SizedBox(width: 4),
                      Text(
                        _formatCompact(idol.totalSupport),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: Responsive.sp(13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignsList(BuildContext context) {
    final campaigns = MockData.campaigns.take(3).toList();

    return SizedBox(
      height: Responsive.hp(28),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding:
            EdgeInsets.symmetric(horizontal: Responsive.wp(5), vertical: 10),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaigns[index];
          return _buildCampaignCard(context, campaign);
        },
      ),
    );
  }

  Widget _buildCampaignCard(
      BuildContext context, Map<String, dynamic> campaign) {
    final progress =
        (campaign['currentAmount'] as int) / (campaign['goalAmount'] as int);
    final daysLeft =
        DateTime.parse(campaign['endDate']).difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () => context.go('/campaigns/${campaign['id']}'),
      child: Container(
        width: Responsive.wp(70),
        margin: EdgeInsets.only(right: Responsive.wp(3)),
        padding: EdgeInsets.all(Responsive.wp(4)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow(opacity: 0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.wp(2.5),
                    vertical: Responsive.hp(0.5),
                  ),
                  decoration: BoxDecoration(
                    color: daysLeft <= 7
                        ? AppColors.errorSoft
                        : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    daysLeft > 0 ? 'D-$daysLeft' : '마감',
                    style: TextStyle(
                      color:
                          daysLeft <= 7 ? AppColors.error : AppColors.primary,
                      fontSize: Responsive.sp(11),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: Responsive.wp(2)),
                Expanded(
                  child: Text(
                    '${(progress * 100).toInt()}% 달성',
                    style: TextStyle(
                      fontSize: Responsive.sp(11),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.hp(1.5)),
            Text(
              campaign['title'] ?? '',
              style: TextStyle(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),
            SizedBox(height: Responsive.hp(1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatCurrency(campaign['currentAmount'])}원',
                  style: TextStyle(
                    fontSize: Responsive.sp(14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${campaign['supporters']}명 참여',
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
    );
  }

  Widget _buildPremiumServices(BuildContext context) {
    final services = [
      {
        'icon': Icons.calendar_month_rounded,
        'title': '겐바 캘린더',
        'subtitle': '라이브/오프회 일정 확인',
        'price': '일정 보기',
        'route': '/calendar',
        'gradient': AppColors.primaryGradient,
      },
      {
        'icon': Icons.campaign_rounded,
        'title': '광고 홍보',
        'subtitle': '겐바/아이돌 홍보하기',
        'price': '신청하기',
        'route': '/advertising',
        'gradient': AppColors.premiumGradient,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(5)),
      child: Column(
        children: [
          Row(
            children: services.map((service) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go(service['route'] as String);
                  },
                  child: Container(
                    height: Responsive.hp(21),
                    margin: EdgeInsets.only(
                      right: service == services.first ? Responsive.wp(3) : 0,
                    ),
                    padding: EdgeInsets.all(Responsive.wp(5)),
                    decoration: BoxDecoration(
                      gradient: service['gradient'] as LinearGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.glowShadow(AppColors.primary,
                          opacity: 0.15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                service['icon'] as IconData,
                                color: Colors.white,
                                size: Responsive.sp(20),
                              ),
                            ),
                            SizedBox(height: Responsive.hp(2)),
                            Text(
                              service['title'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.sp(16),
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Responsive.hp(0.8)),
                            Text(
                              service['subtitle'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: Responsive.sp(12),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '진행중인 이벤트 보기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.sp(12),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: Responsive.sp(12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: Responsive.hp(3)),
          Row(
            children: [
              Expanded(
                child: _buildServiceQuickButton(
                  context,
                  icon: Icons.campaign,
                  label: '팬 광고 펀딩',
                  route: '/ad-shop',
                  color: AppColors.gold,
                ),
              ),
              SizedBox(width: Responsive.wp(3)),
              Expanded(
                child: _buildServiceQuickButton(
                  context,
                  icon: Icons.emoji_events,
                  label: '랭킹',
                  route: '/ranking',
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(width: Responsive.wp(3)),
              Expanded(
                child: _buildServiceQuickButton(
                  context,
                  icon: Icons.add_circle,
                  label: '아이돌 등록',
                  route: '/crm/register-idol',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceQuickButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go(route);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(1.5),
          vertical: Responsive.hp(1.5),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: Responsive.sp(22)),
            SizedBox(height: Responsive.hp(0.5)),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: Responsive.sp(10),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {
        'icon': Icons.mic,
        'label': '지하 아이돌',
        'color': AppColors.idolCategory,
        'value': 'UNDERGROUND_IDOL'
      },
      {
        'icon': Icons.emoji_people,
        'label': '메이드카페',
        'color': AppColors.maidCategory,
        'value': 'MAID_CAFE'
      },
      {
        'icon': Icons.camera_alt,
        'label': '코스플레이어',
        'color': AppColors.cosplayCategory,
        'value': 'COSPLAYER'
      },
      {
        'icon': Icons.smart_display,
        'label': 'VTuber',
        'color': AppColors.vtuberCategory,
        'value': 'VTuber'
      },
    ];

    return SizedBox(
      height: Responsive.hp(12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Responsive.wp(5)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => context.go('/idols?category=${cat['value']}'),
            child: Container(
              width: Responsive.wp(20),
              margin: EdgeInsets.only(
                right: index != categories.length - 1 ? Responsive.wp(3) : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.wp(3)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow(opacity: 0.05),
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      color: cat['color'] as Color,
                      size: Responsive.sp(20),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(1)),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: Responsive.sp(11),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
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

  Widget _buildRecentPosts(BuildContext context) {
    final posts = MockData.posts.take(3).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(5)),
      child: Column(
        children: posts.map((post) {
          IdolModel? author;
          try {
            // Find author in idolModels using id
            author =
                MockData.idolModels.firstWhere((i) => i.id == post['authorId']);
          } catch (_) {}

          // Fallback to searching in generic idols map if not found (backward compatibility)
          // Actually, let's just use idolModels. If not found, it's null.
          final profileImage = author?.profileImage;
          final stageName = author?.stageName ?? '익명';
          final isVerified = author?.isVerified ?? false;

          return Container(
            margin: EdgeInsets.only(bottom: Responsive.hp(1.5)),
            padding: EdgeInsets.all(Responsive.wp(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow(opacity: 0.05),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: Responsive.wp(6),
                  backgroundColor: AppColors.primarySoft,
                  backgroundImage: profileImage != null
                      ? CachedNetworkImageProvider(profileImage)
                      : null,
                  child: profileImage == null
                      ? Icon(Icons.person,
                          color: AppColors.primary, size: Responsive.sp(20))
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
                            stageName,
                            style: TextStyle(
                              fontSize: Responsive.sp(14),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isVerified)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.verified,
                                size: Responsive.sp(14),
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: Responsive.hp(0.3)),
                      Text(
                        post['content'] ?? '',
                        style: TextStyle(
                          fontSize: Responsive.sp(12),
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: Responsive.sp(20),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
