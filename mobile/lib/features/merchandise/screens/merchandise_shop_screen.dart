import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/merchandise_model.dart';

class MerchandiseShopScreen extends ConsumerStatefulWidget {
  const MerchandiseShopScreen({super.key});

  @override
  ConsumerState<MerchandiseShopScreen> createState() =>
      _MerchandiseShopScreenState();
}

class _MerchandiseShopScreenState
    extends ConsumerState<MerchandiseShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MerchandiseCategory? _selectedCategory;
  MerchandiseType _selectedType = MerchandiseType.individual;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      appBar: AppBar(
        title: Text(
          '굿즈 샵',
          style: TextStyle(
            fontSize: Responsive.sp(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, size: Responsive.sp(24)),
            onPressed: () {
              // TODO: 장바구니
            },
          ),
          IconButton(
            icon: Icon(Icons.search, size: Responsive.sp(24)),
            onPressed: () {
              // TODO: 검색
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 타입 탭 (개인/그룹/콜라보)
          _buildTypeTab(),

          // 카테고리 필터
          _buildCategoryFilter(),

          // 탭 바 (전체/사전주문/한정판)
          _buildTabBar(),

          // 굿즈 리스트
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMerchandiseList(), // 전체
                _buildMerchandiseList(isPreorder: true), // 사전주문
                _buildMerchandiseList(isLimited: true), // 한정판
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: Responsive.hp(1),
      ),
      color: Colors.white,
      child: Row(
        children: [
          _buildTypeChip('개인', MerchandiseType.individual),
          SizedBox(width: Responsive.wp(2)),
          _buildTypeChip('그룹', MerchandiseType.group),
          SizedBox(width: Responsive.wp(2)),
          _buildTypeChip('콜라보', MerchandiseType.collaboration),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, MerchandiseType type) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: Responsive.hp(1),
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(13),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(vertical: Responsive.hp(1)),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
        itemCount: MerchandiseCategory.values.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip('전체', null);
          }
          final category = MerchandiseCategory.values[index - 1];
          return _buildCategoryChip(category.displayName, category);
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, MerchandiseCategory? category) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        margin: EdgeInsets.only(right: Responsive.wp(2)),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: Responsive.hp(0.8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(12),
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
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
          fontSize: Responsive.sp(13),
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: '전체'),
          Tab(text: '사전주문'),
          Tab(text: '한정판'),
        ],
      ),
    );
  }

  Widget _buildMerchandiseList({
    bool isPreorder = false,
    bool isLimited = false,
  }) {
    // TODO: 실제 데이터 가져오기
    final mockItems = _getMockMerchandise(
      isPreorder: isPreorder,
      isLimited: isLimited,
    );

    if (mockItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: Responsive.hp(2)),
            Text(
              '등록된 굿즈가 없어요',
              style: TextStyle(
                fontSize: Responsive.sp(16),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(Responsive.wp(4)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Responsive.wp(3),
        mainAxisSpacing: Responsive.hp(2),
        childAspectRatio: 0.7,
      ),
      itemCount: mockItems.length,
      itemBuilder: (context, index) {
        return _buildMerchandiseCard(mockItems[index]);
      },
    );
  }

  Widget _buildMerchandiseCard(MerchandiseModel item) {
    return GestureDetector(
      onTap: () {
        // TODO: 상세 페이지
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: item.thumbnailImage,
                    height: Responsive.hp(18),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: Responsive.hp(18),
                      color: AppColors.backgroundAlt,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: Responsive.sp(40),
                          color: AppColors.border,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: Responsive.hp(18),
                      color: AppColors.backgroundAlt,
                      child: Icon(Icons.broken_image),
                    ),
                  ),
                ),

                // 배지
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                      if (item.isLimitedEdition)
                        _buildBadge('한정판', AppColors.error),
                      if (item.isPreorder)
                        _buildBadge('사전주문', AppColors.warning),
                      if (item.isOnSale)
                        _buildBadge('${item.discountRate}%', AppColors.success),
                    ],
                  ),
                ),

                // 품절
                if (item.isSoldOut)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '품절',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.sp(16),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 좋아요 버튼
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: Responsive.sp(18),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            // 정보
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(Responsive.wp(3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타입 & 그룹명
                    if (item.groupName != null)
                      Text(
                        '[${item.groupName}]',
                        style: TextStyle(
                          fontSize: Responsive.sp(11),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // 상품명
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: Responsive.sp(13),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // 평점
                    if (item.rating > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: Responsive.sp(12),
                            color: AppColors.warning,
                          ),
                          SizedBox(width: Responsive.wp(1)),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: Responsive.sp(11),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: Responsive.hp(0.5)),

                    // 가격
                    Row(
                      children: [
                        if (item.originalPrice != null) ...[
                          Text(
                            '${_formatPrice(item.originalPrice!)}원',
                            style: TextStyle(
                              fontSize: Responsive.sp(11),
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: Responsive.wp(1)),
                        ],
                        Text(
                          '${_formatPrice(item.price)}원',
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            fontWeight: FontWeight.w700,
                            color: item.isOnSale
                                ? AppColors.error
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
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

  Widget _buildBadge(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: Responsive.wp(1)),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(2),
        vertical: Responsive.hp(0.5),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: Responsive.sp(10),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  // Mock 데이터 (임시)
  List<MerchandiseModel> _getMockMerchandise({
    bool isPreorder = false,
    bool isLimited = false,
  }) {
    return [
      MerchandiseModel(
        id: '1',
        name: '공식 포토카드 Vol.1',
        description: '한정판 포토카드',
        category: MerchandiseCategory.photocard,
        type: MerchandiseType.group,
        groupName: 'STARLIGHT',
        price: 15000,
        originalPrice: 20000,
        discountRate: 25,
        thumbnailImage: 'https://picsum.photos/300/400?random=1',
        images: [],
        isLimitedEdition: true,
        limitedQuantity: 500,
        stock: 50,
        rating: 4.8,
        reviewCount: 23,
        createdAt: DateTime.now(),
      ),
      MerchandiseModel(
        id: '2',
        name: '응원봉',
        description: '공식 응원봉',
        category: MerchandiseCategory.lightstick,
        type: MerchandiseType.group,
        groupName: 'MOONLIGHT',
        price: 45000,
        thumbnailImage: 'https://picsum.photos/300/400?random=2',
        images: [],
        stock: 200,
        rating: 4.9,
        reviewCount: 156,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
