import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/idol_model.dart';
import '../../../shared/widgets/custom_button.dart';

class IdolDetailScreen extends ConsumerWidget {
  final String idolId;

  const IdolDetailScreen({super.key, required this.idolId});

  IdolModel? _findIdol() {
    try {
      return MockData.idolModels.firstWhere((idol) => idol.id == idolId);
    } catch (e) {
      if (MockData.idolModels.isNotEmpty) {
        return MockData.idolModels.first;
      }
      return null;
    }
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

    // Parse idol image color for dynamic theming
    final idolColor =
        AppColors.fromHex(idol.imageColor, defaultColor: AppColors.primary);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Image
          SliverAppBar(
            expandedHeight: Responsive.hp(35),
            pinned: true,
            backgroundColor: idolColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: idol.profileImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: idolColor.withValues(alpha: 0.2),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.background,
                      child: Center(
                          child: Icon(Icons.error, color: AppColors.error)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share_rounded,
                    size: Responsive.sp(22), color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.more_vert_rounded,
                    size: Responsive.sp(22), color: Colors.white),
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
                      border: Border.all(color: AppColors.background, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: Responsive.wp(16),
                      backgroundColor: AppColors.background,
                      backgroundImage:
                          CachedNetworkImageProvider(idol.profileImage),
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),

                  // Name & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        idol.stageName,
                        style: TextStyle(
                          fontSize: Responsive.sp(26),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (idol.isVerified) ...[
                        SizedBox(width: Responsive.wp(1.5)),
                        Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: Responsive.sp(22),
                        ),
                      ],
                    ],
                  ),
                  if (idol.groupName != null) ...[
                    SizedBox(height: 4),
                    Text(
                      idol.groupName!,
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(height: Responsive.hp(2.5)),

                  // Stats Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(8)),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: Responsive.hp(2)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow(opacity: 0.05),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat(context, '${idol.supporterCount}', '팔로워',
                              idolColor),
                          Container(
                            width: 1,
                            height: Responsive.hp(4),
                            color: AppColors.border,
                          ),
                          _buildStat(
                              context, '${idol.ranking}위', '현재 순위', idolColor),
                          Container(
                            width: 1,
                            height: Responsive.hp(4),
                            color: AppColors.border,
                          ),
                          _buildStat(
                              context,
                              'Lv.${(idol.totalSupport / 100000).floor() + 1}',
                              '레벨', // Simplified label
                              idolColor),
                        ],
                      ),
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
                            onPressed: () => context.go('/support/${idol.id}'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_rounded,
                                    color: Colors.white,
                                    size: Responsive.sp(20)),
                                SizedBox(width: Responsive.wp(2)),
                                Text(
                                  '후원하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
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
                              // Follow Logic (Toggle)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('아이돌을 팔로우했습니다!')),
                              );
                            },
                            isOutlined: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star_outline_rounded,
                                    size: Responsive.sp(20),
                                    color: AppColors.textPrimary),
                                SizedBox(width: Responsive.wp(2)),
                                Text(
                                  '팔로우',
                                  style: TextStyle(
                                      fontSize: Responsive.sp(15),
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.hp(4)),

                  // Membership Benefits
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '멤버십 등급 혜택',
                          style: TextStyle(
                            fontSize: Responsive.sp(18),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: Responsive.hp(2)),
                        _buildBenefitTier(
                          context,
                          name: '브론즈 팬',
                          benefits: ['독점 게시물 열람', '월간 인사 메시지'],
                          color: AppColors.bronze,
                        ),
                        SizedBox(height: Responsive.hp(1.5)),
                        _buildBenefitTier(
                          context,
                          name: '실버 팬',
                          benefits: [
                            '브론즈 혜택 전체',
                            '라이브 방송 참여',
                            '팬미팅 우선권',
                          ],
                          color: AppColors.silver,
                        ),
                        SizedBox(height: Responsive.hp(1.5)),
                        _buildBenefitTier(
                          context,
                          name: '골드 팬',
                          benefits: [
                            '실버 혜택 전체',
                            '1:1 영상 메시지',
                            '사인 굿즈 증정',
                          ],
                          color: AppColors.gold,
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.hp(2)),

                  // Top Supporters
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '베스트 서포터',
                              style: TextStyle(
                                fontSize: Responsive.sp(18),
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                '전체 보기',
                                style: TextStyle(
                                    fontSize: Responsive.sp(13),
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.hp(1)),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppColors.cardShadow(opacity: 0.05),
                          ),
                          padding: EdgeInsets.all(Responsive.wp(4)),
                          child: Column(
                            children: List.generate(
                              3,
                              (index) => _buildSupporterItem(context, index),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildBenefitTier(
    BuildContext context, {
    required String name,
    required List<String> benefits,
    required Color color,
    bool isHighlight = false,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isHighlight ? color : Colors.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isHighlight
            ? [
                BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 4))
              ]
            : AppColors.cardShadow(opacity: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star_rounded, color: color, size: 18),
              ),
              SizedBox(width: 12),
              Text(
                name,
                style: TextStyle(
                  fontSize: Responsive.sp(16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isHighlight) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '추천',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: Responsive.hp(1.5)),
          ...benefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: color),
                    SizedBox(width: 8),
                    Text(
                      benefit,
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStat(
      BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(18),
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        SizedBox(height: Responsive.hp(0.5)),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(12),
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSupporterItem(BuildContext context, int index) {
    final medals = [
      Icons.looks_one_rounded,
      Icons.looks_two_rounded,
      Icons.looks_3_rounded
    ];
    final colors = [AppColors.gold, AppColors.silver, AppColors.bronze];
    final names = ['최고의팬', '열정서포터', '응원단장'];

    return Padding(
      padding: EdgeInsets.only(bottom: index == 2 ? 0 : Responsive.hp(1.5)),
      child: Row(
        children: [
          Icon(medals[index], color: colors[index], size: Responsive.sp(28)),
          SizedBox(width: Responsive.wp(3)),
          CircleAvatar(
            radius: Responsive.wp(5),
            backgroundColor: AppColors.backgroundAlt,
            backgroundImage: CachedNetworkImageProvider(
              'https://i.pravatar.cc/100?img=${index + 10}',
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'VIP ${index + 1}등급',
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
