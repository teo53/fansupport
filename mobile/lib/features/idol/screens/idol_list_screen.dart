import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';
import '../../../shared/models/idol_model.dart';

class IdolListScreen extends ConsumerStatefulWidget {
  const IdolListScreen({super.key});

  @override
  ConsumerState<IdolListScreen> createState() => _IdolListScreenState();
}

class _IdolListScreenState extends ConsumerState<IdolListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  IdolCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IdolModel> _getFilteredIdols() {
    return MockData.idolModels.where((idol) {
      final matchesCategory = _selectedCategory == null || idol.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          idol.stageName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final filteredIdols = _getFilteredIdols();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '아이돌',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard_outlined, color: AppColors.textPrimary),
            onPressed: () => context.go('/ranking'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(Responsive.wp(6)),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '아이돌 검색',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.backgroundAlt,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Category Filter
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: Responsive.wp(6),
              right: Responsive.wp(6),
              bottom: Responsive.wp(4),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('전체', null),
                  const SizedBox(width: 8),
                  _buildCategoryChip('지하돌', IdolCategory.undergroundIdol),
                  const SizedBox(width: 8),
                  _buildCategoryChip('메이드 카페', IdolCategory.maidCafe),
                  const SizedBox(width: 8),
                  _buildCategoryChip('코스프레이어', IdolCategory.cosplayer),
                  const SizedBox(width: 8),
                  _buildCategoryChip('VTuber', IdolCategory.vtuber),
                ],
              ),
            ),
          ),

          // Idol List
          Expanded(
            child: filteredIdols.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(Responsive.wp(6)),
                    itemCount: filteredIdols.length,
                    itemBuilder: (context, index) => _buildIdolCard(filteredIdols[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, IdolCategory? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      backgroundColor: AppColors.backgroundAlt,
      selectedColor: AppColors.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 14,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: isSelected ? 1.5 : 1,
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdolCard(IdolModel idol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: () => context.go('/idols/${idol.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(int.parse(idol.imageColor)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: idol.profileImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Color(int.parse(idol.imageColor)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Color(int.parse(idol.imageColor)),
                      child: const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            idol.stageName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (idol.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoryText(idol.category),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatNumber(idol.supporterCount)} 서포터',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryText(IdolCategory category) {
    switch (category) {
      case IdolCategory.undergroundIdol:
        return '지하돌';
      case IdolCategory.maidCafe:
        return '메이드 카페';
      case IdolCategory.cosplayer:
        return '코스프레이어';
      case IdolCategory.vtuber:
        return 'VTuber';
      case IdolCategory.other:
        return '기타';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
