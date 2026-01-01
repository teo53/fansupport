import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/date_ticket_model.dart';
import '../../../shared/widgets/custom_button.dart';

class DateTicketScreen extends ConsumerStatefulWidget {
  const DateTicketScreen({super.key});

  @override
  ConsumerState<DateTicketScreen> createState() => _DateTicketScreenState();
}

class _DateTicketScreenState extends ConsumerState<DateTicketScreen> {
  DateTicketType? _selectedType;

  List<DateTicketProduct> get _filteredProducts {
    if (_selectedType == null) {
      return MockData.dateTicketProducts;
    }
    return MockData.dateTicketProducts
        .where((p) => p.type == _selectedType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildInfoBanner(),
            _buildTypeFilter(),
            _buildProductList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Container(
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
                    '데이트권',
                    style: TextStyle(
                      fontSize: Responsive.sp(22),
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  Text(
                    '좋아하는 아이돌과 특별한 시간을',
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
      ),
    );
  }

  Widget _buildInfoBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(Responsive.wp(4)),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.neonPink.withOpacity(0.1),
              AppColors.neonPurple.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonPink.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.neonGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '프리미엄 데이트',
                        style: TextStyle(
                          fontSize: Responsive.sp(18),
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      Text(
                        '아이돌과 1:1 특별한 만남',
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.restaurant_rounded, '식사 데이트', '150만원~'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.local_cafe_rounded, '카페 데이트', '100만원~'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '※ 매니저 동행, 촬영/녹음 금지, 신분증 확인 필수',
              style: TextStyle(
                fontSize: Responsive.sp(11),
                color: AppColors.textTertiary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String price) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
          ),
        ),
        const Spacer(),
        Text(
          price,
          style: TextStyle(
            fontSize: Responsive.sp(14),
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
        child: Row(
          children: [
            _buildFilterChip(null, '전체'),
            const SizedBox(width: 8),
            _buildFilterChip(DateTicketType.meal, '식사 데이트'),
            const SizedBox(width: 8),
            _buildFilterChip(DateTicketType.cafe, '카페 데이트'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(DateTicketType? type, String label) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(13),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    final products = _filteredProducts;

    return SliverPadding(
      padding: EdgeInsets.all(Responsive.wp(4)),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(DateTicketProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with idol info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: CachedNetworkImageProvider(product.idolProfileImage),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            product.idolName,
                            style: TextStyle(
                              fontSize: Responsive.sp(17),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.verified, size: 18, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: product.type == DateTicketType.meal
                              ? AppColors.warning.withOpacity(0.1)
                              : AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.type == DateTicketType.meal
                                  ? Icons.restaurant_rounded
                                  : Icons.local_cafe_rounded,
                              size: 14,
                              color: product.type == DateTicketType.meal
                                  ? AppColors.warning
                                  : AppColors.info,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.type.displayName,
                              style: TextStyle(
                                fontSize: Responsive.sp(12),
                                fontWeight: FontWeight.w600,
                                color: product.type == DateTicketType.meal
                                    ? AppColors.warning
                                    : AppColors.info,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                      '${product.duration}분',
                      style: TextStyle(
                        fontSize: Responsive.sp(12),
                        color: AppColors.textSecondary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              product.description,
              style: TextStyle(
                fontSize: Responsive.sp(14),
                color: AppColors.textSecondary,
                height: 1.4,
                fontFamily: 'Pretendard',
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Include items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: product.includeItems.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: Responsive.sp(12),
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Details
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.location_on_outlined,
                  '지역',
                  product.location,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.calendar_today_outlined,
                  '가능 요일',
                  product.availableDays.join(', '),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.access_time_outlined,
                  '가능 시간',
                  '${product.availableTimeStart ?? '-'} ~ ${product.availableTimeEnd ?? '-'}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.event_available_outlined,
                  '잔여',
                  '${product.remainingSlots}/${product.maxMonthlyCount}회 (이번 달)',
                  isHighlight: product.remainingSlots <= 1,
                ),
              ],
            ),
          ),

          // Notice
          if (product.notice != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      product.notice!,
                      style: TextStyle(
                        fontSize: Responsive.sp(11),
                        color: AppColors.textTertiary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: GradientButton(
              onPressed: product.isAvailable
                  ? () => _showPurchaseDialog(product)
                  : null,
              height: 50,
              child: Text(
                product.isAvailable ? '예약하기' : '예약 마감',
                style: TextStyle(fontSize: Responsive.sp(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(12),
            color: AppColors.textSecondary,
            fontFamily: 'Pretendard',
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.sp(13),
            fontWeight: FontWeight.w600,
            color: isHighlight ? AppColors.error : AppColors.textPrimary,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  void _showPurchaseDialog(DateTicketProduct product) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: Responsive.hp(70),
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
                      '예약 확인',
                      style: TextStyle(
                        fontSize: Responsive.sp(22),
                        fontWeight: FontWeight.w800,
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: CachedNetworkImageProvider(
                              product.idolProfileImage,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.idolName,
                                  style: TextStyle(
                                    fontSize: Responsive.sp(18),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                                Text(
                                  product.type.displayName,
                                  style: TextStyle(
                                    fontSize: Responsive.sp(14),
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
                    const SizedBox(height: 16),
                    _buildPriceRow('상품 금액', product.price),
                    const SizedBox(height: 8),
                    _buildPriceRow('플랫폼 수수료', (product.price * 0.1).toInt()),
                    const Divider(height: 24),
                    _buildPriceRow(
                      '총 결제 금액',
                      (product.price * 1.1).toInt(),
                      isTotal: true,
                    ),
                    const Spacer(),
                    Text(
                      '※ 예약 후 아이돌 승인 시 결제가 진행됩니다\n※ 일정 확정 후 취소 시 환불 불가',
                      style: TextStyle(
                        fontSize: Responsive.sp(12),
                        color: AppColors.textTertiary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('예약 요청이 접수되었습니다'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      height: 54,
                      child: Text(
                        '예약 요청하기',
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

  Widget _buildPriceRow(String label, int price, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(isTotal ? 16 : 14),
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontFamily: 'Pretendard',
          ),
        ),
        Text(
          _formatPrice(price),
          style: TextStyle(
            fontSize: Responsive.sp(isTotal ? 20 : 14),
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    if (price >= 10000) {
      final man = price ~/ 10000;
      final remainder = price % 10000;
      if (remainder == 0) {
        return '${man}만원';
      } else {
        return '$man만 ${remainder ~/ 1000}천원';
      }
    }
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }
}
