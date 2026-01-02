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
            onPressed: () => _showSearchSheet(context),
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
        onPressed: () => _showCreatePostSheet(context),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isLiked ? '좋아요 취소' : '좋아요!'),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),
                SizedBox(width: Responsive.wp(4)),
                _buildActionButton(
                  context,
                  icon: Icons.chat_bubble_outline,
                  label: '${post['commentCount'] ?? 0}',
                  onTap: () => _showCommentsSheet(context, post),
                ),
                SizedBox(width: Responsive.wp(4)),
                _buildActionButton(
                  context,
                  icon: Icons.share_outlined,
                  label: '공유',
                  onTap: () => _showShareSheet(context, post),
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
            ListTile(title: const Text('신고하기'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(Responsive.wp(4)),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '게시물 검색...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onSubmitted: (value) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"$value" 검색 결과')),
                  );
                },
              ),
              SizedBox(height: Responsive.hp(2)),
              Text('최근 검색어', style: TextStyle(color: Colors.grey[600], fontSize: Responsive.sp(14))),
              SizedBox(height: Responsive.hp(10)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(Responsive.wp(4)),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('새 게시물', style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (textController.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('게시물이 작성되었습니다!')),
                        );
                      }
                    },
                    child: const Text('게시'),
                  ),
                ],
              ),
              SizedBox(height: Responsive.hp(2)),
              TextField(
                controller: textController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '무슨 생각을 하고 계신가요?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              SizedBox(height: Responsive.hp(2)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.green),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이미지 선택')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.gif_box, color: Colors.purple),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.poll, color: Colors.orange),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: Responsive.hp(2)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.wp(4)),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('댓글 ${post['commentCount'] ?? 0}개', style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(Responsive.wp(4)),
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: Responsive.hp(2)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 16, backgroundColor: Colors.grey[300]),
                        SizedBox(width: Responsive.wp(2)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('팬${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Text('응원합니다! 💕'),
                              Text('${index + 1}시간 전', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(Responsive.wp(3)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '댓글 달기...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: AppColors.primary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글이 등록되었습니다!')));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, Map<String, dynamic> post) {
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
            Text('공유하기', style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)),
            SizedBox(height: Responsive.hp(2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.link, '링크 복사', Colors.grey, () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('링크가 복사되었습니다')));
                }),
                _buildShareOption(Icons.message, '메시지', Colors.blue, () => Navigator.pop(context)),
                _buildShareOption(Icons.share, '더보기', Colors.green, () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: Responsive.hp(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }
}
