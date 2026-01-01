import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/custom_button.dart';

class IdolDetailScreen extends ConsumerWidget {
  final String idolId;

  const IdolDetailScreen({super.key, required this.idolId});

  Map<String, dynamic>? _findIdol() {
    try {
      return MockData.idols.firstWhere((idol) => idol['id'] == idolId);
    } catch (e) {
      return MockData.idols.first;
    }
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);
    final idol = _findIdol();

    if (idol == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('아이돌을 찾을 수 없습니다')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Image
          SliverAppBar(
            expandedHeight: Responsive.hp(30),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: idol['profileImage'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share, size: Responsive.sp(22)),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.more_vert, size: Responsive.sp(22)),
                onPressed: () {},
              ),
            ],
          ),

          // Profile Section
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -Responsive.hp(5)),
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: Responsive.wp(14),
                      backgroundColor: Colors.white,
                      backgroundImage: CachedNetworkImageProvider(idol['profileImage']),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),

                  // Name & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        idol['stageName'],
                        style: TextStyle(
                          fontSize: Responsive.sp(24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (idol['isVerified']) ...[
                        SizedBox(width: Responsive.wp(2)),
                        Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: Responsive.sp(22),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: Responsive.hp(0.5)),
                  Text(
                    _getCategoryName(idol['category']),
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(3)),

                  // Stats Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(context, '${idol['supporterCount']}', '서포터'),
                        Container(
                          width: 1,
                          height: Responsive.hp(5),
                          color: AppColors.divider,
                        ),
                        _buildStat(context, '￦${_formatAmount(idol['totalSupport'])}', '총 후원'),
                        Container(
                          width: 1,
                          height: Responsive.hp(5),
                          color: AppColors.divider,
                        ),
                        _buildStat(context, '#${idol['ranking']}', '랭킹'),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.hp(3)),

                  // Action Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            onPressed: () => context.go('/support/${idol['id']}'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite, color: Colors.white, size: Responsive.sp(20)),
                                SizedBox(width: Responsive.wp(2)),
                                Text(
                                  '후원하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: Responsive.sp(15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.wp(3)),
                        Expanded(
                          child: CustomButton(
                            onPressed: () {
                              _showSubscriptionModal(context);
                            },
                            isOutlined: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.card_membership, size: Responsive.sp(20)),
                                SizedBox(width: Responsive.wp(2)),
                                Text(
                                  '구독하기',
                                  style: TextStyle(fontSize: Responsive.sp(15)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.hp(4)),

                  // Quick Action Buttons (Date Tickets & Bubble)
                  if (idol['offersMealDate'] == true || idol['offersCafeDate'] == true || idol['hasBubble'] == true)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(Responsive.wp(4)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '프리미엄 서비스',
                                style: TextStyle(
                                  fontSize: Responsive.sp(18),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: Responsive.hp(2)),
                              if (idol['offersMealDate'] == true)
                                _buildServiceButton(
                                  context,
                                  icon: Icons.restaurant,
                                  title: '식사 데이트권',
                                  price: idol['mealDatePrice'] ?? 1500000,
                                  color: AppColors.primary,
                                  onTap: () => context.go('/date-tickets'),
                                ),
                              if (idol['offersCafeDate'] == true) ...[
                                SizedBox(height: Responsive.hp(1.5)),
                                _buildServiceButton(
                                  context,
                                  icon: Icons.local_cafe,
                                  title: '카페 데이트권',
                                  price: idol['cafeDatePrice'] ?? 1000000,
                                  color: AppColors.secondary,
                                  onTap: () => context.go('/date-tickets'),
                                ),
                              ],
                              if (idol['hasBubble'] == true) ...[
                                SizedBox(height: Responsive.hp(1.5)),
                                _buildServiceButton(
                                  context,
                                  icon: Icons.chat_bubble,
                                  title: '버블 구독',
                                  price: idol['bubblePrice'] ?? 4500,
                                  color: AppColors.neonPink,
                                  isMonthly: true,
                                  onTap: () => context.go('/bubble'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (idol['offersMealDate'] == true || idol['offersCafeDate'] == true || idol['hasBubble'] == true)
                    SizedBox(height: Responsive.hp(2)),

                  // Photo Gallery
                  if (idol['galleryImages'] != null && (idol['galleryImages'] as List).isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(Responsive.wp(4)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '포토 갤러리',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(18),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      '전체 보기',
                                      style: TextStyle(fontSize: Responsive.sp(14)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.hp(1.5)),
                              SizedBox(
                                height: Responsive.hp(15),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: (idol['galleryImages'] as List).length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: Responsive.wp(30),
                                      margin: EdgeInsets.only(right: Responsive.wp(2)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: AppColors.softShadow(),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: (idol['galleryImages'] as List)[index],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: AppColors.primarySoft,
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            color: AppColors.primarySoft,
                                            child: const Icon(Icons.image, color: AppColors.primary),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (idol['galleryImages'] != null && (idol['galleryImages'] as List).isNotEmpty)
                    SizedBox(height: Responsive.hp(2)),

                  // Introduction
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(Responsive.wp(4)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '소개',
                              style: TextStyle(
                                fontSize: Responsive.sp(18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.hp(1.5)),
                            Text(
                              idol['description'] ?? '',
                              style: TextStyle(
                                fontSize: Responsive.sp(14),
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: Responsive.hp(2)),
                            Text(
                              idol['bio'] ?? '',
                              style: TextStyle(
                                fontSize: Responsive.sp(13),
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),

                  // SNS Links
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(Responsive.wp(4)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SNS',
                              style: TextStyle(
                                fontSize: Responsive.sp(18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.hp(2)),
                            Wrap(
                              spacing: Responsive.wp(2),
                              runSpacing: Responsive.hp(1),
                              children: [
                                if (idol['twitterUrl'] != null)
                                  _buildSnsButton(
                                    icon: Icons.close,
                                    label: 'Twitter',
                                    url: idol['twitterUrl'],
                                    color: Colors.black,
                                  ),
                                if (idol['instagramUrl'] != null)
                                  _buildSnsButton(
                                    icon: Icons.camera_alt,
                                    label: 'Instagram',
                                    url: idol['instagramUrl'],
                                    color: const Color(0xFFE4405F),
                                  ),
                                if (idol['youtubeUrl'] != null)
                                  _buildSnsButton(
                                    icon: Icons.play_arrow,
                                    label: 'YouTube',
                                    url: idol['youtubeUrl'],
                                    color: const Color(0xFFFF0000),
                                  ),
                                if (idol['tiktokUrl'] != null)
                                  _buildSnsButton(
                                    icon: Icons.music_note,
                                    label: 'TikTok',
                                    url: idol['tiktokUrl'],
                                    color: Colors.black,
                                  ),
                                if (idol['twitterUrl'] == null &&
                                    idol['instagramUrl'] == null &&
                                    idol['youtubeUrl'] == null &&
                                    idol['tiktokUrl'] == null)
                                  Text(
                                    '등록된 SNS가 없습니다',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(13),
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),

                  // Subscription Tiers
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(Responsive.wp(4)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '구독 티어',
                              style: TextStyle(
                                fontSize: Responsive.sp(18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.hp(2)),
                            _buildSubscriptionTier(
                              context,
                              name: '브론즈',
                              price: '5,000',
                              benefits: ['독점 게시물 열람', '월간 인사 메시지'],
                              color: AppColors.bronze,
                            ),
                            SizedBox(height: Responsive.hp(1.5)),
                            _buildSubscriptionTier(
                              context,
                              name: '실버',
                              price: '10,000',
                              benefits: [
                                '브론즈 혜택 전체',
                                '라이브 방송 참여',
                                '팬미팅 우선권',
                              ],
                              color: AppColors.silver,
                            ),
                            SizedBox(height: Responsive.hp(1.5)),
                            _buildSubscriptionTier(
                              context,
                              name: '골드',
                              price: '30,000',
                              benefits: [
                                '실버 혜택 전체',
                                '1:1 영상 메시지',
                                '사인 굿즈 증정',
                              ],
                              color: AppColors.gold,
                              isPopular: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),

                  // Top Supporters
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(Responsive.wp(4)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '탑 서포터',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    '전체 보기',
                                    style: TextStyle(fontSize: Responsive.sp(14)),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.hp(1.5)),
                            ...List.generate(
                              3,
                              (index) => _buildSupporterItem(context, index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    final names = {
      'UNDERGROUND_IDOL': '지하 아이돌',
      'MAID_CAFE': '메이드카페',
      'COSPLAYER': '코스플레이어',
      'VTuber': 'VTuber',
    };
    return names[category] ?? '기타';
  }

  void _showSubscriptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: Responsive.hp(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(Responsive.wp(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: Responsive.wp(10),
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: Responsive.hp(3)),
            Text(
              '구독 티어 선택',
              style: TextStyle(
                fontSize: Responsive.sp(20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.hp(2)),
            Expanded(
              child: ListView(
                children: [
                  _buildSubscriptionOption(context, '브론즈', 5000, AppColors.bronze),
                  SizedBox(height: Responsive.hp(1.5)),
                  _buildSubscriptionOption(context, '실버', 10000, AppColors.silver),
                  SizedBox(height: Responsive.hp(1.5)),
                  _buildSubscriptionOption(context, '골드', 30000, AppColors.gold, isPopular: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOption(BuildContext context, String name, int price, Color color, {bool isPopular = false}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name 구독이 완료되었습니다! (데모)')),
        );
      },
      child: Container(
        padding: EdgeInsets.all(Responsive.wp(4)),
        decoration: BoxDecoration(
          border: Border.all(color: isPopular ? color : AppColors.border),
          borderRadius: BorderRadius.circular(12),
          color: isPopular ? color.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.wp(2)),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.star, color: Colors.white, size: Responsive.sp(18)),
            ),
            SizedBox(width: Responsive.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isPopular) ...[
                        SizedBox(width: Responsive.wp(2)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.wp(2),
                            vertical: Responsive.hp(0.3),
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '인기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.sp(10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '￦${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} /월',
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(18),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: Responsive.hp(0.5)),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(12),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int price,
    required Color color,
    bool isMonthly = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(Responsive.wp(3.5)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.wp(2.5)),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: Responsive.sp(20)),
            ),
            SizedBox(width: Responsive.wp(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.sp(15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_formatAmount(price)}원${isMonthly ? '/월' : ''}',
                    style: TextStyle(
                      fontSize: Responsive.sp(13),
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: Responsive.sp(22)),
          ],
        ),
      ),
    );
  }

  Widget _buildSnsButton({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: Responsive.hp(1.2),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: Responsive.sp(16), color: color),
            SizedBox(width: Responsive.wp(1.5)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(12),
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTier(
    BuildContext context, {
    required String name,
    required String price,
    required List<String> benefits,
    required Color color,
    bool isPopular = false,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      decoration: BoxDecoration(
        border: Border.all(color: isPopular ? color : AppColors.border),
        borderRadius: BorderRadius.circular(12),
        color: isPopular ? color.withOpacity(0.05) : null,
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
                    padding: EdgeInsets.all(Responsive.wp(1.5)),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star, size: Responsive.sp(12), color: Colors.white),
                  ),
                  SizedBox(width: Responsive.wp(2)),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: Responsive.sp(15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isPopular) ...[
                    SizedBox(width: Responsive.wp(2)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.wp(2),
                        vertical: Responsive.hp(0.3),
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '인기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.sp(10),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '￦$price/월',
                style: TextStyle(
                  fontSize: Responsive.sp(15),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.hp(1.5)),
          ...benefits.map(
            (benefit) => Padding(
              padding: EdgeInsets.only(bottom: Responsive.hp(0.5)),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: Responsive.sp(14), color: color),
                  SizedBox(width: Responsive.wp(2)),
                  Text(
                    benefit,
                    style: TextStyle(fontSize: Responsive.sp(13)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupporterItem(BuildContext context, int index) {
    final medals = [Icons.looks_one, Icons.looks_two, Icons.looks_3];
    final colors = [AppColors.gold, AppColors.silver, AppColors.bronze];
    final names = ['최고의팬', '열정서포터', '응원단장'];
    final bgColors = ['FBBF24', '94A3B8', 'F97316'];

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.hp(1.5)),
      child: Row(
        children: [
          Icon(medals[index], color: colors[index], size: Responsive.sp(28)),
          SizedBox(width: Responsive.wp(3)),
          CircleAvatar(
            radius: Responsive.wp(5),
            backgroundImage: CachedNetworkImageProvider(
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(names[index])}&background=${bgColors[index]}&color=fff&size=100&font-size=0.4&rounded=true',
            ),
          ),
          SizedBox(width: Responsive.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  names[index],
                  style: TextStyle(
                    fontSize: Responsive.sp(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '￦${(3 - index) * 100},000',
                  style: TextStyle(
                    fontSize: Responsive.sp(12),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
