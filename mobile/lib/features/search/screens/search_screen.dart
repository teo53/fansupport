import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/services/local_storage_provider.dart';
import '../../../shared/models/idol_model.dart';

/// Search type enum
enum SearchType { all, idol, campaign, post }

/// Search result model
class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final SearchType type;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.type,
  });
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  SearchType _selectedType = SearchType.all;
  List<SearchResult> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final lowercaseQuery = query.toLowerCase();
    final results = <SearchResult>[];

    // Search idols
    if (_selectedType == SearchType.all || _selectedType == SearchType.idol) {
      for (final idol in MockData.idolModels) {
        if (idol.stageName.toLowerCase().contains(lowercaseQuery) ||
            (idol.groupName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            idol.category.toLowerCase().contains(lowercaseQuery)) {
          results.add(SearchResult(
            id: idol.id,
            title: idol.stageName,
            subtitle: idol.groupName ?? idol.category,
            imageUrl: idol.profileImage,
            type: SearchType.idol,
          ));
        }
      }
    }

    // Search campaigns
    if (_selectedType == SearchType.all ||
        _selectedType == SearchType.campaign) {
      for (final campaign in MockData.campaigns) {
        final title = campaign['title'] as String? ?? '';
        final description = campaign['description'] as String? ?? '';
        if (title.toLowerCase().contains(lowercaseQuery) ||
            description.toLowerCase().contains(lowercaseQuery)) {
          results.add(SearchResult(
            id: campaign['id'] as String,
            title: title,
            subtitle: '펀딩 캠페인',
            imageUrl: campaign['image'] as String?,
            type: SearchType.campaign,
          ));
        }
      }
    }

    // Search posts
    if (_selectedType == SearchType.all || _selectedType == SearchType.post) {
      for (final post in MockData.posts) {
        final content = post['content'] as String? ?? '';
        if (content.toLowerCase().contains(lowercaseQuery)) {
          results.add(SearchResult(
            id: post['id'] as String,
            title: content.length > 50
                ? '${content.substring(0, 50)}...'
                : content,
            subtitle: '게시물',
            type: SearchType.post,
          ));
        }
      }
    }

    setState(() {
      _results = results;
      _isSearching = false;
    });

    // Save to search history
    if (query.trim().isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).addQuery(query.trim());
    }
  }

  void _onResultTap(SearchResult result) {
    switch (result.type) {
      case SearchType.idol:
        context.push('/idols/${result.id}');
        break;
      case SearchType.campaign:
        context.push('/campaigns/${result.id}');
        break;
      case SearchType.post:
        context.push('/community');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchHistory = ref.watch(searchHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _performSearch,
          onSubmitted: _performSearch,
          style: TextStyle(
            fontSize: 16,
            fontFamily: TypographyTokens.fontFamily,
          ),
          decoration: InputDecoration(
            hintText: '아이돌, 캠페인, 게시물 검색...',
            hintStyle: TextStyle(
              color: AppColors.textTertiary,
              fontFamily: TypographyTokens.fontFamily,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('전체', SearchType.all),
                  SizedBox(width: Spacing.sm),
                  _buildFilterChip('아이돌', SearchType.idol),
                  SizedBox(width: Spacing.sm),
                  _buildFilterChip('캠페인', SearchType.campaign),
                  SizedBox(width: Spacing.sm),
                  _buildFilterChip('게시물', SearchType.post),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.border),

          // Content
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildSearchHistory(searchHistory)
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SearchType type) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedType = type);
        _performSearch(_searchController.text);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(Radii.full),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: TypographyTokens.fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHistory(List<String> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.grey300,
            ),
            SizedBox(height: Spacing.base),
            Text(
              '검색어를 입력해주세요',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontFamily: TypographyTokens.fontFamily,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(Spacing.base),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 검색',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: TypographyTokens.fontFamily,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(searchHistoryProvider.notifier).clear();
              },
              child: Text(
                '전체 삭제',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: TypographyTokens.fontFamily,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.sm),
        ...history.map((query) => ListTile(
              leading: Icon(Icons.history, color: AppColors.grey400),
              title: Text(
                query,
                style: TextStyle(
                  fontFamily: TypographyTokens.fontFamily,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.close, size: 18, color: AppColors.grey400),
                onPressed: () {
                  ref.read(searchHistoryProvider.notifier).removeQuery(query);
                },
              ),
              onTap: () {
                _searchController.text = query;
                _performSearch(query);
              },
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.grey300,
            ),
            SizedBox(height: Spacing.base),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontFamily: TypographyTokens.fontFamily,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(Spacing.base),
      itemCount: _results.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: AppColors.border,
      ),
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildResultItem(SearchResult result) {
    IconData typeIcon;
    Color typeColor;

    switch (result.type) {
      case SearchType.idol:
        typeIcon = Icons.person;
        typeColor = AppColors.primary;
        break;
      case SearchType.campaign:
        typeIcon = Icons.campaign;
        typeColor = AppColors.success;
        break;
      case SearchType.post:
        typeIcon = Icons.article;
        typeColor = AppColors.warning;
        break;
      default:
        typeIcon = Icons.search;
        typeColor = AppColors.grey400;
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: Spacing.sm),
      leading: result.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(Radii.sm),
              child: Image.network(
                result.imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.grey100,
                  child: Icon(typeIcon, color: typeColor),
                ),
              ),
            )
          : Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Icon(typeIcon, color: typeColor),
            ),
      title: Text(
        result.title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: TypographyTokens.fontFamily,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        result.subtitle,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          fontFamily: TypographyTokens.fontFamily,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.grey400,
      ),
      onTap: () => _onResultTap(result),
    );
  }
}
