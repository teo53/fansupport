import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/post_entity.dart';

/// 재사용 가능한 게시물 카드 위젯
class PostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMoreTap;
  final Function(int index)? onImageTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.onProfileTap,
    this.onMoreTap,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.hp(1)),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildContent(context),
            if (post.images.isNotEmpty) _buildImages(context),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Responsive.wp(4)),
      child: Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: Responsive.wp(5),
              backgroundImage: post.author.profileImage != null
                  ? CachedNetworkImageProvider(post.author.profileImage!)
                  : null,
              child: post.author.profileImage == null
                  ? Icon(Icons.person, size: Responsive.sp(20))
                  : null,
            ),
          ),
          SizedBox(width: Responsive.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.author.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.sp(14),
                      ),
                    ),
                    if (post.author.isVerified) ...[
                      SizedBox(width: Responsive.wp(1)),
                      Icon(
                        Icons.verified,
                        size: Responsive.sp(14),
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                Text(
                  TimeFormatter.formatRelative(post.createdAt),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: Responsive.sp(12),
                  ),
                ),
              ],
            ),
          ),
          if (onMoreTap != null)
            IconButton(
              icon: Icon(Icons.more_horiz, size: Responsive.sp(20)),
              onPressed: onMoreTap,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.wp(4)),
      child: Text(
        post.content,
        style: TextStyle(
          fontSize: Responsive.sp(15),
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImages(BuildContext context) {
    final images = post.images;
    if (images.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: Responsive.hp(1.5)),
      child: _buildImageGrid(context, images),
    );
  }

  Widget _buildImageGrid(BuildContext context, List<String> images) {
    if (images.length == 1) {
      return GestureDetector(
        onTap: () => onImageTap?.call(0),
        child: CachedNetworkImage(
          imageUrl: images[0],
          width: double.infinity,
          height: Responsive.hp(30),
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: Responsive.hp(30),
            color: AppColors.background,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => Container(
            height: Responsive.hp(30),
            color: AppColors.background,
            child: Icon(Icons.image, color: AppColors.textHint),
          ),
        ),
      );
    }

    return SizedBox(
      height: Responsive.hp(25),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onImageTap?.call(0),
              child: CachedNetworkImage(
                imageUrl: images[0],
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (images.length > 1) ...[
            SizedBox(width: Responsive.wp(0.5)),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onImageTap?.call(1),
                      child: CachedNetworkImage(
                        imageUrl: images[1],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (images.length > 2) ...[
                    SizedBox(height: Responsive.wp(0.5)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onImageTap?.call(2),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: images[2],
                              fit: BoxFit.cover,
                            ),
                            if (images.length > 3)
                              Container(
                                color: Colors.black54,
                                child: Center(
                                  child: Text(
                                    '+${images.length - 3}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Responsive.sp(20),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Responsive.wp(4)),
      child: Row(
        children: [
          _ActionButton(
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            label: NumberFormatter.formatKorean(post.likeCount),
            color: post.isLiked ? AppColors.error : null,
            onTap: () {
              HapticFeedback.lightImpact();
              onLike?.call();
            },
          ),
          SizedBox(width: Responsive.wp(6)),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: NumberFormatter.formatKorean(post.commentCount),
            onTap: () {
              HapticFeedback.lightImpact();
              onComment?.call();
            },
          ),
          SizedBox(width: Responsive.wp(6)),
          _ActionButton(
            icon: Icons.share_outlined,
            label: '',
            onTap: () {
              HapticFeedback.lightImpact();
              onShare?.call();
            },
          ),
          const Spacer(),
          _ActionButton(
            icon: post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            label: '',
            color: post.isBookmarked ? AppColors.primary : null,
            onTap: () {
              HapticFeedback.lightImpact();
              onBookmark?.call();
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            icon,
            size: Responsive.sp(20),
            color: color ?? AppColors.textSecondary,
          ),
          if (label.isNotEmpty) ...[
            SizedBox(width: Responsive.wp(1)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(13),
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
