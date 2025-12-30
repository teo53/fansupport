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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() => _scrollOffset = _scrollController.offset);
      });
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
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0),
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
                      AppColors.secondary.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(
                  child: _buildHeader(context, user),
                ),

                // Wallet Card
                SliverToBoxAdapter(
                  child: _buildWalletCard(context, user),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: _buildQuickActions(context),
                ),

                // Hot Idols Section
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    context,
                    'HOT 아이돌',
                    'TOP 10',
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

                // Premium Services
                SliverToBoxAdapter(
                  child: _buildSectionHeader(context, '프리미엄 서비스', null),
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
                  onTap: () {},
                ),
                SizedBox(width: Responsive.wp(2)),
                _buildHeaderButton(
                  icon: Icons.search_rounded,
                  onTap: () {},
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

  Widget _buildWalletCard(BuildContext context, user) {
    final balance = user?.walletBalance ?? 0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(5),
        vertical: Responsive.hp(1),
      ),
      child: GestureDetector(
        onTap: () => context.go('/wallet'),
        child: Container(
          padding: EdgeInsets.all(Responsive.wp(5)),
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: Responsive.sp(20),
                        ),
                      ),
                      SizedBox(width: Responsive.wp(3)),
                      Text(
                        '내 지갑',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: Responsive.sp(15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.wp(3),
                      vertical: Responsive.hp(0.8),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          size: Responsive.sp(16),
                          color: AppColors.primary,
                        ),
                        SizedBox(width: Responsive.wp(1)),
                        Text(
                          '충전',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: Responsive.sp(13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.hp(2.5)),
              Text(
                '${_formatCurrency(balance)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.sp(36),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              Text(
                '원',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: Responsive.sp(18),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.star_rounded, 'label': '아이돌', 'route': '/idols', 'color': AppColors.idolCategory},
      {'icon': Icons.chat_bubble_rounded, 'label': '버블', 'route': '/bubble', 'color': AppColors.neonPink},
      {'icon': Icons.restaurant_rounded, 'label': '데이트권', 'route': '/date-tickets', 'color': AppColors.secondary},
      {'icon': Icons.campaign_rounded, 'label': '광고', 'route': '/ad-shop', 'color': AppColors.gold},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(5),
        vertical: Responsive.hp(2.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go(action['route'] as String);
            },
            child: Column(
              children: [
                Container(
                  width: Responsive.wp(16),
                  height: Responsive.wp(16),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withValues(alpha: 0.1),
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
    final idols = MockData.idols.take(5).toList();

    return SizedBox(
      height: Responsive.hp(22),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Responsive.wp(5)),
        itemCount: idols.length,
        itemBuilder: (context, index) {
          final idol = idols[index];
          return _buildIdolCard(context, idol, index + 1);
        },
      ),
    );
  }

  Widget _buildIdolCard(BuildContext context, Map<String, dynamic> idol, int rank) {
    return GestureDetector(
      onTap: () => context.go('/idols/${idol['id']}'),
      child: Container(
        width: Responsive.wp(35),
        margin: EdgeInsets.only(right: Responsive.wp(3)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow(opacity: 0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: idol['profileImage'] != null
                      ? CachedNetworkImage(
                          imageUrl: idol['profileImage'],
                          height: Responsive.hp(12),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _buildImagePlaceholder(),
                          errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: rank <= 3 ? AppColors.goldGradient : null,
                      color: rank > 3 ? AppColors.textPrimary : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.sp(11),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.wp(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          idol['stageName'] ?? '',
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (idol['isVerified'] ?? false)
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
                    '${_formatCompact(idol['totalReceived'] ?? 0)}원 후원',
                    style: TextStyle(
                      fontSize: Responsive.sp(11),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: Responsive.hp(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.secondary.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: Responsive.sp(30),
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildCampaignsList(BuildContext context) {
    final campaigns = MockData.campaigns.take(3).toList();

    return SizedBox(
      height: Responsive.hp(20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Responsive.wp(5)),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaigns[index];
          return _buildCampaignCard(context, campaign);
        },
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, Map<String, dynamic> campaign) {
    final progress = (campaign['currentAmount'] as int) / (campaign['goalAmount'] as int);
    final daysLeft = DateTime.parse(campaign['endDate']).difference(DateTime.now()).inDays;

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
                    color: daysLeft <= 7 ? AppColors.errorSoft : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    daysLeft > 0 ? 'D-$daysLeft' : '마감',
                    style: TextStyle(
                      color: daysLeft <= 7 ? AppColors.error : AppColors.primary,
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
        'icon': Icons.restaurant,
        'title': '식사 데이트권',
        'subtitle': '아이돌과 함께하는 프리미엄 식사',
        'price': '150만원~',
        'route': '/date-tickets',
        'gradient': AppColors.primaryGradient,
      },
      {
        'icon': Icons.local_cafe,
        'title': '카페 데이트권',
        'subtitle': '아이돌과 티타임',
        'price': '100만원~',
        'route': '/date-tickets',
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
                    margin: EdgeInsets.only(
                      right: service == services.first ? Responsive.wp(2) : 0,
                    ),
                    padding: EdgeInsets.all(Responsive.wp(4)),
                    decoration: BoxDecoration(
                      gradient: service['gradient'] as LinearGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.glowShadow(AppColors.primary, opacity: 0.3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          service['icon'] as IconData,
                          color: Colors.white,
                          size: Responsive.sp(28),
                        ),
                        SizedBox(height: Responsive.hp(1.5)),
                        Text(
                          service['title'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.sp(15),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: Responsive.hp(0.5)),
                        Text(
                          service['subtitle'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: Responsive.sp(11),
                          ),
                        ),
                        SizedBox(height: Responsive.hp(1)),
                        Text(
                          service['price'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.sp(14),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: Responsive.hp(1.5)),
          // Additional service buttons
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
              SizedBox(width: Responsive.wp(2)),
              Expanded(
                child: _buildServiceQuickButton(
                  context,
                  icon: Icons.emoji_events,
                  label: '랭킹',
                  route: '/ranking',
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(width: Responsive.wp(2)),
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
          horizontal: Responsive.wp(3),
          vertical: Responsive.hp(1.5),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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
      {'icon': Icons.mic, 'label': '지하 아이돌', 'color': AppColors.idolCategory, 'value': 'UNDERGROUND_IDOL'},
      {'icon': Icons.emoji_people, 'label': '메이드카페', 'color': AppColors.maidCategory, 'value': 'MAID_CAFE'},
      {'icon': Icons.camera_alt, 'label': '코스플레이어', 'color': AppColors.cosplayCategory, 'value': 'COSPLAYER'},
      {'icon': Icons.smart_display, 'label': 'VTuber', 'color': AppColors.vtuberCategory, 'value': 'VTuber'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(5)),
      child: Row(
        children: categories.map((cat) {
          return Expanded(
            child: GestureDetector(
              onTap: () => context.go('/idols'),
              child: Container(
                margin: EdgeInsets.only(right: cat != categories.last ? Responsive.wp(2) : 0),
                padding: EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.cardShadow(opacity: 0.05),
                ),
                child: Column(
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      color: cat['color'] as Color,
                      size: Responsive.sp(22),
                    ),
                    SizedBox(height: Responsive.hp(0.8)),
                    Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontSize: Responsive.sp(10),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentPosts(BuildContext context) {
    final posts = MockData.posts.take(3).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(5)),
      child: Column(
        children: posts.map((post) {
          Map<String, dynamic>? author;
          try {
            author = MockData.idols.firstWhere((i) => i['id'] == post['authorId']);
          } catch (_) {}

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
                  backgroundImage: author?['profileImage'] != null
                      ? CachedNetworkImageProvider(author!['profileImage'])
                      : null,
                  child: author?['profileImage'] == null
                      ? Icon(Icons.person, color: AppColors.primary, size: Responsive.sp(20))
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
                            author?['stageName'] ?? '익명',
                            style: TextStyle(
                              fontSize: Responsive.sp(14),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (author?['isVerified'] ?? false)
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
