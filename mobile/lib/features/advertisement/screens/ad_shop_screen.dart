import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/advertisement_model.dart';
import '../../../shared/widgets/custom_button.dart';

class AdShopScreen extends ConsumerStatefulWidget {
  const AdShopScreen({super.key});

  @override
  ConsumerState<AdShopScreen> createState() => _AdShopScreenState();
}

class _AdShopScreenState extends ConsumerState<AdShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAdProductList(),
                  _buildAdFundingList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(1.5),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          SizedBox(width: Responsive.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '광고 서포트',
                  style: TextStyle(
                    fontSize: Responsive.sp(22),
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Pretendard',
                  ),
                ),
                Text(
                  '아이돌을 더 빛나게 해주세요',
                  style: TextStyle(
                    fontSize: Responsive.sp(13),
                    color: AppColors.textSecondary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(1),
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppColors.softShadow(),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontSize: Responsive.sp(14),
          fontWeight: FontWeight.w600,
          fontFamily: 'Pretendard',
        ),
        tabs: const [
          Tab(text: '광고 상품'),
          Tab(text: '팬덤 광고 펀딩'),
        ],
      ),
    );
  }

  Widget _buildAdProductList() {
    final products = MockData.adProducts;

    return ListView(
      padding: EdgeInsets.all(Responsive.wp(4)),
      children: [
        // Premium Banner
        _buildPremiumBanner(),
        const SizedBox(height: 16),

        // Product categories
        _buildCategorySection('인기 광고', products.where((p) => p.isPopular).toList()),
        _buildCategorySection('전광판/옥외 광고', products.where((p) =>
          p.type == AdProductType.billboardLarge ||
          p.type == AdProductType.billboardSmall ||
          p.type == AdProductType.subwayAd ||
          p.type == AdProductType.busAd
        ).toList()),
        _buildCategorySection('앱 내 광고', products.where((p) =>
          p.type == AdProductType.appBanner ||
          p.type == AdProductType.appPopup ||
          p.type == AdProductType.homeFeature
        ).toList()),
      ],
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: Responsive.sp(11),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '좋아하는 아이돌을\n전광판에서 만나세요',
                style: TextStyle(
                  fontSize: Responsive.sp(22),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '강남역, 홍대입구, 삼성역 등 주요 지역',
                style: TextStyle(
                  fontSize: Responsive.sp(13),
                  color: Colors.white.withValues(alpha: 0.8),
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '자세히 보기',
                  style: TextStyle(
                    fontSize: Responsive.sp(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<AdProduct> products) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: Responsive.sp(18),
              fontWeight: FontWeight.w700,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
        ...products.map((product) => _buildAdProductCard(product)),
      ],
    );
  }

  Widget _buildAdProductCard(AdProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        children: [
          if (product.sampleImages.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: product.sampleImages.first,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 120,
                  color: AppColors.backgroundAlt,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (product.isPopular)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '인기',
                          style: TextStyle(
                            fontSize: Responsive.sp(10),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: Responsive.sp(13),
                    color: AppColors.textSecondary,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (product.location != null) ...[
                      Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        product.location!,
                        style: TextStyle(
                          fontSize: Responsive.sp(12),
                          color: AppColors.textTertiary,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(Icons.access_time_outlined,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${product.durationDays}일',
                      style: TextStyle(
                        fontSize: Responsive.sp(12),
                        color: AppColors.textTertiary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    if (product.impressions != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.visibility_outlined,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatNumber(product.impressions!)}+',
                        style: TextStyle(
                          fontSize: Responsive.sp(12),
                          color: AppColors.textTertiary,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatPrice(product.price),
                          style: TextStyle(
                            fontSize: Responsive.sp(20),
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        Text(
                          '${product.soldCount}건 판매',
                          style: TextStyle(
                            fontSize: Responsive.sp(11),
                            color: AppColors.textTertiary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showAdPurchaseDialog(product),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '구매하기',
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdFundingList() {
    final fundings = MockData.adFundings;

    return ListView(
      padding: EdgeInsets.all(Responsive.wp(4)),
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.info.withValues(alpha: 0.1),
                AppColors.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.groups_rounded, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '팬덤 광고 펀딩',
                      style: TextStyle(
                        fontSize: Responsive.sp(15),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    Text(
                      '팬들이 모아서 아이돌 생일/기념일 광고를!',
                      style: TextStyle(
                        fontSize: Responsive.sp(12),
                        color: AppColors.textSecondary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        ...fundings.map((funding) => _buildAdFundingCard(funding)),

        // Create funding button
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: CustomButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('팬덤 광고 펀딩 개설 기능 준비 중입니다'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            isOutlined: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  '새 펀딩 개설하기',
                  style: TextStyle(fontSize: Responsive.sp(15)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdFundingCard(AdFunding funding) {
    final progress = funding.progressPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: CachedNetworkImageProvider(
                    funding.targetIdolImage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        funding.title,
                        style: TextStyle(
                          fontSize: Responsive.sp(16),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      Text(
                        '${funding.organizerName} 주최',
                        style: TextStyle(
                          fontSize: Responsive.sp(12),
                          color: AppColors.textSecondary,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: funding.isFunded
                        ? AppColors.successSoft
                        : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    funding.isFunded ? '달성!' : 'D-${funding.daysLeft}',
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      fontWeight: FontWeight.w600,
                      color: funding.isFunded ? AppColors.success : AppColors.primary,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ad preview
          if (funding.adDesignImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: funding.adDesignImage!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign_outlined,
                        size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      funding.adType.displayName,
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        color: AppColors.textSecondary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    if (funding.adLocation != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        funding.adLocation!,
                        style: TextStyle(
                          fontSize: Responsive.sp(13),
                          color: AppColors.textSecondary,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Progress
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: Responsive.sp(18),
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        Text(
                          '${_formatPrice(funding.currentAmount)} / ${_formatPrice(funding.goalAmount)}',
                          style: TextStyle(
                            fontSize: Responsive.sp(13),
                            color: AppColors.textSecondary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.backgroundAlt,
                        valueColor: AlwaysStoppedAnimation(
                          funding.isFunded ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${funding.supporterCount}명 참여',
                          style: TextStyle(
                            fontSize: Responsive.sp(12),
                            color: AppColors.textTertiary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        Text(
                          '${funding.daysLeft}일 남음',
                          style: TextStyle(
                            fontSize: Responsive.sp(12),
                            color: AppColors.textTertiary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                GradientButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('펀딩 참여 페이지로 이동합니다'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  height: 48,
                  child: Text(
                    '펀딩 참여하기',
                    style: TextStyle(fontSize: Responsive.sp(14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAdPurchaseDialog(AdProduct product) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: Responsive.hp(60),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: Responsive.sp(22),
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        color: AppColors.textSecondary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('게재 기간', '${product.durationDays}일'),
                          const SizedBox(height: 8),
                          if (product.location != null)
                            _buildInfoRow('위치', product.location!),
                          if (product.impressions != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow('예상 노출', '${_formatNumber(product.impressions!)}+회'),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (product.requirements.isNotEmpty) ...[
                      Text(
                        '광고 소재 요구사항',
                        style: TextStyle(
                          fontSize: Responsive.sp(14),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...product.requirements.map((req) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 16, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text(
                              req,
                              style: TextStyle(
                                fontSize: Responsive.sp(13),
                                color: AppColors.textSecondary,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '결제 금액',
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            color: AppColors.textSecondary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        Text(
                          _formatPrice(product.price),
                          style: TextStyle(
                            fontSize: Responsive.sp(24),
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('광고 구매 신청이 완료되었습니다'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      height: 54,
                      child: Text(
                        '구매 신청하기',
                        style: TextStyle(fontSize: Responsive.sp(16)),
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(13),
            color: AppColors.textSecondary,
            fontFamily: 'Pretendard',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    if (price >= 100000000) {
      return '${(price / 100000000).toStringAsFixed(0)}억원';
    } else if (price >= 10000) {
      return '${(price / 10000).toStringAsFixed(0)}만원';
    }
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(0)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
