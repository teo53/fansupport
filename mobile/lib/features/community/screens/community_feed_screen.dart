import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/mock/mock_data.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() =>
      _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  final Set<String> _bookmarkedPosts = {};

  String _formatTimeAgo(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final posts = MockData.posts;

    return Scaffold(
      appBar: AppBar(
        title: Text('커뮤니티', style: TextStyle(fontSize: Responsive.sp(18))),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: Responsive.sp(24)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('검색 기능은 준비 중입니다')),
              );
            },
          ),
        ],
      ),
      body: posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: Responsive.sp(60),
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: Responsive.hp(2)),
                  Text(
                    '게시물이 없습니다',
                    style: TextStyle(
                      fontSize: Responsive.sp(16),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: EdgeInsets.all(Responsive.wp(4)),
                itemCount: posts.length,
                itemBuilder: (context, index) =>
                    _buildPostCard(context, posts[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('글 작성 기능은 준비 중입니다')),
          );
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.edit, color: Colors.white, size: Responsive.sp(24)),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    final postId = post['id'] as String;
    final isLiked = post['isLiked'] ?? false; // In a real app, use local state
    final isBookmarked = _bookmarkedPosts.contains(postId);
    final likesCount = post['likeCount'] ?? 0;
    final isSubscriberOnly = post['isSubscriberOnly'] ?? false;

    // Handle images: MockData uses 'images' list, UI expects one or more
    final images = post['images'] as List<dynamic>? ?? [];
    final firstImage = images.isNotEmpty ? images.first as String : null;

    final author = post['author'] as Map<String, dynamic>?;

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0, // Flat design
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Info
            if (author != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: Responsive.wp(5),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: author['profileImage'] != null
                        ? CachedNetworkImageProvider(author['profileImage'])
                        : null,
                    child: author['profileImage'] == null
                        ? Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: Responsive.sp(20),
                          )
                        : null,
                  ),
                  SizedBox(width: Responsive.wp(3)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                author['nickname'] ?? '익명',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: Responsive.sp(15),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (author['isVerified'] == true) ...[
                              SizedBox(width: Responsive.wp(1)),
                              Icon(
                                Icons.verified,
                                size: Responsive.sp(16),
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          _formatTimeAgo(post['createdAt']),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: Responsive.sp(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSubscriberOnly)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.wp(2),
                        vertical: Responsive.hp(0.5),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '구독자 전용',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: Responsive.sp(10),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(Icons.more_vert, size: Responsive.sp(20)),
                    onPressed: () => _showPostOptions(context, post),
                  ),
                ],
              ),
            SizedBox(height: Responsive.hp(1.5)),

            // Content
            Text(
              post['content'] ?? '',
              style: TextStyle(
                height: 1.6,
                fontSize: Responsive.sp(14),
              ),
            ),

            // Image
            if (firstImage != null) ...[
              SizedBox(height: Responsive.hp(1.5)),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: firstImage,
                  height: Responsive.hp(25),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: Responsive.hp(25),
                    color: AppColors.primary.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: Responsive.sp(40),
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: Responsive.hp(25),
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image),
                  ),
                ),
              ),
            ],
            SizedBox(height: Responsive.hp(1.5)),

            // Actions
            Row(
              children: [
                _buildActionButton(
                  context,
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '$likesCount',
                  color: isLiked ? AppColors.primary : AppColors.textSecondary,
                  onTap: () {
                    // Toggle like
                  },
                ),
                SizedBox(width: Responsive.wp(4)),
                _buildActionButton(
                  context,
                  icon: Icons.chat_bubble_outline,
                  label: '${post['commentCount'] ?? 0}',
                  onTap: () {},
                ),
                SizedBox(width: Responsive.wp(4)),
                _buildActionButton(
                  context,
                  icon: Icons.share_outlined,
                  label: '공유',
                  onTap: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: Responsive.sp(24),
                  ),
                  onPressed: () {
                    setState(() {
                      if (isBookmarked) {
                        _bookmarkedPosts.remove(postId);
                      } else {
                        _bookmarkedPosts.add(postId);
                      }
                    });
                  },
                  color: isBookmarked
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(2),
          vertical: Responsive.hp(0.5),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: Responsive.sp(20),
                color: color ?? AppColors.textSecondary),
            SizedBox(width: Responsive.wp(1)),
            Text(
              label,
              style: TextStyle(
                color: color ?? AppColors.textSecondary,
                fontSize: Responsive.sp(13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context, Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(Responsive.wp(4)),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ... kept simple for brevity
            ListTile(title: Text('신고하기'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
