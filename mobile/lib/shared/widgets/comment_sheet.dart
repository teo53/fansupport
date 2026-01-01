import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
    this.replies = const [],
  });
}

class CommentSheet extends StatefulWidget {
  final String postId;
  final List<Comment>? initialComments;
  final Function(String)? onCommentSubmit;

  const CommentSheet({
    super.key,
    required this.postId,
    this.initialComments,
    this.onCommentSubmit,
  });

  static Future<void> show(BuildContext context, {
    required String postId,
    List<Comment>? initialComments,
    Function(String)? onCommentSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(
        postId: postId,
        initialComments: initialComments,
        onCommentSubmit: onCommentSubmit,
      ),
    );
  }

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  late List<Comment> _comments;
  String? _replyingTo;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _comments = widget.initialComments ?? _getMockComments();
  }

  List<Comment> _getMockComments() {
    return [
      Comment(
        id: 'c1',
        userId: 'u1',
        userName: '하늘별',
        userImage: 'https://api.dicebear.com/7.x/adventurer-neutral/svg?seed=haneulbyeol',
        content: '오늘도 응원해주셔서 감사합니다~ 💕',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        likeCount: 24,
        isLiked: true,
      ),
      Comment(
        id: 'c2',
        userId: 'u2',
        userName: '별빛팬',
        userImage: 'https://api.dicebear.com/7.x/adventurer-neutral/svg?seed=starfan',
        content: '정말 멋진 무대였어요! 다음 공연도 기대할게요 😍',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likeCount: 8,
        replies: [
          Comment(
            id: 'c2-1',
            userId: 'u1',
            userName: '하늘별',
            userImage: 'https://api.dicebear.com/7.x/adventurer-neutral/svg?seed=haneulbyeol',
            content: '감사합니다! 더 열심히 할게요~',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
            likeCount: 5,
          ),
        ],
      ),
      Comment(
        id: 'c3',
        userId: 'u3',
        userName: '스타라이트',
        userImage: 'https://api.dicebear.com/7.x/adventurer-neutral/svg?seed=starlight',
        content: '다음 공연은 언제인가요?',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likeCount: 2,
      ),
    ];
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: Responsive.screenHeight * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle & Header
          _buildHeader(),

          // Comments List
          Expanded(
            child: _comments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) => _buildCommentItem(_comments[index]),
                  ),
          ),

          // Input Area
          _buildInputArea(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    int totalComments = _comments.length;
    for (var comment in _comments) {
      totalComments += comment.replies.length;
    }

    return Column(
      children: [
        // Handle
        Container(
          margin: EdgeInsets.symmetric(vertical: Responsive.hp(1.5)),
          width: Responsive.wp(10),
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Title
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.wp(4),
            vertical: Responsive.hp(1),
          ),
          child: Row(
            children: [
              Text(
                '댓글',
                style: TextStyle(
                  fontSize: Responsive.sp(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: Responsive.wp(2)),
              Text(
                '$totalComments',
                style: TextStyle(
                  fontSize: Responsive.sp(16),
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.border),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: Responsive.sp(48),
            color: AppColors.textHint,
          ),
          SizedBox(height: Responsive.hp(2)),
          Text(
            '첫 번째 댓글을 남겨보세요!',
            style: TextStyle(
              fontSize: Responsive.sp(15),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, {bool isReply = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? Responsive.wp(10) : 0,
        top: Responsive.hp(1.5),
        bottom: Responsive.hp(1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              CircleAvatar(
                radius: isReply ? Responsive.wp(4) : Responsive.wp(5),
                backgroundImage: CachedNetworkImageProvider(comment.userImage),
              ),
              SizedBox(width: Responsive.wp(2.5)),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: TextStyle(
                            fontSize: Responsive.sp(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: Responsive.wp(2)),
                        Text(
                          _formatTime(comment.createdAt),
                          style: TextStyle(
                            fontSize: Responsive.sp(12),
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.hp(0.5)),
                    Text(
                      comment.content,
                      style: TextStyle(
                        fontSize: Responsive.sp(14),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: Responsive.hp(1)),

                    // Actions
                    Row(
                      children: [
                        _buildActionButton(
                          icon: comment.isLiked ? Icons.favorite : Icons.favorite_border,
                          label: comment.likeCount > 0 ? '${comment.likeCount}' : '좋아요',
                          color: comment.isLiked ? AppColors.error : AppColors.textSecondary,
                          onTap: () => _toggleLike(comment),
                        ),
                        SizedBox(width: Responsive.wp(4)),
                        if (!isReply)
                          _buildActionButton(
                            icon: Icons.reply,
                            label: '답글',
                            color: AppColors.textSecondary,
                            onTap: () => _setReplyTo(comment),
                          ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz,
                            size: Responsive.sp(18),
                            color: AppColors.textHint,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'report', child: Text('신고하기')),
                            const PopupMenuItem(value: 'block', child: Text('차단하기')),
                          ],
                          onSelected: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$value 기능은 준비 중입니다')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Replies
          if (comment.replies.isNotEmpty)
            ...comment.replies.map((reply) => _buildCommentItem(reply, isReply: true)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: Responsive.sp(16), color: color),
          SizedBox(width: Responsive.wp(1)),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(12),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(double bottomPadding) {
    return Container(
      padding: EdgeInsets.only(
        left: Responsive.wp(4),
        right: Responsive.wp(4),
        top: Responsive.hp(1),
        bottom: Responsive.hp(1) + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply indicator
          if (_replyingTo != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.wp(3),
                vertical: Responsive.hp(0.8),
              ),
              margin: EdgeInsets.only(bottom: Responsive.hp(1)),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '$_replyingTo님에게 답글 작성 중',
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _replyingTo = null),
                    child: Icon(
                      Icons.close,
                      size: Responsive.sp(16),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Input field
          Row(
            children: [
              CircleAvatar(
                radius: Responsive.wp(4.5),
                backgroundImage: const CachedNetworkImageProvider(
                  'https://api.dicebear.com/7.x/adventurer-neutral/svg?seed=myfan',
                ),
              ),
              SizedBox(width: Responsive.wp(2)),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  minLines: 1,
                  style: TextStyle(fontSize: Responsive.sp(14)),
                  decoration: InputDecoration(
                    hintText: '댓글을 입력하세요...',
                    hintStyle: TextStyle(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Responsive.wp(4),
                      vertical: Responsive.hp(1),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: Responsive.wp(2)),
              GestureDetector(
                onTap: _commentController.text.trim().isNotEmpty && !_isSubmitting
                    ? _submitComment
                    : null,
                child: Container(
                  width: Responsive.wp(10),
                  height: Responsive.wp(10),
                  decoration: BoxDecoration(
                    color: _commentController.text.trim().isNotEmpty
                        ? AppColors.primary
                        : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: _isSubmitting
                      ? Padding(
                          padding: EdgeInsets.all(Responsive.wp(2.5)),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: Responsive.sp(18),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분';
    if (diff.inHours < 24) return '${diff.inHours}시간';
    if (diff.inDays < 7) return '${diff.inDays}일';
    return '${dateTime.month}/${dateTime.day}';
  }

  void _toggleLike(Comment comment) {
    HapticFeedback.lightImpact();
    // Toggle like logic
  }

  void _setReplyTo(Comment comment) {
    setState(() => _replyingTo = comment.userName);
    // Focus on input
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'me',
      userName: '별빛팬',
      userImage: 'https://api.dicebear.com/7.x/adventurer-neutral/svg?seed=myfan',
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
      _replyingTo = null;
      _isSubmitting = false;
    });

    widget.onCommentSubmit?.call(newComment.content);

    // Scroll to top
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
