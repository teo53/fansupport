/// 📝 미답글 정산 목록
/// 아이돌 전용 - 답글 필요한 정산 리스트 (긴급도 순)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/models/post_model.dart';
import '../../../shared/models/post_type.dart';
import 'post_detail_screen.dart';

class UnansweredChekiListScreen extends ConsumerStatefulWidget {
  const UnansweredChekiListScreen({super.key});

  @override
  ConsumerState<UnansweredChekiListScreen> createState() =>
      _UnansweredChekiListScreenState();
}

class _UnansweredChekiListScreenState
    extends ConsumerState<UnansweredChekiListScreen> {
  bool _showOnlyUrgent = false;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    // TODO: Replace with actual provider
    final unansweredPosts = _getMockUnansweredPosts();

    // Filter and sort
    var filteredPosts = unansweredPosts.where((p) => p.needsCreatorReply).toList();
    if (_showOnlyUrgent) {
      filteredPosts = filteredPosts.where((p) => p.isChekiUrgent).toList();
    }

    // Sort by urgency: overdue first, then urgent, then by oldest
    filteredPosts.sort((a, b) {
      if (a.isChekiOverdue && !b.isChekiOverdue) return -1;
      if (!a.isChekiOverdue && b.isChekiOverdue) return 1;
      if (a.isChekiUrgent && !b.isChekiUrgent) return -1;
      if (!a.isChekiUrgent && b.isChekiUrgent) return 1;
      return a.createdAt.compareTo(b.createdAt); // Oldest first
    });

    final overdueCount = filteredPosts.where((p) => p.isChekiOverdue).length;
    final urgentCount = filteredPosts.where((p) => p.isChekiUrgent && !p.isChekiOverdue).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '답글 필요한 정산',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Pretendard',
          ),
        ),
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
          // Stats header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.wp(4),
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatChip(
                      label: '전체',
                      count: filteredPosts.length,
                      color: AppColors.textSecondary,
                      isActive: !_showOnlyUrgent,
                      onTap: () => setState(() => _showOnlyUrgent = false),
                    ),
                    const SizedBox(width: 8),
                    if (urgentCount > 0)
                      _buildStatChip(
                        label: '긴급 (12시간+)',
                        count: urgentCount,
                        color: AppColors.warning,
                        isActive: false,
                      ),
                    const SizedBox(width: 8),
                    if (overdueCount > 0)
                      _buildStatChip(
                        label: '지연 (24시간+)',
                        count: overdueCount,
                        color: AppColors.error,
                        isActive: _showOnlyUrgent,
                        onTap: () => setState(() => _showOnlyUrgent = true),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '오래된 정산부터 표시됩니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),

          // Post list
          Expanded(
            child: filteredPosts.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      // TODO: Refresh from API
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        return _buildChekiCard(post);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required int count,
    required Color color,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? color : AppColors.textSecondary,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChekiCard(Post post) {
    final hoursSincePost = DateTime.now().difference(post.createdAt).inHours;
    final isOverdue = post.isChekiOverdue;
    final isUrgent = post.isChekiUrgent;

    Color urgencyColor = AppColors.textSecondary;
    String urgencyText = '';

    if (isOverdue) {
      urgencyColor = AppColors.error;
      urgencyText = '지연 (${hoursSincePost}시간 경과)';
    } else if (isUrgent) {
      urgencyColor = AppColors.warning;
      urgencyText = '긴급 (${hoursSincePost}시간 경과)';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Responsive.wp(4),
          vertical: 6,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue
                ? AppColors.error
                : isUrgent
                    ? AppColors.warning
                    : AppColors.border,
            width: isOverdue || isUrgent ? 2 : 1,
          ),
          boxShadow: isOverdue || isUrgent
              ? AppColors.glowShadow(urgencyColor)
              : AppColors.softShadow(),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (post.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: post.images.first,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.textTertiary,
                  size: 32,
                ),
              ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: post.type.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: post.type.color,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.type.icon,
                          size: 12,
                          color: post.type.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.type.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: post.type.color,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Author
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: post.author.profileImage != null
                            ? CachedNetworkImageProvider(post.author.profileImage!)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.author.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Content preview
                  Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                      fontFamily: 'Pretendard',
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Urgency indicator
                  Row(
                    children: [
                      Icon(
                        isOverdue
                            ? Icons.error_outline
                            : isUrgent
                                ? Icons.access_time
                                : Icons.schedule,
                        size: 14,
                        color: urgencyColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverdue || isUrgent
                            ? urgencyText
                            : FormatUtils.formatRelativeTime(post.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isOverdue || isUrgent
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: urgencyColor,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '모든 정산에 답글을 달았어요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '팬들과의 소통이 완료되었습니다',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }

  // Mock data - TODO: Replace with actual provider
  List<Post> _getMockUnansweredPosts() {
    return [
      Post(
        id: '1',
        content: '오늘 공연 너무 재밌었어요! 다음에도 꼭 올게요 💕',
        author: _getMockUser('김민지', 'https://i.pravatar.cc/150?img=1'),
        createdAt: DateTime.now().subtract(const Duration(hours: 26)),
        type: PostType.cheki,
        hasCreatorReply: false,
        images: ['https://picsum.photos/400/300?random=1'],
        likeCount: 15,
        commentCount: 3,
        viewCount: 89,
      ),
      Post(
        id: '2',
        content: '어제 공연 최고였어요!! 사진 공유합니다 📸',
        author: _getMockUser('이서연', 'https://i.pravatar.cc/150?img=2'),
        createdAt: DateTime.now().subtract(const Duration(hours: 15)),
        type: PostType.cheki,
        hasCreatorReply: false,
        images: ['https://picsum.photos/400/300?random=2'],
        likeCount: 23,
        commentCount: 7,
        viewCount: 134,
      ),
      Post(
        id: '3',
        content: '생일 축하 공연 감사합니다 🎂',
        author: _getMockUser('박지우', 'https://i.pravatar.cc/150?img=3'),
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        type: PostType.cheki,
        hasCreatorReply: false,
        images: ['https://picsum.photos/400/300?random=3'],
        likeCount: 31,
        commentCount: 12,
        viewCount: 201,
      ),
      Post(
        id: '4',
        content: '오늘도 멋진 공연이었어요! 히든정산 올립니다',
        author: _getMockUser('최유나', 'https://i.pravatar.cc/150?img=4'),
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        type: PostType.hiddenCheki,
        hasCreatorReply: false,
        images: ['https://picsum.photos/400/300?random=4'],
        likeCount: 8,
        commentCount: 2,
        viewCount: 45,
      ),
    ];
  }

  User _getMockUser(String name, String? profileImage) {
    return User(
      id: 'user_${name.hashCode}',
      name: name,
      profileImage: profileImage,
      isVerified: false,
    );
  }
}
