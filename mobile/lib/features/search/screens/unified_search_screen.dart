/// 🔍 통합 검색
/// 아이돌, 게시글, 이벤트 통합 검색
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/models/post_model.dart';
import '../../../shared/models/post_type.dart';

enum SearchType {
  all,
  idols,
  posts,
  events,
}

extension SearchTypeExtension on SearchType {
  String get displayName {
    switch (this) {
      case SearchType.all:
        return '전체';
      case SearchType.idols:
        return '아이돌';
      case SearchType.posts:
        return '게시글';
      case SearchType.events:
        return '이벤트';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchType.all:
        return Icons.search;
      case SearchType.idols:
        return Icons.person;
      case SearchType.posts:
        return Icons.article;
      case SearchType.events:
        return Icons.event;
    }
  }
}

class UnifiedSearchScreen extends ConsumerStatefulWidget {
  const UnifiedSearchScreen({super.key});

  @override
  ConsumerState<UnifiedSearchScreen> createState() =>
      _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends ConsumerState<UnifiedSearchScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  SearchType _selectedType = SearchType.all;
  bool _isSearching = false;
  List<String> _recentSearches = [];

  // Mock search results - TODO: Replace with actual API
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    // TODO: Load from local storage
    setState(() {
      _recentSearches = [
        '아이유',
        '르세라핌',
        '정산',
        '공연 일정',
      ];
    });
  }

  void _saveRecentSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });

    // TODO: Save to local storage
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
    // TODO: Clear from local storage
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      // TODO: Perform actual API search
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock results
      final results = _getMockSearchResults(query);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      _saveRecentSearch(query);
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('검색 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: '아이돌, 게시글, 이벤트 검색...',
            hintStyle: TextStyle(
              color: AppColors.textTertiary,
              fontFamily: 'Pretendard',
            ),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                      });
                    },
                  )
                : null,
          ),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Pretendard',
          ),
          onSubmitted: _performSearch,
          onChanged: (value) {
            setState(() {});
            if (value.trim().isEmpty) {
              setState(() {
                _searchResults = [];
              });
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => _performSearch(_searchController.text),
            child: const Text(
              '검색',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search type filters
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.wp(4),
              vertical: 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: SearchType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildTypeChip(type),
                  );
                }).toList(),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildRecentSearches()
                : _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(SearchType type) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              type.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              '아이돌, 게시글, 이벤트를 검색하세요',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: 16,
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '최근 검색',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Pretendard',
              ),
            ),
            TextButton(
              onPressed: _clearRecentSearches,
              child: const Text(
                '전체 삭제',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentSearches.map((search) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.history,
              color: AppColors.textTertiary,
              size: 20,
            ),
            title: Text(
              search,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Pretendard',
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.textTertiary,
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _recentSearches.remove(search);
                });
              },
            ),
            onTap: () {
              _searchController.text = search;
              _performSearch(search);
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      );
    }

    // Filter by selected type
    var filteredResults = _searchResults;
    if (_selectedType != SearchType.all) {
      filteredResults = _searchResults.where((result) {
        if (_selectedType == SearchType.idols) {
          return result is SearchResultIdol;
        } else if (_selectedType == SearchType.posts) {
          return result is SearchResultPost;
        } else if (_selectedType == SearchType.events) {
          return result is SearchResultEvent;
        }
        return true;
      }).toList();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final result = filteredResults[index];

        if (result is SearchResultIdol) {
          return _buildIdolResultCard(result);
        } else if (result is SearchResultPost) {
          return _buildPostResultCard(result);
        } else if (result is SearchResultEvent) {
          return _buildEventResultCard(result);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildIdolResultCard(SearchResultIdol result) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: 6,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: result.profileImage != null
                ? CachedNetworkImageProvider(result.profileImage!)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      result.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    if (result.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '구독자 ${FormatUtils.formatCount(result.subscriberCount)}명',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPostResultCard(SearchResultPost result) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: 6,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.thumbnailUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: result.thumbnailUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.article,
                color: AppColors.textTertiary,
                size: 24,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: result.type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: result.type.color, width: 1),
                  ),
                  child: Text(
                    result.type.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: result.type.color,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${result.authorName} · ${FormatUtils.formatRelativeTime(result.createdAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEventResultCard(SearchResultEvent result) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.wp(4),
        vertical: 6,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${result.eventDate.day}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                    fontFamily: 'Pretendard',
                  ),
                ),
                Text(
                  '${result.eventDate.month}월',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.warning,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.location,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  // Mock data - TODO: Replace with actual API
  List<dynamic> _getMockSearchResults(String query) {
    return [
      SearchResultIdol(
        id: '1',
        name: '아이유',
        profileImage: 'https://i.pravatar.cc/150?img=5',
        isVerified: true,
        subscriberCount: 15420,
      ),
      SearchResultPost(
        id: '1',
        content: '오늘 공연 너무 재밌었어요! 다음에도 꼭 올게요 💕',
        authorName: '김민지',
        type: PostType.cheki,
        thumbnailUrl: 'https://picsum.photos/400/300?random=1',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SearchResultEvent(
        id: '1',
        title: '아이유 콘서트 2025',
        location: '올림픽공원 체조경기장',
        eventDate: DateTime(2025, 2, 15),
      ),
      SearchResultPost(
        id: '2',
        content: '생일 축하 공연 감사합니다 🎂',
        authorName: '박지우',
        type: PostType.birthdayTime,
        thumbnailUrl: 'https://picsum.photos/400/300?random=2',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

// Search result models
class SearchResultIdol {
  final String id;
  final String name;
  final String? profileImage;
  final bool isVerified;
  final int subscriberCount;

  SearchResultIdol({
    required this.id,
    required this.name,
    this.profileImage,
    required this.isVerified,
    required this.subscriberCount,
  });
}

class SearchResultPost {
  final String id;
  final String content;
  final String authorName;
  final PostType type;
  final String? thumbnailUrl;
  final DateTime createdAt;

  SearchResultPost({
    required this.id,
    required this.content,
    required this.authorName,
    required this.type,
    this.thumbnailUrl,
    required this.createdAt,
  });
}

class SearchResultEvent {
  final String id;
  final String title;
  final String location;
  final DateTime eventDate;

  SearchResultEvent({
    required this.id,
    required this.title,
    required this.location,
    required this.eventDate,
  });
}
