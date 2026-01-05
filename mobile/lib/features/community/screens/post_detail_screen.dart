/// 📱 게시글 상세 화면
/// 정산 답글 시스템의 핵심
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/models/post_model.dart';
import '../../../shared/models/post_type.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final Post post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSubmitting = false;

  // Mock comments - TODO: Replace with actual provider
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadComments() {
    // TODO: Load from provider/API
    setState(() {
      _comments = [
        Comment(
          id: '1',
          authorId: 'user1',
          authorName: '팬123',
          authorProfileImage: null,
          isCreator: false,
          content: '오늘 공연 너무 좋았어요! 💕',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          likeCount: 12,
          isLiked: false,
        ),
        if (widget.post.hasCreatorReply)
          Comment(
            id: '2',
            authorId: widget.post.author.id,
            authorName: widget.post.author.name,
            authorProfileImage: widget.post.author.profileImage,
            isCreator: true,
            content: '와주셔서 감사해요! 다음에 또 만나요 🫶',
            createdAt: widget.post.creatorRepliedAt ?? DateTime.now(),
            likeCount: 45,
            isLiked: true,
          ),
      ];
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Submit to API
      await Future.delayed(const Duration(milliseconds: 500));

      final newComment = Comment(
        id: DateTime.now().toString(),
        authorId: 'current_user', // TODO: Get from auth
        authorName: '나',
        authorProfileImage: null,
        isCreator: false, // TODO: Check if current user is creator
        content: _commentController.text,
        createdAt: DateTime.now(),
        likeCount: 0,
        isLiked: false,
      );

      setState(() {
        _comments.add(newComment);
        _commentController.clear();
      });

      // Scroll to bottom
      _scrollToBottom();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('댓글이 등록되었습니다'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('댓글 등록에 실패했습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '게시글',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: [
                // Post Content
                _buildPostContent(),

                const Divider(height: 8, thickness: 8),

                // Comments Section
                _buildCommentsSection(),
              ],
            ),
          ),

          // Comment Input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.post.author.profileImage != null
                    ? CachedNetworkImageProvider(
                        widget.post.author.profileImage!)
                    : null,
                backgroundColor: AppColors.backgroundAlt,
                child: widget.post.author.profileImage == null
                    ? const Icon(Icons.person, size: 20)
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
                          widget.post.author.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        if (widget.post.author.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                        if (widget.post.author.isCreator) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ARTIST',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FormatUtils.formatRelativeTime(widget.post.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              ),
              _buildPostTypeBadge(widget.post.type),
            ],
          ),

          const SizedBox(height: 16),

          // Content
          Text(
            widget.post.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              fontFamily: 'Pretendard',
            ),
          ),

          // Images
          if (widget.post.images.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildImages(),
          ],

          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _buildStat(Icons.favorite_border, widget.post.likeCount),
              const SizedBox(width: 16),
              _buildStat(Icons.chat_bubble_outline, widget.post.commentCount),
              const SizedBox(width: 16),
              _buildStat(Icons.visibility_outlined, widget.post.viewCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeBadge(PostType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: type.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 12, color: type.color),
          const SizedBox(width: 4),
          Text(
            type.displayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: type.color,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImages() {
    if (widget.post.images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: widget.post.images.first,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.post.images.length > 4 ? 4 : widget.post.images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: widget.post.images[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildStat(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          FormatUtils.formatCount(count),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      padding: EdgeInsets.all(Responsive.wp(4)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '댓글',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_comments.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_comments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '첫 댓글을 남겨보세요!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            )
          else
            ..._comments.map((comment) => _buildCommentItem(comment)),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.authorProfileImage != null
                ? CachedNetworkImageProvider(comment.authorProfileImage!)
                : null,
            backgroundColor: AppColors.backgroundAlt,
            child: comment.authorProfileImage == null
                ? const Icon(Icons.person, size: 16)
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
                      comment.authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    if (comment.isCreator) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ARTIST',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      FormatUtils.formatRelativeTime(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      comment.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: comment.isLiked
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${comment.likeCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: comment.isLiked
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontFamily: 'Pretendard',
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

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: Responsive.wp(4),
        right: Responsive.wp(4),
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: null,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: '댓글을 입력하세요...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                  fontFamily: 'Pretendard',
                ),
                filled: true,
                fillColor: AppColors.backgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                counterText: '',
              ),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isSubmitting ? null : _submitComment,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: _commentController.text.trim().isNotEmpty
                    ? AppColors.primaryGradient
                    : null,
                color: _commentController.text.trim().isEmpty
                    ? AppColors.backgroundAlt
                    : null,
                shape: BoxShape.circle,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: _commentController.text.trim().isNotEmpty
                          ? Colors.white
                          : AppColors.textTertiary,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Comment Model
class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorProfileImage;
  final bool isCreator;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;

  Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorProfileImage,
    required this.isCreator,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
  });
}
