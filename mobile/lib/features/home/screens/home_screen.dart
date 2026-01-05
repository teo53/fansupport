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

/// 🏠 PIPO - Bubble Style Home Screen (Complete Edition)
/// 모든 필수 기능 포함 + 토스/당근처럼 깔끔한 UI
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ============================================
              // 📌 Header (안녕하세요 + 알림)
              // ============================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.wp(6),
                    Responsive.wp(4),
                    Responsive.wp(6),
                    Responsive.wp(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '안녕하세요',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user?.nickname ?? '게스트',
                              style: TextStyle(
                                fontSize: 32, // Bubble style - 더 크게
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notification + Search Buttons
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundAlt,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppColors.softShadow(opacity: 0.02),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(16),
                                child: Icon(
                                  Icons.search_rounded,
                                  color: AppColors.textPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundAlt,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppColors.softShadow(opacity: 0.02),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(16),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.textPrimary,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ============================================
              // 🌟 Story Section (Live Idols)
              // ============================================
              SliverToBoxAdapter(
                child: SizedBox(
                  height: Responsive.hp(14),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: MockData.idolModels.length,
                    separatorBuilder: (context, index) => SizedBox(width: Responsive.wp(4)),
                    itemBuilder: (context, index) {
                      final idol = MockData.idolModels[index];
                      final isLive = index == 0; // Mock: first idol is live
                      return StoryCircle(
                        idol: idol,
                        isLive: isLive,
                        onTap: () {
                          if (isLive) {
                            _showLiveComingSoonDialog(context, idol);
                          } else {
                            context.go('/home/idols/${idol.id}');
                          }
                        },
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ============================================
              // 🎯 Quick Actions (멤버십, Bubble, 피드, 스케줄)
              // ============================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAction(
                        context,
                        icon: Icons.star_rounded,
                        label: '멤버십',
                        color: const Color(0xFF6B4DFF),
                        onTap: () => context.go('/home/idols'),
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.chat_bubble_rounded,
                        label: 'Bubble',
                        color: AppColors.primary,
                        onTap: () => context.go('/bubble'),
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.feed_rounded,
                        label: '피드',
                        color: const Color(0xFFFF8E87),
                        onTap: () => context.go('/community'),
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: '스케줄',
                        color: const Color(0xFF00C853),
                        onTap: () => context.go('/booking'),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ============================================
              // 🌟 Section Header (인기 아이돌)
              // ============================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            '인기 아이돌',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'HOT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.go('/home/idols'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '전체보기',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                letterSpacing: -0.1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ============================================
              // 🎨 Hot Idols Photocard List (Horizontal Scroll)
              // ============================================
              SliverToBoxAdapter(
                child: SizedBox(
                  height: Responsive.hp(38),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
                    itemCount: MockData.idolModels.length > 5 ? 5 : MockData.idolModels.length,
                    itemBuilder: (context, index) {
                      final idol = MockData.idolModels[index];
                      return _buildIdolPhotocard(context, idol, index + 1);
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ============================================
              // 💰 Trending Campaigns (인기 펀딩)
              // ============================================
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  context,
                  '인기 펀딩',
                  '전체보기',
                  onTap: () => context.go('/campaigns'),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: Responsive.hp(28),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
                    itemCount: MockData.campaigns.length > 3 ? 3 : MockData.campaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = MockData.campaigns[index];
                      return _buildCampaignCard(context, campaign);
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ============================================
              // 🎫 Premium Services (VIP 팬미팅, 데이트권)
              // ============================================
              SliverToBoxAdapter(
                child: _buildSectionHeader(context, '스페셜 이벤트', null),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: _buildPremiumServices(context),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ============================================
              // 🏷️ Categories (카테고리)
              // ============================================
              SliverToBoxAdapter(
                child: _buildSectionHeader(context, '카테고리', null),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: _buildCategories(context),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ============================================
              // 📰 Recent Community Posts (최근 소식)
              // ============================================
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  context,
                  '최근 소식',
                  '더보기',
                  onTap: () => context.go('/community'),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: _buildRecentPosts(context),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  /// ⚡ Quick Action Button (Bubble Style)
  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: Responsive.wp(16),
            height: Responsive.wp(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20), // Bubble style
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Section Header (Bubble Style)
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String? actionText, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (actionText != null)
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 🎨 Idol Photocard (Bubble Style with Ranking)
  Widget _buildIdolPhotocard(BuildContext context, IdolModel idol, int rank) {
    final imageColor = Color(int.parse(idol.imageColor ?? "0xFFFF7169"));

    return GestureDetector(
      onTap: () => context.go('/home/idols/${idol.id}'),
      child: Container(
        width: Responsive.wp(55),
        margin: EdgeInsets.only(right: Responsive.wp(4)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24), // Bubble style
          boxShadow: AppColors.softShadow(opacity: 0.12),
        ),
        child: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: imageColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: idol.profileImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: imageColor,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: imageColor,
                    child: Icon(
                      Icons.person,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.9),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: imageColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        idol.groupName!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Text(
                    idol.stageName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatNumber(idol.totalSupport)} 서포트',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
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

  /// 💰 Campaign Card (Bubble Style)
  Widget _buildCampaignCard(BuildContext context, Map<String, dynamic> campaign) {
    final progress = (campaign['currentAmount'] as int) / (campaign['goalAmount'] as int);
    final daysLeft = DateTime.parse(campaign['endDate']).difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () => context.go('/campaigns/${campaign['id']}'),
      child: Container(
        width: Responsive.wp(70),
        margin: EdgeInsets.only(right: Responsive.wp(3)),
        padding: const EdgeInsets.all(20), // Bubble style - wider padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Bubble style
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppColors.softShadow(opacity: 0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: daysLeft <= 7 ? AppColors.errorSoft : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    daysLeft > 0 ? 'D-$daysLeft' : '마감',
                    style: TextStyle(
                      color: daysLeft <= 7 ? AppColors.error : AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${(progress * 100).toInt()}% 달성',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              campaign['title'] ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.textPrimary,
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
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatCurrency(campaign['currentAmount'])}원',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${campaign['supporters']}명 참여',
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

  /// 🎫 Premium Services (Bubble Style)
  Widget _buildPremiumServices(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
      child: Column(
        children: [
          // Main Premium Services (VIP 팬미팅, 1:1 영상통화)
          Row(
            children: [
              Expanded(
                child: _buildPremiumCard(
                  context,
                  icon: Icons.airplane_ticket_rounded,
                  title: 'VIP 팬미팅',
                  subtitle: '소수 정예 오프라인 만남',
                  gradient: AppColors.primaryGradient,
                  onTap: () => context.go('/date-tickets'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPremiumCard(
                  context,
                  icon: Icons.videocam_rounded,
                  title: '1:1 영상통화',
                  subtitle: '나만을 위한 응원 메시지',
                  gradient: AppColors.premiumGradient,
                  onTap: () => context.go('/date-tickets'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick Buttons (팬 광고 펀딩, 랭킹, 아이돌 등록)
          Row(
            children: [
              Expanded(
                child: _buildServiceQuickButton(
                  context,
                  icon: Icons.campaign,
                  label: '팬 광고 펀딩',
                  route: '/advertisements',
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceQuickButton(
                  context,
                  icon: Icons.emoji_events,
                  label: '랭킹',
                  route: '/ranking',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceQuickButton(
                  context,
                  icon: Icons.add_circle,
                  label: '아이돌 등록',
                  route: '/home/idols',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎨 Premium Card (Bubble Style)
  Widget _buildPremiumCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: Responsive.hp(21),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24), // Bubble style
          boxShadow: AppColors.glowShadow(AppColors.primary, opacity: 0.12),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
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
                  '자세히 보기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔘 Service Quick Button (Bubble Style)
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
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

  /// 🏷️ Categories (Bubble Style)
  Widget _buildCategories(BuildContext context) {
    final categories = [
      {
        'icon': Icons.mic,
        'label': '지하 아이돌',
        'color': AppColors.idolCategory,
        'value': 'UNDERGROUND_IDOL',
      },
      {
        'icon': Icons.emoji_people,
        'label': '메이드카페',
        'color': AppColors.maidCategory,
        'value': 'MAID_CAFE',
      },
      {
        'icon': Icons.camera_alt,
        'label': '코스플레이어',
        'color': AppColors.cosplayCategory,
        'value': 'COSPLAYER',
      },
      {
        'icon': Icons.smart_display,
        'label': 'VTuber',
        'color': AppColors.vtuberCategory,
        'value': 'VTUBER',
      },
    ];

    return SizedBox(
      height: Responsive.hp(12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/home/idols?category=${cat['value']}');
            },
            child: Container(
              width: Responsive.wp(20),
              margin: EdgeInsets.only(
                right: index != categories.length - 1 ? Responsive.wp(3) : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16), // Bubble style
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: AppColors.softShadow(opacity: 0.03),
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      color: cat['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
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

  /// 📰 Recent Community Posts (Bubble Style)
  Widget _buildRecentPosts(BuildContext context) {
    final posts = MockData.posts.take(3).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(6)),
      child: Column(
        children: posts.map((post) {
          IdolModel? author;
          try {
            author = MockData.idolModels.firstWhere((i) => i.id == post['authorId']);
          } catch (_) {}

          final profileImage = author?.profileImage;
          final stageName = author?.stageName ?? '익명';
          final isVerified = author?.isVerified ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18), // Bubble style - wider padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Bubble style
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: AppColors.softShadow(opacity: 0.03),
            ),
            child: Row(
              children: [
                // Profile Image
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14), // Bubble style
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: profileImage != null
                        ? CachedNetworkImage(
                            imageUrl: profileImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            stageName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (isVerified)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post['content'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 🔔 라이브 기능 준비 중 다이얼로그 (Coming Soon)
  void _showLiveComingSoonDialog(BuildContext context, IdolModel idol) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28), // Bubble style
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with Gradient Background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF9500),
                      const Color(0xFFFFCC00),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9500).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                '라이브 기능 준비 중',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                '${idol.stageName}님과 실시간으로 소통할 수 있는\n라이브 스트리밍 기능을 준비하고 있습니다.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Features Preview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '출시 예정 기능',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.videocam_rounded, '실시간 영상 스트리밍'),
                    const SizedBox(height: 8),
                    _buildFeatureItem(Icons.chat_bubble_rounded, '실시간 채팅'),
                    const SizedBox(height: 8),
                    _buildFeatureItem(Icons.favorite_rounded, '하트 & 선물 보내기'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () => Navigator.pop(context),
                      text: '닫기',
                      height: 52,
                      isOutlined: true,
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GradientButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.notifications_active_rounded, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '라이브 기능 출시 시 알려드리겠습니다!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      text: '알림 받기',
                      height: 52,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF9500),
                          const Color(0xFFFFCC00),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📋 Feature Item
  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
