import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/demo_feedback.dart';
import '../../../core/mock/mock_data.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  final Set<String> _likedPosts = {};
  final Set<String> _bookmarkedPosts = {};

  String _formatTimeAgo(String dateStr) {
    return TimeFormatter.formatRelative(DateTime.parse(dateStr));
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
              DemoFeedback.showSearchDemo(context);
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
                itemBuilder: (context, index) => _buildPostCard(context, posts[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DemoFeedback.showSuccess(context, DemoMessages.postCreated);
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.edit, color: Colors.white, size: Responsive.sp(24)),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    final postId = post['id'] as String;
    final isLiked = _likedPosts.contains(postId);
    final isBookmarked = _bookmarkedPosts.contains(postId);
    final likesCount = (post['likes'] as int) + (isLiked ? 1 : 0);
    final isSubscriberOnly = post['isSubscriberOnly'] ?? false;
    final hasImage = post['imageUrl'] != null;

    // Get author info
    Map<String, dynamic>? author;
    try {
      author = MockData.idols.firstWhere((i) => i['id'] == post['authorId']);
    } catch (e) {
      author = null;
    }

    final isIdol = author != null;

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(Responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Info
            Row(
              children: [
                CircleAvatar(
                  radius: Responsive.wp(5),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: author?['profileImage'] != null
                      ? CachedNetworkImageProvider(author!['profileImage'])
                      : null,
                  child: author?['profileImage'] == null
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
                              author?['stageName'] ?? post['authorName'] ?? '익명',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Responsive.sp(15),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isIdol && (author?['isVerified'] ?? false)) ...[
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
                      color: AppColors.secondary.withValues(alpha: 0.1),
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
            if (hasImage) ...[
              SizedBox(height: Responsive.hp(1.5)),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: post['imageUrl'],
                  height: Responsive.hp(25),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: Responsive.hp(25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.secondary.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: Responsive.sp(50),
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: Responsive.hp(25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.secondary.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: Responsive.sp(50),
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
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
                    setState(() {
                      if (isLiked) {
                        _likedPosts.remove(postId);
                      } else {
                        _likedPosts.add(postId);
                      }
                    });
                  },
                ),
                SizedBox(width: Responsive.wp(4)),
                _buildActionButton(
                  context,
                  icon: Icons.chat_bubble_outline,
                  label: '${post['comments'] ?? 0}',
                  onTap: () {
                    DemoFeedback.showSuccess(context, DemoMessages.commentAdded);
                  },
                ),
                SizedBox(width: Responsive.wp(4)),
                _buildActionButton(
                  context,
                  icon: Icons.share_outlined,
                  label: '공유',
                  onTap: () {
                    DemoFeedback.showShareDemo(context, '게시물');
                  },
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
                    DemoFeedback.showBookmarkDemo(context, !isBookmarked);
                  },
                  color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
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
            Icon(icon, size: Responsive.sp(20), color: color ?? AppColors.textSecondary),
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
            Container(
              width: Responsive.wp(10),
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: Responsive.hp(2)),
            ListTile(
              leading: Icon(Icons.report_outlined, size: Responsive.sp(24)),
              title: Text('신고하기', style: TextStyle(fontSize: Responsive.sp(15))),
              onTap: () {
                Navigator.pop(context);
                DemoFeedback.showReportDemo(context, '신고가 접수');
              },
            ),
            ListTile(
              leading: Icon(Icons.block, size: Responsive.sp(24)),
              title: Text('이 사용자 숨기기', style: TextStyle(fontSize: Responsive.sp(15))),
              onTap: () {
                Navigator.pop(context);
                DemoFeedback.showSuccess(context, DemoMessages.userBlocked);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, size: Responsive.sp(24)),
              title: Text('링크 복사', style: TextStyle(fontSize: Responsive.sp(15))),
              onTap: () {
                Navigator.pop(context);
                DemoFeedback.showSuccess(context, '링크가 복사되었습니다', icon: Icons.copy);
              },
            ),
            SizedBox(height: Responsive.hp(2)),
          ],
        ),
      ),
    );
  }
}
